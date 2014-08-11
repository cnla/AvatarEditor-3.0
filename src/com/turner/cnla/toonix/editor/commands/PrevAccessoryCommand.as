package com.turner.cnla.toonix.editor.commands
{
	import com.turner.caf.commands.ICommand;
	import com.turner.caf.control.CAFEvent;
	import com.turner.cnla.toonix.editor.model.Model;
	
	public class PrevAccessoryCommand implements ICommand
	{
		private var model:Model;
		
		public function PrevAccessoryCommand()
		{
			model= Model.getInstance();
		}
		
		public function execute(event:CAFEvent):void
		{
			var currentId:Number= event.data as Number;
			model.prevAccessory(currentId);
		}
	}
}