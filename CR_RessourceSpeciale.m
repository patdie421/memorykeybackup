#import "CR_RessourceSpeciale.h"


static NSMutableDictionary *ressources;

@implementation CR_RessourceSpeciale

+(void)initialize
{
	if(!ressources)
		ressources=[[NSMutableDictionary alloc] init];
}


-(id)init
{
	if (self = [super init])
	{
	}
	return self;
}


-(void)dealloc
{
	[super dealloc];
}


-(void)prendre:(NSString *)idRessource
{
	NSRecursiveLock *ressource;
	
	@synchronized(ressources)
	{
		ressource=[ressources objectForKey:idRessource];
		if(!ressource)
		{
			ressource=[[NSRecursiveLock alloc] init];
			[ressources setObject:ressource forKey:idRessource];
		}
		else
		{
			[ressource retain];
		}
	}
	[ressource lock];
	[ressource release];
}


-(BOOL)testEtPrendre:(NSString *)idRessource
{
	BOOL retour;
	NSRecursiveLock *ressource;
	
	@synchronized(ressources)
	{
		ressource=[ressources objectForKey:idRessource];
		if(!ressource)
		{
			ressource=[[NSRecursiveLock alloc] init];
			[ressources setObject:ressource forKey:idRessource];
		}
		else
		{
			[ressource retain];
		}
	}
	retour=[ressource tryLock];
	
	[ressource release];
	
	return retour;
}


-(BOOL)prendre:(NSString *)idRessource etAttendre:(NSInteger)secondes
{
	BOOL retour;
	NSRecursiveLock *ressource;

	@synchronized(ressources)
	{
		ressource=[ressources objectForKey:idRessource];
		if(!ressource)
		{
			ressource=[[NSRecursiveLock alloc] init];
			[ressources setObject:ressource forKey:idRessource];
		}
		else
		{
			[ressource retain];
		}
	}
	
	retour=[ressource lockBeforeDate:[NSDate dateWithTimeIntervalSinceNow:secondes]];
	
	[ressource release];
	
	return retour;
}


-(void)rendre:(NSString *)idRessource
{
	NSRecursiveLock *ressource;

	@synchronized(ressources)
	{
		ressource=[ressources objectForKey:idRessource];
		[ressource retain];
	}
	[ressource unlock];
	[ressource release];
}


-(void)detruire:(NSString *)idRessource
{
	@synchronized(ressources)
	{
		[ressources removeObjectForKey:idRessource];
	}
}

@end	
