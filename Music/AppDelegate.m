//
//  AppDelegate.m
//  Music
//
//  Created by Alin Panaitiu on 31.10.2023.
//

#import "AppDelegate.h"
#import "LaunchAtLoginController.h"

@interface AppDelegate ()
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    LaunchAtLoginController *launchController = [[LaunchAtLoginController alloc] init];
    [launchController setLaunchAtLogin:YES];
}

@end
