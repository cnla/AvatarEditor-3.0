package com.turner.cnla.toonix.editor.vo
{
	public class PopupVO
	{
		public var title:String;
		public var message:String;
		public var type:String;
		/**
		 * Only if type == PopupType.POPUP_CREDITS
		 */
		public var credits:int;
		public var okLabel:String;
		public var okCommand:String;
		public var okParams:Object;
	}
}