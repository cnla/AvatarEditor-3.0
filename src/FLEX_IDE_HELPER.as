package
{
	import com.turner.cnla.toonix.editor.AvatarEditorMainApp;
	import com.turner.cnla.toonix.editor.commands.*;
	import com.turner.cnla.toonix.editor.controller.*;
	import com.turner.cnla.toonix.editor.events.*;
	import com.turner.cnla.toonix.editor.model.*;
	import com.turner.cnla.toonix.editor.types.*;
	import com.turner.cnla.toonix.editor.ui.*;
	import com.turner.cnla.toonix.editor.view.*;
	import com.turner.cnla.toonix.editor.vo.*;
	
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.net.URLRequest;

	[SWF(frameRate="24", width="900", height="500", backgroundColor="0xFFFFFF")]
	public class FLEX_IDE_HELPER extends Sprite
	{
		public function FLEX_IDE_HELPER()
		{
			BuyAccessoryCommand;
			CancelRandomCommand;
			ChangeAccessoryCommand;
			ChangeActiveAreaCommand;
			ChangeColorCommand;
			ClosePopupCommand;
			CommandType;
			GetRandomCommand;
			InitAppCommand;
			LoadAssetsCommand;
			NextAccessoryCommand;
			PrevAccessoryCommand;
			SaveRandomCommand;
			UndoChangesCommand;
			
			Controller;
			
			AvatarEditorEvent;
			AvatarEditorInternalEvent;
			Dispatcher;
			
			Dictionary;
			Model;
			Params;
			ResourceLoader;
			
			AccessoryType;
			AlignTypes;
			PopupType;
			SponsorType;
			
			BasicButton;
			BasicList;
			ColoredButton;
			ListItem;
			
			AccessoryManager;
			AvatarEditorView;
			BackgroundWrapper;
			BackPaleta;
			ColorPaleta;
			CostumeManager;
			Credits;
			FeatureManager;
			Paleta;
			PopupWindow;
			Preloader;
			PriceManager;
			Toonix;
			
			FeatureAccessoryVO;
			FeatureDataVO;
			FixedSkinVO;
			PopupVO;
			
			AvatarEditorMainApp;
			
			var ldr:Loader= new Loader();
			ldr.contentLoaderInfo.addEventListener(Event.INIT, onInit);
			ldr.load(new URLRequest("AvatarEditor_25.swf"));
		}
		
		protected function onInit(event:Event):void
		{
			var mc:MovieClip= MovieClip(event.target.content);
			addChild(mc);
		}
	}
}