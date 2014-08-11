package com.turner.cnla.toonix.editor.view
{
	import com.greensock.TweenLite;
	
	import flash.display.MovieClip;
	import flash.geom.Point;
	
	public class BackPaleta extends MovieClip
	{
		private var topLeft:MovieClip;
		private var top:MovieClip;
		private var topRight:MovieClip;
		
		private var left:MovieClip;
		private var center:MovieClip;
		private var right:MovieClip;
		
		private var bottomLeft:MovieClip;
		private var bottom:MovieClip;
		private var bottomRight:MovieClip;
		
		private var _lastPoint:Point;
		
		public function BackPaleta()
		{
			super();
			
			_lastPoint= new Point(0, 0);
			
			createChildren();
		}
		
		private function createChildren():void
		{
			topLeft= getChildByName("topLeftInstance") as MovieClip;
			top= getChildByName("topInstance") as MovieClip;
			topRight= getChildByName("topRightInstance") as MovieClip;
			
			left= getChildByName("leftInstance") as MovieClip;
			center= getChildByName("centerInstance") as MovieClip;
			right= getChildByName("rightInstance") as MovieClip;
			
			bottomLeft= getChildByName("bottomLeftInstance") as MovieClip;
			bottom= getChildByName("bottomInstance") as MovieClip;
			bottomRight= getChildByName("bottomRightInstance") as MovieClip;
			
			if(!topLeft || !top || !topRight || !left || !center || !right || !bottomLeft || !bottom || !bottomRight){
				throw new Error("## ToonixEditor - BackPaleta::createChildren() - Children must not be null");
			}
		}
		
		public function drawBack(newCase:Point, animate:Boolean=true):void
		{
			var destPoint:Point= new Point(newCase.x-20, newCase.y-20);
			
			/*
			center.width= destPoint.x;
			center.height= destPoint.y;
			
			left.height= destPoint.y;

			right.height= destPoint.y;
			right.x= center.x + destPoint.x;
			
			top.width= destPoint.x;
			
			bottom.width= destPoint.x;
			bottom.y= center.y + destPoint.y;
			
			topRight.x= top.x + destPoint.x;
			
			bottomLeft.y= left.y + destPoint.y;
			
			bottomRight.x= bottom.x + destPoint.x;
			bottomRight.y= right.y + destPoint.y;
			*/
			
			var time:Number;
			if(((_lastPoint.x == 0) && (_lastPoint.y == 0)) || !animate){
				time= 0;
			} else {
				time= 0.7;
			}
			
			TweenLite.to(center, 		time, {width: destPoint.x, height: destPoint.y});
			TweenLite.to(left, 			time, {height: destPoint.y});
			TweenLite.to(right, 		time, {height: destPoint.y, x: center.x + destPoint.x});
			TweenLite.to(top, 			time, {width: destPoint.x});
			TweenLite.to(bottom, 		time, {width: destPoint.x, y: center.y + destPoint.y});
			TweenLite.to(topRight, 		time, {x: top.x + destPoint.x});
			TweenLite.to(bottomLeft, 	time, {y: left.y + destPoint.y});
			TweenLite.to(bottomRight, 	time, {x: bottom.x + destPoint.x, y: right.y + destPoint.y});
			
			_lastPoint= newCase;
		}
	}
}