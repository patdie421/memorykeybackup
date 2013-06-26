#import <Cocoa/Cocoa.h>

#import "PD_Dispatcheur.h"


@interface PD_Detecteur : NSObject
{
    id pere; // qui m'a créé
    
    PD_Dispatcheur *dispatcheur;
}

@property(readwrite, retain) id pere;
@property(readwrite, retain) PD_Dispatcheur *dispatcheur;

-(void)detectionInitiale;

@end
