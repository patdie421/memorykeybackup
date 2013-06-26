#import <Cocoa/Cocoa.h>
#include <sys/param.h>
#include <sys/mount.h>

#import "general.h"

#import "PD_Logueur.h"
#import "CR_Notificateur.h"

#import "PD_Moteur.h"
#import "PD_TacheDispatcheur.h"
#import "PD_Dispatcheur.h"

#import "PD_Cle.h"
#import "CR_Tache.h"

#import "PD_TacheSauvegarde.h"


@implementation PD_TacheDispatcheur

@synthesize pointDeMontage;
@synthesize montageOuDemontage;
@synthesize pere;


-(id)init
{
	if (self = [super init])
	{
	}
    return self;
}


-(void)dealloc
{
    [pointDeMontage release];
    [pere release];
    
    [super dealloc];
}


-(void)executerTache:(id)monDispatcheur
{
 PD_Cle *uneCle;
 BOOL retour;
 double max;
 NSArray *condition;
 PD_Logueur *logueur;

	logueur=[[PD_Logueur alloc] init];
	[monDispatcheur retain];
	
    if(montageOuDemontage==YES)
    {
        /*
         * Montage
         */
		[logueur loguerMessage:[NSString stringWithFormat:NSLocalizedString(@"%@ MOUNTDETECTED",nil), pointDeMontage]];
        uneCle=[[PD_Cle alloc] init];
        [uneCle setPointDeMontage:pointDeMontage];

        max=[[[[NSUserDefaults standardUserDefaults] dictionaryForKey:D_DEFAULTS] objectForKey:D_MAXKEYSIZE] doubleValue];
        condition=[[[NSUserDefaults standardUserDefaults] dictionaryForKey:D_DEFAULTS] objectForKey:D_DETECTION];
        
        if([uneCle estEligibleALaSauvegarde:max conditionDeDetection:condition])
        {
            if([uneCle chargerDepuisTagCle])
            {
                if([[monDispatcheur enregistreur] enregistrer:uneCle])
                {
					[logueur loguerMessage:[NSString stringWithFormat:NSLocalizedString(@"%@ ISAKEY %@",nil), pointDeMontage, [uneCle idCle]]];
                    //
                    // Envoie de la cle au planificateur ...
                    //
                    retour=[[monDispatcheur planificateur] planifier:uneCle];
                }
                else
					[logueur loguerMessage:[NSString stringWithFormat:NSLocalizedString(@"ERRORREGISTERINGKEY %@ %@",nil), [uneCle idCle], pointDeMontage ]];
            }
            else
            {
                // erreur de chargement de la cle depuis le tag : à programmer
            }
        }
        else
			[logueur loguerMessage:[NSString stringWithFormat:NSLocalizedString(@"%@ NOTAKEY",nil), pointDeMontage]];
        
        [uneCle release];
    }
    else
    {
        /*
         * demontage
         */
		[logueur loguerMessage:[NSString stringWithFormat:NSLocalizedString(@"%@ UNMOUNTDETECTED",nil), pointDeMontage]];
        /*
         * suppression éventuelle dans la liste des taches en attentes
         */
		uneCle=[[monDispatcheur enregistreur] cleMonteeParPointDeMontage:pointDeMontage];
		[uneCle retain];
        if(uneCle)
        {
			[[[monDispatcheur pere] traitementDesTaches] arreterTachesPourCle:uneCle];
			[[[monDispatcheur pere] traitementDesTaches] supprimerCleDeLaFileDeSauvegardes:uneCle];
            [[monDispatcheur planificateur] deplanifierCle:uneCle];
            [[monDispatcheur enregistreur] desenregistrerCle:uneCle];
        }
		[uneCle release];
    }
	
	[monDispatcheur release];
	[logueur release];
}


@end
