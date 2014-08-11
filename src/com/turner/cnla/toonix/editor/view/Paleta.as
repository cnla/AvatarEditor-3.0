package com.turner.cnla.toonix.editor.view
{
	import com.turner.caf.control.CAFEvent;
	import com.turner.cnla.toonix.editor.commands.CommandType;
	import com.turner.cnla.toonix.editor.events.AvatarEditorInternalEvent;
	import com.turner.cnla.toonix.editor.events.Dispatcher;
	import com.turner.cnla.toonix.editor.model.Params;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	[Event(name="colorChange", type="com.turner.cnla.toonix.editor.events.AvatarEditorInternalEvent")]
	public class Paleta extends MovieClip
	{
		private var dispatcher:Dispatcher;
		private var maskColores:MovieClip;
		private var colorGuide:ColorPaleta;
		private var colorContainer:Sprite;
		private var _accessoryType:String;
		
		public function Paleta()
		{
			super();
			
			dispatcher= Dispatcher.getInstance();
			maskColores= getChildByName("maskColoresInstance") as MovieClip;
			colorGuide= getChildByName("colorGuideInstance") as ColorPaleta;
			
			visible= false;
		}
		
		public function init():void
		{
			var len:int= Params.COLOR_LIST.length;
			var lastClr:ColorPaleta;
			
			colorContainer= new Sprite();
			colorContainer.x= colorGuide.x;
			colorContainer.y= colorGuide.y;
			if(maskColores)
				colorContainer.mask= maskColores;
			addChild(colorContainer);
			
			for(var i:int= 0; i < len; i++)
			{
				var clr:ColorPaleta= new ColorPaleta();
				if(lastClr) {
					clr.x= lastClr.x + lastClr.width;
					clr.y= lastClr.y;
				} else {
					clr.x= 0;
					clr.y= 0;
				}
				clr.width= colorGuide.width;
				clr.height= colorGuide.height;
				
				clr.setColor(Params.COLOR_LIST[i]);
				clr.addEventListener(MouseEvent.CLICK, onColorClick);
				
				colorContainer.addChild(clr);
				lastClr= clr;
			}
			
			colorGuide.visible= false;
			visible= true;
		}
		
		public function setAccessoryType(value:String):void
		{
			_accessoryType= value;
		}
		
		public function getAccessoryType():String
		{
			return _accessoryType;
		}
		
		protected function onColorClick(event:MouseEvent):void
		{
			var clr:ColorPaleta= event.target as ColorPaleta;
			var colorCode:Number= clr.getColor();
			
			dispatcher.dispatchEvent(new CAFEvent(CommandType.CHANGE_COLOR, {accessory: _accessoryType, color: colorCode}));
		}
		
		public function destroy():void
		{
			_accessoryType= null;
			if(contains(colorContainer)) removeChild(colorContainer);
			colorContainer= null;
		}
	}
}