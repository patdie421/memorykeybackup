#import <Cocoa/Cocoa.h>

#import "PD_Cle.h"


@interface PD_Enregistreur : NSObject
{
    id pere; // qui m'a créé
	
	NSMutableDictionary *listeDesClesMontees;
	
	NSString *notifEnregistrement;
}

@property(readwrite, retain) id pere;
@property(readwrite, retain) NSString *notifEnregistrement;
@property(readonly) NSMutableDictionary *listeDesClesMontees;

-(BOOL)enregistrer:(PD_Cle *)uneCle;
-(BOOL)desenregistrerCle:(PD_Cle *)uneCle;
-(BOOL)desenregistrer:(NSString *)pointDeMontage;

-(BOOL)CleEstEnregistree:(PD_Cle *)uneCle;
-(id)cleMonteeParPointDeMontage:(NSString *)pointDeMontage;
-(id)cleMonteeParIdCle:(NSString *)unIdCle;
#ifdef D_DEBUG
-(void)afficherClesMontees;
#endif
@end
