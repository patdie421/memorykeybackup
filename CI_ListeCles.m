#import <Cocoa/Cocoa.h>

#import "general.h"

#import "DB_Cles.h"

#import "CI_Principal.h"
#import "CI_ListeCles.h"
#import "CI_ConfigCle.h"
#import "CI_StorageManagement.h"
#import "CI_GetADate.h"

#import "PD_Moteur.h"
#import "PD_Planificateur.h"


@implementation CI_ListeCles

@synthesize listeIdentifiantsDeToutesLesColonnes;
@synthesize table_listeCles;
@synthesize CI_configCle;

- (void)arreter
{
    if(timer && [timer isValid])
        [timer invalidate];
}


- (void)demarrer
{
    [timer release];
    timer = [NSTimer scheduledTimerWithTimeInterval: 30
                                             target: self
                                           selector: @selector(rafraichirAffichage:)
                                           userInfo: nil
                                            repeats: YES];
    [timer retain];
}


-(void)dealloc
{
    [listeIdentifiantsDeToutesLesColonnes release];
    [D_toutesLesColonnesConstruites release];
    
    [super dealloc];
}


-(void)animationBoutons
{
 int row;
 id cle;
    
    row=[table_listeCles selectedRow];
    
	if(row < 0)
	{
		[bouton_Editer setEnabled:NO];
		[bouton_Suppr setEnabled:NO];
        [bouton_Sauvegarder setEnabled:NO];
		[bouton_SauvegarderMaintenant setEnabled:NO];
		[bouton_restaurer setEnabled:NO];
		[bouton_purger setEnabled:NO];
		
	}
    else
    {
        [bouton_Editer setEnabled:YES];
        [bouton_Suppr setEnabled:YES];
//		[bouton_purger setEnabled:YES];

		id listeDesClesMontees = [[[CI_principal moteur] enregistreur] listeDesClesMontees];
		@synchronized(listeDesClesMontees)
		{
			cle=[ listeDesClesMontees objectForKey:[[db_cles cleTrieeParPosition:row] objectForKey:D_IDCLE] ];
			
			[cle retain];
			
			if(cle)
			{
				[bouton_Sauvegarder setEnabled:YES];
				if([cle sauvegardeEnCours])
				{
					[bouton_SauvegarderMaintenant setEnabled:NO];
					[bouton_restaurer setEnabled:NO];
					[bouton_purger setEnabled:NO];
					[bouton_Suppr setEnabled:NO];
				}
				else
				{
					if([CI_restauration estOuverte])
					{
						[bouton_SauvegarderMaintenant setEnabled:NO];
						[bouton_restaurer setEnabled:NO];
						[bouton_purger setEnabled:NO];
						[bouton_Suppr setEnabled:NO];
					}
					else
					{
						[bouton_SauvegarderMaintenant setEnabled:YES];
						[bouton_restaurer setEnabled:YES];
						[bouton_purger setEnabled:YES];
						[bouton_Suppr setEnabled:YES];
					}
				}
			}
			else
			{
				[bouton_Sauvegarder setEnabled:NO];
				[bouton_SauvegarderMaintenant setEnabled:NO];
				if([CI_restauration estOuverte])
				{
					[bouton_restaurer setEnabled:NO];
					[bouton_purger setEnabled:NO];
					[bouton_Suppr setEnabled:NO];
				}
				else
				{
					[bouton_restaurer setEnabled:YES];
					[bouton_purger setEnabled:YES];
					[bouton_Suppr setEnabled:YES];
				}
			}
			
			[cle release];
		}
    }
}


- (void)checkDefaultsEndUpdateButton
{
	id defaults=[[CI_principal prefs] dictionaryForKey:D_DEFAULTS];
	
	[bouton_purger setHidden:![[defaults objectForKey:D_ADVANCED] intValue]];
}


