#import <Cocoa/Cocoa.h>

#import "CR_File.h"
#import "CR_Tache.h"


@interface CR_TraitementsMultiThreads : NSObject
{
    BOOL traitementsEnCours;
    NSInteger nbThread;
    NSMutableArray *listeDesThreads;
    CR_File * fileDEntree;
    
	NSMutableArray *tachesEnCoursDExecution;
    NSLock *verrouSurTachesEnCoursDExecution;
    NSConditionLock *synchroFinDeTache;    

	NSString *notifLancementTache;
	NSString *notifFinTache;
	NSString *notifErreurTache;
}

@property(readonly) NSMutableArray *tachesEnCoursDExecution;
@property(readonly) NSLock *verrouSurTachesEnCoursDExecution;
@property(readonly) CR_File *fileDEntree;
@property(readwrite) NSInteger nbThread;

@property(readwrite, retain) NSString *notifLancementTache;
@property(readwrite, retain) NSString *notifFinTache;
@property(readwrite, retain) NSString *notifErreurTache;

- (BOOL)arreter:(NSInteger)timeout;
- (BOOL)run:(NSInteger)nb racineDuNomDesThreads:(NSString *)uneRacine;

- (void)ajouterTacheDansFileDEntree:(CR_Tache *)uneTache;

@end
