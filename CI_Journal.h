#import <Cocoa/Cocoa.h>


@interface CI_Journal : NSObject
{
	IBOutlet id fenetre;
	IBOutlet id texte_journal;
	
	NSDateFormatter *dateFormatter;
    
    NSLock *verrou;
}

- (IBAction)bouton_Clear:(id)sender;

- (void)informer:(NSString *)chaineALoguer;
- (void)afficher:(BOOL)flag;

@end