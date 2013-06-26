#import <Cocoa/Cocoa.h>
#import <AppKit/AppKit.h>


@interface CI_InfosTachesCelluleInfo : NSCell
{
    @private

    NSView *subview;
}

- (void) addSubview:(NSView *) view;

@end
