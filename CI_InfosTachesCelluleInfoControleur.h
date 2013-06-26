#import <Cocoa/Cocoa.h>
#import <AppKit/AppKit.h>


@interface CI_InfosTachesCelluleInfoControleur : NSObject
{
    IBOutlet NSView *subview;
	
    IBOutlet NSProgressIndicator *indicateurAvancement;
    IBOutlet NSButton *boutonArretTache;
	IBOutlet NSTextField *infoLigne1;
	IBOutlet NSTextField *infoLigne2;
	IBOutlet NSTextField *infoLigne3;
}

+ (id) celluleInfoControleur;

// The view displayed in the table view
- (NSView *) view;

- (IBAction) arreterTache:(id) sender;

- (void)activeIndicateurAvancement;
- (void)desactiveIndicateurAvancement;
- (void)messageLigne1:(NSString *)msg;
- (void)messageLigne2:(NSString *)msg;
- (void)messageLigne3:(NSString *)msg;
- (NSProgressIndicator *)indicateurAvancement;
- (void)boutonArretTacheSetTarget:(id)unObjet setAction:(SEL)unSelecteur;

@end
