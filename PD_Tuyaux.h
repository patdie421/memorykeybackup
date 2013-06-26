#import <Cocoa/Cocoa.h>

#import "CR_File.h"


@interface PD_Tuyaux : NSObject
{
	// liste des clés à sauvegarder
    NSMutableArray *listeDesClesPlanifiees;
    NSLock *verrouSurListeDesClesPlanifiees;
	
    NSMutableArray *listeDesTachesEnCours;
    NSLock *verrouSurListeDesTachesEnCours;
	
    CR_File *fileDesTachesEnAttente;
}

@property(readwrite, retain) CR_File *fileDesTachesEnAttente;

@property(readwrite, retain) NSMutableArray *listeDesTachesEnCours;
@property(readwrite, retain) NSLock *verrouSurListeDesTachesEnCours;

@property(readwrite, retain) NSMutableArray *listeDesClesPlanifiees;
@property(readwrite, retain) NSLock *verrouSurListeDesClesPlanifiees;

- (BOOL)tryLockAll;
- (void)unlockAll;

- (int)count;
-(id)objectAtIndex:(int)index;

@end
