package com.turner.cnla.toonix.editor.ui
{
	import flash.display.MovieClip;
	import flash.geom.ColorTransform;

	public class ColoredButton extends BasicButton
	{
		private var color:MovieClip;
		
		public function ColoredButton()
		{
			super();
			
			color= getChildByName("colorInstance") as MovieClip;
		}
		
		public function changeColor(newColor:Number):void
		{
			var ct:ColorTransform= new ColorTransform();
			ct.color= newColor;
			if(color){
				color.transform.colorTransform= ct;
			}
		}
	}
}