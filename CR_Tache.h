#import <Cocoa/Cocoa.h>


@interface CR_Tache : NSObject
{
	NSString *idTache;
    NSString *nomTache;

	float avancement;

    BOOL interrompreTache;
	BOOL traitementEnCours;
	BOOL traitementTerminer;
}

@property(readonly, retain) NSString *idTache;
@property(readwrite, retain) NSString *nomTache;
@property(readwrite) BOOL interrompreTache;
@property(readwrite) BOOL traitementEnCours;
@property(readwrite) BOOL traitementTerminer;
@property(readwrite) float avancement;

-(void)executerTache:(id)unObjet;

@end
