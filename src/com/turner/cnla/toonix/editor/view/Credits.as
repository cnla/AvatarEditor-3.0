package com.turner.cnla.toonix.editor.view
{
	import com.turner.cnla.toonix.editor.events.AvatarEditorEvent;
	import com.turner.cnla.toonix.editor.events.AvatarEditorInternalEvent;
	import com.turner.cnla.toonix.editor.model.Dictionary;
	import com.turner.cnla.toonix.editor.model.Model;
	import com.turner.cnla.toonix.editor.model.Params;
	import com.turner.cnla.toonix.editor.ui.BasicButton;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	[Event(name="showCreditsWindow", type="com.turner.cnla.toonix.editor.events.AvatarEditorInternalEvent")]
	public class Credits extends MovieClip
	{
		private var dictionary:Dictionary;
		private var txtCreditsTitle:TextField;
		private var txtCredits:TextField;
		private var btnAddCredits:BasicButton;
		private var model:Model;
		private var _credits:int;
		private var _oldCredits:int;
		private var _creditsRate:Number;
		
		public function Credits()
		{
			super();
			
			dictionary= Dictionary.getInstance();
			
			model= Model.getInstance();
			
			_credits= 0;
			
			txtCreditsTitle= getChildByName("txtCreditsTitleInstance") as TextField;
			txtCredits= getChildByName("txtCreditsInstance") as TextField;
			btnAddCredits= getChildByName("btnAddCreditsInstance") as BasicButton;
			
			txtCredits.mouseEnabled= false;
			
			setCredits(0);
		}
		
		public function init():void
		{
			txtCreditsTitle.text= dictionary.credits.myCredits;
			btnAddCredits.label= dictionary.credits.addCredits;
			
			btnAddCredits.addEventListener(MouseEvent.CLICK, onButtonClick);
			
			btnAddCredits.enabled= (model.userId > 0);
			
			model.addEventListener(AvatarEditorInternalEvent.CREDITS_UPDATE, onCreditsUpdate);
			model.addEventListener(AvatarEditorInternalEvent.ITEM_PURCHASED, onItemPurchased);
		}
		
		protected function onCreditsUpdate(event:Event):void
		{
			setCredits(model.userCredits, true);
		}
		
		protected function onItemPurchased(event:Event):void
		{
			if(model.userId){
				setCredits(model.userCredits, true);
			} else {
				setCredits((Params.FREE_CREDITS - model.creditsSpent), true);
			}
		}
		
		protected function onButtonClick(event:MouseEvent):void
		{
			var btn:BasicButton= event.target as BasicButton;
			
			if(btn == btnAddCredits){
				model.dispatchExternalEvent(AvatarEditorEvent.SHOW_CREDITS_WINDOW);
			}
		}
		
		public function setCredits(credits:int, animated:Boolean=false):void
		{
			_credits= credits;
			
			if(animated){
				animateCredits();
			} else {
				txtCredits.text= _credits.toString();
			}
		}
		
		public function getCredits():int
		{
			return parseInt(txtCredits.text);
		}
		
		private function animateCredits():void
		{
			_oldCredits= parseInt(txtCredits.text);
			
			_creditsRate= Math.abs(_credits - _oldCredits) / 12;
			
			addEventListener(Event.ENTER_FRAME, onLoop);
		}
		
		protected function onLoop(event:Event):void
		{
			if(_oldCredits > _credits){
				txtCredits.text= Math.round(parseInt(txtCredits.text) - _creditsRate).toString();
				if(parseInt(txtCredits.text) <= _credits){
					txtCredits.text= _credits.toString();
					removeEventListener(Event.ENTER_FRAME, onLoop);
				}
			} else {
				txtCredits.text= Math.round(parseInt(txtCredits.text) + _creditsRate).toString();
				if(parseInt(txtCredits.text) >= _credits){
					txtCredits.text= _credits.toString();
					removeEventListener(Event.ENTER_FRAME, onLoop);
				}
			}
		}
		
		public function destroy():void
		{
			if(btnAddCredits.hasEventListener(MouseEvent.CLICK)) btnAddCredits.removeEventListener(MouseEvent.CLICK, onButtonClick);
			if(model.hasEventListener(AvatarEditorInternalEvent.ITEM_PURCHASED)) model.removeEventListener(AvatarEditorInternalEvent.ITEM_PURCHASED, onItemPurchased);
			if(hasEventListener(Event.ENTER_FRAME)) removeEventListener(Event.ENTER_FRAME, onLoop);
			
			txtCreditsTitle.text= "";
			txtCredits.text= "";
			_credits= 0;
			_oldCredits= 0;
			_creditsRate= 0;
		}
	}
}