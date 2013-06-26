#import <Cocoa/Cocoa.h>

#import "CI_Restauration.h"
#import "CI_StorageManagement.h"
#import "CI_ConfigCle.h"


@interface CI_ListeCles : NSObject
{
	IBOutlet id CI_principal;
	IBOutlet id CI_listeCles;
	
	IBOutlet id db_cles;

	IBOutlet id bouton_Editer;
	IBOutlet id bouton_Suppr;
    IBOutlet id bouton_Sauvegarder;
    IBOutlet id table_listeCles;
	IBOutlet id bouton_SauvegarderMaintenant;
	IBOutlet id bouton_restaurer;
	IBOutlet id bouton_purger;

	CI_StorageManagement *CI_storageManagement;
	CI_ConfigCle *CI_configCle;
	CI_Restauration *CI_restauration;
	NSMutableDictionary *D_toutesLesColonnesConstruites;
	NSArray *listeIdentifiantsDeToutesLesColonnes;
    
    NSTimer *timer;
}

@property(readwrite, retain) CI_ConfigCle *CI_configCle;
@property(readonly) NSArray *listeIdentifiantsDeToutesLesColonnes;
@property(readonly) id table_listeCles;

- (IBAction)table_listeCles:(id)sender;

- (IBAction)bouton_Suppr:(id)sender;
- (IBAction)bouton_Editer:(id)sender;
- (IBAction)bouton_Sauvegarder:(id)sender;
- (IBAction)bouton_Preferences:(id)sender;
- (IBAction)bouton_quitter:(id)sender;
- (IBAction)bouton_SauvegarderMaintenant:(id)sender;
- (IBAction)bouton_restaurer:(id)sender;
- (IBAction)bouton_StorageManagement:(id)sender;

- (IBAction)ouvrirFenetre:(id)sender;

- (void)animationBoutons;
- (void)checkDefaultsEndUpdateButton;

- (void)editerCle:(id)idCle;

// - (id)table_listeCles;
- (void)sauvegarderColonnesTable:(NSUserDefaults *)prefs;
- (void)chargerColonnesTable:(NSUserDefaults *)prefs;
- (void)chargerOuInitialiserColonnesTable_prefs:(NSUserDefaults *)prefs nomsDesColonnes:(id)nomDesColonnes;
- (void)desactiverColonneTable:(id)identifiantCle;
- (void)activerColonneTable:(id)identifiantCle;
- (NSMutableArray *)listeColonnesAffichees;

- (void)rafraichirAffichage;


@end
