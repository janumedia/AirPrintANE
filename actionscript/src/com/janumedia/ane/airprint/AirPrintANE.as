package com.janumedia.ane.airprint
{
	import flash.display.BitmapData;
	import flash.events.EventDispatcher;
	import flash.events.StatusEvent;
	import flash.external.ExtensionContext;
	
	public class AirPrintANE extends EventDispatcher
	{
		private static const EXTENSION_ID:String = "com.janumedia.ane.AirPrintANE";
		
		private var context:ExtensionContext;
		
		public function AirPrintANE ()
		{
			try
			{
				context = ExtensionContext.createExtensionContext (EXTENSION_ID, null);
				context.addEventListener (StatusEvent.STATUS, onStatus);
				
			} catch (e:Error)
			{
				trace (this, e.message, e.errorID);
			}
		}

		public static function isSupported():Boolean{
			return true;
		}

		private function onStatus(e:StatusEvent):void 
		{
			if (hasEventListener (StatusEvent.STATUS))
			{
				dispatchEvent (e.clone());
			} else 
			{
				trace (e.type + " " + e.code + " " + e.level);
			}
		}
		
		public function printBitmapData (bitmapData:BitmapData) : void
		{
			context.call ("printBitmapData", bitmapData);
		}
	}
}