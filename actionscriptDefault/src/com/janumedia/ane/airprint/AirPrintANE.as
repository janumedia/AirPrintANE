package com.janumedia.ane.airprint
{
	import flash.display.BitmapData;
	import flash.events.EventDispatcher;
	import flash.events.StatusEvent;
	
	public class AirPrintANE extends EventDispatcher
	{
		private static const EXTENSION_ID:String = "com.janumedia.ane.AirPrintANE";
		
		
		public function AirPrintANE ()
		{
		}
		
		public static function get isSupported():Boolean{
			return false;
		}
		
		private function onStatus(e:StatusEvent):void 
		{
		}
		
		public function printBitmapData (bitmapData:BitmapData) : void
		{
		}
	}
}