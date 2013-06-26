#import <Cocoa/Cocoa.h>

#import <CR_ArbreFS.h>


@interface CR_ForetFS : NSObject
{
	NSMutableDictionary *foret;
}

-(CR_ArbreFS *)arbreParIdentifiant:(NSString *)unIdentifiant;
-(void)ajouterArbre:(CR_ArbreFS *)unArbre identifiant:(NSString *)unIdentifiant;
-(void)retirerArbreParIdentifiant:(NSString *)unIdentifiant;
-(void)listeFichiersSelectionnes:(NSMutableArray *)listeFichiers;
-(void)vider;

@end
