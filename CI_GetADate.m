#import <Cocoa/Cocoa.h>

#import "general.h"
#import "CI_GetADate.h"


static NSString *c_getADate=@"GetADate";

@implementation CI_GetADate

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


- (NSDate *)modal:(id)mere titre:(NSString *)unTitre dateInitiale:(NSDate *)uneDate
{
	if(!fenetre)
	{
		if (![NSBundle loadNibNamed:c_getADate owner: self])
		{
			DEBUGNSLOG(@"Can't load Nib file %@",c_getADate);
			return nil;
		}
		else
		{
			[fenetre setReleasedWhenClosed:YES];
			[fenetre setDelegate:self];
			
			if(unTitre)
				[label_titre setStringValue:unTitre];
			else
				[label_titre setStringValue:@""];

			[picker_texte setDateValue:uneDate];
			[picker_graphique setDateValue:uneDate];
		}
	}
	
	flag=0;
	
	[NSApp beginSheet: fenetre
       modalForWindow: mere
        modalDelegate: nil
       didEndSelector: nil
          contextInfo: nil];
    [NSApp runModalForWindow:fenetre];
    [NSApp endSheet:fenetre];
    [fenetre orderOut:self];
	
	if(flag)
	{
		NSDate *retour=[picker_texte dateValue];
		[[retour retain] autorelease];
		
		return retour;
	}
	else
	{
		return nil;
	}
}


-(IBAction)bouton_annuler:(id)sender
{
	[NSApp stopModal];
}


-(IBAction)bouton_ok:(id)sender
{
	flag=1;
	[NSApp stopModal];
}


@end
