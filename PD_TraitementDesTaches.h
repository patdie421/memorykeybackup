#import <Cocoa/Cocoa.h>

#import "CR_TraitementsMultiThreads.h"
#import "PD_Cle.h"


@interface PD_TraitementDesTaches : CR_TraitementsMultiThreads
{
    id pere; // qui m'a créé
}

@property(readwrite, retain) id pere;

-(void)supprimerCleDeLaFileDeSauvegardes:(PD_Cle *)uneCle;
-(void)arreterTachesPourCle:(PD_Cle *)uneCle;

@end
