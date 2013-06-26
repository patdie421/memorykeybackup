#import <Cocoa/Cocoa.h>


@interface CI_GetADate : NSObject
{
	IBOutlet id fenetre;
	
	IBOutlet id label_titre;
	IBOutlet id picker_graphique;
	IBOutlet id picker_texte;
	
	BOOL flag;
}

-(IBAction)bouton_annuler:(id)sender;
-(IBAction)bouton_ok:(id)sender;

- (NSDate *)modal:(id)mere titre:(NSString *)unTitre dateInitiale:(NSDate *)uneDate;

@end
