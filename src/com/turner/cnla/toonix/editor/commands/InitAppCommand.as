package com.turner.cnla.toonix.editor.commands
{
	import com.adobe.serialization.json.JSON;
	import com.turner.caf.business.SimpleResponder;
	import com.turner.caf.commands.ICommand;
	import com.turner.caf.control.CAFEvent;
	import com.turner.caf.util.ServiceLocatorHelper;
	import com.turner.cnla.library.AvatarItemVO;
	import com.turner.cnla.library.AvatarVO;
	import com.turner.cnla.library.CNLALibraryInvoker;
	import com.turner.cnla.toonix.editor.model.Dictionary;
	import com.turner.cnla.toonix.editor.model.Model;
	import com.turner.cnla.toonix.editor.model.Params;
	import com.turner.cnla.toonix.editor.types.AccessoryType;
	import com.turner.cnla.toonix.editor.types.SponsorType;
	import com.turner.cnla.toonix.editor.vo.FeatureAccessoryVO;
	import com.turner.cnla.toonix.editor.vo.FeatureDataVO;
	import com.turner.cnla.toonix.editor.vo.FixedSkinVO;
	import com.turner.toonix.avatardisplay.types.AvatarDisplayViewPositionType;
	
	import flash.events.Event;
	import flash.external.ExternalInterface;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.DebugUtils;
	import flash.utils.describeType;
	
	public class InitAppCommand implements ICommand
	{
		private var country:String;
		private var language:String;
		private var configPath:String;
		private var configXML:XML;
		private var dictionaryXML:XML;
		private var accessoryList:Array;
		private var model:Model;
		private var dictionary:Dictionary;
		
		public function execute(event:CAFEvent):void
		{
			model= Model.getInstance();
			dictionary= Dictionary.getInstance();
			
			var data:Object= event.data;
			
			model.lang= data.language;
			model.country= data.country;
			model.userCredits= (data.user) ? data.user.credits : 0;
			model.userId= (data.user) ? data.user.id : 0;
			model.userName= (data.user) ? data.user.name : null;
			configPath= data.configPath;
			Params.CDN_PATH= data.cdnPath;
			
			if(data.hasOwnProperty("avatar") && data.avatar){
				model.initAvatar= AvatarVO.fromObject(data.avatar);
			}
		
			getAvatarAssets();
		}
		
		private function getAvatarAssets():void
		{
			if(CNLALibraryInvoker.available){
				var cnlaInvoker:CNLALibraryInvoker= new CNLALibraryInvoker("CNLALibrary.getAvatarAccessoryList", null, onGetAvatarAssets);
				cnlaInvoker.call();
			} else {
				getDebugAvatarAssets(onGetAvatarAssets);
			}
		}
		
		private function onGetAvatarAssets(data:Object):void
		{
			var accessoryList:Array= data as Array;
			model.assets= new Array();
			for(var i:int= 0, len:int= accessoryList.length; i < len; i++){
				model.assets.push(AvatarItemVO.fromObject(accessoryList[i]));
			}
			
			model.assets.sortOn("id", Array.NUMERIC);

			getPurchases();
		}
		
		private function getPurchases():void
		{
			if(model.userId){
				if(CNLALibraryInvoker.available){
					var cnlaInvoker:CNLALibraryInvoker= new CNLALibraryInvoker("CNLALibrary.getPurchasedAvatarAccessoryListByUser", {userId: model.userId}, onGetPurchases);
					cnlaInvoker.call();
				} else {
					onGetPurchases(new Array());
				}
			} else {
				loadConfigXML();
			}
		}
		
		private function onGetPurchases(data:Object):void
		{
			var purchases:Array= data as Array;
			var accessoryList:Vector.<AvatarItemVO>= new Vector.<AvatarItemVO>();
			model.itemsBought= accessoryList;
			
			loadConfigXML();
		}
		
		private function loadConfigXML():void
		{
			var urlLoader:URLLoader= new URLLoader();
			urlLoader.addEventListener(Event.COMPLETE, onConfigComplete);
			urlLoader.load(new URLRequest(configPath));
		}
		
		protected function onConfigComplete(event:Event):void
		{
			configXML= new XML(event.target.data);
			
			loadDictionaryXML(new XML(configXML.dictionary));
		}
		
		private function loadDictionaryXML(dictionary:XML):void
		{
			var dictPath:String= "";
			for each(var path:XML in dictionary.path){
				if(path.@lang.toString().toLowerCase() == model.lang.toLowerCase()){
					dictPath= path.toString().replace("${cdnPath}", Params.CDN_PATH);
					break;
				}
			}
			
			var urlLdr:URLLoader= new URLLoader();
			urlLdr.addEventListener(Event.COMPLETE, onDictionaryComplete);
			urlLdr.load(new URLRequest(dictPath));
		}
		
		protected function onDictionaryComplete(event:Event):void
		{
			dictionaryXML= new XML(event.target.data);
			
			setup();
		}
		
		private function setup():void
		{
			setupFeature(new XML(configXML.feature));
			
			setupDictionary();

			setupDefaultAvatar(new XML(configXML.defaultAvatar));
			
			setupEmotions(new XML(configXML.emotions));
			
			setupFixedSkin(new XML(configXML.fixedSkinAssets));
			
			model.showShare= (configXML.showSharePanel.toString() == "true");

			model.showCredits= (configXML.showCreditsPanel.toString() == "true");
			
			model.backgroundPath= getRandomBackground(new XML(configXML.backgrounds)); 
			
			model.init();
		}
		
		private function setupFeature(xml:XML):void
		{
			model.featureData= new FeatureDataVO();
			
			// Get the data corresponding to the current country, or the default
			var data:XML= getFeatureDataByCountry(xml, model.country);
			
			// BEGIN -- Parse each FeatureDataVO
			for each(var item:XML in data.item){
				var vo:FeatureDataVO= new FeatureDataVO();
				
				// Acccesory list
				for each(var accessory:XML in item.accessory){
					var accessoryVO:FeatureAccessoryVO= new FeatureAccessoryVO();
					accessoryVO.id= parseInt(getIdByEnvironment(accessory.id));
					accessoryVO.type= accessory.type.toString();
					
					vo.accessories.push(accessoryVO);
				}
				
				// Sponsor data
				if(item.sponsor.text.toString().length > 0){
					vo.sponsorType= SponsorType.TEXT;
					vo.sponsorData= item.sponsor.text.toString();
				} else
				if(item.sponsor.image.toString().length > 0){
					vo.sponsorType= SponsorType.IMAGE;
					vo.sponsorData= item.sponsor.image.toString();
				} else {
					vo.sponsorType= SponsorType.NO_SPONSOR;
					vo.sponsorData= null;
				}
				
				// Preview image
				vo.previewImage= item.preview.toString().replace("${cdnPath}", Params.CDN_PATH);
				if(vo.previewImage.substr(0, 7).toLowerCase() != "http://"){
					vo.previewImage= Params.CDN_PATH + vo.previewImage;
				}
				
				model.features.push(vo);
			}
			// END
		}
		
		private function getFeatureDataByCountry(xml:XML, country:String):XML
		{
			var data:XML;
			for each(var feature:XML in xml.featureData){
				if(feature.@country.toString().length > 0){
					if(feature.@country.toString().toLowerCase() == country){
						data= feature;
						break;
					}
				} else {
					data= feature;
				}
			}
			
			return data;
		}
		
		private function setupDefaultAvatar(avatar:XML):void
		{
			model.defaultAvatarPosition= validateAvatarPosition(avatar.position.toString());

			model.defaultAvatar= new AvatarVO();
			model.defaultAvatar.body= 				parseInt(getIdByEnvironment(avatar.bodyAccessory.id));
			model.defaultAvatar.bodyColor= 			parseInt(avatar.bodyColor.toString());
			model.defaultAvatar.costume= 			parseInt(getIdByEnvironment(avatar.costumeAccessory.id));
			model.defaultAvatar.eye= 				parseInt(getIdByEnvironment(avatar.eyeAccessory.id));
			model.defaultAvatar.head= 				parseInt(getIdByEnvironment(avatar.headAccessory.id));
			model.defaultAvatar.headColor= 			parseInt(avatar.headColor.toString());
			model.defaultAvatar.imagePath= 			null;
			model.defaultAvatar.mouth= 				parseInt(getIdByEnvironment(avatar.mouthAccessory.id));
			model.defaultAvatar.skinColor= 			parseInt(avatar.skinColor.toString());
		}
		
		private function validateAvatarPosition(position:String):String
		{
			// Default value if xml validation fails
			var ret:String= AvatarDisplayViewPositionType.FRONT;
			var positions:XMLList= describeType(AvatarDisplayViewPositionType).constant;
			
			for each(var pos:XML in positions){
				if(AvatarDisplayViewPositionType[pos.@name.toString()].toLowerCase() == position.toLowerCase()){
					ret= AvatarDisplayViewPositionType[pos.@name.toString()];
					break;
				}
			}
			
			return ret;
		}
		
		private function setupDictionary():void
		{
			dictionary= parseNode(dictionaryXML);
		}
		
		private function setupEmotions(emotions:XML):void
		{
			var emotionsMap:Array= new Array();
			for each(var emotion:XML in emotions.emotion){
				var obj:Object= new Object();
				obj.id= emotion.name.toString();
				obj.path= emotion.path.toString().replace("${cdnPath}", Params.CDN_PATH);
				if(obj.path.substr(0, 7).toLowerCase() != "http://"){
					obj.path= Params.CDN_PATH + obj.path;
				}
				if(emotion.@default.toString().toLowerCase() == "true"){
					model.defaultSkeletonUrl= obj.path;
				}
				emotionsMap.push(obj);
			}
			model.emotionsMap= emotionsMap;
		}
		
		private function setupFixedSkin(fixedSkinAssets:XML):void
		{
			var fixedSkinMap:Array= new Array();
			for each(var fixedSkin:XML in fixedSkinAssets.item){
				var fs:FixedSkinVO= new FixedSkinVO();
				fs.accessoryId= parseInt(getIdByEnvironment(fixedSkin.id));
				fs.accessoryType= fixedSkin.type.toString();
				fs.fixedSkin= parseInt(fixedSkin.fixedSkin.toString());
				
				fixedSkinMap.push(fs);
			}
			model.fixedSkinMap= fixedSkinMap;
		}
		
		private function getRandomBackground(backgrounds:XML):String
		{
			var listOfBackgroundPaths:Array= new Array();
			for each(var path:XML in backgrounds.path)
				listOfBackgroundPaths.push(path.toString().replace("${cdnPath}", Params.CDN_PATH));
			
			var rndNumber:Number= Math.floor(Math.random() * listOfBackgroundPaths.length);
			
			return listOfBackgroundPaths[rndNumber];
		}
		
		private function isValidAccessory(item:*, index:int, array:Array):Boolean
		{
			/*
			var ret:Boolean= false;
			
			var itemPrefix:String= (item as AvatarItemVO).swf.name.substr(0, 4).toLowerCase();
			if((itemPrefix == "new.") || (itemPrefix == "inv.")){
				ret= true;
			}
			
			return ret;
			*/
			return true;
		}
		
		private function onFault(info:Object):void
		{
			trace("## Toonix Editor - InitAppCommand::onFault() - Error: " + info);
		}
		
		private function getIdByEnvironment(nodeList:XMLList):String
		{
			var ret:String;
			
			for each(var node:XML in nodeList){
				if(node.@env.toString().length){
					if(node.@env.toString().toLowerCase() == Params.ENVIRONMENT.toLowerCase()){
						ret= node.toString();
						break;
					}
				} else {
					ret= node.toString();
					break;
				}
			}
			
			return ret;
		}
		
		private static function parseNode(node:XML):Dictionary
		{
			var obj:Dictionary= Dictionary.getInstance();
			var children:XMLList = node.children();
			
			for each(var child:XML in children){
				if(child.hasComplexContent()){
					obj[child.name()] = parseNode(child);
				}else{
					obj[child.name()] = child.toString();
				}
			}
			
			return obj;
		}
		
		private static function parseDate(date:String):Date
		{
			if(date == "") return null;
			// Parses date in format YYYY-MM-DD HH:mm
			var fecha:String= date.split(" ")[0];
			var hora:String= date.split(" ")[1];
			
			var anio:int= parseInt(fecha.split("-")[0]);
			var mes:int= (parseInt(fecha.split("-")[1]) - 1);
			var dia:int= parseInt(fecha.split("-")[2]);
			
			var horas:int= parseInt(hora.split(":")[0]);
			var minutos:int= parseInt(hora.split(":")[1]);
			
			return new Date(anio, mes, dia, horas, minutos);
		}
		
		private function getDebugAvatarAssets(callback:Function):void
		{
			var urlLdr:URLLoader= new URLLoader();
			urlLdr.dataFormat= URLLoaderDataFormat.TEXT;
			urlLdr.addEventListener(Event.COMPLETE, function(e:Event):void{
				callback.call(this, JSON.decode(e.target.data));
			});
			urlLdr.load(new URLRequest("http://m.cartoonnetworkla.com/misc/cn30/dummyData/accessoryList.json"));
		}
	}
}