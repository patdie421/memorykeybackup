#import <Cocoa/Cocoa.h>

#import "general.h"

#import "DB_Cles.h"

#import "PD_Moteur.h"

#import "PD_Dispatcheur.h"
#import "PD_Enregistreur.h"

#import "CI_Principal.h"
#import "CI_APropos.h"
#import "CI_ListeCles.h"
#import "CI_Preferences.h"
#import "CI_Restauration.h"
#import "CI_InfosTaches.h"
#import "CI_Journal.h"
#import "CI_GestionDesNotificationsDAffichage.h"


@implementation CI_Principal

// @synthesize CI_configCle;
@synthesize CI_infosTaches;
@synthesize CI_gestionDesNotificationDAffichage;
// @synthesize CI_restauration;
@synthesize CI_listeCles;

@synthesize moteur;

@synthesize prefs;
@synthesize valeursParDefaut;

/*
 * Initialisation et fin
 */
- (void)dealloc
{
    [moteur release];
	[prefs release];
	[valeursParDefaut release];
	[CI_apropos release];
	[CI_preferences release];
	[CI_gestionDesNotificationDAffichage release];	
//	[CI_restauration release];
	[CI_journal release];
	[CI_infosTaches release];
	
	[super dealloc];
}


- (void)awakeFromNib
{
    prefs = [[NSUserDefaults standardUserDefaults] retain];
	
	valeursParDefaut=[prefs dictionaryForKey:D_DEFAULTS];
	if(!valeursParDefaut)
    {
        valeursParDefaut=[[NSMutableDictionary alloc] init];
		
        [valeursParDefaut setObject:[D_DATAFILE stringByDeletingLastPathComponent] forKey:D_BACKDIR];
        [valeursParDefaut setObject:[NSNumber numberWithInt:1] forKey:D_BACKUPTYPE];
        [valeursParDefaut setObject:[NSNumber numberWithInt:1] forKey:D_ACTIONINSERSION];
        [valeursParDefaut setObject:[NSNumber numberWithInt:8] forKey:D_ACTIONINSERSION_NB];
        [valeursParDefaut setObject:[NSNumber numberWithInt:0] forKey:D_ACTIONINSERSION_UNITE];
        [valeursParDefaut setObject:[NSNumber numberWithInt:1] forKey:D_PLANNING];
        [valeursParDefaut setObject:[NSNumber numberWithInt:8] forKey:D_PLANNING_NB];
        [valeursParDefaut setObject:[NSNumber numberWithInt:0] forKey:D_PLANNING_UNITE];
        [valeursParDefaut setObject:[NSNumber numberWithDouble:tailleEnFonctionDePositionSlider(2)] forKey:D_MAXKEYSIZE];
        [valeursParDefaut setObject:[NSArray arrayWithObjects:D_MSDOS,D_NODMCI,D_NOTKEY,D_AFPFS,nil] forKey:D_DETECTION];
        [valeursParDefaut setObject:[NSNumber numberWithInt:NSOffState] forKey:D_AUTODECLARATION];
        [valeursParDefaut setObject:[NSNumber numberWithInt:NSOffState] forKey:D_ADVANCED];
		
        [prefs setObject:valeursParDefaut forKey:D_DEFAULTS];
    }
	else
	{
		[valeursParDefaut retain];
	}
	
    initDidComplet=NO;
}


- (void)applicationDidFinishLaunching:(NSNotification *)uneNotification
{
	BOOL isDir,retour;
	NSFileManager *fileManager;
	NSString *fichier;
    
	
    fileManager = [NSFileManager defaultManager];
    fichier=[D_DATAFILE stringByExpandingTildeInPath]; 
    if ([fileManager fileExistsAtPath:fichier isDirectory:&isDir] && !isDir)
	{
        DEBUGNSLOG(@"OK, the file %@ exist",fichier);
	}
    else
    {
        fichier=[fichier stringByDeletingLastPathComponent];
        if ([fileManager fileExistsAtPath:fichier isDirectory:&isDir] && isDir)
		{
            DEBUGNSLOG(@"OK, directory %@ exist",fichier);
		}
        else
        {   // il n'existe pas donc ...
            // création du repertoire et de tous les répertoires du chemin si nécessaire
            retour=[fileManager createDirectoryAtPath:fichier withIntermediateDirectories:YES attributes:nil error:nil];
            if(retour)
			{
                DEBUGNSLOG(@"Directory %@ was created", fichier);
			}
            else
            {
                // poursuite impossible : fin de l'appication
                DEBUGNSLOG(@"Can't create directory %@", fichier);
                NSBeep();
                NSRunAlertPanel(NSLocalizedString(@"CANTCREATEDBDIR",nil),
                                fichier,
                                NSLocalizedString(@"B_OK",nil),
                                nil,
                                nil); 
                [NSApp terminate:self];
            }
        }
    }
	
	[db_cles charger];
	
    [CI_listeCles chargerColonnesTable:prefs];

//	CI_configCle=[[CI_ConfigCle alloc] init];
//	[CI_configCle setDb_cles:db_cles];
//	[CI_configCle setCI_principal:self];
//	[CI_listeCles setCI_configCle:CI_configCle];
	
	CI_journal=[[CI_Journal alloc] init];
	[CI_journal afficher:NO];
	
    initDidComplet=YES;
	
	// lancement du moteur de sauvegarde
    moteur=[[PD_Moteur alloc] init];
    [moteur setPere:self];
    [moteur setDb_cles:db_cles];
    [moteur demarrer];
	
	CI_infosTaches=[[CI_InfosTaches alloc] init];
	[CI_infosTaches setDb_cles:db_cles];
	[CI_infosTaches setCI_principal:self];
	[CI_infosTaches afficher:NO];
	[CI_infosTaches setLesTuyaux:[moteur tuyaux]];
	
	CI_gestionDesNotificationDAffichage=[[CI_GestionDesNotificationsDAffichage alloc] init];
	[CI_gestionDesNotificationDAffichage setCI_listeCles:CI_listeCles];
//	[CI_gestionDesNotificationDAffichage setCI_configCle:CI_configCle];
	[CI_gestionDesNotificationDAffichage setCI_infosTaches:CI_infosTaches];
	[CI_gestionDesNotificationDAffichage setTimeout:120];	
}


