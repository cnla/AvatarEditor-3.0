package com.turner.cnla.toonix.editor.view
{
	import com.turner.caf.control.CAFEvent;
	import com.turner.cnla.toonix.editor.events.Dispatcher;
	import com.turner.cnla.toonix.editor.types.PopupType;
	import com.turner.cnla.toonix.editor.ui.BasicButton;
	import com.turner.cnla.toonix.editor.vo.PopupVO;
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	public class PopupWindow extends MovieClip
	{
		private var txtTitle:TextField;
		private var txtMessage:TextField;
		private var btnClose:BasicButton;
		private var btnOk:BasicButton;
		private var animationCredits:MovieClip;
		
		private var _credits:int;
		private var _okCommand:String;
		private var _okParams:Object;
		private var dispatcher:Dispatcher;
		private var _popupType:String;
		
		public function PopupWindow()
		{
			super();

			dispatcher= Dispatcher.getInstance();
			
			txtMessage= getChildByName("txtMessageInstance") as TextField;
			txtTitle= getChildByName("txtTitleInstance") as TextField;
			btnClose= getChildByName("btnCloseInstance") as BasicButton;
			btnOk= getChildByName("btnOkInstance") as BasicButton;
			animationCredits= getChildByName("animationCreditsInstance") as MovieClip;
			
			visible= false;
		}
		
		public function init():void
		{
			btnClose.addEventListener(MouseEvent.CLICK, onButtonClick);
			btnOk.addEventListener(MouseEvent.CLICK, onButtonClick);
		}
		
		public function setType(type:String):void
		{
			_popupType= type;
		}
		
		public function showPopup(vo:PopupVO):void
		{
			visible= false;
			
			txtTitle.text= vo.title;
			txtMessage.text= vo.message;
			btnOk.label= vo.okLabel;
			
			_okCommand= vo.okCommand;
			_okParams= vo.okParams;
			_popupType= vo.type;
			_credits= vo.credits;
			
			setupType();
			
			visible= true;
		}
		
		private function setupType():void
		{
			switch(_popupType){
				case PopupType.POPUP_ALERT:
					animationCredits.visible= false;
				break;
				case PopupType.POPUP_CREDITS:
					animationCredits.visible= true;
					animationCredits.gotoAndPlay(1);
					((animationCredits.getChildByName("animCreditsInstance") as MovieClip).getChildByName("txtCreditsInstance") as TextField).text= _credits.toString();
				break;
			}
		}
		
		public function hidePopup():void
		{
			visible= false;
		}
		
		protected function onButtonClick(event:MouseEvent):void
		{
			var btn:BasicButton= event.target as BasicButton;
			
			if(btn == btnClose){
				hidePopup();
			} else
			if(btn == btnOk){
				hidePopup();
				dispatcher.dispatchEvent(new CAFEvent(_okCommand, _okParams, this));
			}
		}
		
		public function destroy():void
		{
			if(btnClose.hasEventListener(MouseEvent.CLICK)) btnClose.removeEventListener(MouseEvent.CLICK, onButtonClick);
			if(btnOk.hasEventListener(MouseEvent.CLICK)) btnOk.removeEventListener(MouseEvent.CLICK, onButtonClick);
			
			txtMessage.text= "";
			txtTitle.text= "";
			_okCommand= null;
			_okParams= null;
		}
	}
}