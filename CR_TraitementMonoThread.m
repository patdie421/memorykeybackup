#import <Cocoa/Cocoa.h>

#import "CR_TraitementMonoThread.h"


@implementation CR_TraitementMonoThread

- (id)init
{
    return [self initWithFile:nil nom:@""];
}


- (id)initWithNom:(NSString *)unNom
{
 id uneFile;

	[unNom retain];
	
	uneFile=[[CR_File alloc] init];
    if (self = [super initWithFile:uneFile nom:unNom])
	{
		id desTaches;
		desTaches=[[NSMutableArray alloc] init];
        [self setTachesEnCoursDExecution:desTaches];
		[desTaches release];

		id unVerrou;
		unVerrou=[[NSConditionLock alloc] initWithCondition:1]; // 1 = nb de thread
		[self setSynchroFinDeTache:unVerrou];
		[unVerrou release];
	}
	[uneFile release];
	
	[unNom release];
	
	return self;
}


- (void)ajouterTacheDansFileDEntree:(CR_Tache *)uneTache
{
    [fileDEntree inWithLock:uneTache];
}


- (BOOL)wait:(NSInteger)leTimeout
{
    if(synchroFinDeTache)
    {
        BOOL retour;
        
        retour=[synchroFinDeTache lockWhenCondition:0 beforeDate:[NSDate dateWithTimeIntervalSinceNow:leTimeout]];
        if(retour)
        {
            [synchroFinDeTache unlock];
            return YES;
        }
    }
    
    return NO;
}

@end