- (IBAction)ouvrirFenetre:(id)sender
{
	[self checkDefaultsEndUpdateButton];
	[CI_listeCles makeKeyAndOrderFront:sender];
}


- (void)rafraichirAffichage
{
    [table_listeCles reloadData];	
	[self animationBoutons];
}


- (void)rafraichirAffichage:(id)info
{
    [self rafraichirAffichage];
}


/*
 * gestion des actions (boutons et tableview)
 */
- (IBAction)table_listeCles:(id)sender
{
}


// methode déléguée de table_listeCles
- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
	[self animationBoutons];
}


- (IBAction)bouton_restaurer:(id)sender
{
	if([table_listeCles selectedRow] > -1)
	{
	 int index;
		
		index=[db_cles positionPourObjet:[db_cles cleTrieeParPosition:[table_listeCles selectedRow]]];

		if(!CI_restauration)
		{
			CI_restauration=[[CI_Restauration alloc] init];
			[CI_restauration setDbCle:db_cles];
			[CI_restauration setCI_principal:CI_principal];
		}
		if([CI_restauration afficher:index])
			[self animationBoutons];
	}
}

	
- (IBAction)bouton_Editer:(id)sender
{
	int uneLigne = [table_listeCles selectedRow];
	if(uneLigne > -1)
	{
		if(!CI_configCle)
		{
			CI_configCle=[[CI_ConfigCle alloc] init];
			[CI_configCle setDb_cles:db_cles];
			[CI_configCle setCI_principal:CI_principal];
		}
		
		int index;
		
		index=[db_cles positionPourObjet:[db_cles cleTrieeParPosition:[table_listeCles selectedRow]]];
		
        [CI_listeCles makeKeyAndOrderFront:self];
		[CI_configCle ouvrirModal:CI_listeCles avecCleParIndex:index];
	}
}


- (void)editerCle:(id)idCle
{
	if(!CI_configCle)
	{
		CI_configCle=[[CI_ConfigCle alloc] init];
		[CI_configCle setDb_cles:db_cles];
		[CI_configCle setCI_principal:CI_principal];
	}
	
	[CI_listeCles makeKeyAndOrderFront:self];
	[CI_configCle ouvrirModal:CI_listeCles avecCleParIdCle:idCle];
}


- (IBAction)bouton_Suppr:(id)sender
{
	id cle;
	int uneLigne = [table_listeCles selectedRow];
	
	if(uneLigne > -1)
	{
		PD_Moteur *moteur;
		int retour;
		
		retour=[CI_principal dialog:NSLocalizedString(@"CONFIRMEDELETE",nil)
							message:NSLocalizedString(@"CONFIRMEDELETE+",nil)
					boutonParDefaut:NSLocalizedString(@"B_NO",nil)
				   boutonAlternatif:NSLocalizedString(@"B_YES",nil)
						autreBouton:nil];
		if(retour)
			return;
		
		moteur=[CI_principal moteur];
		@synchronized([[moteur enregistreur] listeDesClesMontees])
		{
			cle=[[moteur enregistreur] cleMonteeParIdCle:[[db_cles cleTrieeParPosition:uneLigne] objectForKey:D_IDCLE]];
			if(cle)
			{
				[[moteur enregistreur] desenregistrerCle:cle];
				[[moteur traitementDesTaches] supprimerCleDeLaFileDeSauvegardes:cle];
				[[moteur traitementDesTaches] arreterTachesPourCle:cle];
				[[moteur planificateur] deplanifierCle:cle];
			}
			
			[db_cles supprimerCleParPosition:
			 [db_cles positionPourObjet:[db_cles cleTrieeParPosition:uneLigne]]
			 ];
			[db_cles trier:[table_listeCles sortDescriptors]];
		}
		
		[table_listeCles deselectRow:uneLigne];
		[table_listeCles reloadData];
		
		[bouton_Editer setEnabled:NO];
		[bouton_Suppr setEnabled:NO];
		[bouton_Sauvegarder setEnabled:NO];
	}
}


