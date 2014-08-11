package com.turner.cnla.toonix.editor.view
{
	import flash.display.MovieClip;
	import flash.text.TextField;
	
	public class Preloader extends MovieClip
	{
		private var txtPercentage:TextField;
		
		public function Preloader()
		{
			super();
			
			txtPercentage= getChildByName("txtPercentageInstance") as TextField;
		}
		
		public function showProgress(percentage:Number):void
		{
			txtPercentage.text= Math.round(percentage).toString() + "%";
		}
	}
}