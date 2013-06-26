#import <Cocoa/Cocoa.h>

#import "PD_Dispatcheur.h"


@implementation PD_Dispatcheur

@synthesize pere, enregistreur, planificateur;


-(id)init
{
	if (self = [super init])
	{
	}
    return self;
}


-(void)dealloc
{
    [planificateur release];
    [enregistreur release]; 
    [pere release];
    
    [super dealloc];
}

@end
