#import <Cocoa/Cocoa.h>

#import "general.h"
#import "CI_Journal.h"


static NSString *c_journal=@"Journal";

@implementation CI_Journal


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
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
    [verrou release];
	
	[dateFormatter release];
	
	[super dealloc];
}


- (void)afficher:(BOOL)flag
{
	if(!fenetre)
	{
		if (![NSBundle loadNibNamed:c_journal owner: self])
		{
			DEBUGNSLOG(@"Can't load Nib file %@",c_journal);
			return;
		}
		else
		{
			[fenetre setReleasedWhenClosed:NO];
			[fenetre setWorksWhenModal:YES];
			[fenetre setDelegate:self];
		}
	}
	if(flag)
		[fenetre makeKeyAndOrderFront:self];
}


- (void)windowWillClose:(NSNotification *)notification
{
}


- (void)print:(NSString *)chaineALoguer
{
 NSMutableAttributedString *uneChaine;


	[chaineALoguer retain];
    [verrou lock];
    
	uneChaine=[[NSMutableAttributedString alloc] initWithString:chaineALoguer];

	[[texte_journal textStorage] appendAttributedString:uneChaine];
	[texte_journal scrollRangeToVisible: NSMakeRange ([[texte_journal string] length], 0)];
	
	[uneChaine release];

    [verrou unlock];
	[chaineALoguer release];
}


- (void)informer:(NSString *)chaineALoguer
{
 NSMutableString *uneChaine;

	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	[chaineALoguer retain];
	
	uneChaine=[[NSString alloc] initWithFormat:@"[%@] %@\n", [dateFormatter stringFromDate:[NSDate date]], chaineALoguer];
    
    [self performSelectorOnMainThread:@selector(print:) withObject:uneChaine waitUntilDone:YES];
	
	[uneChaine release];
	[chaineALoguer release];
	
	[pool release];
}


- (IBAction)bouton_Clear:(id)sender
{
 id text;
	
	// initialisation à blanc du journal d'activité
    [verrou lock];
    
	text=[texte_journal textStorage];
	[text replaceCharactersInRange:NSMakeRange(0,[text length]) withString:@""];
    
    [verrou unlock];
}


- (void)receptionNotifAJournaliser:(id)unObjet
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	[unObjet retain];
	
	[self informer:[unObjet object]];
	
	[unObjet release];
		
	[pool release];
}


- (void)awakeFromNib
{
 id text;
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateStyle:NSDateFormatterShortStyle];
	[dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
	
    verrou = [[NSLock alloc] init]; 
    
	// initialisation à blanc du journal d'activité
	text=[texte_journal textStorage];
	[text replaceCharactersInRange:NSMakeRange(0,[text length]) withString:@""];

	NSNotificationCenter *nofifcenter=[NSNotificationCenter defaultCenter];
	[nofifcenter addObserver:self
					selector:@selector(receptionNotifAJournaliser:)
						name:D_NOTIFAJOURNALISER
					  object:nil];


	[pool release];
}

@end