-(IBAction)bouton_quitter:(id)sender
{
 int retour;
    
	[[[[CI_principal moteur] tuyaux] verrouSurListeDesTachesEnCours] lock];
	if([[[[CI_principal moteur] tuyaux] listeDesTachesEnCours] count]>0)
	{
		[[[[CI_principal moteur] tuyaux] verrouSurListeDesTachesEnCours] unlock];
		retour=[CI_principal dialog:NSLocalizedString(@"CONFIRMEQUIT",nil)
							message:NSLocalizedString(@"CONFIRMEQUIT+",nil)
					boutonParDefaut:NSLocalizedString(@"B_NO",nil)
				   boutonAlternatif:NSLocalizedString(@"B_YES",nil)
						autreBouton:nil];
		if(retour)
			return;
    }
	else
		[[[[CI_principal moteur] tuyaux] verrouSurListeDesTachesEnCours] unlock];

    [NSApp terminate:nil];
}


- (IBAction)bouton_Preferences:(id)sender
{
	[CI_principal menu_preferences:self];
}


- (IBAction)bouton_Sauvegarder:(id)sender
{

    int uneLigne = [db_cles positionPourObjet:[db_cles cleTrieeParPosition:[table_listeCles selectedRow]]];
	
    if(uneLigne > -1)
	{
		if(uneLigne > -1)
		{
			//      [self modal:fenetre_planifierSauvegarde];
			//		[CI_planifierSauvegarde modal:CI_listeCles];
			id moteur;
			id enregistreur;
			
			CI_GetADate *get;
			get=[[CI_GetADate alloc] init];
			NSDate *uneDate=[get modal:CI_listeCles titre:@"Choose the schedule date and time:" dateInitiale:[NSDate date]];
			[get release];
			if(uneDate)
			{
				moteur=[CI_principal moteur];
				enregistreur=[moteur enregistreur];
				
				@synchronized([enregistreur listeDesClesMontees])
				{
					PD_Cle *cle;
					
					cle=[enregistreur cleMonteeParIdCle:[[db_cles cleParPosition:uneLigne] objectForKey:D_IDCLE]];
					if(cle)
						[[moteur planificateur] planifier:cle aLaDate:uneDate aReplanifier:NO];
				}
			}
		}
	}
}


- (IBAction)bouton_SauvegarderMaintenant:(id)sender
{
    int uneLigne = [table_listeCles selectedRow];
    
    if(uneLigne > -1)
    {
	 id moteur;
	 id enregistreur;
	 PD_Cle *cle;
		
		moteur=[CI_principal moteur];
		enregistreur=[moteur enregistreur];
		
		@synchronized([enregistreur listeDesClesMontees])
		{
			cle=[enregistreur cleMonteeParIdCle:[[db_cles cleParPosition:uneLigne] objectForKey:D_IDCLE]];
			if(cle)
				[[moteur planificateur] planifier:cle aLaDate:[NSDate date] aReplanifier:NO];
		}
	}
}


- (IBAction)bouton_StorageManagement:(id)sender
{
	
	int uneLigne = [table_listeCles selectedRow];
    if(uneLigne > -1)
    {
		if(!CI_storageManagement)
		{
			CI_storageManagement=[[CI_StorageManagement alloc] init];
			[CI_storageManagement setDb_cles:db_cles];
		}
		
		int index=[db_cles positionPourObjet:[db_cles cleTrieeParPosition:[table_listeCles selectedRow]]];

		[CI_storageManagement modal:CI_listeCles indexCle:index];
	}
}


/*
 * Gestion de la table
 */
