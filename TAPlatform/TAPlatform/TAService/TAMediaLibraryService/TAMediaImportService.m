//
//  TAMediaImportService.m
//  TAMediaImportService
//
//  Created by Lam Yick Hong on 29/1/15.
//  Copyright (c) 2015 Tymphany. All rights reserved.
//

#import "TAMediaImportService.h"

#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

#import "TSLibraryImport.h"

@implementation TAMediaImportService


+ (void)exportAssetAtURL:(NSURL*)assetURL outURL:(NSURL*)outURL completionBlock:(void (^)(NSError* error))completionBlock {
	   
    // we're responsible for making sure the destination url doesn't already exist
    [[NSFileManager defaultManager] removeItemAtURL:outURL error:nil];
    
    // create the import object
    TSLibraryImport* import = [[TSLibraryImport alloc] init];
    //NSTimer* timer = [NSTimer timerWithTimeInterval:0.3 target:self selector:@selector(progressTimer:) userInfo:import repeats:YES];
    //[[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    [import importAsset:assetURL toURL:outURL completionBlock:^(TSLibraryImport* import) {
        /*
         * If the export was successful (check the status and error properties of
         * the TSLibraryImport instance) you know have a local copy of the file
         * at `outURL` You can get PCM samples for processing by opening it with
         * ExtAudioFile. Yay!
         *
         * Here we're just playing it with AVPlayer
         */
        if (import.status != AVAssetExportSessionStatusCompleted) {
            // something went wrong with the import
            DDLogError(@"Error importing: %@", import.error);
            
            completionBlock(import.error);
            
            import = nil;
            return;
        }
        
        // import completed
        import = nil;
        
        completionBlock(nil);
        
    }];
}

+ (NSString*)extensionForAssetURL:(NSURL*)assetURL{
    
    return [TSLibraryImport extensionForAssetURL:assetURL];
}


+ (void)progressTimer:(NSTimer*)timer {
    TSLibraryImport* export = (TSLibraryImport*)timer.userInfo;
    switch (export.status) {
        case AVAssetExportSessionStatusExporting:
        {
            //Present the progress here if necessary
            //NSLog(@"progress: %f", export.progress);
            break;
        }
        case AVAssetExportSessionStatusCancelled:
        case AVAssetExportSessionStatusCompleted:
        case AVAssetExportSessionStatusFailed:
            [timer invalidate];
            break;
        default:
            break;
    }
}

@end
