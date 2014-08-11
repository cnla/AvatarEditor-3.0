package com.turner.cnla.toonix.editor.commands
{
	import com.turner.caf.commands.ICommand;
	import com.turner.caf.control.CAFEvent;
	import com.turner.cnla.toonix.editor.model.Model;
	
	public class CancelRandomCommand implements ICommand
	{
		public var model:Model;
		
		public function CancelRandomCommand()
		{
			model= Model.getInstance();
		}
		
		public function execute(event:CAFEvent):void
		{
			/*
			model.updateToonix(model.history[model.history.length-1]);
			
			model.setRandomMode(false);
			*/
		}
	}
}