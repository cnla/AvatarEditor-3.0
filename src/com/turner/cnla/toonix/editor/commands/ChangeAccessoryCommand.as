package com.turner.cnla.toonix.editor.commands
{
	import com.turner.caf.commands.ICommand;
	import com.turner.caf.control.CAFEvent;
	import com.turner.cnla.library.AvatarItemVO;
	import com.turner.cnla.toonix.editor.model.Model;
	
	public class ChangeAccessoryCommand implements ICommand
	{
		private var model:Model;
		
		public function ChangeAccessoryCommand()
		{
			model= Model.getInstance();
		}
		
		public function execute(event:CAFEvent):void
		{
			var accessoryType:String= event.data.type as String;
			var accessory:AvatarItemVO= event.data.item as AvatarItemVO;
			
			model.changeAccessory(accessoryType, accessory);
		}
	}
}