package com.turner.cnla.toonix.editor.events
{
	import com.turner.caf.control.CAFEvent;
	
	[Event(name="dispatchExternalEvent", type="com.turner.cnla.toonix.editor.events.AvatarEditorInternalEvent")]
	[Event(name="appInitialized", type="com.turner.cnla.toonix.editor.events.AvatarEditorInternalEvent")]
	[Event(name="changeColor", type="com.turner.cnla.toonix.editor.events.AvatarEditorInternalEvent")]
	[Event(name="changeActiveArea", type="com.turner.cnla.toonix.editor.events.AvatarEditorInternalEvent")]
	[Event(name="changeRandomMode", type="com.turner.cnla.toonix.editor.events.AvatarEditorInternalEvent")]
	[Event(name="creditsUpdate", type="com.turner.cnla.toonix.editor.events.AvatarEditorInternalEvent")]
	[Event(name="loadComplete", type="com.turner.cnla.toonix.editor.events.AvatarEditorInternalEvent")]
	[Event(name="loadProgress", type="com.turner.cnla.toonix.editor.events.AvatarEditorInternalEvent")]
	[Event(name="loadError", type="com.turner.cnla.toonix.editor.events.AvatarEditorInternalEvent")]
	[Event(name="updateAccessory", type="com.turner.cnla.toonix.editor.events.AvatarEditorInternalEvent")]
	[Event(name="updateToonix", type="com.turner.cnla.toonix.editor.events.AvatarEditorInternalEvent")]
	[Event(name="save", type="com.turner.cnla.toonix.editor.events.AvatarEditorInternalEvent")]
	[Event(name="cancel", type="com.turner.cnla.toonix.editor.events.AvatarEditorInternalEvent")]
	[Event(name="itemPurchased", type="com.turner.cnla.toonix.editor.events.AvatarEditorInternalEvent")]
	[Event(name="showCreditsWindow", type="com.turner.cnla.toonix.editor.events.AvatarEditorInternalEvent")]
	[Event(name="showPopup", type="com.turner.cnla.toonix.editor.events.AvatarEditorInternalEvent")]
	public class AvatarEditorInternalEvent extends CAFEvent
	{
		public static const DISPATCH_EXTERNAL_EVENT:String= 	"dispatchExternalEvent";
		public static const APP_INITIALIZED:String= 			"appInitialized";
		public static const CHANGE_COLOR:String= 				"changeColor";
		public static const CHANGE_ACTIVE_AREA:String= 			"changeActiveArea";
		public static const CHANGE_RANDOM_MODE:String= 			"changeRandomMode";
		public static const CREDITS_UPDATE:String= 				"creditsUpdate";
		public static const LOAD_COMPLETE:String= 				"loadComplete";
		public static const LOAD_PROGRESS:String= 				"loadProgress";
		public static const LOAD_ERROR:String= 					"loadError";
		public static const UPDATE_TOONIX:String= 				"updateToonix";
		public static const UPDATE_ACCESSORY:String= 			"updateAccessory";
		public static const SAVE:String= 						"save";
		public static const CANCEL:String= 						"cancel";
		public static const ITEM_PURCHASED:String= 				"itemPurchased";
		public static const SHOW_CREDITS_WINDOW:String= 		"showCreditsWindow";
		public static const SHOW_POPUP:String= 					"showPopup";
		
		public function AvatarEditorInternalEvent(type:String, data:Object=null, viewTarget:Object=null)
		{
			super(type, data, viewTarget);
		}
	}
}