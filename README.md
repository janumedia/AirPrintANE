Air Print Native Extension for iOS
======================================

AirPrintANE version 1.1.1 enable print bitmapData using iOS Air Print.

Extension ID
---------

```
com.janumedia.ane.AirPrintANE
```

Usage
---------

```
var airPrintAne:AirPrintANE = new AirPrintANE ();
airPrinterAne.addEventListener(StatusEvent.STATUS, onAirPrintStatus);
airPrintAne.printBitmapData (bitmapData, AirPrintANE.PRINT_OUT_DOCUMENT, AirPrintANE.PRINT_ORIENT_PORTRAIT, posX, posY);

// get current version
trace("AirPrintAne version", airPrinterAne.getVersion);

function onAirPrintStatus(e:StatusEvent):void 
{
    trace(this, "onAirPrintStatus", e.code, e.level);
	switch(e.code)
    {
        case AirPrintANE.PRINT_STATUS_COMPLETE:
            //do something here
            break;
        case AirPrintANE.PRINT_STATUS_CANCELED:
            //do something here
            break;
        case AirPrintANE.PRINT_STATUS_ERROR:
            //do something here
            break;
    }
}
```

Author
---------

This ANE has been writen by [I Nengah Januartha](https://github.com/janumedia). It belongs to [JanuMedia Inc.](http://www.janumedia.com) and is distributed under the [Apache Licence, version 2.0](http://www.apache.org/licenses/LICENSE-2.0).