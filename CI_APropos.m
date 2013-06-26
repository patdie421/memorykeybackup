#import <Cocoa/Cocoa.h>

#import "general.h"
#import "CI_APropos.h"


static NSString *c_apropos=@"APropos";

@implementation CI_APropos

- (id) init
{
    if ((self = [super init]) != nil)
    {
		fenetre=nil;
    }
	
    return self;
}


- (void)afficher
{
	NSMutableAttributedString *leTexte;
	NSData *data;
	
	if(!fenetre)
	{
		if (![NSBundle loadNibNamed:c_apropos owner: self])
		{
			DEBUGNSLOG(@"Can't load Nib file %@",c_apropos);
			return;
		}
		else
		{
			[fenetre setDelegate:self];
			[fenetre setReleasedWhenClosed:YES];
			[version setStringValue:@"v0.0"];
			
//			leTexte=[[NSMutableAttributedString alloc] initWithString:@"Un texte localisé à charger"];
			data = [[NSData alloc] initWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:NSLocalizedString(@"ABOUTRTF",nil)]];
			if(data)
			{
				leTexte = [[NSMutableAttributedString alloc]initWithRTF:data documentAttributes:nil];
				[[texte textStorage] appendAttributedString:leTexte];
				
				[leTexte release];
				[data release];
				
			}
		}
	}
	[fenetre makeKeyAndOrderFront:self];
}


- (void)windowWillClose:(NSNotification *)notification
{
	fenetre=nil;
}


- (void)dealloc 
{
	[super dealloc];
}


@end
