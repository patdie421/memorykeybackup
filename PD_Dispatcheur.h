#import <Cocoa/Cocoa.h>

#import "CR_TraitementMonoThread.h"

#import "PD_Enregistreur.h"
#import "PD_Planificateur.h"


@interface PD_Dispatcheur : CR_TraitementMonoThread
{
    id pere; // qui m'a créé

    PD_Enregistreur *enregistreur;
    PD_Planificateur *planificateur;
}

@property(readwrite, retain) id pere;

@property(readwrite, retain) PD_Enregistreur *enregistreur;
@property(readwrite, retain) PD_Planificateur *planificateur;

@end
