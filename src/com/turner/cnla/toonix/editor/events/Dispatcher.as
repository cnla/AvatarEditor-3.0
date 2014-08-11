package com.turner.cnla.toonix.editor.events
{
	import com.turner.caf.control.CAFEventDispatcher;
	
	/**
	 * Singleton
	 */
	public class Dispatcher extends CAFEventDispatcher
	{
		private static var _allowInstantiation:Boolean= false;
		private static var _instance:Dispatcher= null;
		
		public function Dispatcher()
		{
			super();
			
			if(!_allowInstantiation){
				throw new Error("## Toonix Editor - Dispatcher::Dispatcher() - Singleton error. Instantiation not allowed.");
			}
		}
		
		public static function getInstance():Dispatcher
		{
			if(_instance == null){
				_allowInstantiation= true;
				_instance= new Dispatcher();
				_allowInstantiation= false;
			}
			
			return _instance;
		}
		
		public override function destroy():void
		{
			super.destroy();
			_instance= null;
		}
	}
}