- (void)construireTable:(NSArray *)listeIdentifiants
{ 
 NSEnumerator *e; 
 NSTableColumn *uneColonne;
 id identifiant;
 id listeColonnes;
 int i;
	
	[listeIdentifiants retain];
	
	listeColonnes=[table_listeCles tableColumns];
	for(i=[listeColonnes count];i;i--)
		[table_listeCles removeTableColumn:[listeColonnes objectAtIndex:i-1]];
	
	e = [listeIdentifiants objectEnumerator]; 
	while ( (identifiant = [e nextObject]) )
	{
		uneColonne = [D_toutesLesColonnesConstruites objectForKey:identifiant]; 
		[table_listeCles addTableColumn:uneColonne];
	}
	
	[listeIdentifiants release];
}


- (void)sauvegarderColonnesTable:(NSUserDefaults *)prefs
{
 NSTableColumn * uneColonne;
 NSEnumerator *e;
 NSMutableArray *T_listeColonnes;
 NSMutableDictionary *D_tailleColonnes;

	[prefs retain];
	
	T_listeColonnes=[[NSMutableArray alloc] init];
	D_tailleColonnes=[[NSMutableDictionary alloc] init];

	e = [[table_listeCles tableColumns] objectEnumerator];
	while(uneColonne=[e nextObject])
	{
		[T_listeColonnes addObject: [uneColonne identifier]];
		[D_tailleColonnes setObject:[NSNumber numberWithFloat:[uneColonne width]] forKey:[uneColonne identifier]];
	}
	[prefs setObject:T_listeColonnes forKey:D_LISTECOLONNES];
	[prefs setObject:D_tailleColonnes forKey:D_TAILLECOLONNES];

	[T_listeColonnes release];
	[D_tailleColonnes release];
	
	[prefs release];
}


- (NSMutableArray *)listeColonnesAffichees
{
 NSTableColumn * uneColonne;
 NSEnumerator *e;
 NSMutableArray *T_listeColonnes;
	
	T_listeColonnes=[[NSMutableArray alloc] init];
	[T_listeColonnes autorelease];
	
	e = [[table_listeCles tableColumns] objectEnumerator];
	while(uneColonne=[e nextObject])
		[T_listeColonnes addObject: [uneColonne identifier]];

	return T_listeColonnes;
}



- (void)chargerColonnesTable:(NSUserDefaults *)prefs
{
	[prefs retain];
	
	[self chargerOuInitialiserColonnesTable_prefs:prefs nomsDesColonnes:listeIdentifiantsDeToutesLesColonnes];
	
	[prefs release];
}


- (void)desactiverColonneTable:(id)identifiantCle
{
 id uneTable;
 int i,c;
	
	[identifiantCle retain];
	
	uneTable=[table_listeCles tableColumns];
	c=[uneTable count];
	
	for(i=0;i<c;i++)
	{
		if([[[uneTable objectAtIndex:i] identifier] isEqualToString: identifiantCle])
		{
			[uneTable  removeObjectAtIndex:i];
			[table_listeCles reloadData];
			break; // sortie de la boucle
		}
	}
	
	[identifiantCle release];
}


- (void)activerColonneTable:(id)identifiantCle
{
 NSEnumerator *e;
 NSTableColumn *uneColonne;
 id uneTable;
 int i,c;
	
	[identifiantCle retain];
	
	e = [D_toutesLesColonnesConstruites objectEnumerator];
	while ( (uneColonne = [e nextObject]) )
	{
		if([[uneColonne identifier] isEqualToString: identifiantCle])
		{
			uneTable=[table_listeCles tableColumns];
			
			// à quelle position inserer la nouvelle colonne
			c=[listeIdentifiantsDeToutesLesColonnes count];
			for(i=0;i<c;i++)
				if([[listeIdentifiantsDeToutesLesColonnes objectAtIndex:i] isEqualToString: identifiantCle])
					break;

			c=[uneTable count];
			if(i<c) // si l'index max le permet
			    [uneTable insertObject:uneColonne atIndex:i]; // insertion à la position trouvée
			else
				[uneTable insertObject:uneColonne atIndex:c]; // sinon en dernière position

			[table_listeCles reloadData];

			break; // sortie de la boucle
		}
	}
	
	[identifiantCle release];
}
/*
 * Fin gestion de la table
 */


