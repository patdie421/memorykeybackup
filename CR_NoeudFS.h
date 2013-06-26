#import <Cocoa/Cocoa.h>


#define D_UNDEF -1
#define D_FEUILLE_FICHIER 1
#define D_FEUILLE_APPLICATION 2
#define D_REPERTOIRE 3
#define D_ROOT 4
#define D_VIDE 5

int typeDuNoeud(NSString *chemin);

@interface CR_NoeudFS : NSObject
{
	NSString *nom;
	id iconEtTexte;
	
	NSMutableArray *fils;
	CR_NoeudFS *pere;
	char typeNoeud;
	char etat;
	char expand;
}

@property(readwrite, retain) NSString *nom;
@property(readwrite, retain) id iconEtTexte;
@property(readwrite, retain) CR_NoeudFS *pere;
@property(readwrite, retain) NSMutableArray *fils;
@property(readwrite) char typeNoeud;
@property(readwrite) char etat;
@property(readwrite) char expand;

- (NSString *)cheminComplet;

- (int)nbFils;
- (id)filsALIndex:(int)index;

- (void)deployer;
- (void)replier;
- (BOOL)estDeployable;

- (BOOL)filsSontTousSelectionnes:(id)itemExclu;
- (BOOL)filsSontTousDeselectionnes:(id)itemExclu;
- (void)ajusterSelectionsParents;
- (void)ajusterSelectionsFils:(BOOL)e;

- (void)listerFichiersSelectionnes:(NSMutableArray *)fichiersSelectionnes;

- (void)afficher;
- (void)deplierOutLineView:(id)ov;

@end
