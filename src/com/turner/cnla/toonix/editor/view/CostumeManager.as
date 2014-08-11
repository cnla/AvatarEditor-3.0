package com.turner.cnla.toonix.editor.view
{
	import com.greensock.TweenLite;
	import com.greensock.easing.Bounce;
	import com.greensock.easing.Elastic;
	import com.turner.caf.control.CAFEvent;
	import com.turner.cnla.library.AvatarItemVO;
	import com.turner.cnla.library.AvatarVO;
	import com.turner.cnla.toonix.editor.commands.CommandType;
	import com.turner.cnla.toonix.editor.events.AvatarEditorInternalEvent;
	import com.turner.cnla.toonix.editor.events.Dispatcher;
	import com.turner.cnla.toonix.editor.model.Dictionary;
	import com.turner.cnla.toonix.editor.model.Model;
	import com.turner.cnla.toonix.editor.types.AccessoryType;
	import com.turner.cnla.toonix.editor.ui.BasicButton;
	import com.turner.cnla.toonix.editor.ui.BasicList;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;

	[Event(name="scroll", type="flash.events.Event")]
	[Event(name="change", type="flash.events.Event")]
	public class CostumeManager extends MovieClip
	{
		private var model:Model;
		private var dispatcher:Dispatcher;
		private var dictionary:Dictionary;
		private var tryThemOn:MovieClip;
		private var txtTryThemOn:TextField;
		private var categorySelected:MovieClip;
		private var txtCategorySelected:TextField;
		private var btnCostume:BasicButton;
		private var btnLeft:BasicButton;
		private var btnRight:BasicButton;
		private var lstCategories:BasicList;
		
		private var costumeList:Array;
		private var currentCostume:int;
		private var currentCategory:String;
		private var originalY:Number;
		private var _selected:Boolean;
		
		public function CostumeManager()
		{
			super();
			
			model= Model.getInstance();
			dispatcher= Dispatcher.getInstance();
			dictionary= Dictionary.getInstance();
				
			btnCostume= getChildByName("btnCostumeInstance") as BasicButton;
			btnLeft= getChildByName("btnLeftInstance") as BasicButton;
			btnRight= getChildByName("btnRightInstance") as BasicButton;
			lstCategories= getChildByName("lstCategoriesInstance") as BasicList;
			categorySelected= getChildByName("categorySelectedInstance") as MovieClip;
			txtCategorySelected= categorySelected.getChildByName("txtLabelInstance") as TextField;
			tryThemOn= getChildByName("tryThemOnInstance") as MovieClip;
			txtTryThemOn= tryThemOn.getChildByName("txtLabelInstance") as TextField;
			
			tryThemOn.mouseChildren= false;
			tryThemOn.mouseEnabled= false;
			txtTryThemOn.mouseEnabled= false;
			
			categorySelected.mouseChildren= false;
			categorySelected.mouseEnabled= false;
			txtCategorySelected.mouseEnabled= false;
			
			btnLeft.visible= false;
			btnRight.visible= false;
			lstCategories.visible= false;
			categorySelected.visible= false;
			tryThemOn.visible= true;
			
			currentCostume= -1;
			
			_selected= false;
			
			originalY= this.y;
			
			btnCostume.addEventListener(MouseEvent.CLICK, onButtonClick);
			btnLeft.addEventListener(MouseEvent.CLICK, onButtonClick);
			btnRight.addEventListener(MouseEvent.CLICK, onButtonClick);
			
			addEventListener(MouseEvent.MOUSE_OVER, onButtonOver);
			addEventListener(MouseEvent.MOUSE_OUT, onButtonOut);
			
			lstCategories.addEventListener(Event.CHANGE, onListChange);
		}
		
		public function init():void
		{
			model.addEventListener(AvatarEditorInternalEvent.UPDATE_ACCESSORY, onToonixChange);
			model.addEventListener(AvatarEditorInternalEvent.UPDATE_TOONIX, onToonixChange);
			model.addEventListener(AvatarEditorInternalEvent.CHANGE_ACTIVE_AREA, onChangeActiveArea);
			
			costumeList= model.assets.filter(onlyCostumes);
			
			var categories:Array= new Array();
			
			for each(var vo:AvatarItemVO in costumeList){
				if(vo.category && vo.category.length && (categories.indexOf(vo.category) == -1)){
					categories.push(vo.category);
				}
			}
			
			categories.sort();
			
			btnCostume.label= dictionary.costumeManager.costumes;
			txtTryThemOn.text= dictionary.costumeManager.tryThemOn;
			
			for(var i:int= 0; i < categories.length; i++){
				lstCategories.addItem(categories[i]);
			}
		}
		
		protected function onChangeActiveArea(event:AvatarEditorInternalEvent):void
		{
			if((model.activeArea == AccessoryType.HEAD_ACCESSORY) || (model.activeArea == AccessoryType.BODY_ACCESSORY)){
				lstCategories.visible= false;
				categorySelected.visible= false;
				btnLeft.visible= false;
				btnRight.visible= false;
				tryThemOn.visible= true;
				_selected= false;
				btnCostume.selected= false;
				onButtonOut(null);
			}
		}
		
		protected function onToonixChange(event:AvatarEditorInternalEvent):void
		{
			var isCostume:Boolean= false;
			
			if(event.data is AvatarVO){
				isCostume= ((event.data as AvatarVO).costume > 0);
			} else
			if(event.data.hasOwnProperty("accessoryType")){
				var accessoryType:String= event.data.accessoryType as String;
				isCostume= (accessoryType == AccessoryType.COSTUME_ACCESSORY);
			}
			
			if(!isCostume){
				lstCategories.visible= false;
				categorySelected.visible= false;
				btnLeft.visible= false;
				btnRight.visible= false;
				tryThemOn.visible= true;
				_selected= false;
				btnCostume.selected= false;
				onButtonOut(null);
			}
		}
		
		protected function onListChange(event:Event):void
		{
			lstCategories.visible= false;
			
			currentCategory= lstCategories.selectedText;
			txtCategorySelected.text= currentCategory;
			currentCostume= getFirstCostumeIndexByCategory(lstCategories.selectedText);
			
			categorySelected.visible= true;
			
			changeCostume();
		}
		
		protected function onButtonClick(event:MouseEvent):void
		{
			var btn:BasicButton= (event.target as BasicButton);
			
			if(btn == btnCostume){
				btnLeft.visible= true;
				btnRight.visible= true;
				lstCategories.visible= true;
				tryThemOn.visible= false;
				categorySelected.visible= false;
				_selected= true;
				btnCostume.selected= true;
				dispatchEvent(new Event(Event.SCROLL));
			} else
			if(btn == btnLeft){
				currentCostume--;
				if(currentCostume < 0) currentCostume= costumeList.length - 1;
				
				changeCostume();
			} else
			if(btn == btnRight){
				currentCostume++;
				if(currentCostume == costumeList.length) currentCostume= 0;
				
				changeCostume();
			}
		}
		
		protected function onButtonOut(event:MouseEvent):void
		{
			if(!_selected){
				TweenLite.to(this, 15, {y: originalY, ease: Elastic.easeOut, useFrames: true});
			}
		}
		
		protected function onButtonOver(event:MouseEvent):void
		{
			if(!_selected){
				TweenLite.to(this, 15, {y: originalY+15, ease: Elastic.easeOut, useFrames: true});
			}
		}
		
		private function changeCostume():void
		{
			var costume:AvatarItemVO= costumeList[currentCostume] as AvatarItemVO;
			var newCategory:String= costume.category;
			
			if(newCategory != currentCategory){
				currentCategory= newCategory;
				txtCategorySelected.text= newCategory;
			}
			
			lstCategories.visible= false;
			categorySelected.visible= true;
			
			dispatchEvent(new Event(Event.CHANGE));
			
			dispatcher.dispatchEvent(new CAFEvent(CommandType.CHANGE_ACCESSORY, {type: AccessoryType.COSTUME_ACCESSORY, item: costume}));
		}
		
		private function getFirstCostumeIndexByCategory(category:String):int
		{
			var ret:int;
			
			for(var i:int= 0; i < costumeList.length; i++){
				var vo:AvatarItemVO= costumeList[i] as AvatarItemVO;
				if(vo.category == category){
					ret= i;
					break;
				}
			}
			
			return i;
		}
		
		private function getFirstByCategory(category:String):AvatarItemVO
		{
			var ret:AvatarItemVO;
			
			for(var i:int= 0; i < costumeList.length; i++){
				var vo:AvatarItemVO= costumeList[i] as AvatarItemVO;
				if(vo.category == category){
					ret= vo;
					break;
				}
			}
			
			return ret;
		}
		
		private function onlyCostumes(item:*, index:int, array:Array):Boolean
		{
			var ret:Boolean= false;
			var avatarItem:AvatarItemVO= item as AvatarItemVO;
			
			return (avatarItem.accessoryType == AccessoryType.COSTUME_ACCESSORY);
		}
		
		public function destroy():void
		{
			if(btnCostume.hasEventListener(MouseEvent.CLICK)) btnCostume.removeEventListener(MouseEvent.CLICK, onButtonClick);
			if(btnLeft.hasEventListener(MouseEvent.CLICK)) btnLeft.removeEventListener(MouseEvent.CLICK, onButtonClick); 
			if(btnRight.hasEventListener(MouseEvent.CLICK)) btnRight.removeEventListener(MouseEvent.CLICK, onButtonClick); 
			
			if(hasEventListener(MouseEvent.MOUSE_OVER)) removeEventListener(MouseEvent.MOUSE_OVER, onButtonOver);
			if(hasEventListener(MouseEvent.MOUSE_OUT)) removeEventListener(MouseEvent.MOUSE_OUT, onButtonOut);
			
			if(lstCategories.hasEventListener(Event.CHANGE)) lstCategories.removeEventListener(Event.CHANGE, onListChange);
			if(model.hasEventListener(AvatarEditorInternalEvent.UPDATE_ACCESSORY)) model.removeEventListener(AvatarEditorInternalEvent.UPDATE_ACCESSORY, onToonixChange);
			if(model.hasEventListener(AvatarEditorInternalEvent.UPDATE_TOONIX)) model.removeEventListener(AvatarEditorInternalEvent.UPDATE_TOONIX, onToonixChange);
			if(model.hasEventListener(AvatarEditorInternalEvent.CHANGE_ACTIVE_AREA)) model.removeEventListener(AvatarEditorInternalEvent.CHANGE_ACTIVE_AREA, onChangeActiveArea);
			
			txtCategorySelected.text= "";
			txtTryThemOn.text= "";
			
			categorySelected= null;
			lstCategories.destroy();
			
			costumeList= new Array();
			costumeList= null;
			currentCostume= 0;
			currentCategory= null;
			originalY= 0;
		}
	}
}