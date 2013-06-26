#import <Cocoa/Cocoa.h>

#import "CR_Tache.h"


static unsigned long compteur=0;
static NSObject *lockCompteur=nil;

@implementation CR_Tache

@synthesize idTache;
@synthesize nomTache;
@synthesize interrompreTache;
@synthesize avancement;
@synthesize traitementTerminer;
@synthesize traitementEnCours;

+(void)initialize
{
	if(!lockCompteur)
		lockCompteur=[[NSObject alloc] init];
}


-(id)init
{
	if (self = [super init])
	{
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		
		@synchronized(lockCompteur)
		{
			idTache=[[NSString alloc] initWithFormat:@"%ld",compteur++];
		}
		
		traitementEnCours=FALSE;
		traitementTerminer=FALSE;

		[pool release];
	}
	return self;
}


-(void)dealloc
{
    [nomTache release];
	[idTache release];
    
    [super dealloc];
}


-(void)executerTache:(id)unObjet
{
}


@end
