#import <Cocoa/Cocoa.h>

#import "CI_GestionDesNotificationsDAffichage.h"
#import "CI_APropos.h"
#import "CI_Preferences.h"
#import "CI_Restauration.h"
#import "CI_Journal.h"
#import "CI_InfosTaches.h"

#import "PD_Moteur.h"

#import <Cocoa/Cocoa.h>


@interface CI_Principal : NSObject
{
	IBOutlet id CI_listeCles;
	IBOutlet id fenetre_CI_listeCles;
    
	IBOutlet id db_cles;
	
//    CI_ConfigCle *CI_configCle;
    CI_InfosTaches *CI_infosTaches;
	CI_APropos *CI_apropos;
	CI_Preferences *CI_preferences;
//	CI_Restauration *CI_restauration;
	CI_Journal *CI_journal;
	CI_GestionDesNotificationsDAffichage *CI_gestionDesNotificationDAffichage;
	
    BOOL initDidComplet;
	NSUserDefaults *prefs;
	id valeursParDefaut;
	
    PD_Moteur *moteur;
}

// @property(readonly) id CI_configCle;
@property(readonly) id CI_infosTaches;
@property(readonly) id CI_listeCles;
// @property(readonly) CI_Restauration *CI_restauration;
@property(readonly) CI_GestionDesNotificationsDAffichage *CI_gestionDesNotificationDAffichage;

@property(readonly) PD_Moteur *moteur;

@property(readonly) NSUserDefaults *prefs;
@property(readonly) id valeursParDefaut;


- (IBAction)menu_sauver:(id)sender;

- (IBAction)menu_apropos:(id)sender;
- (IBAction)menu_preferences:(id)sender;
- (IBAction)menu_journal:(id)sender;
- (IBAction)menu_infosTaches:(id)sender;

// - (BOOL)retaurer:(int)indexCle;

- (int)dialog:          (NSString *)titre
       message:         (NSString *)msg
       boutonParDefaut: (NSString *)boutonParDefaut
       boutonAlternatif:(NSString *)boutonAlternatif
       autreBouton:     (NSString *)autreBouton;

@end
