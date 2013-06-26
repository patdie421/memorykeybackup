#import <Cocoa/Cocoa.h>

#import "PD_TacheSauvegarde.h"
#import "PD_TraitementDesTaches.h"


@implementation PD_TraitementDesTaches

@synthesize pere;


- (id)init
{
	if (self = [super init])
	{
	}
	return self;
}


- (void)dealloc
{
	[pere release];
    
	[super dealloc];
}


-(void)supprimerCleDeLaFileDeSauvegardes:(PD_Cle *)uneCle
{
 NSConditionLock *verrou;
 int i;
    
	[uneCle retain];
	
    verrou=[fileDEntree verrou];
    [verrou retain];
    
    [verrou lock];
    
    for(i=[fileDEntree nbElem]-1;i>=0;i--)
    {
        if(uneCle == [[fileDEntree elemALaPosition:i] cle])
        {
            [fileDEntree supprimerElemALaPosition:i];
			break;
        }
    }
    
    if([fileDEntree nbElem]>0)
        [verrou unlockWithCondition:NON_VIDE];
    else
        [verrou unlockWithCondition:EST_VIDE];
    
    [verrou release];
	
	[uneCle release];
}


-(void)arreterTachesPourCle:(PD_Cle *)uneCle
{
 id elem;

	[uneCle retain];
	
    NSEnumerator *e = [tachesEnCoursDExecution objectEnumerator];

    while(elem=[e nextObject])
    {
        if([elem cle] == uneCle)
        {
            [elem setInterrompreTache:YES];
			break;
        }
    }
	
	[uneCle release];
}

@end
