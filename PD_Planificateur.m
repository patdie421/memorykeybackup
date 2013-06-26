#import <Cocoa/Cocoa.h>

#import "general.h"
#import "CR_Notificateur.h"
#import "PD_Planificateur.h"
#import "PD_Logueur.h"
#import "PD_Moteur.h"


@implementation PD_Planificateur

@synthesize pere;
@synthesize notifClePlanifiee;
@synthesize notifCleDeplanifiee;
@synthesize listeDesClesPlanifiees;
@synthesize verrouSurListeDesClesPlanifiees;


-(void)dealloc
{
    [pere release];
	[notifClePlanifiee release];
	[notifCleDeplanifiee release];
	[listeDesClesPlanifiees release];
	[verrouSurListeDesClesPlanifiees release];

    [super dealloc];
}


- (id)init
{
	if (self = [super init])
	{
		listeDesClesPlanifiees=[[NSMutableArray alloc] init];
        verrouSurListeDesClesPlanifiees=[[NSLock alloc] init];
	}
	return self;
}


-(void)supprimerToutesLesNotifications
{
	[notifClePlanifiee release];
	notifClePlanifiee=nil;
	
	[notifCleDeplanifiee release];
	notifCleDeplanifiee=nil;
}


-(BOOL)planifier:(PD_Cle *)uneCle aLaDate:(NSDate *)uneDate aReplanifier:(BOOL)unEtat
{
 NSMutableArray *clePlanifiee;
 int i;
 PD_Logueur *logueur;
 id moteur;

	[uneCle retain];
	[uneDate retain];
	
	moteur=[self pere];
	logueur=[[PD_Logueur alloc] init];
	
	[verrouSurListeDesClesPlanifiees lock];

    if(uneDate)
    {
        clePlanifiee=[[NSMutableArray alloc] initWithObjects:uneDate,uneCle,[NSNumber numberWithInt:unEtat],nil]; // rajouté indicateur de replanif
        
        for(i=0;i<[listeDesClesPlanifiees count];i++)
        {
            if([ [clePlanifiee objectAtIndex:0] compare: [ [listeDesClesPlanifiees objectAtIndex:i] objectAtIndex:0] ] == NSOrderedAscending)
                break;
        }
        [listeDesClesPlanifiees insertObject:clePlanifiee atIndex:i];
		
		[verrouSurListeDesClesPlanifiees unlock];
	
		CR_Notificateur *notifSimple=[[CR_Notificateur alloc] init];
		[notifSimple envoyerNotification:notifClePlanifiee];
		[notifSimple release];
		
        [clePlanifiee release];
        
//		[logueur loguerMessage:[NSString stringWithFormat:NSLocalizedString(@"DATE:",nil), uneDate]];
        [[moteur ordonnanceur] reveiller];
    }
    else
	{
		[logueur loguerMessage:[NSString stringWithFormat:NSLocalizedString(@"NOTTIMETOBACLUP",nil)]];
		[verrouSurListeDesClesPlanifiees unlock];
    }

	[logueur release];
	
	[uneDate release];
    [uneCle release];
	
    return YES;
}


