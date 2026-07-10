//
//  AppDelegate.m
//  Music
//
//  Created by Alin Panaitiu on 31.10.2023.
//

#import "AppDelegate.h"
#import "LaunchAtLoginController.h"
#import "MusicDecoyApplication.h"
#import <UniformTypeIdentifiers/UniformTypeIdentifiers.h>

static NSString * const kMusicDecoyDefaultsSuite = @"com.lowtechguys.MusicDecoy";
static NSString * const kMediaAppPathKey = @"mediaAppPath";

@interface AppDelegate () <NSWindowDelegate>
@property (nonatomic, strong) NSUserDefaults *defaults;
@property (nonatomic, assign) BOOL isConfiguring;
@property (nonatomic, strong) NSPanel *configPanel;
@property (nonatomic, strong) NSTextField *pathField;
@property (nonatomic, strong) NSButton *clearButton;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    LaunchAtLoginController *launchController = [[LaunchAtLoginController alloc] init];
    [launchController setLaunchAtLogin:YES];

    // Re-evaluate the policy live whenever mediaAppPath is written.
    self.defaults = [[NSUserDefaults alloc] initWithSuiteName:kMusicDecoyDefaultsSuite];
    [self.defaults addObserver:self forKeyPath:kMediaAppPathKey options:0 context:NULL];
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
    if (self.isConfiguring) {
        // Keep the config panel activatable while it is open.
        [NSApp setActivationPolicy:NSApplicationActivationPolicyAccessory];
        return;
    }

    if ([self.defaults stringForKey:kMediaAppPathKey]) {
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
        if (self.configPanel.isVisible) {
            [self refreshPathField];
        }
    });
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
    // Opening the config panel also activates us — skip the media-app launch then.
    if (self.isConfiguring) {
        return;
    }

    // LSBackgroundOnly means no launch activation, so this only fires while we're
    // Accessory, i.e. mediaAppPath is set and Play was pressed.
    [(MusicDecoyApplication *)NSApp launchConfiguredMediaApp];
}

#pragma mark - Configuration UI

