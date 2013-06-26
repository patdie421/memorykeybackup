#import <Cocoa/Cocoa.h>

#import "general.h"
#import "CR_Tache.h"

#import "CI_GestionDesNotificationsDAffichage.h"


@interface _Notif : CR_Tache
{
	id ci;
	SEL selecteur;
	id obj;
}

@property(readwrite, retain) id ci;
@property(readwrite) SEL selecteur;
@property(readwrite, retain) id obj;

@end


@implementation _Notif

@synthesize ci;
@synthesize selecteur;
@synthesize obj;

- (id)init
{
    return [super init];
}


- (void)dealloc
{
    [super dealloc];
}


-(void)executerTache:(id)unObjet
{
	[ci performSelectorOnMainThread:selecteur withObject:obj waitUntilDone:NO];
}


-(BOOL)isEqualToCi:(id)unCi etSelecteur:(SEL)unSelecteur
{
	if((ci == unCi) && (selecteur == unSelecteur))
		return TRUE;
	
	return FALSE;
}

@end


@implementation CI_GestionDesNotificationsDAffichage

@synthesize CI_listeCles;
@synthesize CI_infosTaches;

-(id)init
{
	if (self = [super init])
	{
		fileNotificationsDAffichage=[[CR_File alloc] init];
		fileDEntree=fileNotificationsDAffichage;
		nom=@"fileRefresh";
		[self run];
		
		// abonnement aux notifications
		NSNotificationCenter *notifcenter=[NSNotificationCenter defaultCenter];
		[notifcenter addObserver:self
						selector:@selector(recptionNotifFileDeSauvegardes:)
							name:D_NOTIFLANCEMENTTACHE
						  object:nil];
		[notifcenter addObserver:self
						selector:@selector(recptionNotifFileDeSauvegardes:)
							name:D_NOTIFFINTACHE
						  object:nil];
		[notifcenter addObserver:self
						selector:@selector(recptionNotifFileDeSauvegardes:)
							name:D_NOTIFERREURTACHE
						  object:nil];
		
		[notifcenter addObserver:self
						selector:@selector(receptionNotifPlanificateur:)
							name:D_NOTIFCLEPLANIFIEE
						  object:nil];
		[notifcenter addObserver:self
						selector:@selector(receptionNotifPlanificateur:)
							name:D_NOTIFCLEDEPLANIFIEE
						  object:nil];
		
		[notifcenter addObserver:self
						selector:@selector(receptionNotifDemarrageTache:)
							name:D_NOTIFDEMARRAGESAUVEGARDE
						  object:nil];
		
		[notifcenter addObserver:self
						selector:@selector(receptionNotifEnregistreur:)
							name:D_NOTIFENREGISTREMENT
						  object:nil];
		
		[notifcenter addObserver:self
						selector:@selector(receptionNotifDemarrageTache:)
							name:D_NOTIFFINRESTAURATION
						  object:nil];
		[notifcenter addObserver:self
						selector:@selector(receptionNotifDemarrageTache:)
							name:D_NOTIFDEMARRAGERESTAURATION
						  object:nil];
	}
	return self;	
}


-(void)dealloc
{
    [fileNotificationsDAffichage release];

    [super dealloc];
}


-(void)arreter
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];

	[super arreter];
}


-(BOOL)existeDansLaFileParCi:(id)unCi etSelecteur:(SEL)unSelecteur
{
 NSConditionLock *verrou;
 int i,nbElem;
 BOOL retour;
 char etatVerrou;
	
	return FALSE;

	retour=FALSE;

	verrou=[fileNotificationsDAffichage verrou];
	[verrou retain];
	[verrou lock];
	
	nbElem=[fileNotificationsDAffichage nbElem];
	for(i=0;i<nbElem;i++)
	{
		if([[fileNotificationsDAffichage elemALaPosition:i] isEqualToCi:unCi etSelecteur:unSelecteur])
				retour=TRUE;
	}
	
	if(nbElem>0)
		etatVerrou=NON_VIDE;
	else
		etatVerrou=EST_VIDE;
	
	[verrou unlockWithCondition:etatVerrou];
	[verrou release];
	
	return retour;
}


-(void)CI_listeClesRafraichirAffichage:(id)unObjet
{
	if(![self existeDansLaFileParCi:CI_listeCles etSelecteur:@selector(rafraichirAffichage)])
	{
	 _Notif *tacheNotif;
		
		tacheNotif=[[_Notif alloc] init];
		
		[tacheNotif setCi:CI_listeCles];
		[tacheNotif setSelecteur:@selector(rafraichirAffichage)];
		[tacheNotif setObj:nil];
		
		[fileNotificationsDAffichage inWithLock:tacheNotif];
		
		[tacheNotif release];
	}
}


-(void)CI_infosTachesReload:(id)unObjet
{
	_Notif *tacheNotif;
	
	tacheNotif=[[_Notif alloc] init];
	
	[tacheNotif setCi:CI_infosTaches];
	[tacheNotif setSelecteur:@selector(reload:)];
	[tacheNotif setObj:unObjet];
	
	[fileNotificationsDAffichage inWithLock:tacheNotif];
	
	[tacheNotif release];
}


-(void)receptionNotifDemarrageTache:(id)unObjet
{
	[self CI_infosTachesReload:unObjet];
}


-(void)recptionNotifFileDeSauvegardes:(id)unObjet
{
	[self CI_listeClesRafraichirAffichage:unObjet];
	[self CI_infosTachesReload:unObjet];
}


-(void)receptionNotifPlanificateur:(id)unObjet
{
	[self CI_listeClesRafraichirAffichage:unObjet];
	[self CI_infosTachesReload:unObjet];
}


-(void)receptionNotifEnregistreur:(id)unObjet
{
	[self CI_listeClesRafraichirAffichage:unObjet];
}

@end
