package com.turner.cnla.toonix.editor.vo
{
	import com.turner.caf.vo.ICloneable;
	
	public class FeatureDataVO implements ICloneable
	{
		public var accessoryType:String;
		public var accessoryId:Number;
		public var accessories:Vector.<FeatureAccessoryVO>;
		public var sponsorType:String;
		public var sponsorData:String;
		public var previewImage:String;
		
		public function FeatureDataVO()
		{
			accessories= new Vector.<FeatureAccessoryVO>();
		}
		
		public function clone():Object
		{
			if(this==null) return null;
			
			var ret:FeatureDataVO= new FeatureDataVO();
			ret.accessoryId= this.accessoryId;
			ret.accessoryType= this.accessoryType;
			ret.accessories= new Vector.<FeatureAccessoryVO>();
			for each(var acc:FeatureAccessoryVO in this.accessories){
				var newAcc:FeatureAccessoryVO= new FeatureAccessoryVO();
				newAcc.id= acc.id;
				newAcc.type= acc.type;
				ret.accessories.push(newAcc);
			}
			ret.sponsorData= this.sponsorData;
			ret.sponsorType= this.sponsorType;
			ret.previewImage= this.previewImage;
			
			return ret;
		}
	}
}