// Double-click Music Decoy while it is already running (Finder / Spotlight).
- (BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag {
    [self showConfiguration];
    return NO;
}

- (void)showConfiguration {
    if (self.configPanel.isVisible) {
        [self.configPanel makeKeyAndOrderFront:nil];
        [NSApp activateIgnoringOtherApps:YES];
        return;
    }

    self.isConfiguring = YES;
    [self updateActivationPolicy];

    if (!self.configPanel) {
        [self buildConfigPanel];
    }

    [self refreshPathField];
    [self.configPanel center];
    [self.configPanel makeKeyAndOrderFront:nil];
    [NSApp activateIgnoringOtherApps:YES];
}

- (void)buildConfigPanel {
    NSRect contentRect = NSMakeRect(0, 0, 440, 148);
    NSPanel *panel = [[NSPanel alloc] initWithContentRect:contentRect
                                                styleMask:(NSWindowStyleMaskTitled
                                                           | NSWindowStyleMaskClosable)
                                                  backing:NSBackingStoreBuffered
                                                    defer:NO];
    panel.title = @"Music Decoy";
    panel.level = NSFloatingWindowLevel;
    panel.hidesOnDeactivate = NO;
    panel.releasedWhenClosed = NO;
    panel.delegate = self;

    NSView *content = panel.contentView;
    CGFloat pad = 20.0;
    CGFloat width = NSWidth(content.bounds) - pad * 2.0;

    NSTextField *title = [self labelWithString:@"Play button action"
                                         frame:NSMakeRect(pad, 108, width, 18)
                                         bold:YES];
    [content addSubview:title];

    NSTextField *subtitle = [self labelWithString:@"When ▶ Play is pressed and nothing is playing:"
                                            frame:NSMakeRect(pad, 86, width, 16)
                                             bold:NO];
    subtitle.textColor = [NSColor secondaryLabelColor];
    [content addSubview:subtitle];

    NSTextField *pathField = [[NSTextField alloc] initWithFrame:NSMakeRect(pad, 52, width, 24)];
    pathField.editable = NO;
    pathField.selectable = YES;
    pathField.bezeled = YES;
    pathField.bezelStyle = NSTextFieldRoundedBezel;
    pathField.font = [NSFont monospacedSystemFontOfSize:11 weight:NSFontWeightRegular];
    pathField.lineBreakMode = NSLineBreakByTruncatingMiddle;
    [content addSubview:pathField];
    self.pathField = pathField;

    NSButton *chooseButton = [[NSButton alloc] initWithFrame:NSMakeRect(pad, 16, 110, 28)];
    chooseButton.title = @"Choose App…";
    chooseButton.bezelStyle = NSBezelStyleRounded;
    chooseButton.target = self;
    chooseButton.action = @selector(chooseMediaApp:);
    [content addSubview:chooseButton];

    NSButton *clearButton = [[NSButton alloc] initWithFrame:NSMakeRect(pad + 118, 16, 80, 28)];
    clearButton.title = @"Clear";
    clearButton.bezelStyle = NSBezelStyleRounded;
    clearButton.target = self;
    clearButton.action = @selector(clearMediaApp:);
    [content addSubview:clearButton];
    self.clearButton = clearButton;

    NSButton *doneButton = [[NSButton alloc] initWithFrame:NSMakeRect(NSWidth(content.bounds) - pad - 80, 16, 80, 28)];
    doneButton.title = @"Done";
    doneButton.bezelStyle = NSBezelStyleRounded;
    doneButton.keyEquivalent = @"\r";
    doneButton.target = self;
    doneButton.action = @selector(closeConfiguration:);
    [content addSubview:doneButton];

    self.configPanel = panel;
}

- (NSTextField *)labelWithString:(NSString *)string frame:(NSRect)frame bold:(BOOL)bold {
    NSTextField *label = [[NSTextField alloc] initWithFrame:frame];
    label.stringValue = string;
    label.editable = NO;
    label.selectable = NO;
    label.bordered = NO;
    label.drawsBackground = NO;
    label.font = bold
        ? [NSFont boldSystemFontOfSize:13]
        : [NSFont systemFontOfSize:12];
    return label;
}

- (void)refreshPathField {
    NSString *path = [self.defaults stringForKey:kMediaAppPathKey];
    if (path.length) {
        self.pathField.stringValue = path;
        self.pathField.textColor = [NSColor labelColor];
        self.clearButton.enabled = YES;
    } else {
        self.pathField.stringValue = @"None — block Music only";
        self.pathField.textColor = [NSColor secondaryLabelColor];
        self.clearButton.enabled = NO;
    }
}

- (void)chooseMediaApp:(id)sender {
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    openPanel.canChooseFiles = YES;
    openPanel.canChooseDirectories = NO;
    openPanel.allowsMultipleSelection = NO;
    openPanel.treatsFilePackagesAsDirectories = NO;
    openPanel.allowedContentTypes = @[UTTypeApplication];
    openPanel.directoryURL = [NSURL fileURLWithPath:@"/Applications"];
    openPanel.message = @"Choose the app to open when ▶ Play is pressed";
    openPanel.prompt = @"Select";

    [openPanel beginSheetModalForWindow:self.configPanel completionHandler:^(NSModalResponse result) {
        if (result != NSModalResponseOK || openPanel.URLs.count == 0) {
            return;
        }

        NSString *path = openPanel.URLs.firstObject.path;
        [self.defaults setObject:path forKey:kMediaAppPathKey];
        [self.defaults synchronize];
        [self refreshPathField];
        [self updateActivationPolicy];
    }];
}

- (void)clearMediaApp:(id)sender {
    [self.defaults removeObjectForKey:kMediaAppPathKey];
    [self.defaults synchronize];
    [self refreshPathField];
    // Stay Accessory while the panel is open; restore real policy on close.
    [self updateActivationPolicy];
}

- (void)closeConfiguration:(id)sender {
    [self.configPanel close];
}

- (void)windowWillClose:(NSNotification *)notification {
    if (notification.object != self.configPanel) {
        return;
    }

    self.isConfiguring = NO;
    [self updateActivationPolicy];
}

@end
