package com.turner.cnla.toonix.editor.view
{
	import flash.display.MovieClip;
	import flash.geom.ColorTransform;
	
	public class ColorPaleta extends MovieClip
	{
		private var _color:Number;
		
		public function ColorPaleta()
		{
			super();
			
			buttonMode= true;
			useHandCursor= true;
			mouseChildren= false;
		}
		
		public function setColor(colorCode:Number):void
		{
			var ct:ColorTransform= new ColorTransform();
			ct.color= colorCode;
			this.transform.colorTransform= ct;
			_color= colorCode;
		}
		
		public function getColor():Number
		{
			return _color;
		}
	}
}