#import <Cocoa/Cocoa.h>

#import "PD_Cle.h"


@interface PD_Planificateur : NSObject
{
    id pere; // qui m'a créé
	
    NSMutableArray *listeDesClesPlanifiees;
    NSLock *verrouSurListeDesClesPlanifiees;

	NSString *notifClePlanifiee;
	NSString *notifCleDeplanifiee;
}

@property(readwrite, retain) id pere;
@property(readwrite, retain) NSString *notifClePlanifiee;
@property(readwrite, retain) NSString *notifCleDeplanifiee;
@property(readwrite, retain) NSMutableArray *listeDesClesPlanifiees;
@property(readwrite, retain) NSLock *verrouSurListeDesClesPlanifiees;

-(void)supprimerToutesLesNotifications;

-(BOOL)planifier:(PD_Cle *)uneCle;
-(BOOL)planifier:(PD_Cle *)uneCle aLaDate:(NSDate *)uneDate aReplanifier:(BOOL)unEtat;

-(BOOL)replanifier:(PD_Cle *)uneCle;

-(BOOL)deplanifier:(NSString *)pointDeMontage;
-(BOOL)deplanifierCle:(PD_Cle *)uneCle;

@end
