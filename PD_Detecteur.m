#import <Cocoa/Cocoa.h>

#import "PD_Detecteur.h"
#import "CR_File.h"
#import "PD_TacheDispatcheur.h"


@implementation PD_Detecteur

@synthesize pere;
@synthesize dispatcheur;


-(id)init:(SEL)mountNotificationMethod:(SEL)umountNotificationMethod 
{
 NSWorkspace *CurrentAppsSharedWorkspace; 
 NSNotificationCenter *WorkspaceNotificationCenter; 
    
	if(self=[super init])
    {
        CurrentAppsSharedWorkspace=[NSWorkspace sharedWorkspace];
        WorkspaceNotificationCenter=[CurrentAppsSharedWorkspace notificationCenter];
        
        [WorkspaceNotificationCenter addObserver:self selector:mountNotificationMethod name:NSWorkspaceDidMountNotification object:nil];
        [WorkspaceNotificationCenter addObserver:self selector:umountNotificationMethod name:NSWorkspaceDidUnmountNotification object:nil];
    }
    return self;
}


- (id)init
{
    return [self init:@selector(mountNotification:):@selector(umountNotification:)];
}


- (void)dealloc 
{
	NSWorkspace* CurrentAppsSharedWorkspace=[NSWorkspace sharedWorkspace]; 
    NSNotificationCenter* WorkspaceNotificationCenter=[CurrentAppsSharedWorkspace notificationCenter]; 
    
    [WorkspaceNotificationCenter removeObserver:self]; 
    
    [dispatcheur release];
    [pere release];
    
    [super dealloc];
}


- (void)nouvelleTache:(BOOL)montage chemin:(NSString *)chemin
{
 PD_TacheDispatcheur *maTache;
    
    maTache = [[PD_TacheDispatcheur alloc] init];
    [maTache setPointDeMontage:chemin];
    [maTache setMontageOuDemontage:montage];
    
    [dispatcheur ajouterTacheDansFileDEntree:maTache];
    
    [maTache release];
}


- (void)detectionInitiale
{
 NSString *path;
 NSWorkspace *sharedWorkspace = [NSWorkspace sharedWorkspace];
    
    NSEnumerator *mountedPathsEnumerator = [[sharedWorkspace mountedLocalVolumePaths] objectEnumerator];
    while (path = [mountedPathsEnumerator nextObject] ) 
        [self nouvelleTache:YES chemin:path];
}


-(void)mountNotification: (NSNotification *)mountNotificationRecieved 
{ 
    NSString *chemin=[[mountNotificationRecieved userInfo] objectForKey: @"NSDevicePath"];
  
    [self nouvelleTache:YES chemin:chemin];
}


-(void)umountNotification:(NSNotification *)umountNotificationRecieved 
{
    NSString *chemin=[[umountNotificationRecieved userInfo] objectForKey: @"NSDevicePath"];
    
    [self nouvelleTache:NO chemin:chemin];
} 


@end
