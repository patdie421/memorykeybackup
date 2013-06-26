#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>

#import "CR_Consommateur.h"
#import "DB_Cles.h"
#import "PD_Tuyaux.h"

#import "CI_InfosTachesControleurListe.h"


@interface CI_InfosTaches : NSObject
{
	IBOutlet id fenetre;
    IBOutlet NSTableView *table_listePlanificationEtTachesEnCours;
    IBOutlet NSTableColumn *colonne_status;
	IBOutlet id label_info;
	
    id CI_principal;
    DB_Cles *db_cles;
    
	CI_InfosTachesControleurListe *controleurListe;
	PD_Tuyaux *lesTuyaux;
	NSLock *verrouReload;
	
    NSMutableArray *listeDesControleursDeCellules; // liste des controleurs des "views" des cellules
	
}

@property(readwrite, retain) id CI_principal;
@property(readwrite, retain) DB_Cles *db_cles;
@property(readwrite, retain) PD_Tuyaux *lesTuyaux;

- (void)afficher:(BOOL)flag;

@end
