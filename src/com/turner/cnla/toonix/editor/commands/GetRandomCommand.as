package com.turner.cnla.toonix.editor.commands
{
	import com.turner.caf.commands.ICommand;
	import com.turner.caf.control.CAFEvent;
	import com.turner.cnla.library.AvatarItemVO;
	import com.turner.cnla.library.AvatarVO;
	import com.turner.cnla.toonix.editor.model.Model;
	import com.turner.cnla.toonix.editor.model.Params;
	import com.turner.cnla.toonix.editor.types.AccessoryType;
	
	public class GetRandomCommand implements ICommand
	{
		private var model:Model;
		
		public function GetRandomCommand()
		{
			model= Model.getInstance();
		}
		
		public function execute(event:CAFEvent):void
		{
			var assets:Array= model.assets;
			
			var rndHead:Number= 		getRandomItem(assets, AccessoryType.HEAD_ACCESSORY);
			var rndEyes:Number= 		getRandomItem(assets, AccessoryType.EYES_ACCESSORY);
			var rndMouth:Number= 		getRandomItem(assets, AccessoryType.MOUTH_ACCESSORY);
			var rndBody:Number= 		getRandomItem(assets, AccessoryType.BODY_ACCESSORY);
			var rndHeadColor:Number= 	getRandomColor();
			var rndBodyColor:Number= 	getRandomColor();
			var rndSkinColor:Number= 	getRandomColor();
			
			var avatar:AvatarVO= new AvatarVO();
			avatar.body= rndBody;
			avatar.bodyColor= rndBodyColor;
			avatar.costume= 0;
			avatar.eye= rndEyes;
			avatar.head= rndHead;
			avatar.headColor= rndHeadColor;
			avatar.imagePath= null;
			avatar.mouth= rndMouth;
			avatar.skinColor= rndSkinColor;
			
			model.setRandomMode(true);
			
			model.updateToonix(avatar);
		}
		
		private function getRandomItem(itemList:Array, accessoryType:String):Number
		{
			var filteredList:Array= itemList.filter(function (item:*, index:int, array:Array):Boolean{
				return ((item as AvatarItemVO).accessoryType == accessoryType);
			});
			
			var rnd:Number;
			do{
				rnd= Math.floor(Math.random() * filteredList.length);
			} while((filteredList[rnd] as AvatarItemVO).price > 0)
				
			return (filteredList[rnd] as AvatarItemVO).id;
		}
		
		private function getRandomColor():Number
		{
			var rnd:Number= Math.floor(Math.random() * Params.COLOR_LIST.length);
			
			return Params.COLOR_LIST[rnd];
		}
	}
}