#import <Cocoa/Cocoa.h>

#import "general.h"

#import "CR_File.h"
#import "CR_Consommateur.h"
#import "CR_Tache.h"
#import "CR_Notificateur.h"

/**************************************************/
/* Classe definissant un objet utilisé pour       */
/* arrêter le thread                              */
/**************************************************/
@interface Consommateur_demandeDArret : NSObject
{
}
- (void)arreter;
@end

@implementation Consommateur_demandeDArret
- (id)init
{
    return [super init];
}

- (void)dealloc
{
    [super dealloc];
}

- (void)arreter
{
}
@end
/**************************************************/


@implementation CR_Consommateur

@synthesize nom, timeout, fileDEntree, estEnCoursDExecution, doitSArreter, verrouSurTacheEnCoursDExecution;
@synthesize tachesEnCoursDExecution, synchroFinDeTache, infosComplementaires;
@synthesize notifLancementTache, notifFinTache, notifErreurTache;


- (id)init
{
    return [self initWithFile:nil nom:@""];
}


- (void) print
{
	DEBUGNSLOG(@"CONSOMMATEUR %@ : %@ %@ %@",nom, notifLancementTache, notifFinTache, notifErreurTache);
}


- (id)initWithFile:(id)uneFile nom:unNom
{
	if (self = [super init])
	{
		[uneFile retain];
		[fileDEntree release];
		fileDEntree=uneFile;
		
		[unNom retain];
		[nom release];
		nom=unNom;
		
		timeout=10;
        
        estEnCoursDExecution=NO;
        doitSArreter=NO;
        verrouSurTacheEnCoursDExecution=[[NSLock alloc] init];
	}
	return self;
}


- (void)dealloc
{
	[nom release];
	[fileDEntree release];
    [verrouSurTacheEnCoursDExecution release];
    [tachesEnCoursDExecution release];
    [synchroFinDeTache release];
    [infosComplementaires release];
	
	[notifLancementTache release];
	[notifFinTache release];
	[notifErreurTache release];

    
	[super dealloc];
}


-(void)supprimerToutesLesNotifications
{
	[notifLancementTache release];
	notifLancementTache=nil;
	
	[notifFinTache release];
	notifFinTache=nil;
	
	[notifErreurTache release];
	notifErreurTache=nil;
}


+ (void)consommateur:(id)unConsommateur
{
 id unElem;
 id uneFile;
 char sortie;
 int i;
 NSString *unNom;
 NSInteger compteurCondition;
    
 NSMutableArray *tachesEnCoursDExecution;
 NSLock *verrouSurTacheEnCoursDExecution;
 NSConditionLock *synchroFinDeTache;

 CR_Notificateur *notifSimple;

    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	notifSimple=[[CR_Notificateur alloc] init];
	
	[unConsommateur retain];
	
	uneFile=[unConsommateur fileDEntree];
	if(uneFile==nil)
    {
        [pool release];
		return;
    }
	[uneFile retain];
    
	unNom=[unConsommateur nom];
	[unNom retain];
    
    tachesEnCoursDExecution=[unConsommateur tachesEnCoursDExecution];
    if(tachesEnCoursDExecution)
    {
        [tachesEnCoursDExecution retain];
    }
    
    verrouSurTacheEnCoursDExecution=[unConsommateur verrouSurTacheEnCoursDExecution];
    if(verrouSurTacheEnCoursDExecution)
    {
        [verrouSurTacheEnCoursDExecution retain];
    }
    
    synchroFinDeTache=[unConsommateur synchroFinDeTache];
    if(synchroFinDeTache)
    {
        [synchroFinDeTache retain];
    }
		
    [unConsommateur setEstEnCoursDExecution:YES];
    
	DEBUGNSLOG(@"Consommateur %s start\n",[unNom UTF8String]);
	
	sortie=0;
	i=0;
	while(!sortie)
	{
        
		NSAutoreleasePool *pool2 = [[NSAutoreleasePool alloc] init];

		unElem=[uneFile outWithLockAndTimeOut:[unConsommateur timeout]];
        if(unElem)
        {
            [unElem retain];
			
            if([unElem respondsToSelector: @selector (executerTache:)] )
            {
                NSString *idTache;
                @try
                {
                   if(tachesEnCoursDExecution && verrouSurTacheEnCoursDExecution)
                    {
                        
                        idTache=[NSString stringWithFormat:@"%@-%d",unNom,i];
                        [idTache retain];
                        
                        [verrouSurTacheEnCoursDExecution lock];
						[tachesEnCoursDExecution addObject:unElem];
                        [verrouSurTacheEnCoursDExecution unlock];
						
						// lancement de la tache
						[notifSimple envoyerNotification:[unConsommateur notifLancementTache]];
						
                        [unElem executerTache:unConsommateur];
						
                        [verrouSurTacheEnCoursDExecution lock];
                        [tachesEnCoursDExecution removeObject:unElem];
                        [verrouSurTacheEnCoursDExecution unlock];

						// fin de la tache
						[notifSimple envoyerNotification:[unConsommateur notifFinTache]];

						
                        [idTache release];
                    }
                    else
					{
						// lancement de la tache
						[notifSimple envoyerNotification:[unConsommateur notifLancementTache]];
						
                        [unElem executerTache:unConsommateur];
						
						// fin de la tache
						[notifSimple envoyerNotification:[unConsommateur notifFinTache]];
					}
                }
                @catch (NSException * e)
                {
					if(tachesEnCoursDExecution && verrouSurTacheEnCoursDExecution)
                    {
						[verrouSurTacheEnCoursDExecution lock];
						[tachesEnCoursDExecution removeObject:unElem];
						[verrouSurTacheEnCoursDExecution unlock];
					}
					
					// fin de la tache
					[notifSimple envoyerNotification:[unConsommateur notifErreurTache]];
					
                    [idTache release];
                    DEBUGNSLOG(@"%@ : Execution error !",unNom);
                }
                i++;
            }
            else
            {
                if([unElem respondsToSelector: @selector (arreter)] )
                {
                    sortie=1;
                }
#ifdef D_DEBUG
                else
				{
                    NSLog(@"Warning : incorrect object recieved! Skip object.");
				}
#endif
            }
            
            [unElem release];
        }
        else
        {
            if([unConsommateur doitSArreter])
            {
                sortie=1;
            }
        }
        

        [pool2 release];
    }
	DEBUGNSLOG(@"End of consommateur : %s\n",[unNom UTF8String]);

    [unConsommateur setEstEnCoursDExecution:NO];

    if(synchroFinDeTache)
    {
        [synchroFinDeTache lock];
        compteurCondition=[synchroFinDeTache condition];
        compteurCondition--;
        [synchroFinDeTache unlockWithCondition:compteurCondition];
        [synchroFinDeTache release];
    }
    
    [tachesEnCoursDExecution release];
    [verrouSurTacheEnCoursDExecution release];
	
    [unNom release];
    [uneFile release];

	[unConsommateur release];
	[notifSimple release];
	[pool release];
}


- (void)run
{
	[NSThread detachNewThreadSelector:@selector(consommateur:) toTarget:[CR_Consommateur class] withObject:self];	
}


- (void)arreter
{
 id demandeDArret;
    
    demandeDArret=[[Consommateur_demandeDArret alloc] init];
    
    [fileDEntree inWithLock:demandeDArret];
    
    [demandeDArret release];
    
    doitSArreter=YES;
}


@end
