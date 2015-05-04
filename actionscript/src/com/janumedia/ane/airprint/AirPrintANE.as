package com.janumedia.ane.airprint
{
	import flash.display.BitmapData;
	import flash.events.EventDispatcher;
	import flash.events.StatusEvent;
	import flash.external.ExtensionContext;
	import flash.system.Capabilities;
	
	public class AirPrintANE extends EventDispatcher
	{
		public static const PRINT_OUT_PHOTO:String = "print_out_photo";
		public static const PRINT_OUT_DOCUMENT:String = "print_out_document";
		public static const PRINT_OUT_GRAYSCALE:String = "print_out_grayscale";
		public static const PRINT_ORIENT_PORTRAIT:String = "print_orient_portrait";
		public static const PRINT_ORIENT_LANDSCAPE:String = "print_orient_landscape";
		
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
		
		public final function isSupported () : Boolean
		{
			// only support iOS device
			return (Capabilities.manufacturer.indexOf("iOS") > -1);
		}
		
		public final function getVersion () : String
		{
			var str:String = "";
			
			if (context)
			{
				str = String (context.call("getVersion"));
			}
			
			return str;
		}
		
		/**
		 * pritBitmapData
		 * @param	bitmapData
		 * @param	outputType
		 * @param	orient
		 * @param	posX : iPad only
		 * @param	posY : iPad only
		 */
		public function printBitmapData (bitmapData:BitmapData, outputType:String=PRINT_OUT_DOCUMENT, orient:String=PRINT_ORIENT_PORTRAIT, posX:uint=10, posY:uint=10) : void
		{
			context.call ("printBitmapData", bitmapData, outputType, orient, posX, posY);
		}
	}
}