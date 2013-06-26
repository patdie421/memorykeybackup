#import <Cocoa/Cocoa.h>

#import "general.h"
#import "DB_Cles.h"
#import "PD_Cle.h"
#import "CR_File.h"

/*
@interface NSArray (triListeCle)
- (NSComparisonResult)compareTypeSauv:(NSArray *)unArray;
@end

@implementation NSArray (triListeCle)

- (NSComparisonResult)compareTypeSauv:(NSArray *)unArray
{
    NSLog(@"%@ %@",self,unArray);

//    NSOrderedAscending,
//    NSOrderedSame,
//    NSOrderedDescending

    return NSOrderedAscending;
}

@end
*/

@implementation DB_Cles

@synthesize verrouDB;

- init
{    
	if (self = [super init])
	{
		fichier=[NSString stringWithString:D_DATAFILE]; 
		fichier=[fichier stringByExpandingTildeInPath]; 
		[fichier retain];

		verrouDB=[[NSRecursiveLock alloc] init];
		
        // liste de toutes les clés
		listeDesClesDefinies = [[NSMutableArray alloc] init];
        listeTrieeDesClesDefinies=listeDesClesDefinies;
        [listeTrieeDesClesDefinies retain];
        
		indexIdClesSurlisteDesClesDefinies = [[NSMutableDictionary alloc] init];
        verrouSurListeDesClesDefinies=[[NSLock alloc] init];		
	}
	return self;
}


- (void)dealloc
{
	[fichier release];
	
	[verrouDB release];

	[listeDesClesDefinies release];
    [listeTrieeDesClesDefinies release];
    [descripteursDeTri release];

	[indexIdClesSurlisteDesClesDefinies release];
    [verrouSurListeDesClesDefinies release];

	[super dealloc];
}


- (void)verrouiller
{
	if(verrouDB)
	{
		[verrouDB lock];
	}
}


- (void)deverrouiller
{
	if(verrouDB)
	{
		[verrouDB unlock];
	}	
}


- (int)nbClesDansListeDesClesDefinies
{
 int nb;

	nb=[listeDesClesDefinies count];

    return nb;
}


- (id)cleParPosition:(int)unePosition
{
 id unObjet;

	unObjet=[listeDesClesDefinies objectAtIndex:unePosition];

	return unObjet;
}


- (id)cleTrieeParPosition:(int)unePosition
{
 id unObjet;
	
	unObjet=[listeTrieeDesClesDefinies objectAtIndex:unePosition];

	return unObjet;
}


- (void)trier
{
    [listeTrieeDesClesDefinies release];
    
    if(descripteursDeTri!=nil)
        listeTrieeDesClesDefinies=(NSMutableArray *)[listeDesClesDefinies sortedArrayUsingDescriptors:descripteursDeTri];
    else
        listeTrieeDesClesDefinies=listeDesClesDefinies;
    
    [listeTrieeDesClesDefinies retain];
}


- (void)trier:(NSArray *)descripteurs
{
	[descripteurs retain];
	
    [listeTrieeDesClesDefinies release];
    
    listeTrieeDesClesDefinies=(NSMutableArray *)[listeDesClesDefinies sortedArrayUsingDescriptors:descripteurs];
    [listeTrieeDesClesDefinies retain];
    
    [descripteursDeTri release];
    descripteursDeTri=descripteurs;
    [descripteursDeTri retain];
	
	[descripteurs release];
}


- (int)positionPourObjet:(id)unObjet
{
 int nb;
	
	[unObjet retain];
	
    nb=[listeDesClesDefinies indexOfObject:unObjet];
	
	[unObjet release];
	
	return nb;
}

    
-(id)cleParIndexIdCle:(id)unIdCle
{
 id row;
 id unObjet;

	[[unIdCle retain] autorelease];
	
	row=[indexIdClesSurlisteDesClesDefinies objectForKey:unIdCle];
	if(nil == row)
		return nil;
	
	unObjet=[listeDesClesDefinies objectAtIndex:[row intValue]];

	return unObjet;
}


-(int)indexPourIdCle:(id)unIdCle
{
 id row;
    
	[[unIdCle retain] autorelease];
	
    row=[indexIdClesSurlisteDesClesDefinies objectForKey:unIdCle];
    if(nil == row)
        return -1;
    
    return [row intValue];
}


- (void)creerIndexIdCle
{
 int i;
 int nbLigne;
 id unEnregistrement;

	[indexIdClesSurlisteDesClesDefinies removeAllObjects];
	nbLigne = [listeDesClesDefinies count];
	
	for(i=0;i<nbLigne;i++)
	{
        unEnregistrement = [listeDesClesDefinies objectAtIndex:i];
        [indexIdClesSurlisteDesClesDefinies setObject:[NSNumber numberWithInt:i] forKey:[unEnregistrement objectForKey:D_IDCLE]];
	}
}


- (BOOL)ajouterEnregistrement:(id)idCle enregistrement:(NSMutableDictionary *)unEnregistrement
{
 NSString *identifiant;
// BOOL retour;
 
	[idCle retain];
	[unEnregistrement retain];
	
    identifiant=[unEnregistrement objectForKey:D_IDCLE];
    if(!identifiant)
    {
        [unEnregistrement setObject:idCle forKey:D_IDCLE];
    }

//    retour=[self supprimerCleParIndexIdCle:idCle];
    [self supprimerCleParIndexIdCle:idCle];
    
	[listeDesClesDefinies insertObject: unEnregistrement atIndex:0];

    [self creerIndexIdCle];
    [self trier];

    [unEnregistrement release];
	[idCle release];
	
	return YES;
}


- (BOOL)supprimerCleParIndexIdCle:(id)unIdCle
{
 NSNumber *row;
    
	[[unIdCle retain] autorelease];
	
    row=[indexIdClesSurlisteDesClesDefinies objectForKey:unIdCle];
    if(nil==row)
        return NO;
    
    return [self supprimerCleParPosition:[row intValue]];
}


- (BOOL)supprimerCleParPosition:(int)unePosition
{
 BOOL retour;
    
	if(unePosition > [listeDesClesDefinies count])
	{
		retour=NO;
	}
	else
	{
		[listeDesClesDefinies removeObjectAtIndex:unePosition];
		
		[self creerIndexIdCle];
		[self trier];
		retour=YES;
	}
    
	return retour;
}


- (BOOL)sauvegarder
{
    [listeDesClesDefinies writeToFile:fichier atomically:YES];

    return TRUE;
}


- (BOOL)charger
{
    if(nil != listeDesClesDefinies)
    {
        [listeDesClesDefinies release];
        [listeTrieeDesClesDefinies release];
    }
    
    listeDesClesDefinies = [[NSMutableArray alloc] initWithContentsOfFile:fichier];

    if (nil == listeDesClesDefinies)
    {
        listeDesClesDefinies = [[NSMutableArray alloc] init];
		
		listeTrieeDesClesDefinies=listeDesClesDefinies;
		[listeTrieeDesClesDefinies retain];
    }
    else
		
    {
		listeTrieeDesClesDefinies=listeDesClesDefinies;
		[listeTrieeDesClesDefinies retain];
		
        [self creerIndexIdCle];
    }
    

    return TRUE;
}

@end
