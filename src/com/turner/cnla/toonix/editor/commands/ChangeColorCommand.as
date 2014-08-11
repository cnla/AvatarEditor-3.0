package com.turner.cnla.toonix.editor.commands
{
	import com.turner.caf.commands.ICommand;
	import com.turner.caf.control.CAFEvent;
	import com.turner.cnla.toonix.editor.model.Model;
	
	public class ChangeColorCommand implements ICommand
	{
		private var model:Model;
		
		public function ChangeColorCommand()
		{
			model= Model.getInstance();
		}
		
		public function execute(event:CAFEvent):void
		{
			var accessory:String= event.data.accessory as String;
			var color:Number= event.data.color as Number;
			
			model.changeColor(accessory, color);
		}
	}
}