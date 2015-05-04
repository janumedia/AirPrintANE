//
//  AirPrintANE.m
//  AirPrintANE
//
//  Created by I Nengah Januartha on 6/21/13.
//  Copyright (c) 2013 JanuMedia.com All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FlashRuntimeExtensions.h"

FREContext * context = nil;
NSString * VERSION = @"1.1.0";
NSString * event_print_complete = @"print_complete";
NSString * event_print_error = @"print_error";
NSString * PRINT_OUT_PHOTO = @"print_out_photo";
NSString * PRINT_OUT_DOCUMENT = @"print_out_document";
NSString * PRINT_OUT_GRAYSCALE = @"print_out_grayscale";
NSString * PRINT_ORIENT_PORTRAIT = @"print_orient_portrait";
NSString * PRINT_ORIENT_LANDSCAPE = @"print_orient_landscape";

FREObject getVersion (FREContext context, void* funcData, uint32_t argc, FREObject args[])
{
    @autoreleasepool
    {
        const char *str = [VERSION UTF8String];
        
        FREObject result = nil;
        FRENewObjectFromUTF8((uint32_t)(strlen(str)+1), (const uint8_t*)str, &result);
        
        return result;
    }
}

FREObject printBitmapData (FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
    
    @autoreleasepool {
        context = ctx;
        
        uint32_t string1Length;
        const uint8_t *string1;
        uint32_t string2Length;
        const uint8_t *string2;
        uint32_t posX;
        uint32_t posY;
        FREGetObjectAsUTF8(argv[1], &string1Length, &string1);
        FREGetObjectAsUTF8(argv[2], &string2Length, &string2);
        FREGetObjectAsUint32(argv[3], &posX);
        FREGetObjectAsUint32(argv[4], &posY);
        NSString *printTypeStr = [NSString stringWithUTF8String:(char*)string1];
        NSString *printOrientStr = [NSString stringWithUTF8String:(char*)string2];
        
        FREBitmapData bitmapData;
        //BitmapData to CGImageRef from http://forums.adobe.com/message/4201451
        FREAcquireBitmapData(argv[0], &bitmapData);
        int width       = bitmapData.width;
        int height      = bitmapData.height;
        
        
        // make data provider from buffer
        CGDataProviderRef provider = CGDataProviderCreateWithData (NULL, bitmapData.bits32, (width * height * 4), NULL);
        
        // set up for CGImage creation
        int                     bitsPerComponent    = 8;
        int                     bitsPerPixel        = 32;
        int                     bytesPerRow         = 4 * width;
        CGColorSpaceRef         colorSpaceRef       = CGColorSpaceCreateDeviceRGB();
        CGBitmapInfo            bitmapInfo;
        
        if( bitmapData.hasAlpha )
        {
            if( bitmapData.isPremultiplied )
                bitmapInfo = kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst;
            else
                bitmapInfo = kCGBitmapByteOrder32Little | kCGImageAlphaFirst;
        }
        else
        {
            bitmapInfo = kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipFirst;
        }
        
        CGColorRenderingIntent  renderingIntent     = kCGRenderingIntentDefault;
        CGImageRef              imageRef            = CGImageCreate(width, height, bitsPerComponent, bitsPerPixel, bytesPerRow, colorSpaceRef, bitmapInfo, provider, NULL, NO, renderingIntent);
        UIImage *myImage = [UIImage imageWithCGImage:imageRef];
        NSData * dataRef = UIImagePNGRepresentation(myImage);
        
        
        UIPrintInteractionController *printerController = [UIPrintInteractionController sharedPrintController];
        
        UIPrintInfo *printInfo = [UIPrintInfo printInfo];
        // out put type
        if ([printTypeStr isEqualToString:PRINT_OUT_DOCUMENT])
        {
            printInfo.outputType = UIPrintInfoOutputGeneral;
        } else if ([printTypeStr isEqualToString:PRINT_OUT_GRAYSCALE])
            printInfo.outputType = UIPrintInfoOutputGrayscale;
        else
        {
            printInfo.outputType = UIPrintInfoOutputPhoto;
        }
        // orientation
        if ([printOrientStr isEqualToString:PRINT_ORIENT_LANDSCAPE])
        {
            printInfo.orientation = UIPrintInfoOrientationLandscape;
        } else
        {
            printInfo.orientation = UIPrintInfoOrientationPortrait;
        }
        
        printInfo.jobName = [NSString stringWithFormat:@"airprintANE"];
        printInfo.duplex = UIPrintInfoDuplexLongEdge;
        
        printerController.printInfo = printInfo;
        printerController.showsPageRange = YES;
        printerController.printingItem = dataRef;
        
        // dispatch to ActionScript
        void (^completionHandler)(UIPrintInteractionController *, BOOL, NSError *) = ^(UIPrintInteractionController *printController, BOOL completed, NSError *error) {
            if (!completed && error) {
                NSString *errorStr = [NSString stringWithFormat:@"Failed! due to error in domain %@ with error code %lu ", error.domain, (long)error.code];
                FREDispatchStatusEventAsync(context, (uint8_t*)[event_print_error UTF8String], (uint8_t*) (uint8_t*)[errorStr UTF8String]);
            } else
            {
                NSString *successStr = [NSString stringWithFormat:@"Success!"];
                FREDispatchStatusEventAsync(context, (uint8_t*)[event_print_complete UTF8String], (uint8_t*) (uint8_t*)[successStr UTF8String]);
            }
        };
        
        // on iPad we should manage diferently
        // http://stackoverflow.com/a/20916718
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
           
            UIViewController *rootViewController = [[[UIApplication sharedApplication] keyWindow] rootViewController];
            
            [printerController presentFromRect:CGRectMake(posX, posY, 0, 0) inView:rootViewController.view animated:YES completionHandler:completionHandler];
            
        } else
        {
            [printerController presentAnimated:YES completionHandler:completionHandler];
        }
        
        FREReleaseBitmapData(argv[0]);
        CGColorSpaceRelease(colorSpaceRef);
        CGImageRelease(imageRef);
        CGDataProviderRelease(provider);
        
        return NULL;
    }
}

void AIRPrintANEContextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx,
                                   uint32_t* numFunctionsToTest, const FRENamedFunction** functionsToSet) {
    
    *numFunctionsToTest = 2;
    FRENamedFunction* func = (FRENamedFunction*)malloc(sizeof(FRENamedFunction) * (*numFunctionsToTest));
    func[0].name = (const uint8_t*)"printBitmapData";
    func[0].functionData = NULL;
    func[0].function = &printBitmapData;
    
    func[1].name = (const uint8_t*)"getVersion";
    func[1].functionData = NULL;
    func[1].function = &getVersion;
    
    
    *functionsToSet = func;
}

void AIRPrintANEContextFinalizer(FREContext ctx) {
    return;
}

void AIRPrintANEExtInitializer(void** extDataToSet, FREContextInitializer* ctxInitializerToSet,
                               FREContextFinalizer* ctxFinalizerToSet) {
    *extDataToSet = NULL;
    *ctxInitializerToSet = &AIRPrintANEContextInitializer;
    *ctxFinalizerToSet = &AIRPrintANEContextFinalizer;
}

void AIRPrintANEExtFinalizer(void* extData) {
    return;
}

