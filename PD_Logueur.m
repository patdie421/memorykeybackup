#import "general.h"
#import "PD_Logueur.h"


@implementation PD_Logueur


-(id)init
{
	if (self = [super init])
	{
	}
	return self;
}


-(void)envoyerNotification:(NSNotification *)uneNotif
{
	[uneNotif retain];
	
	[[NSNotificationQueue defaultQueue]
	 enqueueNotification: uneNotif
	 postingStyle: NSPostASAP
	 coalesceMask: NSNotificationNoCoalescing
	 forModes: nil];
	
	[uneNotif release];
}


-(void)loguerMessage:(NSString *)uneChaine
{
	[uneChaine retain];
	
	NSNotification *uneNotif=[NSNotification notificationWithName:D_NOTIFAJOURNALISER object:uneChaine];
	[self performSelectorOnMainThread:@selector(envoyerNotification:) withObject:uneNotif waitUntilDone:YES];
	
	[uneChaine release];
}

@end
