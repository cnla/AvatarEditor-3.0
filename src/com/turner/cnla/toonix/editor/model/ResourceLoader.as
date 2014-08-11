package com.turner.cnla.toonix.editor.model
{
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.net.*;
	import flash.system.*;
	import flash.utils.*;
	
	[Event(name="complete", type="flash.events.Event")]
	[Event(name="progress", type="flash.events.ProgressEvent")]
	[Event(name="error", type="flash.events.ErrorEvent")]
	public final class ResourceLoader extends EventDispatcher
	{
		private var resourceList:Array;
		private var idMap:Array;
		private var _isLoading:Boolean;
		private var loader:Loader;
		private var urlList:Array;
		private var index:uint;
		private var retryDelay:Number;
		private var retryTotal:int;
		private var retryCount:int;
		
		public function ResourceLoader()
		{
		}
		
		public function getResourceList():Array
		{
			return resourceList;
		}
		
		public function getResourceById(id:String):DisplayObject
		{
			var len:int= idMap.length;
			var ret:DisplayObject;
			
			for(var i:int= 0; i < len; i++){
				if(idMap[i] == id){
					ret= resourceList[i];
					break;
				}
			}
			
			return ret;
		}
		
		public function isLoading():Boolean
		{
			return _isLoading;
		}		
		
		/**
		 * Loads a list of DisplayObject resources.
		 * @param urlList An array of objects with two properties: id (String) and path (String).
		 */
		public function load(urlList:Array, retryDelay:Number=1000, retryTotal:uint=3):void
		{
			if(urlList==null || urlList.length==0){
				return;
			}
			
			destroyLoader();

			this.urlList = urlList;
			resourceList= new Array;
			idMap= new Array();
			
			index = 0;
			retryCount = 0;
			
			loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.INIT, loadInitHandler);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, loadErrorHandler);
			loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, loadProgressHandler);

			try{
				loader.load( new URLRequest(urlList[index].path) );
			}catch(error:Error){
				loadErrorHandler( new IOErrorEvent(IOErrorEvent.IO_ERROR, false, false, error.getStackTrace()) );
			}
		}
		
		private function loadInitHandler(event:Event):void
		{
			resourceList.push(loader.content);
			idMap.push(urlList[index].id);
			
			index++;
			
			if(index<urlList.length){
				dispatchEvent( new ProgressEvent(ProgressEvent.PROGRESS, false, false, index, urlList.length) );
				loader.load( new URLRequest(urlList[index].path) );
			}else{
				destroyLoader();
				dispatchEvent( new Event(Event.COMPLETE) );
			}
		}
		
		private function loadErrorHandler(event:IOErrorEvent):void
		{
			destroyLoader();
			dispatchEvent( new ErrorEvent(ErrorEvent.ERROR, false, false, event.text) );
		}
		
		private function loadProgressHandler(event:ProgressEvent):void
		{
			var progressPoint:Point = new Point();
			progressPoint.x = index + event.bytesLoaded/event.bytesTotal;
			progressPoint.y = urlList.length;
			
			dispatchEvent( new ProgressEvent(ProgressEvent.PROGRESS, false, false, progressPoint.x, progressPoint.y) );
		}
		
		private function destroyLoader():void
		{
			try{
				if(loader!=null){
					loader.contentLoaderInfo.removeEventListener(Event.INIT, loadInitHandler);
					loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, loadErrorHandler);
					loader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, loadProgressHandler);
					loader.unload();
					loader = null;
				}
			}catch(error:Error){
				trace("## ERROR com.turner.cnla.toonix.editor.model.ResourceLoader.destroyLoader() ", error);
			}
		}
		
		public function destroy():void
		{
			destroyLoader();
			resourceList= new Array();
			resourceList= null;
			idMap= new Array();
			idMap= null;
			_isLoading= false;
			urlList= new Array();
			urlList= null;
			index= 0;
		}
	}
}