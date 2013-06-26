#import <Cocoa/Cocoa.h>

#import "CI_ListeCles.h"
#import "CI_ConfigCle.h"
#import "CI_InfosTaches.h"


@interface CI_GestionDesNotificationsDAffichage : CR_Consommateur
{
	id CI_listeCles;
	id CI_infosTaches;
	
	CR_File *fileNotificationsDAffichage;
}

@property(readwrite, retain) id CI_listeCles;
@property(readwrite, retain) id CI_infosTaches;

@end
