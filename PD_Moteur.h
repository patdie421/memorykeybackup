#import <Cocoa/Cocoa.h>

#import "general.h"

#import "PD_Tuyaux.h"
#import "PD_Detecteur.h"
#import "PD_Dispatcheur.h"
#import "PD_Enregistreur.h"
#import "PD_Planificateur.h"
#import "PD_Ordonnanceur.h"
#import "PD_TraitementDesTaches.h"

#import "DB_Cles.h"


@interface PD_Moteur : NSObject
{
    id pere; // qui m'a créé
    
	id db_cles;
    
	PD_Tuyaux *tuyaux;
	
    PD_Detecteur *detecteur;
    PD_Dispatcheur *dispatcheur;
    PD_Enregistreur *enregistreur;
    PD_Planificateur *planificateur;
    PD_Ordonnanceur *ordonnanceur;
    PD_TraitementDesTaches *traitementDesTaches;
}

@property(readwrite, retain) id pere;

@property(readwrite, retain) id db_cles;

@property(readonly) PD_Tuyaux *tuyaux;

@property(readonly) PD_Ordonnanceur *ordonnanceur;
@property(readonly) PD_Enregistreur *enregistreur;
@property(readonly) PD_Planificateur *planificateur;
@property(readonly) PD_TraitementDesTaches *traitementDesTaches;

-(void)demarrer;
-(void)arreter;

@end
