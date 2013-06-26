#import <Cocoa/Cocoa.h>

#import "PD_Tuyaux.h"


@implementation PD_Tuyaux

@synthesize fileDesTachesEnAttente;
@synthesize listeDesTachesEnCours;
@synthesize listeDesClesPlanifiees;
@synthesize verrouSurListeDesTachesEnCours;
@synthesize verrouSurListeDesClesPlanifiees;


-(id)init
{
	if (self = [super init])
	{
	}
    return self;
}


- (void)dealloc
{
    [fileDesTachesEnAttente release];	
    [verrouSurListeDesTachesEnCours release];
    [listeDesTachesEnCours release];
    [verrouSurListeDesClesPlanifiees release];
    [listeDesClesPlanifiees release];
	
	[super dealloc];
}


- (BOOL)tryLockAll
{
	BOOL tousLesLocks=NO;
	
	if([verrouSurListeDesClesPlanifiees tryLock])
	{
		if([[fileDesTachesEnAttente verrou] tryLock])
		{
			if([verrouSurListeDesTachesEnCours tryLock])
				tousLesLocks=YES;
			else
			{
				[verrouSurListeDesClesPlanifiees unlock];
				[[fileDesTachesEnAttente verrou] unlock];
			}
		}
		else
			[verrouSurListeDesClesPlanifiees unlock];
	}
	
	return tousLesLocks;
}


- (void)unlockAll
{
	[verrouSurListeDesClesPlanifiees unlock];
	[[fileDesTachesEnAttente verrou] unlock];
	[verrouSurListeDesTachesEnCours unlock];
}


- (int)count
{
 int nb = [listeDesClesPlanifiees count ] +
		  [fileDesTachesEnAttente nbElem] +
		  [listeDesTachesEnCours count ];

	return nb;
}


-(id)objectAtIndex:(int)index
{
 int n1,n2;

	n1=[listeDesTachesEnCours count];
	if(index<n1)
		return([listeDesTachesEnCours objectAtIndex:index]);

	n2=[fileDesTachesEnAttente nbElem];
	if (index<(n1+n2))
		return([fileDesTachesEnAttente elemALaPosition:(index-n1)]);
	
	if(index<(n1+n2+[listeDesClesPlanifiees count]))
		return ([listeDesClesPlanifiees objectAtIndex:(index-n1-n2)]);
	
	return nil;
}

@end
