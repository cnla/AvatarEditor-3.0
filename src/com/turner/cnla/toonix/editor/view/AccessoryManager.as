package com.turner.cnla.toonix.editor.view
{
	import com.greensock.TweenLite;
	import com.turner.caf.control.CAFEvent;
	import com.turner.cnla.library.AvatarItemVO;
	import com.turner.cnla.toonix.editor.commands.CommandType;
	import com.turner.cnla.toonix.editor.events.AvatarEditorInternalEvent;
	import com.turner.cnla.toonix.editor.events.Dispatcher;
	import com.turner.cnla.toonix.editor.model.Model;
	import com.turner.cnla.toonix.editor.types.AccessoryType;
	import com.turner.cnla.toonix.editor.ui.BasicButton;
	import com.turner.cnla.toonix.editor.ui.ColoredButton;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	public class AccessoryManager extends MovieClip
	{
		private const CASE_NONE:Point= 					new Point(0, 0);
		private const CASE_BTN:Point= 					new Point(45, 50);
		private const CASE_BTN_PALETA:Point= 			new Point(261, 50);
		private const CASE_BTN_BUY:Point= 				new Point(204, 81);
		private const CASE_BTN_BUY_PALETA:Point= 		new Point(261, 81);
		private const CASE_BUY:Point= 					new	Point(200, 41);
		private const CASE_BTN_NOBUY:Point= 			new Point(267, 81);
		private const CASE_BTN_NOBUY_PALETA:Point= 		new Point(267, 81);
		private const CASE_NOBUY:Point= 				new Point(263, 41);
		
		private const POSITIONS:Array= [{acc: AccessoryType.HEAD_ACCESSORY, 	pos: new Point(-60, -10), 	hasPalette: true}, 
										{acc: AccessoryType.EYES_ACCESSORY, 	pos: new Point(-60, 45), 	hasPalette: false}, 
										{acc: AccessoryType.MOUTH_ACCESSORY, 	pos: new Point(-60, 71), 	hasPalette: false}, 
										{acc: AccessoryType.BODY_ACCESSORY, 	pos: new Point(-60, 122), 	hasPalette: true}];
		
		private var dispatcher:Dispatcher;
		private var model:Model;
		private var btnLeft:BasicButton;
		private var btnRight:BasicButton;
		private var btnPaleta:ColoredButton;
		private var priceManager:PriceManager;
		private var backPaleta:BackPaleta;
		private var paleta:Paleta;
		private var _accessoryType:String;
		private var currentId:Number;
		private var currentItem:AvatarItemVO;
		
		public function AccessoryManager()
		{
			super();
			
			model= Model.getInstance();
			dispatcher= Dispatcher.getInstance();
			
			btnLeft= getChildByName("btnLeftInstance") as BasicButton;
			btnRight= getChildByName("btnRightInstance") as BasicButton;
			btnPaleta= getChildByName("btnPaletaInstance") as ColoredButton;
			priceManager= getChildByName("priceManagerInstance") as PriceManager;
			paleta= getChildByName("paletaInstance") as Paleta;
			backPaleta= getChildByName("backPaletaInstance") as BackPaleta;
			
			visible= false;
		}
		
		public function init():void
		{
			paleta.init();
			paleta.visible= false;
			
			priceManager.hide();
			
			backPaleta.drawBack(CASE_NONE);
			
			btnPaleta.addEventListener(MouseEvent.CLICK, onButtonClick);
			btnLeft.addEventListener(MouseEvent.CLICK, onButtonClick);
			btnRight.addEventListener(MouseEvent.CLICK, onButtonClick);
			
			model.addEventListener(AvatarEditorInternalEvent.CHANGE_COLOR, onChangeColor);
			model.addEventListener(AvatarEditorInternalEvent.UPDATE_ACCESSORY, onUpdateToonix);
			model.addEventListener(AvatarEditorInternalEvent.UPDATE_TOONIX, onUpdateToonix);
			model.addEventListener(AvatarEditorInternalEvent.ITEM_PURCHASED, onItemPurchased);
			
			visible= true;
		}
		
		protected function onUpdateToonix(event:Event):void
		{
			switch(_accessoryType){
				case AccessoryType.HEAD_ACCESSORY:
					btnPaleta.changeColor(model.avatar.headColor); break;
				case AccessoryType.BODY_ACCESSORY:
					btnPaleta.changeColor(model.avatar.bodyColor); break;
			}
		}
		
		protected function onChangeColor(event:AvatarEditorInternalEvent):void
		{
			if(event.data.accessory == _accessoryType){
				var color:Number= event.data.color as Number;
				btnPaleta.changeColor(color);
			}
		}
		
		public function setAccessoryType(accessoryType:String):void
		{
			_accessoryType= accessoryType;
			paleta.setAccessoryType(accessoryType);
			paleta.visible= false;
			
			priceManager.setAccessoryType(accessoryType);
			
			switch(accessoryType){
				case AccessoryType.BODY_ACCESSORY:
					btnPaleta.changeColor(model.avatar.bodyColor); break;
				case AccessoryType.HEAD_ACCESSORY:
					btnPaleta.changeColor(model.avatar.headColor); break;
			}
			
			for each(var posData:Object in POSITIONS){
				if(posData.acc == accessoryType){
					x= posData.pos.x;
					y= posData.pos.y;
					
					break;
				}
			}

			showControls(false);
		}
		
		public function getAccessoryType():String
		{
			return _accessoryType;
		}
		
		public function setPrice(price:Number):void
		{
			priceManager.setPrice(price);
			
			showControls();
		}
		
		public function getPrice():Number
		{
			return priceManager.getPrice();
		}
		
		protected function onItemPurchased(event:AvatarEditorInternalEvent):void
		{
			showControls();
		}
		
		protected function onButtonClick(event:MouseEvent):void
		{
			var btn:BasicButton= event.target as BasicButton;
			
			if(btn == btnPaleta){
				if(paleta.visible){
					hidePaleta();
				} else {
					showPaleta();
				}
			} else
			if(btn == btnLeft){
				dispatcher.dispatchEvent(new CAFEvent(CommandType.PREV_ACCESSORY, currentId));
			} else
			if(btn == btnRight){
				dispatcher.dispatchEvent(new CAFEvent(CommandType.NEXT_ACCESSORY, currentId));
			}
		}
		
		
		private function showControls(animate:Boolean=true):void
		{
			if(!visible) return;
			var hasItem:Boolean= false;
			
			var showPalette:Boolean= false;
			var showPrice:Boolean= false;
			var showPriceButton:Boolean= false;
			
			switch(_accessoryType){
				case AccessoryType.BODY_ACCESSORY: 		currentId= model.avatar.body; break;
				case AccessoryType.COSTUME_ACCESSORY: 	currentId= model.avatar.costume; break;
				case AccessoryType.EYES_ACCESSORY: 		currentId= model.avatar.eye; break;
				case AccessoryType.HEAD_ACCESSORY: 		currentId= model.avatar.head; break;
				case AccessoryType.MOUTH_ACCESSORY: 	currentId= model.avatar.mouth; break;
			}
			currentItem= model.getAccessoryById(currentId);
			
			hasItem= model.hasItemInPurchases(currentItem);
			
			// Show palette
			for each(var obj:Object in POSITIONS){
				if(obj.acc == _accessoryType){
					showPalette= obj.hasPalette;
					break;
				}
			}
			
			trace("Checking item");
			trace("itemCost: " + currentItem.price);
			trace("hasItem: " + hasItem);
			// Show price
			if(currentItem.price > 0){
				showPrice= !hasItem;
			}
			trace("showPrice: " + showPrice);

			if(currentItem.price > 0 && !hasItem){
				showPriceButton= model.canBuyItem(currentItem);
			}
			trace("showPriceButton: " + showPriceButton);

			// Back Paleta
			if(!showPalette && !showPrice){
				backPaleta.drawBack(CASE_NONE, animate);
			} else
			if(!showPalette && showPrice){
				if(showPriceButton){
					backPaleta.drawBack(CASE_BUY, animate);
				} else {
					backPaleta.drawBack(CASE_NOBUY, animate);
				}
				priceManager.y= 6;
			} else
			if(showPalette && !showPrice){
				backPaleta.drawBack(CASE_BTN, animate);
			} else
			if(showPalette && showPrice){
				if(showPriceButton){
					backPaleta.drawBack(CASE_BTN_BUY, animate);
				} else {
					backPaleta.drawBack(CASE_BTN_NOBUY, animate);
				}
				priceManager.y= 42.25;
			}
			
			btnPaleta.visible= showPalette;
			paleta.visible= false;
			if(showPrice){
				priceManager.setItem(currentItem);
				priceManager.setPrice(currentItem.price);
				priceManager.show();
			} else {
				priceManager.hide();
			}
			
			backPaleta.visible= showPalette || showPrice;
		}
		
		private function showPaleta():void
		{
			paleta.x-= 230;
			paleta.visible= true;
			TweenLite.to(paleta, 0.7, {x: paleta.x + 230});
			
			if(priceManager.visible){
				if(model.canBuyItem(currentItem)){
					backPaleta.drawBack(CASE_BTN_BUY_PALETA);
				} else {
					backPaleta.drawBack(CASE_BTN_NOBUY_PALETA);
				}
			} else {
				backPaleta.drawBack(CASE_BTN_PALETA);
			}
		}
		
		private function hidePaleta():void
		{
			TweenLite.to(paleta, 0.7, {x: paleta.x - 230, onComplete: function():void{ paleta.x+= 230; paleta.visible= false; }});
			
			if(priceManager.visible){
				if(model.canBuyItem(currentItem)){
					backPaleta.drawBack(CASE_BTN_BUY);
				} else {
					backPaleta.drawBack(CASE_BTN_NOBUY);
				}
			} else {
				backPaleta.drawBack(CASE_BTN);
			}
		}
	}
}