- (int)numberOfRowsInTableView:(NSTableView *)tableView
{
 int nbCle;

	nbCle=[db_cles nbClesDansListeDesClesDefinies];
	
    return nbCle;
}


- (void)tableView:(NSTableView *)tableView sortDescriptorsDidChange:(NSArray *)oldDecriptor
{
 NSArray *descripteurs;
    
    descripteurs=[tableView sortDescriptors];
    
    [db_cles trier:descripteurs];
    
    [self rafraichirAffichage];
}


- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(int)row
{
 id identifiantColonne;
 id unChamp;
 id ligne;

    identifiantColonne=[tableColumn identifier];
	
    ligne=[db_cles cleTrieeParPosition:row];
	
    unChamp=[ligne objectForKey:identifiantColonne];

    if([identifiantColonne isEqualToString:D_SAUVSUIV]==YES)
    {
     id listeDesClesPlanifiees;
     NSString *idCle;
     int i;
	 NSLock *verrou;
		
		verrou=[[[CI_principal moteur] tuyaux] verrouSurListeDesClesPlanifiees];
		[verrou retain];
		[verrou lock];
		
        listeDesClesPlanifiees=[[[CI_principal moteur] tuyaux] listeDesClesPlanifiees];
        idCle=[ligne objectForKey:D_IDCLE];
        for(i=0;i<[listeDesClesPlanifiees count];i++)
        {
            if([[[[listeDesClesPlanifiees objectAtIndex:i] objectAtIndex:1] idCle] isEqualToString:idCle])
            {
                unChamp=[[listeDesClesPlanifiees objectAtIndex:i] objectAtIndex:0];
                break;
            }
        }
		
		[verrou unlock];
		[verrou release];
		
    }
    
    if([unChamp isKindOfClass:[NSDate class]])
    {
        NSTimeInterval interval=[unChamp timeIntervalSinceNow];
        
        if([unChamp compare:[NSDate dateWithTimeIntervalSince1970:0]]==NSOrderedAscending)
		{
            return @"";
        }

        NSDateFormatter *formateur = [[NSDateFormatter alloc] init];
		
        if(abs(interval) < (24*60*60))
        {
            [formateur setDateStyle:NSDateFormatterNoStyle];
            [formateur setTimeStyle:NSDateFormatterMediumStyle];
        }
        else
        {
            [formateur setDateStyle:NSDateFormatterShortStyle];
            [formateur setTimeStyle:NSDateFormatterNoStyle];
        }
		
        NSString *chaineFormatee = [formateur stringFromDate:unChamp];
        [chaineFormatee retain];
		[chaineFormatee autorelease];
		
        [formateur release];
		
        return chaineFormatee;
    }
    
    if([identifiantColonne isEqualToString:D_TYPESAUV])
    {
        @try
        {
         NSString *uneChaine;
		 NSNumber *unNombre;
         int num;
            
            unNombre=[ligne objectForKey:D_BACKUPTYPE];
            num=[unNombre intValue];

            switch (num)
            {
                case 1:
                    uneChaine=NSLocalizedString(@"NOTBACKUPED",nil);
                    break;

                case 2:
                    uneChaine=NSLocalizedString(@"FULLBACKUP",nil);
                    break;
                    
                case 3:
                    uneChaine=NSLocalizedString(@"INCREMENTALBACKUP",nil);
                    break;
                    
                case 4:
                    uneChaine=NSLocalizedString(@"SYNCHRONIZATION",nil);
                    break;
                    
                default:
                    uneChaine=NSLocalizedString(@"UNKNOWN",nil);
                    break;
            }
            return uneChaine;
        }
        @catch (NSException * e)
        {
            return @"";
        }
    }

    if([identifiantColonne isEqualToString:D_KSTATUS])
    {
     NSImage *uneImage;
     id cle;
	 id listeDesClesMontees;
		
		listeDesClesMontees=[[[CI_principal moteur] enregistreur] listeDesClesMontees];
		@synchronized(listeDesClesMontees)
		{
			cle=[listeDesClesMontees objectForKey:[ligne objectForKey:D_IDCLE]];
			[cle retain];
			if(cle)
			{
				if([cle sauvegardeEnCours])
					uneImage=[NSImage imageNamed:@"yellow.tiff"];
				else
					uneImage=[NSImage imageNamed:@"green.tiff"];
			}
			else
				uneImage=[NSImage imageNamed:@"red.tiff"];
			[cle release];
		}
		
        return uneImage;
	}

    return unChamp;
}


