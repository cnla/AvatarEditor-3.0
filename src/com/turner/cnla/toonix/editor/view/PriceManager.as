package com.turner.cnla.toonix.editor.view
{
	import com.turner.cnla.library.AvatarItemVO;
	import com.turner.cnla.toonix.editor.commands.CommandType;
	import com.turner.cnla.toonix.editor.model.Dictionary;
	import com.turner.cnla.toonix.editor.model.Model;
	import com.turner.cnla.toonix.editor.types.PopupType;
	import com.turner.cnla.toonix.editor.ui.BasicButton;
	import com.turner.cnla.toonix.editor.vo.PopupVO;
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	public class PriceManager extends MovieClip
	{
		private var _item:AvatarItemVO;
		private var _price:Number;
		private var _accessoryType:String;
		
		private var model:Model;
		private var dictionary:Dictionary;
		
		private var priceEnabled:MovieClip;
		private var priceDisabled:MovieClip;
		private var txtPriceEnabled:TextField;
		private var txtPriceDisabled:TextField;
		private var txtCredits:TextField;
		private var btnBuy:BasicButton;
		
		public function PriceManager()
		{
			super();
			
			model= Model.getInstance();
			dictionary= Dictionary.getInstance();
			
			priceEnabled= getChildByName("priceEnabledInstance") as MovieClip;
			priceDisabled= getChildByName("priceDisabledInstance") as MovieClip;
			txtPriceEnabled= priceEnabled.getChildByName("txtLabelInstance") as TextField;
			txtPriceDisabled= priceDisabled.getChildByName("txtLabelInstance") as TextField;
			txtCredits= getChildByName("txtCreditsInstance") as TextField;
			btnBuy= getChildByName("btnBuyInstance") as BasicButton;
			
			btnBuy.addEventListener(MouseEvent.CLICK, onButtonClick);
		}
		
		public function init():void
		{
			txtCredits= dictionary.buyAccessory.notEnoughCredits;
		}
		
		protected function onButtonClick(event:MouseEvent):void
		{
			var btn:BasicButton= event.target as BasicButton;
			
			if(btn == btnBuy){
				var vo:PopupVO= new PopupVO();
				vo.title= dictionary.buyAccessory.popupTitle;
				vo.message= dictionary.buyAccessory.popupMessage.replace("${price}", _price.toString());
				vo.type= PopupType.POPUP_CREDITS;
				vo.credits= (_price * (-1));
				vo.okLabel= dictionary.buyAccessory.popupOk;
				vo.okCommand= CommandType.BUY_ACCESSORY;
				vo.okParams= _accessoryType;
				
				model.showPopup(vo);
			}
		}
		
		public function setAccessoryType(accessoryType:String):void
		{
			_accessoryType= accessoryType;
		}
		
		public function setItem(item:AvatarItemVO):void
		{
			_item= item;
			
			if(model.canBuyItem(_item)){
				priceEnabled.visible= true;
				priceDisabled.visible= false;
				txtCredits.visible= false;
				btnBuy.visible= true;
			} else {
				priceEnabled.visible= false;
				priceDisabled.visible= true;
				txtCredits.visible= true;
				btnBuy.visible= false;
			}
		}
		
		public function setPrice(value:Number):void
		{
			_price= value;
			txtPriceEnabled.text= value.toString();
			txtPriceDisabled.text= value.toString();
		}
		
		public function getPrice():Number
		{
			return _price;
		}
		
		public function show():void
		{
			visible= true;
		}
		
		public function hide():void
		{
			visible= false;
		}
		
		public function destroy():void
		{
			if(btnBuy.hasEventListener(MouseEvent.CLICK)) btnBuy.removeEventListener(MouseEvent.CLICK, onButtonClick);
			
			_item= null;
			_price= 0;
			_accessoryType= null;
			txtCredits.text= "";
			txtPriceDisabled.text= "";
			txtPriceEnabled.text= "";
		}
	}
}