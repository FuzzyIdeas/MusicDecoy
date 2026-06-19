//
//  MusicDecoyApplication.h
//  Music Decoy
//

#import <Cocoa/Cocoa.h>

@interface MusicDecoyApplication : NSApplication

- (void)launchConfiguredMediaApp;
- (void)handlePlayPauseAppleEvent:(NSAppleEventDescriptor *)event
                   withReplyEvent:(NSAppleEventDescriptor *)replyEvent;

@end
