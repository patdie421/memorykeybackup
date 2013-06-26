#import <Cocoa/Cocoa.h>


@interface CI_StatusMenu : NSObject
{
    IBOutlet NSMenu *statusMenu;

    NSStatusItem * statusItem;
}

@end