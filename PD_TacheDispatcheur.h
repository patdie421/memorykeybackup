#import <Cocoa/Cocoa.h>

#import "CR_Tache.h"


@interface PD_TacheDispatcheur : CR_Tache
{
    id pere; // qui m'a créé
    
    NSString *pointDeMontage;
    BOOL montageOuDemontage;
}

@property(readwrite, retain) id pere;
@property(readwrite, retain) NSString *pointDeMontage;
@property(readwrite) BOOL montageOuDemontage;

@end
