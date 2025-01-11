//
//  AppDelegate.m
//  Music
//
//  Created by Alin Panaitiu on 31.10.2023.
//

#import "AppDelegate.h"
#import "LaunchAtLoginController.h"

bool didBecomeActiveAtLeastOnce = false;

@interface AppDelegate ()
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    LaunchAtLoginController *launchController = [[LaunchAtLoginController alloc] init];
    [launchController setLaunchAtLogin:YES];
}

- (void)applicationWillBecomeActive:(NSNotification *)notification {
    if (!didBecomeActiveAtLeastOnce) {
        didBecomeActiveAtLeastOnce = true;
        return;
    }

    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"com.lowtechguys.MusicDecoy"];
    NSString *appPath = [defaults stringForKey:@"mediaAppPath"];

    // If the app path is not set, return
    // else, check if the app is running and launch it if it's not
    if (!appPath) {
        return;
    }

    NSString *bundleIdentifier = [[NSBundle bundleWithPath:appPath] bundleIdentifier];

    if (![[NSRunningApplication runningApplicationsWithBundleIdentifier:bundleIdentifier] count]) {
        [[NSWorkspace sharedWorkspace] launchApplication:appPath];
    }
}

@end
