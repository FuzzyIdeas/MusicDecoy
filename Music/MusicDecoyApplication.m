//
//  MusicDecoyApplication.m
//  Music Decoy
//

#import "MusicDecoyApplication.h"

typedef NS_ENUM(OSType, MusicDecoyPlayerState) {
    MusicDecoyPlayerStateStopped = 'kPSS',
};

@implementation MusicDecoyApplication

- (NSNumber *)playerState {
    return @(MusicDecoyPlayerStateStopped);
}

- (void)launchConfiguredMediaApp {
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"com.lowtechguys.MusicDecoy"];
    NSString *appPath = [defaults stringForKey:@"mediaAppPath"];
    if (!appPath) {
        return;
    }

    NSBundle *bundle = [NSBundle bundleWithPath:appPath];
    NSString *bundleIdentifier = bundle.bundleIdentifier;
    if (!bundleIdentifier) {
        [self launchApplicationAtPath:appPath];
        return;
    }

    NSArray<NSRunningApplication *> *running = [NSRunningApplication runningApplicationsWithBundleIdentifier:bundleIdentifier];
    if (running.count) {
        [running.firstObject activateWithOptions:0];
    } else {
        [self launchApplicationAtPath:appPath];
    }
}

- (void)launchApplicationAtPath:(NSString *)appPath {
    NSURL *appURL = [NSURL fileURLWithPath:appPath];
    if (@available(macOS 10.15, *)) {
        NSWorkspaceOpenConfiguration *configuration = [NSWorkspaceOpenConfiguration configuration];
        configuration.activates = YES;
        [[NSWorkspace sharedWorkspace] openApplicationAtURL:appURL
                                              configuration:configuration
                                          completionHandler:nil];
    } else {
        [[NSWorkspace sharedWorkspace] launchApplication:appPath];
    }
}

- (void)pause:(NSScriptCommand *)command {
}

- (void)playpause:(NSScriptCommand *)command {
    [self launchConfiguredMediaApp];
}

- (void)handlePlayPauseAppleEvent:(NSAppleEventDescriptor *)event
                   withReplyEvent:(NSAppleEventDescriptor *)replyEvent {
    [self launchConfiguredMediaApp];
}

- (void)resume:(NSScriptCommand *)command {
}

- (void)stop:(NSScriptCommand *)command {
}

@end
