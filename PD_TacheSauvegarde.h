#import <Cocoa/Cocoa.h>

#import "CR_Tache.h"
#import "PD_Cle.h"
#import "PD_Logueur.h"


#define ER_NOERROR 0
#define ER_TASKCANTBELAUNCHED 1
#define ER_READINGPIPE 2
#define ER_TASKSTOPED 3
#define ER_CREATEDESTDIR 4
#define ER_DELREPSAV 5
#define ER_CREATESYMLINK 6
#define ER_DELOLD 7
#define ER_RENAMEFULL 8
#define ER_RENAMEINPROGRESS 9
#define ER_DELINPROGRESS 10

@interface PD_TacheSauvegarde : CR_Tache
{
    id pere;  // qui m'a créé

    PD_Cle *cle;
    BOOL aReplanifier;
	NSString *complementDInfo;

	NSString *notifDebutTacheSauvegarde;
	NSString *notifFinTacheSauvegarde;
	NSString *notifChangementTacheSauvegarde;
	
	PD_Logueur *logueur;
	
	NSString *tmpNomFichier;
}

@property(readwrite, retain) id pere;
@property(readwrite, retain) PD_Cle *cle;
@property(readwrite) BOOL aReplanifier;
@property(readwrite, retain) NSString *complementDInfo;

@property(readwrite, retain) NSString *notifDebutTacheSauvegarde;
@property(readwrite, retain) NSString *notifFinTacheSauvegarde;
@property(readwrite, retain) NSString *notifChangementTacheSauvegarde;

@end
