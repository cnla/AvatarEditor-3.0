package com.turner.cnla.toonix.editor.model
{
	/**
	 * Singleton
	 */
	public dynamic class Dictionary
	{
		private static var _instance:Dictionary= null;
		
		public function Dictionary(d_key:D_Key)
		{
			if(!d_key){
				throw new Error("## Toonix Editor - Dictionary::Dictionary() - Singleton error. Use getInstance() method");
			}
		}
		
		public static function getInstance():Dictionary
		{
			if(!_instance){
				_instance= new Dictionary(new D_Key());
			}
			
			return _instance;
		}
		
		public function destroy():void
		{
			_instance= null;
		}
	}
}

internal class D_Key
{
	public function D_Key()
	{
		
	}
}