package com.turner.cnla.toonix.editor.view
{
	import com.turner.cnla.toonix.editor.model.Model;
	import com.turner.cnla.toonix.editor.model.Params;
	
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.net.URLRequest;

	public class BackgroundWrapper extends MovieClip
	{
		private const AVATAR_EDITOR_DIMENSIONS:Point= 			new Point(900, 700);

		private var model:Model;
		private var backgroundPath:String;
		private var backgroundDimension:Point;
		
		public function BackgroundWrapper()
		{
			model= Model.getInstance();
		}
		
		public function init():void
		{
			if(model.backgroundPath && model.backgroundPath.length > 0){
				backgroundPath= model.backgroundPath;
				
				loadBackground();
			}
		}
		
		private function loadBackground():void
		{
			var ldr:Loader= new Loader();
			ldr.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
			ldr.load(new URLRequest(backgroundPath));
		}
		
		protected function onComplete(event:Event):void
		{
			var back:Bitmap= (event.target as LoaderInfo).content as Bitmap;
			backgroundDimension= new Point(back.width, back.height);
			
			addChild(back);
			
			centerBack();
		}
		
		private function centerBack():void
		{
			var diffX:Number= Math.abs(backgroundDimension.x - AVATAR_EDITOR_DIMENSIONS.x);
			var diffY:Number= Math.abs(backgroundDimension.y - AVATAR_EDITOR_DIMENSIONS.y);
			x-= diffX/2;
			x+= 3;
			y-= diffY;
			y-= 35;
		}
		
		public function destroy():void
		{
			while(numChildren>0) removeChildAt(0);
		}
	}
}