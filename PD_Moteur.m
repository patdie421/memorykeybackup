#import <Cocoa/Cocoa.h>

#import "PD_Moteur.h"
#import "PD_Logueur.h"

#import "CR_ArbreFS.h"


@implementation PD_Moteur

@synthesize db_cles;
@synthesize tuyaux;
@synthesize pere;
@synthesize ordonnanceur;
@synthesize enregistreur;
@synthesize planificateur;
@synthesize traitementDesTaches;


-(id)init
{
    return [super init];
}


-(void)dealloc
{
    [db_cles release];
    
	[tuyaux release];
	
    [detecteur release];
    [dispatcheur release];
    [enregistreur release];
    [planificateur release];
    [ordonnanceur release];
    [traitementDesTaches release];

    [pere release];
    
    [super dealloc];
}


-(void)demarrer
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	PD_Logueur *logueur=[[PD_Logueur alloc] init];
	
	[logueur loguerMessage:NSLocalizedString(@"STARTINGENGINE",nil)];
	
    traitementDesTaches=[[PD_TraitementDesTaches alloc] init];
    [traitementDesTaches setPere:self];
	[traitementDesTaches setNotifLancementTache:D_NOTIFLANCEMENTTACHE];
	[traitementDesTaches setNotifFinTache:D_NOTIFFINTACHE];
	[traitementDesTaches setNotifErreurTache:D_NOTIFERREURTACHE];

    enregistreur=[[PD_Enregistreur alloc] init];
	[enregistreur setNotifEnregistrement:D_NOTIFENREGISTREMENT];
    [enregistreur setPere:self];
    
    planificateur=[[PD_Planificateur alloc] init];
	[planificateur setNotifClePlanifiee:D_NOTIFCLEPLANIFIEE];
	[planificateur setNotifCleDeplanifiee:D_NOTIFCLEDEPLANIFIEE];
    [planificateur setPere:self];

    dispatcheur=[[PD_Dispatcheur alloc] initWithNom:@"DISPATCH"];
    [dispatcheur setPere:self];
    [dispatcheur setEnregistreur: enregistreur];
    [dispatcheur setPlanificateur: planificateur];
    
    detecteur=[[PD_Detecteur alloc] init];
    [detecteur setPere:self];
    [detecteur setDispatcheur:dispatcheur];
    
    ordonnanceur=[[PD_Ordonnanceur alloc] init];
    [ordonnanceur setPere:self];
    [ordonnanceur setFileDeSauvegardes:traitementDesTaches];
	[ordonnanceur setNotifDemarrageSauvegarde:D_NOTIFDEMARRAGESAUVEGARDE];

	tuyaux=[[PD_Tuyaux alloc] init];
	[tuyaux setFileDesTachesEnAttente:[traitementDesTaches fileDEntree]];
	[tuyaux setListeDesTachesEnCours:[traitementDesTaches tachesEnCoursDExecution]];
	[tuyaux setVerrouSurListeDesTachesEnCours:[traitementDesTaches verrouSurTachesEnCoursDExecution]];	 
	[tuyaux setListeDesClesPlanifiees:[planificateur listeDesClesPlanifiees]];
	[tuyaux setVerrouSurListeDesClesPlanifiees:[planificateur verrouSurListeDesClesPlanifiees]];

	// lancement du moteur
	[traitementDesTaches run:[[NSProcessInfo processInfo] activeProcessorCount] racineDuNomDesThreads:@"SAUVE"];
    [dispatcheur run];
    [ordonnanceur demarrer];
    [detecteur detectionInitiale];
	
	[logueur loguerMessage:NSLocalizedString(@"ENGINESTARTED",nil)];
	
	[logueur release];
		
    [pool release];
}


-(void)arreter
{
    [ordonnanceur arreter];

    [dispatcheur arreter];
    [dispatcheur wait:30];

    [traitementDesTaches arreter:30];
}

@end
