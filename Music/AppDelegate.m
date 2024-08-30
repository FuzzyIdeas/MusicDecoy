//
//  AppDelegate.m
//  Music
//
//  Created by Francisco Montaldo on 29.08.2024.
//

#import "AppDelegate.h"
#import "LaunchAtLoginController.h"
#import "MediaPlayerController.h"
#import "ConfigurationController.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    LaunchAtLoginController *launchController = [[LaunchAtLoginController alloc] init];
    [launchController setLaunchAtLogin:YES];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *config = [defaults objectForKey:@"appConfiguration"];
    if (!config) {
        ConfigurationController *configurationController = [[ConfigurationController alloc] init];
        [configurationController openConfigWindow];
    }
}

- (void)applicationWillBecomeActive:(NSNotification *)notification {
    MediaPlayerController *mediaPlayerController = [[MediaPlayerController alloc] init];
    [mediaPlayerController launchMediaPlayer];
}

@end
