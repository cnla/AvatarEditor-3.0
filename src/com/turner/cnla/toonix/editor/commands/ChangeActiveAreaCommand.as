package com.turner.cnla.toonix.editor.commands
{
	import com.turner.caf.commands.ICommand;
	import com.turner.caf.control.CAFEvent;
	import com.turner.cnla.toonix.editor.model.Model;
	
	public class ChangeActiveAreaCommand implements ICommand
	{
		private var model:Model;
		
		public function ChangeActiveAreaCommand()
		{
			model= Model.getInstance();
		}
		
		public function execute(event:CAFEvent):void
		{
			var activeArea:String= event.data as String;
			model.changeActiveArea(activeArea);
		}
	}
}