//
//  ConfigurationController.m
//  Music Decoy
//
//  Created by Francisco Montaldo on 29/08/2024.
//

#import <Foundation/Foundation.h>
#import "ConfigurationController.h"
#import "OpenPanelAccessoryView.h"
#import "LaunchAtLoginController.h"

@implementation ConfigurationController {
    NSString *bundleID;
    NSString *appPath;
}

- (void)openConfigWindow {
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    OpenPanelAccessoryView *accessoryView = [[OpenPanelAccessoryView alloc] initWithFrame:NSMakeRect(0, 0, 400, 50)];
    [openPanel setAccessoryView:accessoryView];
    [openPanel setMessage:@"Please select your preferred media player application."];
    [openPanel setCanChooseFiles:YES];
    [openPanel setCanChooseDirectories:NO];
    [openPanel setCanCreateDirectories:NO];
    [openPanel setAllowsMultipleSelection:NO];
    [openPanel setCanSelectHiddenExtension:YES];
    [openPanel setAllowedFileTypes:@[@"app"]];
    
    [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
    
    [openPanel beginWithCompletionHandler:^(NSModalResponse result) {
        NSURL *selectedFileURL = (result == NSModalResponseOK) ? [[openPanel URLs] firstObject] : nil;
        if (selectedFileURL) {
            [self saveConfiguration:selectedFileURL.path];
        } else {
            [self cancelConfiguration];
        }
    }];
}

- (void)saveConfiguration:(NSString *)selectedPath {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    appPath = selectedPath;
    NSBundle *selectedAppBundle = [NSBundle bundleWithPath:appPath];
    bundleID = [selectedAppBundle bundleIdentifier];
    
    if (bundleID.length > 0 && appPath.length > 0) {
        NSDictionary *config = @{
            @"mediaPlayerBundleID": bundleID,
            @"mediaPlayerAppPath": appPath
        };
        [defaults setObject:config forKey:@"appConfiguration"];
        [defaults synchronize];
        LaunchAtLoginController *launchController = [[LaunchAtLoginController alloc] init];
        [launchController setLaunchAtLogin:YES];
    } else {
        [self cancelConfiguration];
    }
}

- (void)cancelConfiguration {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"appConfiguration"];
    [defaults synchronize];
    [NSApp terminate:nil];
}

@end
