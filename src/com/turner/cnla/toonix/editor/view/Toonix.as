package com.turner.cnla.toonix.editor.view
{
	import com.turner.caf.control.CAFEvent;
	import com.turner.cnla.library.AvatarItemVO;
	import com.turner.cnla.library.AvatarVO;
	import com.turner.cnla.toonix.editor.commands.CommandType;
	import com.turner.cnla.toonix.editor.events.AvatarEditorEvent;
	import com.turner.cnla.toonix.editor.events.AvatarEditorInternalEvent;
	import com.turner.cnla.toonix.editor.events.Dispatcher;
	import com.turner.cnla.toonix.editor.model.Model;
	import com.turner.cnla.toonix.editor.model.Params;
	import com.turner.cnla.toonix.editor.model.ResourceLoader;
	import com.turner.cnla.toonix.editor.types.AccessoryType;
	import com.turner.cnla.toonix.editor.ui.BasicButton;
	import com.turner.toonix.avatardisplay.AvatarDisplay;
	import com.turner.toonix.avatardisplay.IAvatarDisplay;
	import com.turner.toonix.avatardisplay.event.AvatarDisplayEvent;
	import com.turner.toonix.avatardisplay.vo.AvatarDisplayEmotionVO;
	import com.turner.toonix.avatardisplay.vo.AvatarDisplayInitVO;
	import com.turner.toonix.avatardisplay.vo.AvatarDisplayUpdateVO;
	
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.utils.DebugUtils;
	import flash.utils.Timer;
	
	[Event(name="loadComplete", type="com.turner.toonix.avatardisplay.event.AvatarDisplayEvent")]
	[Event(name="emotionComplete", type="com.turner.toonix.avatardisplay.event.AvatarDisplayEvent")]
	public class Toonix extends MovieClip
	{
		private const MAX_RANDOM_DELAY:Number= 						6;
		private const MIN_RANDOM_DELAY:Number= 						2;
		
		private var model:Model;
		private var dispatcher:Dispatcher;
		
		private var guide:MovieClip;
		private var toonixContainer:MovieClip;
		private var toonix:IAvatarDisplay;
		private var toonixDisplay:DisplayObject;
		private var accessoryManager:AccessoryManager;
		private var emotions:ResourceLoader;
		private var randomToonixVO:AvatarDisplayUpdateVO;
		private var playingEmotion:Boolean;
		private var idleTimer:Timer;
		
		// Areas
		private var areaHead:MovieClip;
		private var areaEyes:MovieClip;
		private var areaMouth:MovieClip;
		private var areaBody:MovieClip;
		
		public function Toonix()
		{
			super();
			
			model= Model.getInstance();
			dispatcher= Dispatcher.getInstance();
			
			guide= getChildByName("guideInstance") as MovieClip;
			toonixContainer= getChildByName("toonixContainerInstance") as MovieClip;
			accessoryManager= getChildByName("accessoryManagerInstance") as AccessoryManager;
			
			areaHead= 			getChildByName("areaHeadInstance") as MovieClip;
			areaEyes= 			getChildByName("areaEyesInstance") as MovieClip;
			areaMouth= 			getChildByName("areaMouthInstance") as MovieClip;
			areaBody= 			getChildByName("areaBodyInstance") as MovieClip;
			
			guide.visible= false;
			playingEmotion= false;
			
			areaHead.alpha= 	0;
			areaEyes.alpha= 	0;
			areaMouth.alpha= 	0;
			areaBody.alpha= 	0;
		}
		
		public function init():void
		{
			areaHead.addEventListener(MouseEvent.CLICK, onButtonClick);
			areaEyes.addEventListener(MouseEvent.CLICK, onButtonClick);
			areaMouth.addEventListener(MouseEvent.CLICK, onButtonClick);
			areaBody.addEventListener(MouseEvent.CLICK, onButtonClick);
			
			model.addEventListener(AvatarEditorInternalEvent.UPDATE_TOONIX, onUpdateToonix);
			model.addEventListener(AvatarEditorInternalEvent.UPDATE_ACCESSORY, onUpdateAccessory);
			model.addEventListener(AvatarEditorInternalEvent.CHANGE_COLOR, onChangeColor);
			model.addEventListener(AvatarEditorInternalEvent.CHANGE_ACTIVE_AREA, onChangeActiveArea);
			
			accessoryManager.init();
			accessoryManager.visible= false;
			
			var initVO:AvatarDisplayInitVO= model.getAvatarDisplayInitVO();

			toonix= new AvatarDisplay();
			toonix.addEventListener(AvatarDisplayEvent.LOAD_COMPLETE, onLoadComplete);
			toonix.init(initVO);
		}
		
		private function onLoadComplete(event:AvatarDisplayEvent):void
		{
			toonix.removeEventListener(AvatarDisplayEvent.LOAD_COMPLETE, onLoadComplete);
			toonixDisplay= DisplayObject(toonix);
			toonixContainer.addChild(toonixDisplay);
			
			model.generateImage(getToonixImage());
			
			setFilters();
			setScale();
			
			emotions= new ResourceLoader();
			emotions.addEventListener(Event.COMPLETE, onEmotionComplete);
			emotions.load(model.emotionsMap);
		}
		
		protected function onEmotionComplete(event:Event):void
		{
			dispatchEvent(new AvatarDisplayEvent(AvatarDisplayEvent.LOAD_COMPLETE));
			
			toonix.addEventListener(AvatarDisplayEvent.EMOTION_COMPLETE, onInitEmotionComplete);
			setEmotion("emotion_new_jump");
		}
		
		private function onInitEmotionComplete(event:AvatarDisplayEvent):void
		{
			toonix.removeEventListener(AvatarDisplayEvent.EMOTION_COMPLETE, onInitEmotionComplete);
			
			idleTimer= new Timer(getRandomInt(MIN_RANDOM_DELAY, MAX_RANDOM_DELAY) * 1000);
			idleTimer.addEventListener(TimerEvent.TIMER, onTimer);
			idleTimer.start();
		}
		
		protected function onTimer(event:TimerEvent):void
		{
			var rndDelay:Number= Math.floor(Math.random() * MAX_RANDOM_DELAY) + 2;

			if(!playingEmotion){
				setEmotion("emotion_idle");
			}
			
			idleTimer.removeEventListener(TimerEvent.TIMER, onTimer);
			idleTimer.stop();
			idleTimer.delay= getRandomInt(MIN_RANDOM_DELAY, MAX_RANDOM_DELAY) * 1000;
			idleTimer.addEventListener(TimerEvent.TIMER, onTimer);
			idleTimer.start();
		}
		
		public function setEmotion(emotionName:String, loopCount:int=0):void
		{
			var vo:AvatarDisplayEmotionVO= new AvatarDisplayEmotionVO();
			vo.emotion= emotions.getResourceById(emotionName) as MovieClip;
			vo.emotionName= emotionName;
			vo.loopCount= loopCount;
			vo.notifyWhenComplete= true;
			
			if(playingEmotion){
				toonix.stopCurrentEmotion();
			}
			
			toonix.setEmotion(vo);
			
			toonix.addEventListener(AvatarDisplayEvent.EMOTION_COMPLETE, onGenericEmotionComplete);
			
			playingEmotion= true;
		}
		
		public function getToonixImage():BitmapData
		{
			var bitmapData:BitmapData = new BitmapData(134, 134, true, 0);
			var matrix:Matrix = new Matrix();
			var dx:Number = 0;
			var dy:Number = 0;
			
			var avatarDisplayWidth:Number = toonixContainer.width;
			var avatarDisplayHeight:Number = toonixContainer.height;
			
			dx = (134-avatarDisplayWidth)/2;
			dy = 134-avatarDisplayHeight;
			dx+= 20;
			dy+= 40;
			
			//matrix.translate(dx, dy);
			matrix.scale(0.45, 0.45);
			matrix.translate(35, 50);
			
			toonixDisplay.filters= null;
			var filters:Array= new Array();
			var stroke:GlowFilter= new GlowFilter(0x000000, 1, 6, 6, 6);
			filters.push(stroke);
			toonixDisplay.filters= filters;
			
			bitmapData.draw(toonixContainer, matrix);
			
			setFilters();
			
			return bitmapData;
		}
		
		private function onGenericEmotionComplete(event:AvatarDisplayEvent):void
		{
			dispatchEvent(new AvatarDisplayEvent(AvatarDisplayEvent.EMOTION_COMPLETE));
			playingEmotion= false;
		}
		
		protected function onUpdateAccessory(event:AvatarEditorInternalEvent):void
		{
			var accessoryType:String= event.data.accessoryType as String;
			var newAccessory:AvatarItemVO= event.data.newAccessory as AvatarItemVO;
			var vo:AvatarDisplayUpdateVO= new AvatarDisplayUpdateVO();
			
			switch(accessoryType){
				case AccessoryType.HEAD_ACCESSORY:
					//vo.headAccessoryUrl= Params.CDN_PATH + newAccessory.path; break;
					vo.headAccessoryUrl= newAccessory.path; break;
				case AccessoryType.EYES_ACCESSORY:
					//vo.eyeAccessoryUrl= Params.CDN_PATH + newAccessory.path; break;
					vo.eyeAccessoryUrl= newAccessory.path; break;
				case AccessoryType.MOUTH_ACCESSORY:
					//vo.mouthAccessoryUrl= Params.CDN_PATH + newAccessory.path; break;
					vo.mouthAccessoryUrl= newAccessory.path; break;
				case AccessoryType.BODY_ACCESSORY:
					//vo.bodyAccessoryUrl= Params.CDN_PATH + newAccessory.path; break;
					vo.bodyAccessoryUrl= newAccessory.path; break;
				case AccessoryType.COSTUME_ACCESSORY:
					/*
					vo.bodyAccessoryUrl= Params.CDN_PATH + newAccessory.bodyPath;
					vo.headAccessoryUrl= Params.CDN_PATH + newAccessory.headPath;
					*/
					vo.bodyAccessoryUrl= newAccessory.bodyPath;
					vo.headAccessoryUrl= newAccessory.headPath;
					vo.fixedSkinColor= model.getFixedSkinColor(newAccessory.id);
					break;
			}
			
			toonix.update(vo);
			
			if(newAccessory.accessoryType == AccessoryType.COSTUME_ACCESSORY){
				accessoryManager.visible= false;
			}
			
			accessoryManager.setPrice(newAccessory.price);
		}
		
		protected function onChangeActiveArea(event:Event):void
		{
			accessoryManager.visible= true;
			accessoryManager.setAccessoryType(model.getActiveArea());
		}
		
		protected function onChangeColor(event:AvatarEditorInternalEvent):void
		{
			var accessory:String= event.data.accessory as String;
			var color:Number= event.data.color as Number;
			
			var vo:AvatarDisplayUpdateVO= new AvatarDisplayUpdateVO();
			
			switch(accessory){
				case AccessoryType.BODY_ACCESSORY:
					vo.bodyColor= color; break;
				case AccessoryType.HEAD_ACCESSORY:
					vo.headColor= color; break;
				case AccessoryType.SKIN_ACCESSORY:
					vo.skinColor= color; break;
			}
			
			toonix.update(vo);
		}
		
		protected function onUpdateToonix(event:AvatarEditorInternalEvent):void
		{
			var avatar:AvatarVO= event.data as AvatarVO;
			var vo:AvatarDisplayUpdateVO= new AvatarDisplayUpdateVO();
			var bodyAccessoryPath:String= (avatar.costume > 0) ? model.getAccessoryPathById(avatar.costume, AccessoryType.BODY_ACCESSORY) : model.getAccessoryPathById(avatar.body);
			var headAccessoryPath:String= (avatar.costume > 0) ? model.getAccessoryPathById(avatar.costume, AccessoryType.HEAD_ACCESSORY) : model.getAccessoryPathById(avatar.head);
			var bodyAccessory:AvatarItemVO= (avatar.costume>0)?model.getAccessoryById(avatar.costume):model.getAccessoryById(avatar.body);
			var headAccessory:AvatarItemVO= (avatar.costume>0)?model.getAccessoryById(avatar.costume):model.getAccessoryById(avatar.head);

			//vo.bodyAccessoryUrl= Params.CDN_PATH + bodyAccessoryPath;
			vo.bodyAccessoryUrl= bodyAccessoryPath;
			vo.bodyColor= avatar.bodyColor;
			//vo.eyeAccessoryUrl= Params.CDN_PATH + model.getAccessoryPathById(avatar.eye);
			vo.eyeAccessoryUrl= model.getAccessoryPathById(avatar.eye);
			vo.fixedSkinColor= model.getFixedSkinColor(avatar.costume, avatar.head, avatar.eye, avatar.mouth, avatar.body);
			//vo.headAccessoryUrl= Params.CDN_PATH + headAccessoryPath;
			vo.headAccessoryUrl= headAccessoryPath;
			vo.headColor= avatar.headColor;
			//vo.mouthAccessoryUrl= Params.CDN_PATH + model.getAccessoryPathById(avatar.mouth);
			vo.mouthAccessoryUrl= model.getAccessoryPathById(avatar.mouth);
			vo.skinColor= avatar.skinColor;
			
			if((avatar.costume > 0) && ((accessoryManager.getAccessoryType() == AccessoryType.HEAD_ACCESSORY) || (accessoryManager.getAccessoryType() == AccessoryType.BODY_ACCESSORY))){
				accessoryManager.visible= false;
			}
			
			switch(accessoryManager.getAccessoryType()){
				case AccessoryType.BODY_ACCESSORY:
					accessoryManager.setPrice(model.getAccessoryById(model.avatar.body).price); break;
				case AccessoryType.EYES_ACCESSORY:
					accessoryManager.setPrice(model.getAccessoryById(model.avatar.eye).price); break;
				case AccessoryType.HEAD_ACCESSORY:
					accessoryManager.setPrice(model.getAccessoryById(model.avatar.head).price); break;
				case AccessoryType.MOUTH_ACCESSORY:
					accessoryManager.setPrice(model.getAccessoryById(model.avatar.mouth).price); break;
			}
			
			if(model.getRandomMode()){
				randomToonixVO= vo;
				showRandomAnimation();
			} else {
				toonix.update(vo);
			}
		}
		
		private function showRandomAnimation():void
		{
			toonix.stopCurrentEmotion();
			idleTimer.stop();
			
			toonix.addEventListener(AvatarDisplayEvent.EMOTION_COMPLETE, onRandomStartComplete);
			setEmotion("emotion_rstart");
			
			try{
				toonix.removeEventListener(AvatarDisplayEvent.EMOTION_COMPLETE, onGenericEmotionComplete);
			} catch(e:Error){ }
		}
		
		private function onRandomStartComplete(e:AvatarDisplayEvent):void
		{
			toonix.removeEventListener(AvatarDisplayEvent.EMOTION_COMPLETE, onRandomStartComplete);
			toonix.addEventListener(AvatarDisplayEvent.EMOTION_COMPLETE, onRandomLoopBegin);
			setEmotion("emotion_rloop");
		}
		
		private function onRandomLoopBegin(e:AvatarDisplayEvent):void
		{
			toonix.removeEventListener(AvatarDisplayEvent.EMOTION_COMPLETE, onRandomLoopBegin);
			toonix.addEventListener(AvatarDisplayEvent.UPDATE_COMPLETE, onRandomLoopComplete);
			setEmotion("emotion_rloop", -1);
			toonix.update(randomToonixVO);
		}
		
		private function onRandomLoopComplete(e:AvatarDisplayEvent):void
		{
			toonix.removeEventListener(AvatarDisplayEvent.UPDATE_COMPLETE, onRandomLoopComplete);
			toonix.addEventListener(AvatarDisplayEvent.EMOTION_COMPLETE, onRandomEndComplete);
			setEmotion("emotion_rend");
		}
		
		private function onRandomEndComplete(e:AvatarDisplayEvent):void
		{
			playingEmotion= false;
			toonix.removeEventListener(AvatarDisplayEvent.EMOTION_COMPLETE, onRandomEndComplete);
			toonix.addEventListener(AvatarDisplayEvent.EMOTION_COMPLETE, onGenericEmotionComplete);
			idleTimer.delay= getRandomInt(MIN_RANDOM_DELAY, MAX_RANDOM_DELAY) * 1000;
			idleTimer.start();
		}
		
		protected function onButtonClick(event:MouseEvent):void
		{
			var btn:BasicButton= event.target as BasicButton;
			
			if(btn == areaHead){
				dispatcher.dispatchEvent(new CAFEvent(CommandType.CHANGE_ACTIVE_AREA, AccessoryType.HEAD_ACCESSORY));
			} else
			if(btn == areaEyes){
				dispatcher.dispatchEvent(new CAFEvent(CommandType.CHANGE_ACTIVE_AREA, AccessoryType.EYES_ACCESSORY));
			} else
			if(btn == areaMouth){
				dispatcher.dispatchEvent(new CAFEvent(CommandType.CHANGE_ACTIVE_AREA, AccessoryType.MOUTH_ACCESSORY));
			} else
			if(btn == areaBody){
				dispatcher.dispatchEvent(new CAFEvent(CommandType.CHANGE_ACTIVE_AREA, AccessoryType.BODY_ACCESSORY));
			}
		}
		
		private function setScale():void
		{
			toonixDisplay.scaleX= 2.2;
			toonixDisplay.scaleY= 2.2;
		}
		
		private function setFilters():void
		{
			var filters:Array= new Array();
			var stroke:GlowFilter= new GlowFilter(0x000000, 1, 10, 10, 12);
			filters.push(stroke);
			toonixDisplay.filters= filters;
		}
		
		private function getRandomInt(min:Number, max:Number):int
		{
			var rnd:int= Math.floor(Math.random() * (max-min+1)) + min;
			
			return rnd;
		}
		
		public function destroy():void
		{
			if(areaHead.hasEventListener(MouseEvent.CLICK)) areaHead.removeEventListener(MouseEvent.CLICK, onButtonClick);
			if(areaEyes.hasEventListener(MouseEvent.CLICK)) areaEyes.removeEventListener(MouseEvent.CLICK, onButtonClick);
			if(areaMouth.hasEventListener(MouseEvent.CLICK)) areaMouth.removeEventListener(MouseEvent.CLICK, onButtonClick);
			if(areaBody.hasEventListener(MouseEvent.CLICK)) areaBody.removeEventListener(MouseEvent.CLICK, onButtonClick);
			
			if(model.hasEventListener(AvatarEditorInternalEvent.UPDATE_TOONIX)) model.removeEventListener(AvatarEditorInternalEvent.UPDATE_TOONIX, onUpdateToonix);
			if(model.hasEventListener(AvatarEditorInternalEvent.UPDATE_ACCESSORY)) model.removeEventListener(AvatarEditorInternalEvent.UPDATE_ACCESSORY, onUpdateAccessory);
			if(model.hasEventListener(AvatarEditorInternalEvent.CHANGE_COLOR)) model.removeEventListener(AvatarEditorInternalEvent.CHANGE_COLOR, onChangeColor);
			if(model.hasEventListener(AvatarEditorInternalEvent.CHANGE_ACTIVE_AREA)) model.removeEventListener(AvatarEditorInternalEvent.CHANGE_ACTIVE_AREA, onChangeActiveArea);
			
			if(toonix.hasEventListener(AvatarDisplayEvent.LOAD_COMPLETE)) toonix.removeEventListener(AvatarDisplayEvent.LOAD_COMPLETE, onLoadComplete);
			if(emotions.hasEventListener(Event.COMPLETE)) emotions.removeEventListener(Event.COMPLETE, onEmotionComplete);
			
			if(idleTimer.hasEventListener(TimerEvent.TIMER)) idleTimer.removeEventListener(TimerEvent.TIMER, onTimer);
			
			if(toonixDisplay && toonixContainer && toonixContainer.contains(toonixDisplay)) toonixContainer.removeChild(toonixDisplay);
			
			idleTimer.stop();
			idleTimer= null;
			toonix.destroy();
			toonix= null;
			toonixDisplay= null;
			emotions.destroy();
			emotions= null;
			randomToonixVO= null;
			playingEmotion= false;
		}
	}
}