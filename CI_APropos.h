#import <Cocoa/Cocoa.h>


@interface CI_APropos : NSObject
{
    IBOutlet id fenetre;
	IBOutlet id version;
	IBOutlet id texte;
}

- (void)afficher;

@end
