package com.turner.cnla.toonix.editor.ui
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	[Event(name="change", type="flash.events.Event")]
	public class BasicList extends MovieClip
	{
		private var back:MovieClip;
		private var scrollBar:MovieClip;
		private var backScrollBar:MovieClip;
		private var visibleArea:MovieClip;
		private var maskList:Sprite;
		private var itemGuide:ListItem;
		private var itemList:Vector.<ListItem>;
		private var itemContainer:Sprite;
		private var visibleItems:int;
		private var selectedItem:ListItem;
		
		public function BasicList()
		{
			super();
			
			back= getChildByName("backInstance") as MovieClip;
			scrollBar= getChildByName("scrollBarInstance") as MovieClip;
			backScrollBar= getChildByName("backScrollBarInstance") as MovieClip;
			visibleArea= getChildByName("visibleAreaInstance") as MovieClip;
			itemGuide= getChildByName("itemGuideInstance") as ListItem;
			
			maskList= new Sprite();
			maskList.graphics.beginFill(0x00FF00);
			maskList.graphics.drawRect(0, 0, visibleArea.width, visibleArea.height);
			maskList.graphics.endFill();
			maskList.x= visibleArea.x;
			maskList.y= visibleArea.y;
			addChild(maskList);
			
			itemContainer= new Sprite();
			itemContainer.x= itemGuide.x;
			itemContainer.y= itemGuide.y;
			itemContainer.mask= maskList;
			addChild(itemContainer);
			addChild(backScrollBar);
			addChild(scrollBar);
			
			scrollBar.buttonMode= true;
			scrollBar.addEventListener(MouseEvent.MOUSE_DOWN, onScrollBarDown);
			scrollBar.addEventListener(MouseEvent.MOUSE_UP, onScrollBarUp);
			
			itemGuide.visible= false;
			visibleItems= 0;
			
			itemList= new Vector.<ListItem>;
		}
		
		protected function onAddedToStage(event:Event):void
		{
			stage.addEventListener(MouseEvent.MOUSE_UP, onScrollBarUp);
		}
		
		protected function onScrollBarDown(event:MouseEvent):void
		{
			scrollBar.startDrag(false, new Rectangle(backScrollBar.x, backScrollBar.y, 0, (backScrollBar.height - scrollBar.height)));
			
			addEventListener(Event.ENTER_FRAME, loop);
		}
		
		protected function onScrollBarUp(event:MouseEvent):void
		{
			scrollBar.stopDrag();
			
			var pos:Number= (scrollBar.y - backScrollBar.y) + (scrollBar.height/2);
			var index:int= Math.floor(pos / scrollBar.height);
			
			scrollBar.y= backScrollBar.y + (scrollBar.height * index);
			
			removeEventListener(Event.ENTER_FRAME, loop);
		}
		
		protected function loop(event:Event):void
		{
			var pos:Number= (scrollBar.y - backScrollBar.y) + (scrollBar.height/2);
			var index:int= Math.floor(pos / scrollBar.height);
			
			itemContainer.y= itemGuide.y - (itemGuide.height * index);
		}
		
		public function addItem(label:String):void
		{
			var item:ListItem= new ListItem();
			item.label= label;
			
			if(itemList.length == 0){
				item.x= 0;
				item.y= 0;
			} else {
				var lastItem:ListItem= itemList[(itemList.length-1)] as ListItem;
				item.x= lastItem.x;
				item.y= lastItem.y + lastItem.height;
			}
			
			item.scrollBounds= new Point(0, visibleArea.width);
			item.scrollable= (item.width > visibleArea.width);
			
			item.addEventListener(MouseEvent.CLICK, onItemClick);
			
			itemContainer.addChild(item);
			itemList.push(item);
			
			if((itemContainer.y + item.y) <= (visibleArea.y + visibleArea.height))
				visibleItems++;
			
			checkForScrollbar();
		}
		
		public function get selectedText():String
		{
			return selectedItem.label;
		}
		
		protected function onItemClick(event:MouseEvent):void
		{
			selectedItem= event.target as ListItem;
			
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		private function checkForScrollbar():void
		{
			var lastItem:ListItem= itemList[(itemList.length-1)] as ListItem;

			if(backScrollBar) backScrollBar.visible= (lastItem.y > (visibleArea.y + visibleArea.height));
			scrollBar.visible= (lastItem.y > (visibleArea.y + visibleArea.height));
			
			var itemsOut:int= itemList.length - visibleItems;
			
			scrollBar.height= backScrollBar.height / (itemsOut+1);
		}
		
		public function destroy():void
		{
			if(scrollBar.hasEventListener(MouseEvent.MOUSE_DOWN)) scrollBar.removeEventListener(MouseEvent.MOUSE_DOWN, onScrollBarDown);
			if(scrollBar.hasEventListener(MouseEvent.MOUSE_UP)) scrollBar.removeEventListener(MouseEvent.MOUSE_UP, onScrollBarUp);
			if(stage && stage.hasEventListener(MouseEvent.MOUSE_UP)) stage.removeEventListener(MouseEvent.MOUSE_UP, onScrollBarUp);
			if(hasEventListener(Event.ENTER_FRAME)) removeEventListener(Event.ENTER_FRAME, loop);
			
			itemList= new Vector.<ListItem>();
			itemList= null;
			while(itemContainer.numChildren > 0) itemContainer.removeChildAt(0);
			if(contains(itemContainer)) removeChild(itemContainer);
			if(contains(maskList)) removeChild(maskList);
			
			itemContainer= null;
			maskList= null;
			selectedItem= null;
		}
	}
}