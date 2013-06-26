#import "PD_TacheRestauration.h"
#import "general.h"
#import "CR_Notificateur.h"
#import "CR_RessourceSpeciale.h"


@implementation PD_TacheRestauration

@synthesize complementDInfo;

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


-(void)envoyerNotification:(NSNotification *)uneNotif
{
	[uneNotif retain];
	
	[[NSNotificationQueue defaultQueue]
	 enqueueNotification: uneNotif
	 postingStyle: NSPostNow
	 coalesceMask: NSNotificationNoCoalescing
	 forModes: nil];
	
	[uneNotif release];
}


-(void)stopTache:(id)sender
{
	NSLog(@"Arret demandé");
	interrompreTache=YES;
}


-(void)retaurer
{
 NSNotification *notif;
	
	notif=[NSNotification notificationWithName:D_NOTIFCHANGEMENTRESTAURATION object:self];
	[notif retain];

	avancement=0.0;
	[complementDInfo release];
	complementDInfo=@"lancement de la restauration";
	[self envoyerNotification:notif];
	
	int i;
	for(i=0; i<=10; i++)
	{
		@synchronized(self)
		{
			if(interrompreTache==YES)
				break;

			avancement=(double)i/10.0;
			[complementDInfo release];
			complementDInfo=[[NSString alloc] initWithFormat:@"BOUCLE %d",i];
		}
		
		[self envoyerNotification:notif];
		
		// le traitement unitaire
		sleep(1);
		// fin traitement fichier
	}

	avancement=-1.0;
	[self envoyerNotification:notif];
	sleep(1); // complément de traitement

	[notif release];
}


-(void)executerTache:(id)unObjet
{
 CR_Notificateur *notif;
 CR_RessourceSpeciale *ressource;
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
    [unObjet retain];
	
	ressource=[[CR_RessourceSpeciale alloc] init];
	notif=[[CR_Notificateur alloc] init];
	
	traitementEnCours=TRUE;
	traitementTerminer=FALSE;
	avancement=-1.0;
	[complementDInfo release];
	complementDInfo=@"Attente fin de traitement pour la même clé";
	[notif envoyerNotification:D_NOTIFDEMARRAGERESTAURATION];

	NSDate *loopUntil = [[NSDate alloc] initWithTimeIntervalSinceNow:0.25]; 
	while(![ressource testEtPrendre:nomTache])
	{
		if(interrompreTache)
			break;
		else
			[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:loopUntil];
	}
	[loopUntil release];
	
	[self retaurer];
	
	traitementEnCours=FALSE;
	traitementTerminer=TRUE;
	avancement=-1.0;
	[notif envoyerNotification:D_NOTIFFINRESTAURATION];
	
	[ressource rendre:nomTache];
	
	[notif release];
    [unObjet release];
	[pool release];
	[ressource release];
}

@end
