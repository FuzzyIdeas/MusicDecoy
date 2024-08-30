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
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSDictionary *config = [defaults objectForKey:@"appConfiguration"];
    NSString *bundleIdentifier = config[@"mediaPlayerBundleID"];
    NSString *appPath = config[@"mediaPlayerAppPath"];
    
    NSArray<NSRunningApplication *> *runningApps = [[NSWorkspace sharedWorkspace] runningApplications];
    NSRunningApplication *mediaApp = nil;
    
    for (NSRunningApplication *app in runningApps) {
        if ([app.bundleIdentifier isEqualToString:bundleIdentifier]) {
            mediaApp = app;
            break;
        }
    }
    
    mediaApp ? [mediaApp activateWithOptions:NSApplicationActivateIgnoringOtherApps]
             : [[NSWorkspace sharedWorkspace] openFile:appPath];
}


@end
