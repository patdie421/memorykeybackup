#import <Cocoa/Cocoa.h>

#import "CR_TraitementsMultiThreads.h"
#import "CR_Consommateur.h"


@implementation CR_TraitementsMultiThreads

@synthesize tachesEnCoursDExecution;
@synthesize verrouSurTachesEnCoursDExecution;
@synthesize fileDEntree;
@synthesize nbThread;
@synthesize notifLancementTache;
@synthesize notifFinTache;
@synthesize notifErreurTache;

- (id)init
{
	if (self = [super init])
	{
        fileDEntree             = [[CR_File alloc] init];
        tachesEnCoursDExecution = [[NSMutableArray alloc] init];
        verrouSurTachesEnCoursDExecution = [[NSLock alloc] init];
        synchroFinDeTache       = [[NSConditionLock alloc] initWithCondition:0]; // 1 = nb de thread
        listeDesThreads         = [[NSMutableArray alloc] init];
        traitementsEnCours = NO;
        nbThread = 0;
	}
	return self;
}


- (void)dealloc
{
    [fileDEntree release];
    [tachesEnCoursDExecution release];
    [verrouSurTachesEnCoursDExecution release];

    [synchroFinDeTache release];
    [listeDesThreads release];
    
	[notifLancementTache release];
	[notifFinTache release];
	[notifErreurTache release];
	
    [super dealloc];
}


- (BOOL)arreter:(NSInteger)timeout
{
 int i,j;
 BOOL retour;
 NSConditionLock *verrou;
 NSEnumerator *e; 
 CR_Tache *tache;
    
    // blocage de la file d'entrée
    verrou=[fileDEntree verrou];
    [verrou retain];
    [verrou lock];
    
    // vidage de la file d'entree
    j=[fileDEntree nbElem];
    for(i=0;i<j;i++)
        [fileDEntree supprimerElemALaPosition:0];

    [verrou unlock];
    [verrou release];

    // demande d'arret de toutes les tâches
    [verrouSurTachesEnCoursDExecution lock];
    e = [tachesEnCoursDExecution objectEnumerator]; 
	while ( (tache = [e nextObject]) )
        [tache setInterrompreTache:YES];
    [verrouSurTachesEnCoursDExecution unlock];

    for(i=0;i<nbThread;i++)
        [[listeDesThreads objectAtIndex:i] arreter];
    
    
    retour=[synchroFinDeTache lockWhenCondition:0 beforeDate:[NSDate dateWithTimeIntervalSinceNow:timeout]];
    if(retour)
    {
        [synchroFinDeTache unlock];
        for(i=0;i<nbThread;i++)
        {
            [listeDesThreads removeLastObject];
        }
        traitementsEnCours=NO;
        nbThread=0;
        
        // purger la file d'entree
        // purger la liste des taches en cours ... normalement pas nécessaire
        
        return YES;
    }
    else
    {
        return NO;
    }
}


- (BOOL)run:(NSInteger)nb racineDuNomDesThreads:(NSString *)uneRacine
{
 int i;
 CR_Consommateur *unConsommateur;
 NSString *nomThread;
    
	[[uneRacine retain] autorelease];
	
    if((nb > 0) && !traitementsEnCours)
    {
        nbThread = nb;
        [synchroFinDeTache release];
        synchroFinDeTache = [[NSConditionLock alloc] initWithCondition:nbThread];
        
        for(i=0; i<nbThread ; i++)
        {
            nomThread=[NSString stringWithFormat:@"%@#%d",uneRacine,i];
            
            unConsommateur=[[CR_Consommateur alloc] initWithFile:fileDEntree nom:nomThread];

            [unConsommateur setTachesEnCoursDExecution: tachesEnCoursDExecution];
            [unConsommateur setVerrouSurTacheEnCoursDExecution:verrouSurTachesEnCoursDExecution];
            [unConsommateur setSynchroFinDeTache:synchroFinDeTache];
            [unConsommateur setInfosComplementaires:self];

			if(notifLancementTache)
				[unConsommateur setNotifLancementTache:notifLancementTache];
			if(notifFinTache)
				[unConsommateur setNotifFinTache:notifFinTache];
			if(notifErreurTache)
				[unConsommateur setNotifErreurTache:notifErreurTache];

            [unConsommateur run];
            [listeDesThreads addObject:unConsommateur];

            [unConsommateur release];
        }
        traitementsEnCours=YES;
        
        return YES;
    }
    else
    {
        return NO;
    }
}


- (void)ajouterTacheDansFileDEntree:(CR_Tache *)uneTache
{
    [uneTache retain];
    
    [fileDEntree inWithLock:uneTache];
    
    [uneTache release];
}


@end
