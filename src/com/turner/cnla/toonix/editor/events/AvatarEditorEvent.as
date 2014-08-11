package com.turner.cnla.toonix.editor.events
{
	import com.turner.caf.control.CAFEvent;
	
	[Event(name="save", type="com.turner.cnla.toonix.editor.events.AvatarEditorEvent")]
	[Event(name="cancel", type="com.turner.cnla.toonix.editor.events.AvatarEditorEvent")]
	[Event(name="showCreditsWindow", type="com.turner.cnla.toonix.editor.events.AvatarEditorEvent")]
	[Event(name="buyError", type="com.turner.cnla.toonix.editor.events.AvatarEditorEvent")]
	[Event(name="buyAccessory", type="com.turner.cnla.toonix.editor.events.AvatarEditorEvent")]
	public class AvatarEditorEvent extends CAFEvent
	{
		public static const SAVE:String= 						"save";
		public static const CANCEL:String= 						"cancel";
		public static const SHOW_CREDITS_WINDOW:String= 		"showCreditsWindow";
		public static const BUY_ERROR:String= 					"buyError";
		public static const BUY_ACCESSORY:String= 				"buyAccessory";
		
		public function AvatarEditorEvent(type:String, data:Object=null, viewTarget:Object=null)
		{
			super(type, data, viewTarget);
		}
	}
}