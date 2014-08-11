package com.turner.cnla.toonix.editor.commands
{
	import com.turner.caf.commands.ICommand;
	import com.turner.caf.control.CAFEvent;
	import com.turner.cnla.toonix.editor.model.Model;
	
	public class SaveRandomCommand implements ICommand
	{
		public var model:Model;
		
		public function SaveRandomCommand()
		{
			model= Model.getInstance();
		}
		
		public function execute(event:CAFEvent):void
		{
			/*
			model.setRandomMode(false);
			
			model.updateToonix(model.avatar);
			*/
		}
	}
}