package com.turner.cnla.toonix.editor.commands
{
	import com.turner.caf.commands.ICommand;
	import com.turner.caf.control.CAFEvent;
	import com.turner.cnla.library.AvatarItemVO;
	import com.turner.cnla.toonix.editor.model.Model;
	import com.turner.cnla.toonix.editor.model.Params;
	import com.turner.cnla.toonix.editor.types.AccessoryType;
	
	import flash.utils.DebugUtils;
	
	public class LoadAssetsCommand implements ICommand
	{
		private var model:Model;
		
		public function LoadAssetsCommand()
		{
			model= Model.getInstance();
		}
		
		public function execute(event:CAFEvent):void
		{
			var urlList:Array= new Array();
			var assets:Array= model.assets;
			var assetsList:Array= new Array();
			assetsList= assetsList.concat(assets.disguiseList, assets.eyesAccessoryList, assets.headAccessoryList, assets.mouthAccessoryList, assets.textureList);
			
			for each(var item:AvatarItemVO in assetsList){
				if(item.accessoryType == AccessoryType.COSTUME_ACCESSORY){
					/*
					urlList.push({id: item.id, path: (Params.CDN_PATH + item.headPath)});
					urlList.push({id: item.id, path: (Params.CDN_PATH + item.bodyPath)});
					*/
					urlList.push({id: item.id, path: item.headPath});
					urlList.push({id: item.id, path: item.bodyPath});
				} else {
					/*
					urlList.push({id: item.id, path: (Params.CDN_PATH + item.path)});
					*/
					urlList.push({id: item.id, path: item.path});
				}
			}
			
			model.loadResources(urlList);
		}
	}
}