#import "general.h"

#import "CI_ProgressionRestauration.h"
#import "CI_Restauration.h"


static NSString *c_progressionRestauration=@"ProgressionRestauration";

@implementation CI_ProgressionRestauration

@synthesize progress;
@synthesize tache;

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


-(void)finTache
{
	[NSApp abortModal];
}


-(void)tacheTerminee:(id)sender
{
	[NSApp abortModal];
}


-(void)_changementTache:(id)sender
{
	if([tache avancement]>=0)
	{
		[progress setIndeterminate:NO];
		[progress startAnimation:nil];
		[progress setDoubleValue:[tache avancement]];
	}
	else
	{
		[progress setIndeterminate:YES];
		[progress startAnimation:nil];
	}

	[info setStringValue:[tache complementDInfo]];
}


-(void)changementTache:(id)sender
{
	[self performSelectorOnMainThread:@selector(_changementTache:) withObject:sender waitUntilDone:YES];
}


- (BOOL)modal:(id)mere
{
	flag=YES;
	
	if(!fenetre)
	{
		if (![NSBundle loadNibNamed:c_progressionRestauration owner: self])
		{
			DEBUGNSLOG(@"Can't load Nib file %@",c_progressionRestauration);
			return NO;
		}
		else
		{
			[fenetre setReleasedWhenClosed:YES];
			[fenetre setDelegate:self];
		}
	}
	
	[progress setIndeterminate:YES];
	[progress startAnimation:nil];
	
	NSNotificationCenter *notifcenter=[NSNotificationCenter defaultCenter];
	[notifcenter addObserver:self
					selector:@selector(tacheTerminee:)
						name:D_NOTIFFINRESTAURATION
					  object:nil];
	[notifcenter addObserver:self
					selector:@selector(changementTache:)
						name:D_NOTIFCHANGEMENTRESTAURATION
					  object:nil];

	[NSApp beginSheet: fenetre
       modalForWindow: mere
        modalDelegate: nil
       didEndSelector: nil
          contextInfo: nil];
    [NSApp runModalForWindow:fenetre];
    [NSApp endSheet:fenetre];
    [fenetre orderOut:self];
	
	[notifcenter removeObserver:self];
	[notifcenter release];
	
	return flag;
}


-(IBAction)bouton_annuler:(id)sender
{
	@synchronized(tache)
	{
		[tache setInterrompreTache:YES];
	}
	flag=NO;
}


@end
