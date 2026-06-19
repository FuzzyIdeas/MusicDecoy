//
//  AppDelegate.m
//  Music
//
//  Created by Alin Panaitiu on 31.10.2023.
//

#import "AppDelegate.h"
#import "LaunchAtLoginController.h"
#import "MusicDecoyApplication.h"

@interface AppDelegate ()
@property (nonatomic, strong) NSUserDefaults *defaults;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    LaunchAtLoginController *launchController = [[LaunchAtLoginController alloc] init];
    [launchController setLaunchAtLogin:YES];

    // Re-evaluate the policy live whenever mediaAppPath is written.
    self.defaults = [[NSUserDefaults alloc] initWithSuiteName:@"com.lowtechguys.MusicDecoy"];
    [self.defaults addObserver:self forKeyPath:@"mediaAppPath" options:0 context:NULL];
    [self updateActivationPolicy];

    [[NSAppleEventManager sharedAppleEventManager] setEventHandler:NSApp
                                                      andSelector:@selector(handlePlayPauseAppleEvent:withReplyEvent:)
                                                    forEventClass:'hook'
                                                       andEventID:'PlPs'];
    [[NSAppleEventManager sharedAppleEventManager] setEventHandler:NSApp
                                                      andSelector:@selector(handlePlayPauseAppleEvent:withReplyEvent:)
                                                    forEventClass:'hook'
                                                       andEventID:'Play'];
}

- (void)updateActivationPolicy {
    if ([self.defaults stringForKey:@"mediaAppPath"]) {
        // Stay activatable so the Play press reaches us as the launch trigger.
        [NSApp setActivationPolicy:NSApplicationActivationPolicyAccessory];
    } else {
        // Forbid activation: Play can't pull us forward, so no focus is stolen.
        [NSApp setActivationPolicy:NSApplicationActivationPolicyProhibited];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateActivationPolicy];
    });
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
    // LSBackgroundOnly means no launch activation, so this only fires while we're
    // Accessory, i.e. mediaAppPath is set and Play was pressed.
    [(MusicDecoyApplication *)NSApp launchConfiguredMediaApp];
}

@end
