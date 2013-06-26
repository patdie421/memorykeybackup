#import <Cocoa/Cocoa.h>

#import "general.h"
#import "CR_Notificateur.h"


static NSMutableDictionary *notificationsDejaUtilisees;

@implementation CR_Notificateur

+(void)initialize
{
	if(!notificationsDejaUtilisees)
		notificationsDejaUtilisees=[[NSMutableDictionary alloc] init];
}


-(id)init
{
    if(self=[super init])
    {
    }
    return self;
}


-(void)dealloc
{
    [super dealloc];
}


-(void)envoyerNotification:(NSString *)identNotif
{
 NSNotification *uneNotif;
	
	if(!identNotif)
		return;
	
	@synchronized(notificationsDejaUtilisees)
	{
		uneNotif=[notificationsDejaUtilisees objectForKey:identNotif];
		if(!uneNotif)
		{
			DEBUGNSLOG(@"Nouvelle notification (%@), %d notifications creees",identNotif,[notificationsDejaUtilisees count]);
			uneNotif=[NSNotification notificationWithName:identNotif object:nil];
			[notificationsDejaUtilisees setObject:uneNotif forKey:identNotif];
		}
	}
	[[NSNotificationQueue defaultQueue]
		enqueueNotification: uneNotif
		postingStyle: NSPostNow
		coalesceMask: NSNotificationNoCoalescing
		forModes: nil];
}

@end
