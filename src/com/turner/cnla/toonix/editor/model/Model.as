package com.turner.cnla.toonix.editor.model
{
	import com.adobe.images.PNGEncoder;
	import com.turner.caf.control.CAFEvent;
	import com.turner.caf.util.ServiceLocatorHelper;
	import com.turner.cnla.library.AvatarItemVO;
	import com.turner.cnla.library.AvatarVO;
	import com.turner.cnla.toonix.editor.commands.CommandType;
	import com.turner.cnla.toonix.editor.events.AvatarEditorInternalEvent;
	import com.turner.cnla.toonix.editor.events.Dispatcher;
	import com.turner.cnla.toonix.editor.types.AccessoryType;
	import com.turner.cnla.toonix.editor.types.AlignTypes;
	import com.turner.cnla.toonix.editor.vo.FeatureDataVO;
	import com.turner.cnla.toonix.editor.vo.FixedSkinVO;
	import com.turner.cnla.toonix.editor.vo.PopupVO;
	import com.turner.toonix.avatardisplay.AvatarDisplay;
	import com.turner.toonix.avatardisplay.types.AvatarDisplayViewPositionType;
	import com.turner.toonix.avatardisplay.vo.AvatarDisplayInitVO;
	
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.ProgressEvent;
	import flash.external.ExternalInterface;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.utils.ByteArray;
	import flash.utils.DebugUtils;
	
	import mx.utils.Base64Encoder;

	[Event(name="dispatchExternalEvent", type="com.turner.cnla.toonix.editor.events.AvatarEditorInternalEvent")]
	[Event(name="appInitialized", type="com.turner.cnla.toonix.editor.events.AvatarEditorInternalEvent")]
	[Event(name="changeColor", type="com.turner.cnla.toonix.editor.events.AvatarEditorInternalEvent")]
	[Event(name="changeActiveArea", type="com.turner.cnla.toonix.editor.events.AvatarEditorInternalEvent")]
	[Event(name="changeRandomMode", type="com.turner.cnla.toonix.editor.events.AvatarEditorInternalEvent")]
	[Event(name="creditsUpdate", type="com.turner.cnla.toonix.editor.events.AvatarEditorInternalEvent")]
	[Event(name="updateToonix", type="com.turner.cnla.toonix.editor.events.AvatarEditorInternalEvent")]
	[Event(name="updateAccessory", type="com.turner.cnla.toonix.editor.events.AvatarEditorInternalEvent")]
	[Event(name="loadComplete", type="com.turner.cnla.toonix.editor.events.AvatarEditorInternalEvent")]
	[Event(name="loadProgress", type="com.turner.cnla.toonix.editor.events.AvatarEditorInternalEvent")]
	[Event(name="loadError", type="com.turner.cnla.toonix.editor.events.AvatarEditorInternalEvent")]
	[Event(name="itemPurchased", type="com.turner.cnla.toonix.editor.events.AvatarEditorInternalEvent")]
	[Event(name="showPopup", type="com.turner.cnla.toonix.editor.events.AvatarEditorInternalEvent")]
	/**
	 * Singleton
	 */
	public class Model extends EventDispatcher
	{
		private static var _allowInstantiation:Boolean= false;
		private static var _instance:Model= null;
		
		private var dispatcher:Dispatcher;
		private var _replaceTokens:Object;
		private var _country:String;
		private var _lang:String;
		private var _assets:Array;
		private var _userId:Number;
		private var _userName:String;
		private var _userCredits:int;
		private var _activeArea:String;
		private var _showCredits:Boolean;
		private var _showShare:Boolean;
		private var _resourceLoader:ResourceLoader;
		private var _creditsSpent:int;
		private var _imageData:String;
		private var _itemsBought:Vector.<AvatarItemVO>;
		private var _backgroundPath:String;
		private var _defaultSkeletonUrl:String;
		private var _defaultAvatarPosition:String;
		private var _defaultAvatar:AvatarVO;
		private var _avatar:AvatarVO;
		private var _initAvatar:AvatarVO;
		private var _history:Vector.<AvatarVO>;
		private var _randomMode:Boolean;
		private var _featureData:FeatureDataVO;
		private var _features:Vector.<FeatureDataVO>;
		private var _emotionsMap:Array;
		private var _fixedSkinMap:Array;
		
		public function Model()
		{
			super();
			
			if(!_allowInstantiation){
				throw new Error("## Toonix Editor - Model::Model() - Singleton error. Instantiation not allowed.");
			}
			
			dispatcher= Dispatcher.getInstance();
			_history= new Vector.<AvatarVO>;
			_creditsSpent= 0;
			_itemsBought= new Vector.<AvatarItemVO>;
			_features= new Vector.<FeatureDataVO>();
		}

		public static function getInstance():Model
		{
			if(_instance == null){
				_allowInstantiation= true;
				_instance= new Model();
				_allowInstantiation= false;
			}
			
			return _instance;
		}
		
		
		public function get replaceTokens():Object { return _replaceTokens; }
		
		public function set replaceTokens(value:Object):void { _replaceTokens = value; }
		
		public function get assets():Array { return _assets; }

		public function set assets(value:Array):void { _assets = value; }
		
		public function get lang():String { return _lang; }
		
		public function set lang(value:String):void { _lang = value; }
		
		public function get country():String { return _country; }
		
		public function set country(value:String):void { _country = value; }
		
		public function get activeArea():String { return _activeArea; }
		
		public function set activeArea(value:String):void { _activeArea = value; }
		
		public function get backgroundPath():String { return _backgroundPath; }
		
		public function set backgroundPath(value:String):void { _backgroundPath = value; }

		public function get userId():int { return _userId; }
		
		public function set userId(value:int):void { _userId = value; }
		
		public function get userName():String { return _userName; }
		
		public function set userName(value:String):void { _userName = value; }
		
		public function get userCredits():int { return _userCredits; }
		
		public function set userCredits(value:int):void { _userCredits = value; dispatchEvent(new AvatarEditorInternalEvent(AvatarEditorInternalEvent.CREDITS_UPDATE)); }
		
		public function get defaultSkeletonUrl():String { return _defaultSkeletonUrl; }
		
		public function set defaultSkeletonUrl(value:String):void { _defaultSkeletonUrl= value; }
		
		public function get defaultAvatarPosition():String { return _defaultAvatarPosition; }
		
		public function set defaultAvatarPosition(value:String):void { _defaultAvatarPosition= value; }
		
		public function get defaultAvatar():AvatarVO { return _defaultAvatar; }
		
		public function set defaultAvatar(value:AvatarVO):void { _defaultAvatar= value; }
		
		public function get avatar():AvatarVO { return _avatar; }
		
		public function set avatar(value:AvatarVO):void { _avatar = value; }
		
		public function get initAvatar():AvatarVO { return _initAvatar; }
		
		public function set initAvatar(value:AvatarVO):void { _initAvatar = value; }
		
		public function get imageData():String { return _imageData; }
		
		public function set imageData(value:String):void{ _imageData= value; }

		public function get history():Vector.<AvatarVO> { return _history; }
		
		public function set featureData(value:FeatureDataVO):void { _featureData = value; }

		public function get featureData():FeatureDataVO { return _featureData; }
		
		public function set features(value:Vector.<FeatureDataVO>):void { _features= value; }
		
		public function get features():Vector.<FeatureDataVO> { return _features; }
		
		public function get showCredits():Boolean { return _showCredits; }
		
		public function set showCredits(value:Boolean):void { _showCredits = value; }
		
		public function get showShare():Boolean { return _showShare; }
		
		public function set showShare(value:Boolean):void { _showShare = value; }

		public function get emotionsMap():Array { return _emotionsMap; }
		
		public function set emotionsMap(value:Array):void { _emotionsMap = value; }

		public function get fixedSkinMap():Array { return _fixedSkinMap; }
		
		public function set fixedSkinMap(value:Array):void { _fixedSkinMap = value; }
		
		public function get creditsSpent():int { return _creditsSpent; }
		
		public function set creditsSpent(value:int):void { _creditsSpent = value; }

		public function get itemsBought():Vector.<AvatarItemVO> { return _itemsBought; }
		
		public function set itemsBought(value:Vector.<AvatarItemVO>):void { _itemsBought = value; }
		
		public function init():void
		{
			dispatchEvent(new AvatarEditorInternalEvent(AvatarEditorInternalEvent.APP_INITIALIZED));
		}
		
		public function callJS(functionName:String, ... params):void
		{
			if(ExternalInterface.available){
				ExternalInterface.call(functionName, params);
			}
		}
		
		public function dispatchExternalEvent(type:String, data:Object=null):void
		{
			var eventData:Object= new Object();
			eventData.type= type;
			eventData.data= data;
			dispatchEvent(new AvatarEditorInternalEvent(AvatarEditorInternalEvent.DISPATCH_EXTERNAL_EVENT, eventData));
		}
		
		public function getAvatarDisplayInitVO():AvatarDisplayInitVO
		{
			var ret:AvatarDisplayInitVO= new AvatarDisplayInitVO();
			
			/* 
				Casos posibles
				1. userId null, avatar null -> carga default
				2. userId null, avatar not null -> carga avatar
				3. userId not null, avatar null -> carga default (no debería ocurrir, si userId != null, avatar debería ser != null)
				4. userId not null, avatar not null -> carga avatar
			*/
			
			_avatar= _initAvatar ? _initAvatar : _defaultAvatar;
			
			if(_avatar){
				ret.bodyAccessoryUrl= 		(_avatar.costume > 0) ? getAccessoryPathById(_avatar.costume, AccessoryType.BODY_ACCESSORY) : getAccessoryPathById(_avatar.body, AccessoryType.BODY_ACCESSORY);
				ret.bodyColor= 				_avatar.bodyColor;
				ret.eyeAccessoryUrl= 		getAccessoryPathById(_avatar.eye);
				ret.fixedSkinColor= 		getFixedSkinColor(_avatar.body, _avatar.costume, _avatar.head, _avatar.eye, _avatar.mouth);
				ret.headAccessoryUrl= 		(_avatar.costume > 0) ? getAccessoryPathById(_avatar.costume, AccessoryType.HEAD_ACCESSORY) : getAccessoryPathById(_avatar.head, AccessoryType.HEAD_ACCESSORY);
				ret.headColor= 				_avatar.headColor;
				ret.mouthAccessoryUrl= 		getAccessoryPathById(_avatar.mouth);
				ret.skeletonUrl= 			defaultSkeletonUrl;
				ret.skinColor= 				_avatar.skinColor;
				ret.viewPosition= 			defaultAvatarPosition;
				
				saveToHistory();
			}
			
			return ret;
		}
		
		private function hasNewAvatar(avatar:AvatarVO):Boolean
		{
			return checkValidationByPrefix(avatar, "new.");
		}
		
		private function hasInvisibleAvatar(avatar:AvatarVO):Boolean
		{
			return checkValidationByPrefix(avatar, "inv.");
		}
		
		private function checkValidationByPrefix(avatar:AvatarVO, prefix:String):Boolean
		{
			var ret:Boolean= true;
			
			if(avatar.costume > 0){
				var costume:AvatarItemVO= getAccessoryById(avatar.costume);
				if(costume){
					if(costume.bodyPath.substr(0, 4).toLowerCase() != prefix) ret= false;
					if(costume.headPath.substr(0, 4).toLowerCase() != prefix) ret= false;
				} else {
					ret= false;
				}
			} else {
				var head:AvatarItemVO= 		getAccessoryById(avatar.head);
				var eye:AvatarItemVO= 		getAccessoryById(avatar.eye);
				var mouth:AvatarItemVO= 	getAccessoryById(avatar.mouth);
				var body:AvatarItemVO= 		getAccessoryById(avatar.body);
				
				if(head){
					if(head.path.substr(0, 4).toLowerCase() != prefix) ret= false;
				} else {
					ret= false;
				}
				
				if(eye){ 
					if(eye.path.substr(0, 4).toLowerCase() != prefix) ret= false;
				} else {
					ret= false;
				}
				
				if(mouth){
					if(mouth.path.substr(0, 4).toLowerCase() != prefix) ret= false;
				} else {
					ret= false;
				}
				
				if(body){
					if(body.path.substr(0, 4).toLowerCase() != prefix) ret= false;
				} else {
					ret= false;
				}
			}
			
			return ret;
		}
		
		public function showPopup(vo:PopupVO):void
		{
			dispatchEvent(new AvatarEditorInternalEvent(AvatarEditorInternalEvent.SHOW_POPUP, vo));
		}
		
		public function hasFixedSkin(accessoryId:Number):Boolean
		{
			var ret:Boolean= false;
			
			for each(var fs:FixedSkinVO in _fixedSkinMap){
				if(fs.accessoryId == accessoryId){
					ret= true;
					break;
				}
			}
			
			return ret;
		}
		
		public function getFixedSkinColor(... idList):Number
		{
			var ret:Number= -1;
			
			for each(var fs:FixedSkinVO in _fixedSkinMap){
				for each(var accessoryId:Number in idList){
					if(fs.accessoryId == accessoryId){
						ret= fs.fixedSkin;
						break;
					}
				}
			}
			
			return ret;
		}
		
		public function getActiveArea():String
		{
			return _activeArea;
		}
		
		public function changeActiveArea(newArea:String):void
		{
			_activeArea= newArea;
			dispatchEvent(new AvatarEditorInternalEvent(AvatarEditorInternalEvent.CHANGE_ACTIVE_AREA));
		}
		
		public function changeColor(accessory:String, color:Number):void
		{
			dispatcher.dispatchEvent(new CAFEvent(CommandType.SAVE_RANDOM));
			
			switch(accessory){
				case AccessoryType.BODY_ACCESSORY:
					_avatar.bodyColor= color; break;
				case AccessoryType.HEAD_ACCESSORY:
					_avatar.headColor= color; break;
				case AccessoryType.SKIN_ACCESSORY:
					_avatar.skinColor= color; break;
			}
			
			saveToHistory();
			
			dispatchEvent(new AvatarEditorInternalEvent(AvatarEditorInternalEvent.CHANGE_COLOR, {accessory: accessory, color: color}));
		}
		
		public function updateToonix(newAvatar:AvatarVO):void
		{
			if(!areEqual(_avatar, newAvatar)){
				_avatar= newAvatar;
			
				saveToHistory();
				
				dispatchEvent(new AvatarEditorInternalEvent(AvatarEditorInternalEvent.UPDATE_TOONIX, _avatar));
			}
		}
		
		public function addItemToPurchases(item:AvatarItemVO):void
		{
			_itemsBought.push(item);
			
			dispatchEvent(new AvatarEditorInternalEvent(AvatarEditorInternalEvent.ITEM_PURCHASED, item));
		}
		
		public function hasItemInPurchases(item:AvatarItemVO):Boolean
		{
			var ret:Boolean= false;
			
			for each(var vo:AvatarItemVO in _itemsBought){
				if(vo.id == item.id){
					ret= true;
					break;
				}
			}
			
			if(item.price == 0) ret= true;
			
			return ret;
		}
		
		public function canBuyItem(item:AvatarItemVO):Boolean
		{
			var ret:Boolean= true;
			
			if(hasItemInPurchases(item)){
				ret= false;
			} else {
				if(userCredits){
					ret= (userCredits >= item.price);
				} else {
					ret= (_creditsSpent + item.price <= Params.FREE_CREDITS);
				}
			}
			
			return ret;
		}
		
		public function nextAccessory(currentItemId:Number):void
		{
			moveToItem(currentItemId, 1);
		}
		
		public function prevAccessory(currentItemId:Number):void
		{
			moveToItem(currentItemId, -1);
		}
		
		private function moveToItem(currentItemId:Number, direction:int):void
		{
			var currentItemIndex:Number= binarySearch(_assets, currentItemId, 0, _assets.length);
			var currentItem:AvatarItemVO= (currentItemIndex >= 0) ? (_assets[currentItemIndex] as AvatarItemVO) : null;
			
			if(currentItem){
				var nextItemId:Number= getNextItemId(currentItemIndex, direction);
				var newAvatar:AvatarVO= _avatar.clone() as AvatarVO;
				
				switch(currentItem.accessoryType){
					case AccessoryType.BODY_ACCESSORY:
						newAvatar.body= nextItemId;
						newAvatar.costume= 0;
					break;
					case AccessoryType.COSTUME_ACCESSORY:
						newAvatar.costume= nextItemId;
					break;
					case AccessoryType.EYES_ACCESSORY:
						newAvatar.eye= nextItemId;
					break;
					case AccessoryType.HEAD_ACCESSORY:
						newAvatar.head= nextItemId;
						newAvatar.costume= 0;
					break;
					case AccessoryType.MOUTH_ACCESSORY:
						newAvatar.mouth= nextItemId;
					break;
				}
				
				if(hasFixedSkin(nextItemId)){
					newAvatar.skinColor= getFixedSkinColor(nextItemId);
				} else {
					newAvatar.skinColor= getLatestGoodSkinColor();
				}
				
				setRandomMode(false);
				
				updateToonix(newAvatar);
			}
		}
		
		private function getNextItemId(currentItemIndex:Number, direction:int):Number
		{
			var ret:Number= 0;
			var currentItem:AvatarItemVO= (_assets[currentItemIndex] as AvatarItemVO);
			var nextItemIndex:Number= currentItemIndex;
			var nextItem:AvatarItemVO;
			
			while(ret == 0){
				nextItemIndex+= direction;
				if(nextItemIndex == _assets.length) nextItemIndex= 0;
				if(nextItemIndex == -1) nextItemIndex= (_assets.length - 1);
				
				nextItem= (_assets[nextItemIndex] as AvatarItemVO);
				if(nextItem.accessoryType == currentItem.accessoryType){
					ret= nextItem.id;
				}
			}
			
			return ret;
		}
		
		public function setRandomMode(value:Boolean):void
		{
			_randomMode= value;
			
			dispatchEvent(new AvatarEditorInternalEvent(AvatarEditorInternalEvent.CHANGE_RANDOM_MODE, value));
		}
		
		public function getRandomMode():Boolean
		{
			return _randomMode;
		}
		
		public function undoChanges():void
		{
			var disposedAvatar:AvatarVO= _history.pop();
			
			var newAvatar:AvatarVO= _history.pop();
			
			setRandomMode(false);
			
			updateToonix(newAvatar);
		}
		
		public function saveToHistory():void
		{
			_history.push(_avatar.clone() as AvatarVO);
		}
		
		public function generateImage(bmpData:BitmapData):void
		{
			var _imageBytes:ByteArray= PNGEncoder.encode(bmpData);
			var base:Base64Encoder= new Base64Encoder();
			base.encodeBytes(_imageBytes);
			_imageData= base.toString();
			var regExp:RegExp= /\n/g;
			_imageData= _imageData.replace(regExp, "");
		}
		
		public function changeAccessory(accessoryType:String, newAccessory:AvatarItemVO):void
		{
			dispatcher.dispatchEvent(new CAFEvent(CommandType.SAVE_RANDOM));
			
			switch(accessoryType){
				case AccessoryType.BODY_ACCESSORY:
					_avatar.body= newAccessory.id; break;
				case AccessoryType.COSTUME_ACCESSORY:
					_avatar.costume= newAccessory.id; break;
				case AccessoryType.EYES_ACCESSORY:
					_avatar.eye= newAccessory.id; break;
				case AccessoryType.HEAD_ACCESSORY:
					_avatar.head= newAccessory.id; break;
				case AccessoryType.MOUTH_ACCESSORY:
					_avatar.mouth= newAccessory.id; break;
			}
			
			if(hasFixedSkin(newAccessory.id)){
				_avatar.skinColor= getFixedSkinColor(newAccessory.id);
			} else {
				_avatar.skinColor= getLatestGoodSkinColor();
			}
			
			saveToHistory();
			
			dispatchEvent(new AvatarEditorInternalEvent(AvatarEditorInternalEvent.UPDATE_ACCESSORY, {accessoryType: accessoryType, newAccessory: newAccessory})); 
		}
		
		public function loadResources(resourceList:Array):void
		{
			_resourceLoader= new ResourceLoader();
			_resourceLoader.addEventListener(Event.COMPLETE, onResourceLoaderComplete);
			_resourceLoader.addEventListener(ErrorEvent.ERROR, onResourceLoaderError);
			_resourceLoader.addEventListener(ProgressEvent.PROGRESS, onResourceLoaderProgress);
			_resourceLoader.load(resourceList);
		}
		
		public function getResourceList():Array
		{
			return _resourceLoader.getResourceList();
		}
		
		protected function onResourceLoaderProgress(event:ProgressEvent):void
		{
			dispatchEvent(new AvatarEditorInternalEvent(AvatarEditorInternalEvent.LOAD_PROGRESS, new Point(event.bytesLoaded, event.bytesTotal)));
		}
		
		protected function onResourceLoaderError(event:ErrorEvent):void
		{
			dispatchEvent(new AvatarEditorInternalEvent(AvatarEditorInternalEvent.LOAD_ERROR, event.text));
		}
		
		protected function onResourceLoaderComplete(event:Event):void
		{
			dispatchEvent(new AvatarEditorInternalEvent(AvatarEditorInternalEvent.LOAD_COMPLETE));
		}
		
		public function getAccessoryPathById(id:Number, accessoryType:String = null):String
		{
			// Binary search on assets
			var item:AvatarItemVO= getAccessoryById(id);
			var ret:String= "";
			
			if(item){
				if(item.accessoryType == AccessoryType.COSTUME_ACCESSORY){
					if(accessoryType == AccessoryType.HEAD_ACCESSORY){
						ret= item.headPath;
					} else 
					if(accessoryType == AccessoryType.BODY_ACCESSORY){
						ret= item.bodyPath;
					} else {
						ret= item.path;
					}
				} else {
					ret= item.path;
				}
			}
			
			return ret;
		}
		
		public function getAnyAccessoryById(id:Number):AvatarItemVO
		{
			return getAccessoryById(id);
		}
		
		public function getAccessoryById(id:Number):AvatarItemVO
		{
			var index:Number= binarySearch(_assets, id, 0, _assets.length);
			var ret:AvatarItemVO= (index >= 0) ? (_assets[index] as AvatarItemVO) : null;
			return ret;
		}
		
		private function getLatestGoodSkinColor():Number
		{
			var len:int= _history.length;
			var ret:Number;
			
			for(var i:int= (len-1); i >= 0; i--){
				var curr:AvatarVO= _history[i];
				if(isFixedSkin(curr.skinColor)) continue;
				ret= curr.skinColor;
				break;
			}
			
			if(!ret) ret= 0xFFFFFF;
			
			return ret;
		}
		
		private function isFixedSkin(skinColor:Number):Boolean
		{
			var ret:Boolean= false;
			
			for each(var fs:FixedSkinVO in _fixedSkinMap){
				if(fs.fixedSkin == skinColor){
					ret= true;
					break;
				}
			}
			
			return ret;
		}
		
		private function onlyNewAccessories(item:*, index:int, array:Array):Boolean
		{
			var ret:Boolean= false;
			
			var itemPrefix:String= (item as AvatarItemVO).path.substr(0, 4).toLowerCase();
			if(itemPrefix == "new."){
				ret= true;
			}
			
			return ret;
		}
		
		private function areEqual(avatar1:AvatarVO, avatar2:AvatarVO):Boolean
		{
			var ret:Boolean= true;
			
			if(avatar1.body != avatar2.body) ret= false;
			if(avatar1.bodyColor != avatar2.bodyColor) ret= false;
			if(avatar1.costume != avatar2.costume) ret= false;
			if(avatar1.eye != avatar2.eye) ret= false;
			if(avatar1.head != avatar2.head) ret= false;
			if(avatar1.headColor != avatar2.headColor) ret= false;
			if(avatar1.mouth != avatar2.mouth) ret= false;
			if(avatar1.skinColor != avatar2.skinColor) ret= false;
			
			return ret;
		}
		
		private function binarySearch(array:Array, value:Number, left:int, right:int):Number
		{
			if(left > right)
				return -1;
			var middle:int = (left + right) / 2;
			var item:AvatarItemVO= array[middle] as AvatarItemVO;
			if(!item) return -1;
			if(item.id == value)
				return middle;
			else if(item.id > value)
				return binarySearch(array, value, left, middle - 1);
			else
				return binarySearch(array, value, middle + 1, right);
		}
		
		public function getAvatarDisplayBitmapData(avatarDisplay:AvatarDisplay, width:uint, height:uint, align:uint):BitmapData
		{
			var bitmapData:BitmapData = new BitmapData(width, height, true, 0);
			var matrix:Matrix = new Matrix();
			var dx:Number = 0;
			var dy:Number = 0;
			
			var avatarDisplayWidth:Number = avatarDisplay.width;
			var avatarDisplayHeight:Number = avatarDisplay.height;
			var avatarFilters:Array= avatarDisplay.filters;
			
			avatarDisplay.filters= [];
			switch(align){
				case AlignTypes.TOP_CENTER:
				dx = (width-avatarDisplayWidth)/2;
				//dy = 0;
				break;
				case AlignTypes.TOP_RIGHT:
				dx = width-avatarDisplayWidth;
				//dy = 0;				
				break;
				case AlignTypes.MIDDLE_LEFT:
				//dx = 0;
				dy = (height-avatarDisplayHeight)/2;
				break;
				case AlignTypes.MIDDLE_CENTER:
				dx = (width-avatarDisplayWidth)/2;
				dy = (height-avatarDisplayHeight)/2;
				break;
				case AlignTypes.MIDDLE_RIGHT:
				dx = width-avatarDisplayWidth;
				dy = (height-avatarDisplayHeight)/2;
				break;
				case AlignTypes.BOTTOM_LEFT:
				//dx = 0;
				dy = height-avatarDisplayHeight;
				break;
				case AlignTypes.BOTTOM_CENTER:
				dx = (width-avatarDisplayWidth)/2;
				dy = height-avatarDisplayHeight;
				dy-= 2;
				break;
				case AlignTypes.BOTTOM_RIGHT:
				dx = width-avatarDisplayWidth;
				dy = height-avatarDisplayHeight;
				break;
			}
			
			matrix.translate(dx, dy);
			
			bitmapData.draw(DisplayObject(avatarDisplay), matrix);
			
			avatarDisplay.filters= avatarFilters;
			
			return bitmapData;
		}
		
		public function destroy():void
		{
			// TODO: limpiar
			if(_resourceLoader && _resourceLoader.hasEventListener(Event.COMPLETE)) _resourceLoader.removeEventListener(Event.COMPLETE, onResourceLoaderComplete);
			if(_resourceLoader && _resourceLoader.hasEventListener(ErrorEvent.ERROR)) _resourceLoader.removeEventListener(ErrorEvent.ERROR, onResourceLoaderError);
			if(_resourceLoader && _resourceLoader.hasEventListener(ProgressEvent.PROGRESS)) _resourceLoader.removeEventListener(ProgressEvent.PROGRESS, onResourceLoaderProgress);
			
			dispatcher= null;
			_replaceTokens= null;
			_assets= null;
			_activeArea= "";
			_showCredits= false;
			_showShare= false;
			_backgroundPath= null;
			if(_resourceLoader)
				_resourceLoader.destroy();
			_resourceLoader= null;
			_creditsSpent= 0;
			_itemsBought= new Vector.<AvatarItemVO>();
			_itemsBought= null;
			_avatar= null;
			_history= new Vector.<AvatarVO>();
			_history= null;
			_randomMode= false;
			_featureData= null;
			_features= new Vector.<FeatureDataVO>();
			_features= null;
			_emotionsMap= new Array();
			_emotionsMap= null;
			_fixedSkinMap= new Array();
			_fixedSkinMap= null;
			
			_instance= null;
		}
	}
}