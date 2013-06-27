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
NSString * event_print_complete = @"print_complete";
NSString * event_print_error = @"print_error";

FREObject printBitmapData (FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
    
    context = ctx;
    
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
    printInfo.outputType = UIPrintInfoOutputPhoto;
    printInfo.jobName = [NSString stringWithFormat:@""];
    printInfo.duplex = UIPrintInfoDuplexLongEdge;
    
    printerController.printInfo = printInfo;
    printerController.showsPageRange = YES;
    printerController.printingItem = dataRef;
    
    // dispatch to ActionScript
    void (^completionHandler)(UIPrintInteractionController *, BOOL, NSError *) = ^(UIPrintInteractionController *printController, BOOL completed, NSError *error) {
        if (!completed && error) {
            NSString *errorStr = [NSString stringWithFormat:@"Failed! due to error in domain %@ with error code %u ", error.domain, error.code];
            FREDispatchStatusEventAsync(context, (uint8_t*)[event_print_error UTF8String], (uint8_t*) (uint8_t*)[errorStr UTF8String]);
        } else
        {
            NSString *successStr = [NSString stringWithFormat:@"Success!"];
            FREDispatchStatusEventAsync(context, (uint8_t*)[event_print_complete UTF8String], (uint8_t*) (uint8_t*)[successStr UTF8String]);
        }
    };
    
    [printerController presentAnimated:YES completionHandler:completionHandler];
    
    FREReleaseBitmapData(argv[0]);
    CGColorSpaceRelease(colorSpaceRef);
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    
    return NULL;
}

void AIRPrintANEContextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx,
                                   uint32_t* numFunctionsToTest, const FRENamedFunction** functionsToSet) {
    
    *numFunctionsToTest = 1;
    FRENamedFunction* func = (FRENamedFunction*)malloc(sizeof(FRENamedFunction) * 1);
    func[0].name = (const uint8_t*)"printBitmapData";
    func[0].functionData = NULL;
    func[0].function = &printBitmapData;
    
    
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

