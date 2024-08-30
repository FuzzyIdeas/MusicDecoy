//
//  OpenPanelAccessoryView.m
//  Music Decoy
//
//  Created by Francisco Montaldo on 29/08/2024.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

@interface OpenPanelAccessoryView : NSView
@end

@implementation OpenPanelAccessoryView

- (instancetype)initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:frameRect];
    if (self) {
        NSImageView *iconView = [[NSImageView alloc] initWithFrame:NSMakeRect(0, (frameRect.size.height - 45) / 2,
                                                                              45, 45)];
        NSImage *appIcon = [NSImage imageNamed:@"AppIcon"];
        [iconView setImage:appIcon];
        [iconView setAutoresizingMask:NSViewMinXMargin | NSViewMaxYMargin];
        [self addSubview:iconView];

        NSTextField *infoLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(55, (frameRect.size.height - 65) / 2,
                                                                               frameRect.size.width - 70, frameRect.size.height)];
        [infoLabel setStringValue:@"Please choose your default media player. Music Decoy will use this player when there's no other media playing."];
        [infoLabel setBezeled:NO];
        [infoLabel setDrawsBackground:NO];
        [infoLabel setEditable:NO];
        [infoLabel setSelectable:NO];
        [infoLabel setFont:[NSFont systemFontOfSize:12]];
        [infoLabel setAlignment:NSTextAlignmentLeft];
        [infoLabel setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
        [self addSubview:infoLabel];
    }
    return self;
}

@end

