#import <Cocoa/Cocoa.h>

#import "CR_file.h"


@implementation CR_File

- (id)init
{
	if (self = [super init])
	{
		laFile = [[NSMutableArray alloc] init];
		verrou = [[NSConditionLock alloc] initWithCondition:EST_VIDE];
	}
	return self;
}


- (void)dealloc
{
	[laFile release];
	[verrou release];
    
	[super dealloc];
}


- (NSConditionLock *)verrou
{
    return verrou;
}


- (int)nbElem
{
    return [laFile count];
}


- (id)elemALaPosition:(int)unePosition
{
    return [laFile objectAtIndex:unePosition];
}


-(void)supprimerElemALaPosition:(int)unePosition
{
    [laFile removeObjectAtIndex:unePosition];
}


- (void)inWithLock:(id)element
{
    [element retain];
    
	[verrou lock]; 

    [laFile addObject:element];

    [verrou unlockWithCondition:NON_VIDE]; 
    
    [element release];
}


- (id)outWithLock
{
 id elem;
 char etatVerrou;
 
	[verrou lockWhenCondition:NON_VIDE]; 

    elem=[laFile objectAtIndex:0];
	[elem retain];
	
	[laFile removeObjectAtIndex:0];
	
	if([laFile count]>0)
		etatVerrou=NON_VIDE;
	else
		etatVerrou=EST_VIDE;

    [elem autorelease];
	
    [verrou unlockWithCondition:etatVerrou];

	return elem;
}


- (id)outWithLockAndTimeOut:(NSInteger)timeOut;
{
 id elem;
 char etatVerrou;
 BOOL retour;
	
	retour=[verrou lockWhenCondition:NON_VIDE beforeDate:[NSDate dateWithTimeIntervalSinceNow:timeOut]];
    if(retour)
    {
        elem=[laFile objectAtIndex:0];
        [elem retain];
	
        [laFile removeObjectAtIndex:0];
	
        if([laFile count]>0)
            etatVerrou=NON_VIDE;
        else
            etatVerrou=EST_VIDE;
    
        [elem autorelease];
	
        [verrou unlockWithCondition:etatVerrou];

        return elem;
    }
    else
	{
        return nil;
	}
}


@end