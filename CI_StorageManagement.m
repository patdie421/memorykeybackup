#import <Cocoa/Cocoa.h>

#import "general.h"

#import "CI_StorageManagement.h"

#import "PD_Cle.h"
#import "DB_Cles.h"
#import "CI_GetADate.h"

#define UNESEMAINE -604800

static NSString *c_storageManagement=@"StorageManagement";


@implementation CI_StorageManagement

@synthesize db_cles;

- (id) init
{
    if ((self = [super init]) != nil)
    {
		fenetre=nil;
    }
	
    return self;
}


- (void)dealloc 
{
	[super dealloc];
}


- (void)windowWillClose:(NSNotification *)notification
{
	fenetre=nil;
}


- (void)griserBoutons:(NSString *)chemin
{
	NSString *cheminComplet;
	NSFileManager *fileManager = [NSFileManager defaultManager];
	BOOL flag;
	
	flag=[fileManager fileExistsAtPath:chemin isDirectory:NULL];
	[bouton_finder setEnabled:flag];

	for(id o in cboxs)
		[o setIntValue:NO];
	
	flag=[fileManager fileExistsAtPath:chemin isDirectory:NULL];
	[bouton_finder setEnabled:flag];
	
	cheminComplet=[[NSString alloc] initWithFormat:@"%@/incr",chemin];
	flag=[fileManager fileExistsAtPath:cheminComplet isDirectory:NULL];
	[cbox_deleteallinc setEnabled:flag];
	[cbox_deleteoldestinc setEnabled:flag];
	[cheminComplet release];
	
	cheminComplet=[[NSString alloc] initWithFormat:@"%@/sync",chemin];
	flag=[fileManager fileExistsAtPath:cheminComplet isDirectory:NULL];
	[cbox_deleteallsync setEnabled:flag];
	[cheminComplet release];
	
	cheminComplet=[[NSString alloc] initWithFormat:@"%@/sync/.syncdb",chemin];
	flag=[fileManager fileExistsAtPath:cheminComplet isDirectory:NULL];
	[cbox_deletedbsync setEnabled:flag];
	[cheminComplet release];

	cheminComplet=[[NSString alloc] initWithFormat:@"%@/full/last",chemin];
	flag=[fileManager fileExistsAtPath:cheminComplet isDirectory:NULL];
	[cbox_deletecurrentfull setEnabled:flag];
	[cheminComplet release];
	
	cheminComplet=[[NSString alloc] initWithFormat:@"%@/full/old",chemin];
	flag=[fileManager fileExistsAtPath:cheminComplet isDirectory:NULL];
	[cbox_deleteoldfull setEnabled:flag];
	[cheminComplet release];
	
	[bouton_process setEnabled:NO];
	[picker_date setEnabled:NO];
}


- (void)modal:(id)mere indexCle:(int)indexCle
{
	id champCleDb;
	NSString *idCle;
	NSString *chemin;
	NSDate *uneDate;
		
	if(!fenetre)
	{
		if (![NSBundle loadNibNamed:c_storageManagement owner: self])
		{
			DEBUGNSLOG(@"Can't load Nib file %@",c_storageManagement);
			return;
		}
		else
		{
			[fenetre setReleasedWhenClosed:YES];
			[fenetre setDelegate:self];
			
			cboxs=[[NSArray alloc] initWithObjects:
				   cbox_deleteallinc,
				   cbox_deleteoldestinc,
				   cbox_deletecurrentfull,
				   cbox_deleteoldfull,
				   cbox_deleteallsync,
				   cbox_deletedbsync,
				   nil];
		}
	}
	
	champCleDb=[db_cles cleParPosition:indexCle];
	idCle=[champCleDb objectForKey:D_IDCLE];
	chemin=[[NSString alloc] initWithFormat:@"%@/%@",[champCleDb objectForKey:D_BACKDIR],idCle];
	
	[label_idcle setStringValue:idCle];
	[champ_backupdirectory setStringValue:chemin];
	
	uneDate=[[NSDate alloc] initWithTimeIntervalSinceNow:UNESEMAINE];
	[picker_date setDateValue:uneDate];
	[uneDate release];
	
	[self griserBoutons:chemin];
	
	[chemin release];
	
	[NSApp beginSheet: fenetre
       modalForWindow: mere
        modalDelegate: nil
       didEndSelector: nil
          contextInfo: nil];
    [NSApp runModalForWindow:fenetre];
    [NSApp endSheet:fenetre];
    [fenetre orderOut:self];
}


