#import <Cocoa/Cocoa.h>

#import "PD_Cle.h"


@interface CI_StorageManagement : NSObject
{
	IBOutlet id fenetre;

	IBOutlet id label_idcle;
	IBOutlet id champ_backupdirectory;
	IBOutlet id cbox_deleteallinc;
	IBOutlet id cbox_deleteoldestinc;
	IBOutlet id cbox_deletecurrentfull;
	IBOutlet id cbox_deleteoldfull;
	IBOutlet id cbox_deleteallsync;
	IBOutlet id cbox_deletedbsync;
	IBOutlet id picker_date;
	IBOutlet id bouton_process;
	IBOutlet id bouton_finder;

	id db_cles;
	NSArray * cboxs;
}

-(IBAction)cboxs:(id)sender;
-(IBAction)process:(id)sender;
-(IBAction)done:(id)sender;
-(IBAction)locateInFinder:(id)sender;

@property(readwrite,retain) id db_cles;

- (void)modal:(id)mere indexCle:(int)indexCle;

@end
