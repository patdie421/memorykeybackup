#import <Cocoa/Cocoa.h>

#import "CR_ForetFS.h"


@implementation CR_ForetFS

- (id)init
{
	if (self = [super init])
	{
		foret=[[NSMutableDictionary alloc] init];
	}
	return self;
}


-(void)dealloc
{
	[self vider];
	[foret release];
	[super dealloc];
}


-(CR_ArbreFS *)arbreParIdentifiant:(NSString *)unIdentifiant
{
	return [foret objectForKey:unIdentifiant];
}


-(void)ajouterArbre:(CR_ArbreFS *)unArbre identifiant:(NSString *)unIdentifiant
{
	[foret setObject:unArbre forKey:unIdentifiant];
}


-(void)retirerArbreParIdentifiant:(NSString *)unIdentifiant
{
	[foret removeObjectForKey:unIdentifiant];
}


-(void)vider
{
	CR_ArbreFS *arbre;
	
	NSEnumerator *e = [foret objectEnumerator];
	while(arbre=[e nextObject])
	{
		[arbre vider];
	}
	
	[foret removeAllObjects];
}


-(void)listeFichiersSelectionnes:(NSMutableArray *)listeFichiers
{
	CR_ArbreFS *arbre;
	
	NSEnumerator *e = [foret objectEnumerator];
	while(arbre=[e nextObject])
		[[arbre racine] listerFichiersSelectionnes:listeFichiers];
}


@end

