package com.turner.cnla.toonix.editor.commands
{
	import com.turner.caf.commands.ICommand;
	import com.turner.caf.control.CAFEvent;
	import com.turner.cnla.toonix.editor.view.PopupWindow;
	
	import flash.display.DisplayObject;
	
	public class ClosePopupCommand implements ICommand
	{
		public function ClosePopupCommand()
		{
		}
		
		public function execute(event:CAFEvent):void
		{
			var view:PopupWindow= event.viewTarget as PopupWindow;
			view.hidePopup();
		}
	}
}