//
//  MediaPlayerController.m
//  Music Decoy
//
//  Created by Francisco Montaldo on 29/08/2024.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import "MediaPlayerController.h"

@implementation MediaPlayerController

- (void)launchMediaPlayer {
    NSString *bundleIdentifier = @"com.colliderli.IINA";
    NSArray<NSRunningApplication *> *runningApps = [[NSWorkspace sharedWorkspace] runningApplications];
    NSRunningApplication *mediaApp = nil;
    
    for (NSRunningApplication *app in runningApps) {
        if ([app.bundleIdentifier isEqualToString:bundleIdentifier]) {
            mediaApp = app;
            break;
        }
    }
    
    if (mediaApp) {
        [mediaApp activateWithOptions:NSApplicationActivateIgnoringOtherApps];
    } else {
        NSString *appPath = @"/Applications/IINA.app";
        [[NSWorkspace sharedWorkspace] openFile:appPath withApplication:@"IINA"];
    }
}

@end

