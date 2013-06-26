#import <Cocoa/Cocoa.h>

@interface CR_RessourceSpeciale : NSObject
{
}

-(void)prendre:(NSString *)idRessource;
-(BOOL)testEtPrendre:(NSString *)idRessource;
-(BOOL)prendre:(NSString *)idRessource etAttendre:(NSInteger)secondes;
-(void)rendre:(NSString *)idRessource;
-(void)detruire:(NSString *)idRessource;

@end
