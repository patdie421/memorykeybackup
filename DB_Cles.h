#import <Cocoa/Cocoa.h>

#import "CR_File.h"


@interface DB_Cles : NSObject
{
    NSString *fichier;
	NSRecursiveLock *verrouDB;

    // liste de toutes les clés
    NSMutableArray *listeDesClesDefinies;
    NSMutableArray *listeTrieeDesClesDefinies;
    NSMutableDictionary *indexIdClesSurlisteDesClesDefinies;
    NSLock *verrouSurListeDesClesDefinies;
    NSArray *descripteursDeTri;
}

@property(readwrite, retain) NSRecursiveLock *verrouDB;

// acces à la liste de toutes les cles
//- (void)verrouiller;
//- (void)deverrouiller;
- (BOOL)charger;
- (BOOL)sauvegarder;
- (void)trier;
- (void)trier:(NSArray *)descripteurs;

- (int)nbClesDansListeDesClesDefinies;

- (id)cleParPosition:(int)unePosition;
- (id)cleTrieeParPosition:(int)unePosition;
- (id)cleParIndexIdCle:(id)unIdCle;
- (int)indexPourIdCle:(id)unIdCle;
- (BOOL)supprimerCleParPosition:(int)unePosition;
- (BOOL)supprimerCleParIndexIdCle:(id)unIdCle;
- (int)positionPourObjet:(id)unObjet;

- (BOOL)ajouterEnregistrement:(id)idCle enregistrement:(NSMutableDictionary *)unEnregistrement;

@end
