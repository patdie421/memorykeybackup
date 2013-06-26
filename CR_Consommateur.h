#import <Cocoa/Cocoa.h>

#import "CR_File.h"


@interface CR_Consommateur : NSObject
{
	NSString *nom;
	
	int timeout;

	CR_File *fileDEntree;

    BOOL estEnCoursDExecution;
    BOOL doitSArreter;

    NSLock *verrouSurTacheEnCoursDExecution;
    NSMutableArray *tachesEnCoursDExecution;
    
    NSConditionLock *synchroFinDeTache;
    
	NSString *notifLancementTache;
	NSString *notifFinTache;
	NSString *notifErreurTache;
	
    id infosComplementaires;
}

@property(readonly) NSString *nom;

@property(readwrite) int timeout;

@property(readwrite, retain) CR_File *fileDEntree;
@property(readwrite) BOOL estEnCoursDExecution;
@property(readwrite) BOOL doitSArreter;
@property(readwrite, retain) NSLock *verrouSurTacheEnCoursDExecution;
@property(readwrite, retain) NSMutableArray *tachesEnCoursDExecution;
@property(readwrite, retain) NSConditionLock *synchroFinDeTache;
@property(readwrite, retain) id infosComplementaires;

@property(readwrite, retain) NSString *notifLancementTache;
@property(readwrite, retain) NSString *notifFinTache;
@property(readwrite, retain) NSString *notifErreurTache;

+ (void)consommateur:(id)instanceDeConsommateur;

- (id)initWithFile:(id)uneFile nom:unNom;
- (void)run;
- (void)arreter;
- (void)supprimerToutesLesNotifications;

@end