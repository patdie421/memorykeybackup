#import <Cocoa/Cocoa.h>


@interface CI_Preferences : NSObject
{
	IBOutlet id fenetre;

    // onglet display
    IBOutlet id cb_colonne1;
    IBOutlet id cb_colonne2;
    IBOutlet id cb_colonne3;
    IBOutlet id cb_colonne4;
    IBOutlet id cb_colonne5;
    IBOutlet id cb_colonne6;
    IBOutlet id cb_colonne7;
    IBOutlet id cb_colonne8;

    // onglet defaults
    IBOutlet id champ_repertoireSauvegarde;
    IBOutlet id boutons_typeBackup;
    
    IBOutlet id boutons_actionsALInsertion;
    IBOutlet id champ_actionsALInsertion;
    IBOutlet id boutonPopUp_actionALInsertion;
    
    IBOutlet id boutons_planning;
    IBOutlet id champ_planning;
    IBOutlet id boutonPopUp_planning;
    IBOutlet id slider_tailleMax;
    IBOutlet id label_tailleMax;
	
	IBOutlet id checkBox_autodeclaration;
	IBOutlet id checkBox_advancedOption;
	
	IBOutlet id stepper_insertion;
	IBOutlet id stepper_planning;

    // onglet detection
    IBOutlet id checkBox_msdos;
    IBOutlet id checkBox_hfs;
    IBOutlet id checkBox_ntfs;
    IBOutlet id checkBox_afpfs;
    IBOutlet id checkBox_other;
    IBOutlet id checkBox_nodmci;
    IBOutlet id checkBox_notkey;
    
    // autres objets
	id CI_listeCles;
    id valeursParDefaut;
    
    NSArray *indicateursDetection;
}

@property(readwrite,retain) id CI_listeCles;
@property(readwrite,retain) id valeursParDefaut;

- (IBAction)actionCaseACocher:(id)sender;
- (IBAction)bouton_fermer:(id)sender;
- (IBAction)bouton_choose:(id)sender;
- (IBAction)slider_tailleMax:(id)sender;
- (IBAction)checkBoxs:(id)sender;
- (IBAction)checkAdvancedOption:(id)sender;

- (void)afficher;

- (void)updatePrefs;
- (void)loadPrefs;

@end
