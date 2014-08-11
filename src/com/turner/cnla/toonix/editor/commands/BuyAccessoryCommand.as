package com.turner.cnla.toonix.editor.commands
{
	import com.turner.caf.business.SimpleResponder;
	import com.turner.caf.commands.ICommand;
	import com.turner.caf.control.CAFEvent;
	import com.turner.cnla.library.AvatarItemVO;
	import com.turner.cnla.library.CNLALibraryInvoker;
	import com.turner.cnla.toonix.editor.events.AvatarEditorEvent;
	import com.turner.cnla.toonix.editor.events.Dispatcher;
	import com.turner.cnla.toonix.editor.model.Dictionary;
	import com.turner.cnla.toonix.editor.model.Model;
	import com.turner.cnla.toonix.editor.model.Params;
	import com.turner.cnla.toonix.editor.types.AccessoryType;
	import com.turner.cnla.toonix.editor.types.PopupType;
	import com.turner.cnla.toonix.editor.vo.PopupVO;
	
	public class BuyAccessoryCommand implements ICommand
	{
		private var model:Model;
		private var dictionary:Dictionary;
		private var accessory:AvatarItemVO;
		
		public function BuyAccessoryCommand()
		{
			model= Model.getInstance();
			dictionary= Dictionary.getInstance();
		}
		
		public function execute(event:CAFEvent):void
		{
			var accessoryType:String= event.data as String;
			
			switch(accessoryType){
				case AccessoryType.BODY_ACCESSORY:
					accessory= model.getAccessoryById(model.avatar.body); break;
				case AccessoryType.COSTUME_ACCESSORY:
					accessory= model.getAccessoryById(model.avatar.costume); break;
				case AccessoryType.EYES_ACCESSORY:
					accessory= model.getAccessoryById(model.avatar.eye); break;
				case AccessoryType.HEAD_ACCESSORY:
					accessory= model.getAccessoryById(model.avatar.head); break;
				case AccessoryType.MOUTH_ACCESSORY:
					accessory= model.getAccessoryById(model.avatar.mouth); break;
			}
			
			if(model.userId){
				if(model.userCredits >= accessory.price){
					buyAccessory();
				} else {
					showErrorMessage();
				}
			} else {
				if(model.creditsSpent + accessory.price <= Params.FREE_CREDITS){
					buyAccessory();
				} else {
					showErrorMessage();
				}
			}
		}
		
		private function buyAccessory():void
		{
			if(model.userId){
				if(CNLALibraryInvoker.available){
					var invoker:CNLALibraryInvoker= new CNLALibraryInvoker("CNLALibrary.buyAvatarAccessory", {userId: model.userId, avatarAccessoryId: accessory.id}, onBuyComplete);
					invoker.call();
				} else {
					onBuyComplete({success: true, credits: 50});
				}
			} else {
				model.creditsSpent+= accessory.price;
				model.addItemToPurchases(accessory);
				showSuccessMessage();
			}
			
		}
		
		private function onBuyComplete(data:Object):void
		{
			var success:Boolean= data.success as Boolean;
			var credits:int= data.credits as int;
			
			if(success){
				model.userCredits= credits;
				model.dispatchExternalEvent(AvatarEditorEvent.BUY_ACCESSORY, accessory);

				model.addItemToPurchases(accessory);
				
				showSuccessMessage();
			} else {
				showErrorMessage();
			}
		}
		
		private function showSuccessMessage():void
		{
			trace("Item purchased");
		}
		
		private function showErrorMessage():void
		{
			var vo:PopupVO= new PopupVO();
			vo.title= dictionary.buyAccessory.popupTitle;
			vo.message= dictionary.buyAccessory.notEnoughCredits;
			vo.type= PopupType.POPUP_ALERT;
			vo.credits= -1;
			vo.okLabel= dictionary.main.ok;
			vo.okCommand= CommandType.CLOSE_POPUP;
			vo.okParams= null;
			
			model.showPopup(vo);
			
			model.dispatchExternalEvent(AvatarEditorEvent.BUY_ERROR);
		}
		
		private function onFault(info:Object):void
		{
			trace("## Toonix Editor - BuyAccessoryCommand::onFault() - Error: " + info);
			var vo:PopupVO= new PopupVO();
			vo.title= dictionary.buyAccessory.popupTitle;
			vo.message= dictionary.buyAccessory.connectionError;
			vo.type= PopupType.POPUP_ALERT;
			vo.credits= -1;
			vo.okLabel= dictionary.main.ok;
			vo.okCommand= CommandType.CLOSE_POPUP;
			vo.okParams= null;
			
			model.showPopup(vo);
			
			model.dispatchExternalEvent(AvatarEditorEvent.BUY_ERROR);
		}
	}
}