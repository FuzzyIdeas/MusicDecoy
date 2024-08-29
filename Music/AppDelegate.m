//
//  AppDelegate.m
//  Music
//
//  Created by Alin Panaitiu on 31.10.2023.
//

#import "AppDelegate.h"
#import "LaunchAtLoginController.h"
#import "MediaPlayerController.h"

@interface AppDelegate ()
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    LaunchAtLoginController *launchController = [[LaunchAtLoginController alloc] init];
    [launchController setLaunchAtLogin:YES];
}

- (void)applicationWillBecomeActive:(NSNotification *)notification {
    MediaPlayerController *mediaPlayerController = [[MediaPlayerController alloc] init];
    [mediaPlayerController launchMediaPlayer];
}

@end
