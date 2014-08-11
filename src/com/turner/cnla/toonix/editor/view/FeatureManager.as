package com.turner.cnla.toonix.editor.view
{
	import com.greensock.TweenLite;
	import com.greensock.easing.Elastic;
	import com.turner.caf.control.CAFEvent;
	import com.turner.cnla.library.AvatarItemVO;
	import com.turner.cnla.library.AvatarVO;
	import com.turner.cnla.toonix.editor.commands.CommandType;
	import com.turner.cnla.toonix.editor.events.AvatarEditorInternalEvent;
	import com.turner.cnla.toonix.editor.events.Dispatcher;
	import com.turner.cnla.toonix.editor.model.Dictionary;
	import com.turner.cnla.toonix.editor.model.Model;
	import com.turner.cnla.toonix.editor.model.ResourceLoader;
	import com.turner.cnla.toonix.editor.types.AccessoryType;
	import com.turner.cnla.toonix.editor.types.SponsorType;
	import com.turner.cnla.toonix.editor.ui.BasicButton;
	import com.turner.cnla.toonix.editor.vo.FeatureAccessoryVO;
	import com.turner.cnla.toonix.editor.vo.FeatureDataVO;
	
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.utils.Timer;
	
	[Event(name="event", type="flash.events.Event")]
	public class FeatureManager extends MovieClip
	{
		private const CHANGE_DELAY:int= 				2; // in seconds
		
		private var model:Model;
		private var dispatcher:Dispatcher;
		private var dictionary:Dictionary;
		private var featureTimer:Timer;
		private var txtSponsor:TextField;
		private var txtSponsorName:TextField;
		private var txtNew:TextField;
		private var txtLook:TextField;
		private var txtSelected:TextField;
		private var btnNew:BasicButton;
		private var imageContainer:MovieClip;
		private var selectedText:String;
		private var currentFeature:int;
		private var over:MovieClip;
		private var accessories:Array;
		private var originalY:Number;
		private var _selected:Boolean;
		private var imageList:Vector.<Bitmap>;
		
		public function FeatureManager()
		{
			super();
			
			model= Model.getInstance();
			dispatcher= Dispatcher.getInstance();
			dictionary= Dictionary.getInstance();
			
			txtSponsor= getChildByName("txtSponsorInstance") as TextField;
			txtSponsorName= getChildByName("txtSponsorNameInstance") as TextField;
			txtNew= getChildByName("txtNewInstance") as TextField;
			txtLook= getChildByName("txtLookInstance") as TextField;
			txtSelected= getChildByName("txtSelectedInstance") as TextField;
			btnNew= getChildByName("btnNewInstance") as BasicButton;
			imageContainer= getChildByName("imageContainerInstance") as MovieClip;
			over= getChildByName("overInstance") as MovieClip;
			
			_selected= false;
			
			txtLook.mouseEnabled= false;
			txtNew.mouseEnabled= false;
			txtSponsor.mouseEnabled= false;
			txtSponsorName.mouseEnabled= false;
			txtSelected.mouseEnabled= false;
			
			txtSelected.text= "";
			
			originalY= this.y;
		}
		
		public function init():void
		{
			btnNew.label= dictionary.newLook.tryItOn;
			txtNew.text= dictionary.newLook["new"];
			txtLook.text= dictionary.newLook.look;
			selectedText= dictionary.newLook.selectedText;
			
			over.buttonMode= true;
			
			model.addEventListener(AvatarEditorInternalEvent.UPDATE_ACCESSORY, onUpdateToonix);
			model.addEventListener(AvatarEditorInternalEvent.UPDATE_TOONIX, onUpdateToonix);
			model.addEventListener(AvatarEditorInternalEvent.CHANGE_COLOR, onUpdateToonix);
			
			over.addEventListener(MouseEvent.CLICK, onButtonClick);
			over.addEventListener(MouseEvent.MOUSE_OVER, onButtonOver);
			over.addEventListener(MouseEvent.MOUSE_OUT, onButtonOut);
			
			if(model.features.length > 1){
				featureTimer= new Timer(CHANGE_DELAY * 1000);
				featureTimer.addEventListener(TimerEvent.TIMER, onTimer);
			}
			
			currentFeature= 0;
			
			loadAllImages();
		}
		
		private function loadAllImages():void
		{
			var imagePathList:Array= new Array();
			var rs:ResourceLoader= new ResourceLoader();
			
			for(var i:int= 0, len:int= model.features.length; i < len; i++){
				imagePathList.push({path: model.features[i].previewImage, id: i.toString()});
			}
			
			rs.addEventListener(Event.COMPLETE, onLoadAllImagesComplete);
			rs.load(imagePathList);
		}
		
		protected function onLoadAllImagesComplete(event:Event):void
		{
			var list:Array= (event.target as ResourceLoader).getResourceList();
			
			imageList= new Vector.<Bitmap>();
			
			for each(var img:Bitmap in list){
				imageList.push(img);
			}
			
			loadFeature(currentFeature);
		}
		
		private function loadFeature(index:int):void
		{
			var vo:FeatureDataVO= model.features[index];
			
			accessories= new Array();
			for each(var accessoryVO:FeatureAccessoryVO in vo.accessories){
				var newObj:Object= new Object();
				newObj.accessoryType= accessoryVO.type;
				newObj.accessory= model.getAccessoryById(accessoryVO.id);

				accessories.push(newObj);
			}
			
			switch(vo.sponsorType){
				case SponsorType.TEXT:
					txtSponsor.text= dictionary.newLook.sponsoredBy;
					txtSponsorName.text= vo.sponsorData;
					break;
				case SponsorType.NO_SPONSOR:
					txtSponsor.text= "";
					txtSponsorName.text= "";
					break;
			}
			
			loadImage(index);
		}
		
		private function loadImage(index:int):void
		{
			while(imageContainer.numChildren > 0) imageContainer.removeChildAt(0);
			imageContainer.graphics.clear();
			
			imageContainer.addChild(imageList[index]);
			
			if(featureTimer && !featureTimer.running) featureTimer.start();
		}
		
		private function onTimer(event:TimerEvent):void
		{
			currentFeature++;
			if(currentFeature == model.features.length){
				currentFeature= 0;
			}
			
			loadFeature(currentFeature);
		}
		
		protected function onUpdateToonix(event:AvatarEditorInternalEvent):void
		{
			for each(var accObj:Object in accessories){
				var accType:String= accObj.accessoryType;
				var acc:AvatarItemVO= accObj.accessory;
				if(event.data.hasOwnProperty("accessoryType") && (event.data.accessoryType == accType)){
					var newAcc:AvatarItemVO= event.data.newAccessory as AvatarItemVO;
					if(newAcc && (newAcc.id != acc.id)){
						turnOffButton();
						break;
					}
				} else
				if(event.data.hasOwnProperty("accessory") && (event.data.accessory == accType)){
					continue;
				} else
				if(event.data is AvatarVO){
					var newAccId:int;
					switch(accType){
						case AccessoryType.BODY_ACCESSORY: 			newAccId= model.avatar.body; break;
						case AccessoryType.COSTUME_ACCESSORY: 		newAccId= model.avatar.costume; break;
						case AccessoryType.EYES_ACCESSORY: 			newAccId= model.avatar.eye; break;
						case AccessoryType.HEAD_ACCESSORY: 			newAccId= model.avatar.head; break;
						case AccessoryType.MOUTH_ACCESSORY: 		newAccId= model.avatar.mouth; break;
					}
					
					if(newAccId != acc.id){
						turnOffButton();
						break;
					}
				}
			}
		}
		
		private function turnOffButton():void
		{
			_selected= false;
			txtSelected.text= "";
			btnNew.selected= false;
			if(currentLabel != "off")
				gotoAndPlay("off");
			onButtonOut(null);
			
			if(featureTimer) featureTimer.start();
		}
		
		protected function onButtonClick(event:MouseEvent):void
		{
			if(_selected) return;
			_selected= true;
			txtSelected.text= selectedText;
			btnNew.selected= true;
			gotoAndPlay("selected");
			
			if(featureTimer) featureTimer.stop();
			
			dispatchEvent(new Event(Event.SELECT));
			
			//dispatcher.dispatchEvent(new CAFEvent(CommandType.CHANGE_ACCESSORY, {type: accessoryType, item: accessory}));
			
			for each(var obj:Object in accessories){
				dispatcher.dispatchEvent(new CAFEvent(CommandType.CHANGE_ACCESSORY, {type: obj.accessoryType, item: obj.accessory}));
			}
		}
		
		protected function onButtonOut(event:MouseEvent):void
		{
			if(!_selected){
				TweenLite.to(this, 15, {y: originalY, ease: Elastic.easeOut, useFrames: true});
			}
		}
		
		protected function onButtonOver(event:MouseEvent):void
		{
			if(!_selected){
				TweenLite.to(this, 15, {y: originalY+15, ease: Elastic.easeOut, useFrames: true});
			}
		}
		
		public function destroy():void
		{
			if(over.hasEventListener(MouseEvent.CLICK)) over.removeEventListener(MouseEvent.CLICK, onButtonClick);
			if(over.hasEventListener(MouseEvent.MOUSE_OVER)) over.removeEventListener(MouseEvent.MOUSE_OVER, onButtonOver);
			if(over.hasEventListener(MouseEvent.MOUSE_OUT)) over.removeEventListener(MouseEvent.MOUSE_OUT, onButtonOut);
			if(featureTimer){
				if(featureTimer.hasEventListener(TimerEvent.TIMER)) featureTimer.removeEventListener(TimerEvent.TIMER, onTimer);
				if(featureTimer.running) featureTimer.stop();
				featureTimer= null;
			}
			
			txtLook.text= "";
			txtNew.text= "";
			txtSponsor.text= "";
			txtSponsorName.text= "";
			accessories= new Array();
			accessories= null;
			originalY= 0;
		}
	}
}