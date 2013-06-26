#import <Cocoa/Cocoa.h>

#import "CR_NoeudFS.h"


int typeDuNoeud(NSString *chemin)
{
	BOOL isDir;
	BOOL isApp;
	
	isApp=[[NSWorkspace sharedWorkspace] isFilePackageAtPath:chemin];
	if(isApp)
		return D_FEUILLE_APPLICATION;
	else
	{
		[[NSFileManager defaultManager] fileExistsAtPath:chemin isDirectory:&isDir];
		if(isDir)
			return D_REPERTOIRE;
		else
			return D_FEUILLE_FICHIER;
	}
}


@implementation CR_NoeudFS

@synthesize nom;
@synthesize iconEtTexte;
@synthesize pere;
@synthesize typeNoeud;
@synthesize etat;
@synthesize fils;
@synthesize expand;


- (id)init
{
	if (self = [super init])
	{
		typeNoeud=D_UNDEF;
		expand=NO;
	}
	return self;
}


-(void) dealloc
{
	[nom release];
	[iconEtTexte release];

	[pere release];
	[fils release];
	
	[super dealloc];
}


- (NSString *)cheminComplet
{
	CR_NoeudFS *o;
	NSMutableString *chemin=[[NSMutableString alloc] initWithString:nom];
	
	o=pere;
	while(o)
	{
		[chemin insertString:@"/" atIndex:0];
		[chemin insertString:[o nom] atIndex:0];
		
		o=[o pere];
	}
	[chemin autorelease];
	
	return chemin;
}


-(int)nbFils
{
	if(!fils)
		[self deployer];
	return [fils count];
}


-(id)filsALIndex:(int)index
{
	return [fils objectAtIndex:index];
}


- (void)deployer
{
	if(!fils)
		fils=[[NSMutableArray alloc] init];
	else
		return;

	if([self estDeployable])
	{	
		CR_NoeudFS *unNoeud;
		NSArray *listeRep;

		NSFileManager *fileManager = [NSFileManager defaultManager];
		
		if(listeRep=[fileManager contentsOfDirectoryAtPath:[self cheminComplet] error:NULL])
		{
			for(id o in listeRep)
			{
				if([o characterAtIndex:0]!='.')
				{
					unNoeud=[[CR_NoeudFS alloc] init];
					[unNoeud setNom:o];
					[unNoeud setPere:self];
					[unNoeud setTypeNoeud:typeDuNoeud([unNoeud cheminComplet])];
					if(etat==NSOnState)
						[unNoeud setEtat:NSOnState];
					else
						[unNoeud setEtat:NSOffState];
					[fils addObject:unNoeud];
					
					[unNoeud release];
				}
			}
		}
	}
}


- (void)replier
{
    if(!fils)
        return;
	
    while([fils count])
    {
        id o=[fils objectAtIndex:0];
        if([o fils])
            [o replier];
        [fils removeObjectAtIndex:0];
    }
    [fils release];
	
    fils=nil;
}

			   
-(BOOL)estDeployable
{
	if(typeNoeud==D_REPERTOIRE || typeNoeud==D_ROOT)
		return YES;
	else
		return NO;
}


- (void)ajusterSelectionsFils:(BOOL)e
{
	for (id o in fils)
	{
		[o setEtat:e];
		[o ajusterSelectionsFils:e];
	}
}


- (void)ajusterSelectionsParents
{
	if(etat==NSOnState)
	{
		if([pere filsSontTousSelectionnes:self])
			[pere setEtat:NSOnState];
		else
			[pere setEtat:NSMixedState];
	}
	else if(etat==NSOffState)
	{
		if([pere filsSontTousDeselectionnes:self])
			[pere setEtat:NSOffState];
		else
			[pere setEtat:NSMixedState];
	}
	else
		[pere setEtat:NSMixedState];
	
	if([pere pere])
		[pere ajusterSelectionsParents];
}


- (BOOL)filsSontTousSelectionnes:(id)itemExclu
{
	BOOL e=YES;
	
	if(fils)
	{
		for(id o in fils)
		{
			if(o!=itemExclu)
				if(![o etat])
					return NO;
				else
					e=e & [o filsSontTousSelectionnes:nil];
		}
	}
	else
		return etat;
	
	return e;
}


- (BOOL)_filsSontTousDeselectionnes:(id)itemExclu
{
	BOOL e=NO;
	if(fils)
	{
		for(id o in fils)
		{
			if(o!=itemExclu)
				if([o etat])
					return YES;
				else
					e=e | [o _filsSontTousDeselectionnes:nil];
		}
	}
	else
		return etat;
	
	return e;
}


- (BOOL)filsSontTousDeselectionnes:(id)itemExclu
{
	return ![self _filsSontTousDeselectionnes:itemExclu];
}


- (void)afficher
{
	NSLog(@"%@",[self cheminComplet]);
	
	if(typeNoeud==D_REPERTOIRE)
	{
		for(id o in fils)
		{
			[o afficher];
		}
	}
}


- (void)deplierOutLineView:(id)ov
{
	if(expand==YES)
	{
		[ov expandItem:self];
		for(id o in fils)
		{
			if([o expand]==YES)
			{
				[o deplierOutLineView:ov];
			}
		}
		
	}
}


- (void)listerFichiersSelectionnes:(NSMutableArray *)fichiersSelectionnes
{
	if((typeNoeud==D_FEUILLE_FICHIER) || (typeNoeud==D_FEUILLE_APPLICATION))
	{
		if(etat==NSOnState)
			[fichiersSelectionnes addObject:[self cheminComplet]];
	}
	else
	{
		if(etat!=NSOffState)
		{
			if(!fils)
			{
				[self deployer];
				for(id o in fils)
					[o setEtat:NSOnState];
			}
			for(id o in fils)
				[o listerFichiersSelectionnes:fichiersSelectionnes];
		}
	}
}


@end
