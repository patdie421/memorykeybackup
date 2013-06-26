#import <Cocoa/Cocoa.h>

#import "CR_ArbreFS.h"
#import "CR_ForetFS.h"
#import "CI_ProgressionRestauration.h"
#import "PD_TacheRestauration.h"

@interface CI_Restauration : NSObject
{
	IBOutlet id fenetre;
	
	IBOutlet id label_idcle;

	IBOutlet id outlineview;
	IBOutlet id table_choixBackupSet;

	IBOutlet id onglet_choixSauvegardes;

	IBOutlet id radio_destination;
	IBOutlet id radio_remplacement;
	IBOutlet id radio_destination_original;
	IBOutlet id check_keepCopy;
	IBOutlet id label_extentionAdd;
	IBOutlet id check_addExtention;
	IBOutlet id champ_keeped;
	IBOutlet id champ_restored;
	IBOutlet id champ_destination;
	IBOutlet id bouton_choose;
	
	IBOutlet id radio_full_backup;
	IBOutlet id radio_full_backup_last;
	IBOutlet id radio_full_backup_old;
	
	IBOutlet id radio_sync;
	IBOutlet id radio_sync_sync;
	IBOutlet id radio_sync_bak;
	
	id CI_principal;
	CI_ProgressionRestauration *CI_progressionRestauration;

	id dbCle;
	id cle;
	
	CR_ForetFS *uneForet;
	CR_ArbreFS *unArbre;
	
	NSMutableArray *listeSauvegardeIncr;
	PD_TacheRestauration *tache;
	
	char etat_radio_full_backup;
	char etat_radio_sync;
}

@property(readwrite, retain) id dbCle;
@property(readwrite, retain) id cle;
@property(readwrite, retain) id CI_principal;
@property(readonly) PD_TacheRestauration *tache;

-(IBAction)actionBouttons:(id)sender;
-(IBAction)actionChoose:(id)sender;
-(IBAction)locateInFinder:(id)sender;
-(IBAction)clickCheckBox:(id)sender;
-(IBAction)actionRadio_full_backup:(id)sender;
-(IBAction)actionRadio_sync:(id)sender;
-(IBAction)actionProcess:(id)sender;

-(BOOL)afficher:(int)indexCle;
-(BOOL)estOuverte;

@end
