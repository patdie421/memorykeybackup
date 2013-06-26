#import <Cocoa/Cocoa.h>

#import "CI_StatusMenu.h"


@implementation CI_StatusMenu

-(void)awakeFromNib
{
	statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength] retain];
	[statusItem setMenu:statusMenu];
//	[statusItem setTitle:@"Status"];
	[statusItem setImage:[NSImage imageNamed:@"Ukey.png"]];
	[statusItem setAlternateImage:[NSImage imageNamed:@"Ukey.png"]];
	[statusItem setHighlightMode:YES];
}

@end
