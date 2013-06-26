#import <Cocoa/Cocoa.h>

#import "CI_InfosTachesCelluleInfoControleur.h"


static NSString *c_celluleInfo=@"CelluleInfo";


@implementation CI_InfosTachesCelluleInfoControleur

+ (id) celluleInfoControleur
{
    return [[[self alloc] init] autorelease];
}


- (id) init
{
    if ((self = [super init]) != nil)
    {
        if (![NSBundle loadNibNamed:c_celluleInfo owner: self])
        {
            [self release];
            self = nil;
        }
    }
	
    return self;
}


- (void) dealloc
{
    [subview release];
    
    [super dealloc];
}


- (NSView *) view
{
    return subview;
}


- (IBAction) arreterTache:(id) sender
{
}


- (void)activeIndicateurAvancement
{
	[indicateurAvancement setHidden:NO];
	[infoLigne2 setHidden:YES];
	[boutonArretTache setHidden:NO];
}


- (void)desactiveIndicateurAvancement
{
	[indicateurAvancement setHidden:YES];
	[infoLigne2 setHidden:NO];
	[boutonArretTache setHidden:YES];

}


- (void)messageLigne1:(NSString *)msg
{
	[infoLigne1 setStringValue:msg];
}


- (void)messageLigne2:(NSString *)msg
{
	[infoLigne2 setStringValue:msg];
}


- (void)messageLigne3:(NSString *)msg
{
	[infoLigne3 setStringValue:msg];
}


- (NSProgressIndicator *)indicateurAvancement
{
	return indicateurAvancement;
}


- (void)boutonArretTacheSetTarget:(id)unObjet setAction:(SEL)unSelecteur
{
	[boutonArretTache setTarget:unObjet];
	[boutonArretTache setAction:unSelecteur];
}


@end