-(IBAction)cboxs:(id)sender
{
	switch ([sender tag])
	{
		case 1:
			if([sender intValue]==1)
				[cbox_deleteoldestinc setIntValue:0];
			break;
		case 2:
			if([sender intValue]==1)
				[cbox_deleteallinc setIntValue:0];
			break;

		case 5:
			if([sender intValue]==1)
				[cbox_deletedbsync setIntValue:0];
			break;
		case 6:
			if([sender intValue]==1)
				[cbox_deleteallsync setIntValue:0];
			break;
		default:
			break;
	}
	
	[picker_date setEnabled:[cbox_deleteoldestinc intValue]];

	BOOL flag=NO;
	for(id o in cboxs)
	{
		if([o intValue]==1)
		{
			flag=YES;
			break;
		}
	}
	[bouton_process setEnabled:flag];
}


-(IBAction)process:(id)sender
{
	NSString *racine;
	int status;
	
	status = NSRunAlertPanel(NSLocalizedString(@"TITLEDELETINGDIRECTORYCONFIRMATION",nil),
                             NSLocalizedString(@"TITLEDELETINGDIRECTORYCONFIRMATION+",nil),
                             NSLocalizedString(@"B_DO_IT",nil),
                             NSLocalizedString(@"B_CANCEL",nil),
                             nil);   
 	if(!status)
		return;
	
	racine=[champ_backupdirectory stringValue];
	[racine retain];
	
	if([cbox_deleteallinc intValue])
	{
		NSString *chemin=[[NSString alloc] initWithFormat:@"%@/incr",racine];
		DEBUGNSLOG(@"Deleting %@",chemin);
		testExistAndRemoveIfTrue(chemin);
		[chemin release];
	}
	
	if([cbox_deleteoldestinc intValue])
	{
		NSArray *contenuRepertoire;
		
		NSString *chemin=[[NSString alloc] initWithFormat:@"%@/incr",racine];
		if(contenuRepertoire=[[NSFileManager defaultManager] contentsOfDirectoryAtPath:chemin error:NULL])
		{
			NSDate *uneDate=[picker_date dateValue];
			for(id o in contenuRepertoire)
			{
				NSDate *dateRep=[[NSDate alloc] initWithString:o];
				if([dateRep compare:uneDate]==NSOrderedAscending)
				{
					NSString *ficToDel=[[NSString alloc] initWithFormat:@"%@/%@",chemin,o];
					DEBUGNSLOG(@"Deleting %@",ficToDel);
					testExistAndRemoveIfTrue(ficToDel);
					[ficToDel release];
				}
				else
				{
					[dateRep release];
					break;
				}
				[dateRep release];
			}
		}
		[chemin release];
	}

	if([cbox_deletecurrentfull intValue])
	{
		NSString *chemin=[[NSString alloc] initWithFormat:@"%@/full/last",racine];
		DEBUGNSLOG(@"Deleting %@",chemin);
		testExistAndRemoveIfTrue(chemin);
		[chemin release];
	}
	
	if([cbox_deleteoldfull intValue])
	{
		NSString *chemin=[[NSString alloc] initWithFormat:@"%@/full/old",racine];
		DEBUGNSLOG(@"Deleting %@",chemin);
		testExistAndRemoveIfTrue(chemin);
		[chemin release];
	}
	
	if([cbox_deleteallsync intValue])
	{
		NSString *chemin=[[NSString alloc] initWithFormat:@"%@/sync",racine];
		DEBUGNSLOG(@"Deleting %@",chemin);
		testExistAndRemoveIfTrue(chemin);
		[chemin release];
	}
	
	if([cbox_deletedbsync intValue])
	{
		NSString *chemin=[[NSString alloc] initWithFormat:@"%@/sync/.syncdb",racine];
		DEBUGNSLOG(@"Deleting %@",chemin);
		testExistAndRemoveIfTrue(chemin);
		[chemin release];
	}
	
	[self griserBoutons:racine];
	
	[racine release];
}


-(IBAction)done:(id)sender
{
	[NSApp stopModal];
}


-(IBAction)locateInFinder:(id)sender
{
	[[NSWorkspace sharedWorkspace] openFile:[champ_backupdirectory stringValue] withApplication:@"Finder"];
}


@end
