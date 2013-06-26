#import <Cocoa/Cocoa.h>

#import "CR_ArbreFS.h"


@implementation CR_ArbreFS

@synthesize base;

- (id)init
{
	if (self = [super init])
	{
	}
	return self;
}


-(BOOL) creerRacine:(NSString *)chemin
{
	if(racine)
		return NO;
	
	racine=[[CR_NoeudFS alloc] init];
	[racine setNom:chemin];
	[racine setEtat:NO];
	[racine setPere:nil];
	[racine setTypeNoeud:D_ROOT];
	
	[self setBase:[chemin lastPathComponent]];
	
	return YES;
}


-(CR_NoeudFS *)racine
{
	return racine;
}


-(void)dealloc
{
	[base release];
	[racine release];
	[super dealloc];
}


-(void)vider
{
	[racine replier];
}


-(void)setFirstItemType:(int)type
{
	[racine setTypeNoeud:type];
}

@end
