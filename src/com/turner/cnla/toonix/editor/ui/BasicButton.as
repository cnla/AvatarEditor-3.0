package com.turner.cnla.toonix.editor.ui
{
	import flash.display.FrameLabel;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.text.TextField;

	public class BasicButton extends MovieClip
	{
		private var txtLabel:TextField;
		private var _label:String;
		private var _enabled:Boolean;
		private var _selected:Boolean;
		
		public function BasicButton()
		{
			super();
			
			useHandCursor= true;
			buttonMode= true;
			mouseChildren= false;
			
			_enabled= true;
			_selected= false;
			_label= "";
			
			txtLabel= getChildByName("labelInstance")?((getChildByName("labelInstance") as MovieClip).getChildByName("txtLabelInstance") as TextField):null;
			
			addEventListener(MouseEvent.MOUSE_OVER, onOver);
			addEventListener(MouseEvent.MOUSE_OUT, onOut);
			addEventListener(MouseEvent.CLICK, onClick);
		}
		
		public function get label():String
		{
			return _label;
		}
		
		public function set label(value:String):void
		{
			_label = value;
			if(txtLabel) txtLabel.text= value;
		}
		
		public override function set enabled(value:Boolean):void
		{
			if(value){
				goto("out");
			} else {
				goto("disabled");
			}
			
			super.enabled= value;
			_enabled= value;
		}
		
		public function set selected(value:Boolean):void
		{
			if(value){
				goto("selected");
			} else {
				goto("over");
			}
			
			_selected= value;
		}
		
		public function get selected():Boolean
		{
			return _selected;
		}
		
		protected function onOver(event:MouseEvent):void
		{
			if(_enabled && !_selected)
				goto("over");
		}
		
		protected function onOut(event:MouseEvent):void
		{
			if(_enabled && !_selected)
				goto("out");
		}
		
		protected function onClick(event:MouseEvent):void
		{
			goto("click");
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
	}
}