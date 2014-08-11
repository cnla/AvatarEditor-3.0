package com.turner.cnla.toonix.editor.vo
{
	public class FeatureAccessoryVO
	{
		public var id:int;
		public var type:String;
		
		public function clone():FeatureAccessoryVO
		{
			if(this==null) return null;
			var ret:FeatureAccessoryVO= new FeatureAccessoryVO();
			ret.id= this.id;
			ret.type= this.type;
			
			return ret;
		}
	}
}