-(BOOL)planifier:(PD_Cle *)uneCle
{
 NSInteger intervalEnSeconde;
 NSDate *dateSauvegarde;
 PD_Logueur *logueur;
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	[uneCle retain];
	logueur=[[PD_Logueur alloc] init];
	
    if( [[[uneCle infosCle] objectForKey:D_BACKUPTYPE] intValue] == 1)
    {
		[logueur loguerMessage:[NSString stringWithFormat:NSLocalizedString(@"NOTHINGTODO",nil)]];
    }
    else
    {
        dateSauvegarde=nil;
        if( [[[uneCle infosCle] objectForKey:D_ACTIONINSERSION] intValue] == 2 )
        {
            dateSauvegarde=[NSDate date];
        }
        else if ( [[[uneCle infosCle] objectForKey:D_ACTIONINSERSION] intValue] == 3 )
        {
            intervalEnSeconde=[[[uneCle infosCle] objectForKey:D_ACTIONINSERSION_NB] intValue] *
                             ([[[uneCle infosCle] objectForKey:D_ACTIONINSERSION_UNITE] intValue] * 23 + 1 ) * 60 * 60;
            
            dateSauvegarde = [[[uneCle infosCle] objectForKey:D_DERNSAUV] addTimeInterval:intervalEnSeconde];

            if ([dateSauvegarde compare:[NSDate date]] == NSOrderedAscending)
                dateSauvegarde=[NSDate date];
        }
        
        if(dateSauvegarde==nil)
        {
            if ([[[uneCle infosCle] objectForKey:D_PLANNING] intValue] == 2)
            {
                intervalEnSeconde=[[[uneCle infosCle] objectForKey:D_PLANNING_NB] intValue] *
                                 ([[[uneCle infosCle] objectForKey:D_PLANNING_UNITE] intValue] * 23 + 1 ) * 60 * 60;

                dateSauvegarde = [[[uneCle infosCle] objectForKey:D_DERNSAUV] addTimeInterval:intervalEnSeconde];
            }
        }
        
        [self planifier:uneCle aLaDate:dateSauvegarde aReplanifier:YES];
    }
	
	[logueur release];
	[uneCle release];
	
	[pool release];
	
    return YES;
}


-(BOOL)deplanifierCle:(PD_Cle *)uneCle
{
 int i;
    
	[uneCle retain];
	
	[verrouSurListeDesClesPlanifiees lock];

	i=[listeDesClesPlanifiees count]-1;
    for(;i>=0;i--)
    {
		if(NSOrderedSame == [[[[listeDesClesPlanifiees objectAtIndex:i] objectAtIndex:1] idCle] compare:[uneCle idCle]])
        {
			@synchronized([self pere])
			{
				[listeDesClesPlanifiees removeObjectAtIndex:i];

				CR_Notificateur *notifSimple=[[CR_Notificateur alloc] init];
				[notifSimple envoyerNotification:notifCleDeplanifiee];
				[notifSimple release];
			}
        }
    }    

    [verrouSurListeDesClesPlanifiees unlock];

	[uneCle release];
	
    return YES;
}


-(BOOL)deplanifier:(NSString *)pointDeMontage
{
 PD_Cle *uneCle;
    
	[[pointDeMontage retain] autorelease];
	
	@synchronized([[pere enregistreur] listeDesClesMontees])
	{
		uneCle=[[pere enregistreur] cleMonteeParPointDeMontage:pointDeMontage];
	}
    if(!uneCle)
        return NO;

	[[uneCle retain] autorelease];
    
    return [self deplanifierCle:uneCle];
}


-(BOOL)replanifier:(PD_Cle *)uneCle
{
 NSInteger intervalEnSeconde;
 NSDate *dateSauvegarde=nil;
 PD_Logueur *logueur;
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	[uneCle retain];
	logueur=[[PD_Logueur alloc] init];

    [logueur loguerMessage:[NSString stringWithFormat:NSLocalizedString(@"PLANNINGBACKUPFOR:",nil), [uneCle idCle]]];
    if ([[[uneCle infosCle] objectForKey:D_PLANNING] intValue] == 2)
    {
        intervalEnSeconde=[[[uneCle infosCle] objectForKey:D_PLANNING_NB] intValue] *
        ([[[uneCle infosCle] objectForKey:D_PLANNING_UNITE] intValue] * 23 + 1 ) * 3600;
        
        dateSauvegarde = [[[uneCle infosCle] objectForKey:D_DERNSAUV] addTimeInterval:intervalEnSeconde];
    }
    
    [self deplanifierCle:uneCle];
    
    [self planifier:uneCle aLaDate:dateSauvegarde aReplanifier:YES];
    
	[logueur release];
	[uneCle release];
	
	[pool release];
	
    return YES;
}


@end