- (void) applicationWillTerminate: (NSNotification *)uneNotification
{
    [moteur arreter];
    if(initDidComplet)
    {
        [db_cles sauvegarder];
		
        [CI_listeCles sauvegarderColonnesTable:prefs];
    }
	[CI_gestionDesNotificationDAffichage arreter];
}


/*
 * demande pour les Threads
 */
- (void)_dialog:(NSMutableDictionary *)paramEtRetour
{
 int status;

	[paramEtRetour retain];
	
    status = NSRunAlertPanel([paramEtRetour objectForKey:@"titre"],
                             [paramEtRetour objectForKey:@"msg"],
                             [paramEtRetour objectForKey:@"boutonParDefaut"],
                             [paramEtRetour objectForKey:@"boutonAlternatif"],
                             [paramEtRetour objectForKey:@"autreBouton"]);    

    [paramEtRetour setObject:[NSNumber numberWithInt:status] forKey:@"retour"];
	
	[paramEtRetour release];
}


- (int)dialog:          (NSString *)titre
       message:         (NSString *)msg
       boutonParDefaut: (NSString *)boutonParDefaut
       boutonAlternatif:(NSString *)boutonAlternatif
       autreBouton:     (NSString *)autreBouton
{
 NSMutableDictionary *paramEtRetour;
 int retour;
    
    paramEtRetour=[[NSMutableDictionary alloc] init];
    
    if(titre)            [paramEtRetour setObject:titre            forKey:@"titre"];
    if(msg)              [paramEtRetour setObject:msg              forKey:@"msg"];
    if(boutonParDefaut)  [paramEtRetour setObject:boutonParDefaut  forKey:@"boutonParDefaut"];
    if(boutonAlternatif) [paramEtRetour setObject:boutonAlternatif forKey:@"boutonAlternatif"];
    if(autreBouton)      [paramEtRetour setObject:autreBouton      forKey:@"autreBouton"];
    
    [self performSelectorOnMainThread:@selector(_dialog:) withObject:paramEtRetour waitUntilDone:YES];

    retour=[[paramEtRetour objectForKey:@"retour"] intValue];
    
    [ paramEtRetour release];
    
    return retour;
}
/*
 * fin demande pour les Threads
 */
/*
- (BOOL)retaurer:(int)indexCle
{
	if(!CI_restauration)
	{
		CI_restauration=[[CI_Restauration alloc] init];
		[CI_restauration setDbCle:db_cles];
		[CI_restauration setCI_principal:self];
	}
	return [CI_restauration afficher:indexCle];
}
*/

/*
 * Gestion des boutons
 */
- (IBAction)menu_sauver:(id)sender
{
	[db_cles sauvegarder];
}


- (IBAction)menu_apropos:(id)sender
{
	if(!CI_apropos)
	{
		CI_apropos=[[CI_APropos alloc] init];
	}
	[CI_apropos afficher];
}


- (IBAction)menu_preferences:(id)sender
{
	if(!CI_preferences)
	{
		CI_preferences=[[CI_Preferences alloc] init];
		[CI_preferences setValeursParDefaut:[self valeursParDefaut]];
		[CI_preferences setCI_listeCles:CI_listeCles];
	}
	[CI_preferences afficher];
}


-(IBAction)menu_journal:(id)sender
{
	[CI_journal afficher:YES];
}


-(IBAction)menu_infosTaches:(id)sender
{
	[CI_infosTaches afficher:YES];
}

@end
