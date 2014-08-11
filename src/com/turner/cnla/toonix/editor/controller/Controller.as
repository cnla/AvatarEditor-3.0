package com.turner.cnla.toonix.editor.controller
{
	import com.turner.caf.control.CAFEventDispatcher;
	import com.turner.caf.control.FrontController;
	import com.turner.cnla.toonix.editor.commands.*;
	
	public class Controller extends FrontController
	{
		public function Controller(eventDispatcher:CAFEventDispatcher)
		{
			super(eventDispatcher);
			
			addCommands();
		}
		
		private function addCommands():void
		{
			addCommand(CommandType.INIT_APP, 				InitAppCommand);
			addCommand(CommandType.BUY_ACCESSORY, 			BuyAccessoryCommand);
			addCommand(CommandType.CLOSE_POPUP, 			ClosePopupCommand);
			addCommand(CommandType.LOAD_ASSETS, 			LoadAssetsCommand);
			addCommand(CommandType.GET_RANDOM, 				GetRandomCommand);
			addCommand(CommandType.CANCEL_RANDOM, 			CancelRandomCommand);
			addCommand(CommandType.SAVE_RANDOM, 			SaveRandomCommand);
			addCommand(CommandType.UNDO_CHANGES, 			UndoChangesCommand);
			addCommand(CommandType.CHANGE_COLOR, 			ChangeColorCommand);
			addCommand(CommandType.CHANGE_ACCESSORY, 		ChangeAccessoryCommand);
			addCommand(CommandType.CHANGE_ACTIVE_AREA, 		ChangeActiveAreaCommand);
			addCommand(CommandType.NEXT_ACCESSORY, 			NextAccessoryCommand);
			addCommand(CommandType.PREV_ACCESSORY, 			PrevAccessoryCommand);
		}
	}
}