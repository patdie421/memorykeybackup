#import <Cocoa/Cocoa.h>

#import "CI_InfosTachesCelluleInfo.h"
#import "CI_InfosTachesCelluleInfoControleur.h"


@implementation CI_InfosTachesCelluleInfo

- (void) addSubview:(NSView *) view
{
    // Weak reference
    subview = view;
}

- (void) dealloc
{
    subview = nil;

    [super dealloc];
}


- (NSView *) view
{
    return subview;
}


- (void) drawWithFrame:(NSRect) cellFrame inView:(NSView *) controlView
{
    [super drawWithFrame: cellFrame inView: controlView];

    [[self view] setFrame: cellFrame];

    if ([[self view] superview] != controlView)
    {
		[controlView addSubview: [self view]];
    }
}

@end