- (void)chargerOuInitialiserColonnesTable_prefs:(NSUserDefaults *)prefs nomsDesColonnes:(id)nomDesColonnes
{
 NSEnumerator *e;
 id identifiantCle;
 NSTableColumn *uneColonne;
 NSMutableArray *T_listeColonnes;
 NSMutableDictionary *D_tailleColonnes;
	
	
	[prefs retain];
	[nomDesColonnes retain];
	
	// construction de la liste des colonnes. La recherche se fait par position (tableau)
	if([prefs arrayForKey:D_LISTECOLONNES] == nil)
		T_listeColonnes=[[NSMutableArray alloc] initWithArray:nomDesColonnes];
	else
		T_listeColonnes=[[NSMutableArray alloc] initWithArray:[prefs arrayForKey:D_LISTECOLONNES]];
    
	
	// construction de la liste des tailles des colonnes. La recherche se fait par identifiant (Dictionnaire)
	if([prefs dictionaryForKey:D_TAILLECOLONNES] == nil)
	{
		D_tailleColonnes=[[NSMutableDictionary alloc] init];
		
		e = [T_listeColonnes objectEnumerator]; 
		while ( (identifiantCle = [e nextObject]) )
			[D_tailleColonnes setObject:[NSNumber numberWithInt:100] forKey:identifiantCle];
	}
	else
		D_tailleColonnes=[[NSMutableDictionary alloc] initWithDictionary: [prefs dictionaryForKey:D_TAILLECOLONNES]];
    
	
	// mise à jour des colonnes préconstruites avec la taille
	e = [D_tailleColonnes keyEnumerator];
	while ( (identifiantCle = [e nextObject]) )
	{
		uneColonne = [D_toutesLesColonnesConstruites objectForKey:identifiantCle]; 
		[uneColonne setWidth:[[D_tailleColonnes objectForKey:identifiantCle] floatValue]];
	}
	
	[self construireTable:T_listeColonnes];
	    
	[T_listeColonnes release];
	[D_tailleColonnes release];
	
	[self rafraichirAffichage];
	
	[nomDesColonnes release];
	[prefs release];
}


- (void)awakeFromNib
{
 NSEnumerator *e;
 NSTableColumn *uneColonne;
	
    listeIdentifiantsDeToutesLesColonnes  = [[NSArray arrayWithObjects:D_IDCLE,D_DESCCLE,D_INIT,D_DERNSAUV,D_SAUVSUIV,D_TYPESAUV,D_BACKDIR,D_KSTATUS,nil] retain];
	[listeIdentifiantsDeToutesLesColonnes retain];
    
    D_toutesLesColonnesConstruites = [[NSMutableDictionary alloc] init];

    e = [[table_listeCles tableColumns] objectEnumerator];
    while ( uneColonne = [e nextObject] )
        [D_toutesLesColonnesConstruites setObject:uneColonne forKey:[uneColonne identifier]];
    
    [table_listeCles setTarget:self];
	[table_listeCles setDoubleAction:@selector(bouton_Editer:)];
}


@end