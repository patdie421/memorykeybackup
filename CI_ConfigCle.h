#import <Cocoa/Cocoa.h>


@interface CI_ConfigCle : NSObject
{
    IBOutlet id fenetre_configCle;
    IBOutlet id label_identifiantCle;
    IBOutlet id champ_descriptionCle;
    
    IBOutlet id champ_repertoireSauvegarde;
    
    IBOutlet id boutons_typeSauvegarde;
    
    IBOutlet id boutons_actionsALInsertion;
    IBOutlet id champ_actionsALInsertion;
    IBOutlet id boutonPopUp_actionALInsertion;
    IBOutlet id stepper_actionsALInsertion;
    IBOutlet id bouton_labelNever1;
    IBOutlet id bouton_labelImmediatly;
    IBOutlet id bouton_labelIf;
    IBOutlet id bouton_labelWhere;
    
    IBOutlet id boutons_planning;
    IBOutlet id champ_planning;
    IBOutlet id boutonPopUp_planning;
    IBOutlet id stepper_planning;
    IBOutlet id bouton_labelNever2;
    IBOutlet id bouton_labelAfterLastBackup;
    
    
	id db_cles;
	id CI_principal;

	id enregistrementAModifier;
	NSString *ancienRepertoireBackup;
}

@property(readonly) id enregistrementAModifier;
@property(readwrite,retain) id db_cles;
@property(readwrite,retain) id CI_principal;

- (IBAction)boutons:(id)sender;
- (IBAction)bouton_choisir:(id)sender;
- (IBAction)bouton_ok:(id)sender;
- (IBAction)bouton_annuler:(id)sender;
- (IBAction)bouton_labelNever1:(id)sender;
- (IBAction)bouton_labelImmediatly:(id)sender;
- (IBAction)bouton_labelIfWhere:(id)sender;
- (IBAction)bouton_labelNever2:(id)sender;
- (IBAction)bouton_labelAfterLastBackup:(id)sender;

- (void)ouvrirModal:(id)mere avecCleParIndex:(int)indexCle;
- (void)ouvrirModal:(id)mere avecCleParIdCle:(id)idCle;

@end
