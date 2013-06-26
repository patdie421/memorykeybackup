#import <Cocoa/Cocoa.h>

#import "general.h"

#import "CR_Notificateur.h"

#import "PD_Ordonnanceur.h"
#import "PD_TacheSauvegarde.h"

#import "PD_Moteur.h"


@implementation PD_Ordonnanceur

@synthesize pere;
@synthesize fileDeSauvegardes;
@synthesize notifDemarrageSauvegarde;


- (id)init
{
	if (self = [super init])
	{
	}
	return self;
}


-(void)dealloc
{
    [self arreter];
	
    [pere release];
    [fileDeSauvegardes release];
    [timer release];
	[notifDemarrageSauvegarde release];

    [super dealloc];
}


-(void)supprimerToutesLesNotifications
{
	[notifDemarrageSauvegarde release];
	notifDemarrageSauvegarde=nil;
}


- (void)ordonnancer:(NSTimer *)unTimer
{
 NSLock *verrou;
 NSMutableArray *listeDesClesPlanifiees;
 int i;
 id cle;
 PD_TacheSauvegarde *uneTache;
    
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	[unTimer retain];
	
    verrou=[[pere tuyaux] verrouSurListeDesClesPlanifiees];
    [verrou retain];
    [verrou lock];
    
    listeDesClesPlanifiees=[[pere tuyaux] listeDesClesPlanifiees];
    [listeDesClesPlanifiees retain];
    
    for(i=0;i<[listeDesClesPlanifiees count];i++)
    {
        if([ [[listeDesClesPlanifiees objectAtIndex:i] objectAtIndex:0] compare:[NSDate date]] == NSOrderedAscending)
        {
            cle=[[listeDesClesPlanifiees objectAtIndex:i] objectAtIndex:1];

            // poster dans la file de sauvegarde
            uneTache=[[PD_TacheSauvegarde alloc] init];
            [uneTache setCle:cle];
			[uneTache setNotifDebutTacheSauvegarde:D_NOTIFDEBUTTACHESAUVEGARDE];
			[uneTache setNotifChangementTacheSauvegarde:D_NOTIFICHANGEMENTTACHESAUVEGARDE];
			[uneTache setNotifFinTacheSauvegarde:D_NOTIFFINTACHESAUVEGARDE];
            [uneTache setAReplanifier:[[[listeDesClesPlanifiees objectAtIndex:i] objectAtIndex:2] intValue]];
            [uneTache setPere:self];
			[fileDeSauvegardes ajouterTacheDansFileDEntree:uneTache];

            [listeDesClesPlanifiees removeObjectAtIndex:i];
			
			CR_Notificateur *notifSimple=[[CR_Notificateur alloc] init];
			[notifSimple envoyerNotification:notifDemarrageSauvegarde];
			[notifSimple release];
			
            [uneTache release];
        }
    }

    [listeDesClesPlanifiees release];

    [verrou unlock];
    [verrou release];
	
	[unTimer release];
	
	[pool release];
}


/*
 * demande pour les Threads
 */
- (void)_reveiller:(id)unObjet
{
    [self ordonnancer:nil];
}


- (void)reveiller
{
	if(timer!=nil)
		[self performSelectorOnMainThread:@selector(_reveiller:) withObject:nil waitUntilDone:NO];
}


- (void)demarrer
{
    [timer release];
    timer = [NSTimer scheduledTimerWithTimeInterval: 15
                                             target: self
                                           selector: @selector(ordonnancer:)
                                           userInfo: nil
                                            repeats: YES];
    [timer retain];
}


- (void)arreter
{
    if(timer && [timer isValid])
        [timer invalidate];
	[timer release];
	timer=nil;
}


@end
