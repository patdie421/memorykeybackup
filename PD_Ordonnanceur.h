#import <Cocoa/Cocoa.h>

#import "PD_TraitementDesTaches.h"


@interface PD_Ordonnanceur : NSObject
{
    id pere; // qui m'a créé
    PD_TraitementDesTaches *fileDeSauvegardes;

    NSTimer *timer;
	
	NSString *notifDemarrageSauvegarde;
}

@property(readwrite, retain) id pere;
@property(readwrite, retain) PD_TraitementDesTaches *fileDeSauvegardes;
@property(readwrite, retain) NSString *notifDemarrageSauvegarde;

- (void)demarrer;
- (void)arreter;
- (void)reveiller;
- (void)supprimerToutesLesNotifications;

@end
