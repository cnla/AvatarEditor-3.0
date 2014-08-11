package com.turner.cnla.toonix.editor.ui
{
	import flash.display.DisplayObject;
	import flash.display.FrameLabel;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Transform;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	public class ListItem extends MovieClip
	{
		private const SCROLL_OFFSET:Number= 		10;
		
		private var txtLabel:TextField;
		private var labelContainer:MovieClip;
		private var _txtLabelCopy:TextField;
		private var _label:String;
		private var _scrollable:Boolean;
		private var _scrollBounds:Point;
		
		public function ListItem()
		{
			super();
			
			buttonMode= true;
			useHandCursor= true;
			mouseChildren= false;
			
			_label= "";
			_scrollable= false;
			_scrollBounds= new Point(0, 0);
			
			labelContainer= getChildByName("labelInstance") as MovieClip;
			txtLabel= labelContainer?(labelContainer.getChildByName("txtLabelInstance") as TextField):null;
			
			addEventListener(MouseEvent.MOUSE_OVER, onOver);
			addEventListener(MouseEvent.MOUSE_OUT, onOut);
		}
		
		protected function onOut(event:MouseEvent):void
		{
			goto("out");
			
			stopScroll();
		}
		
		protected function onOver(event:MouseEvent):void
		{
			goto("over");
			
			if(_scrollable) startScroll();
		}
		
		private function startScroll():void
		{
			labelContainer.addChild(_txtLabelCopy);
			_txtLabelCopy.x= txtLabel.x + txtLabel.width + SCROLL_OFFSET;
			_txtLabelCopy.y= txtLabel.y;
			
			addEventListener(Event.ENTER_FRAME, onLoop);
		}
		
		private function stopScroll():void
		{
			if(hasEventListener(Event.ENTER_FRAME)) removeEventListener(Event.ENTER_FRAME, onLoop);
			txtLabel.x= _scrollBounds.x;
			if(labelContainer.contains(_txtLabelCopy)) labelContainer.removeChild(_txtLabelCopy);
		}
		
		protected function onLoop(event:Event):void
		{
			txtLabel.x-= 1;
			_txtLabelCopy.x-= 1;
			if((txtLabel.x + txtLabel.textWidth + 5) < _scrollBounds.x){
				txtLabel.x= _txtLabelCopy.x + _txtLabelCopy.textWidth + 5 + SCROLL_OFFSET;
			}
			if((_txtLabelCopy.x + _txtLabelCopy.textWidth + 5) < _scrollBounds.x){
				_txtLabelCopy.x= txtLabel.x + txtLabel.textWidth + 5 + SCROLL_OFFSET;
			}
		}
		
		public function set scrollBounds(value:Point):void
		{
			_scrollBounds= value;
		}
		
		public function get scrollBounds():Point
		{
			return _scrollBounds;
		}
		
		public function set scrollable(value:Boolean):void
		{
			_scrollable= value;
		}
		
		public function get scrollable():Boolean
		{
			return _scrollable;
		}
		
		public function set label(value:String):void
		{
			_label= value;
			if(!txtLabel) return;
			txtLabel.text= value;
			txtLabel.width= txtLabel.textWidth + 5;
			_txtLabelCopy= cloneTextField(txtLabel);
		}
		
		public function get label():String
		{
			return _label;
		}
		
		private function goto(lblName:String):void
		{
			if(hasLabel(lblName) && (currentLabel != lblName)){
				gotoAndPlay(lblName);
			}
		}
		
		private function hasLabel(lblName:String):Boolean
		{
			var ret:Boolean= false;
			
			for each(var lbl:FrameLabel in this.currentLabels){
				if(lbl.name == lblName){
					ret= true;
					break;
				}
			}
			
			return ret;
		}
		
		private function cloneTextField(_tf:TextField):TextField
		{
			var _textField:TextField= new TextField();
			_textField.alpha= _tf.alpha;
			_textField.antiAliasType= _tf.antiAliasType;
			_textField.autoSize= _tf.autoSize;
			_textField.background= _tf.background;
			_textField.backgroundColor= _tf.backgroundColor;
			_textField.defaultTextFormat= _tf.getTextFormat();
			_textField.embedFonts= _tf.embedFonts;
			_textField.filters= _tf.filters;
			_textField.height= _tf.height;
			_textField.htmlText= _tf.htmlText;
			_textField.multiline= _tf.multiline;
			_textField.scaleX= _tf.scaleX;
			_textField.scaleY= _tf.scaleY;
			_textField.scaleZ= _tf.scaleZ;
			_textField.selectable= _tf.selectable;
			_textField.text= _tf.text;
			_textField.textColor= _tf.textColor;
			_textField.type= _tf.type;
			_textField.visible= _tf.visible;
			_textField.width= _tf.width;
			_textField.wordWrap= _tf.wordWrap;
			
			return _textField;
		}
	}
}