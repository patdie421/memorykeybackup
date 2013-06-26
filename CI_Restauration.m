#import <Cocoa/Cocoa.h>

#import "general.h"

#import "DB_Cles.h"
#import "CI_Principal.h"
#import "CI_Restauration.h"
#import "CR_NoeudFS.h"
#import "CR_ArbreFS.h"
#import "CR_ForetFS.h"

#import "PD_TacheRestauration.h"

static NSString *c_restauration=@"Restauration";
static NSString *c_lucida_grande=@"Lucida Grande";

static NSString *c_full_last=@"full/last";
static NSString *c_full_old=@"full/old";
static NSString *c_sync_key=@"sync/key";
static NSString *c_sync_old=@"sync/old";
static NSString *c_incr=@"incr";

static NSString *c_nsobject=@"NSObject";

static NSString *c_finder=@"Finder";


void combinerIconEtTexte(NSImage *unIcon, NSString *unTexte, NSMutableAttributedString *iconEtTexte)
{
 NSMutableAttributedString *_unTexte;
 NSMutableAttributedString *_iconEtTexte;
 NSString *uneChaine;
 NSRange range;
 NSSize taille;
 NSTextAttachment *icon;
 NSTextAttachmentCell *icon_attachementCell;
	
	
	// préparation de l'icon
	taille.width=16;
	taille.height=16;
	[unIcon setSize:taille];
	
    icon = [[NSTextAttachment alloc] init];
    icon_attachementCell = [[NSTextAttachmentCell alloc] init];
    [icon_attachementCell setImage:unIcon];
    [icon setAttachmentCell:icon_attachementCell];
	
    _iconEtTexte = [[NSMutableAttributedString alloc] initWithAttributedString:[NSAttributedString attributedStringWithAttachment:icon]];
	range.location=0;
	range.length=0;
	[_iconEtTexte replaceCharactersInRange:range withString:@" "];

	[icon_attachementCell release];
	[icon release];

	
	// préparation du texte
	uneChaine=[[NSString alloc] initWithFormat:@" %@",unTexte];
	_unTexte = [[NSMutableAttributedString alloc] initWithString:uneChaine];
	[uneChaine release];

	range.location=0;
	range.length=1;
	[_unTexte setAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
							 [NSFont fontWithName:c_lucida_grande size:18], // changement de la taille d'un "blanc"
							 NSFontAttributeName,							 // 
							 [NSNumber numberWithFloat:2.0],                 // et déplacement de 2 point vers le haut de la base du texte
							 NSBaselineOffsetAttributeName,					 //
							 nil]
					  range:range];
	range.location=1;
	range.length=[_unTexte length]-range.location;
	[_unTexte setAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
							 [NSFont fontWithName:c_lucida_grande size:12], // taille standard du texte
							 NSFontAttributeName,                            //
							 [NSNumber numberWithFloat:2.0],                 // et déplacement de 2 point vers le haut de la base du texte
							 NSBaselineOffsetAttributeName,
							 nil]
					  range:range];

	
	// fabrication de la ligne
	[_iconEtTexte appendAttributedString:_unTexte];
	
	// copier _iconEtTexte dans iconEtTexte ici
	range.location = 0;
	range.length = [iconEtTexte length];
	[iconEtTexte replaceCharactersInRange:range withAttributedString:_iconEtTexte];
	
	[_unTexte release];
	[_iconEtTexte release];
}


@implementation CI_Restauration

@synthesize dbCle;
@synthesize cle;
@synthesize CI_principal;
@synthesize tache;

- (id) init
{
    if ((self = [super init]) != nil)
    {
		uneForet=nil;
		unArbre=nil;
		fenetre=nil;
		uneForet=[[CR_ForetFS alloc] init];
    }
	
    return self;
}


- (void)dealloc 
{
	[CI_principal release];
	[CI_progressionRestauration release];
	[dbCle release];
	[cle release];
	[unArbre release];
	[uneForet release];
	[tache release];
 	[listeSauvegardeIncr release];
	
	[super dealloc];
}


- (BOOL)estOuverte
{
	if(fenetre)
		return YES;
	else
		return NO;
}


- (void)animationBoutons
{
	if([[radio_destination selectedCell] tag]==2)
	{
		[champ_destination setEnabled:YES];
		[bouton_choose setEnabled:YES];
	}
	else
	{
		[champ_destination setEnabled:NO];
		[bouton_choose setEnabled:NO];
	}
	
	if([[radio_remplacement selectedCell] tag]==1)
	{
		[check_keepCopy setEnabled:YES];
		[champ_restored setEnabled:NO];
		if([check_keepCopy intValue])
		{
			[champ_keeped setEnabled:YES];
			[label_extentionAdd setTextColor:[NSColor controlTextColor]];
		}
		else
		{
			[champ_keeped setEnabled:NO];
			[label_extentionAdd setTextColor:[NSColor disabledControlTextColor]];
		}
	}
	else
	{
		[check_keepCopy setEnabled:NO];
		[champ_restored setEnabled:YES];
		[champ_keeped setEnabled:NO];
		[label_extentionAdd setTextColor:[NSColor disabledControlTextColor]];
	}
}


- (void)choisirRepertoire
{
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    
    [openDlg setCanChooseFiles:NO];
    [openDlg setCanChooseDirectories:YES];
    [openDlg setCanCreateDirectories:YES];
    [openDlg setTitle:NSLocalizedString(@"Choose a directory",nil)];
    
    if ( [openDlg runModalForDirectory:nil file:nil] == NSOKButton )
    {
        [champ_destination setStringValue:[[openDlg filenames] objectAtIndex:0]];
    }
}


- (void)sup_onglet:(NSString *)onglet
{
	[onglet_choixSauvegardes removeTabViewItem:
	 [onglet_choixSauvegardes tabViewItemAtIndex:
	  [onglet_choixSauvegardes indexOfTabViewItemWithIdentifier:onglet]]];
}


- (BOOL)testRep:(NSString *)rep etDevalideBouton:(id)bouton
{
	BOOL retour;
	NSString *chemin;
	
	chemin=[[NSString alloc] initWithFormat:@"%@/%@/%@",
			[cle objectForKey:D_BACKDIR],
			[cle objectForKey:D_IDCLE],
			rep];
	retour=exitAndNotEmpty(chemin);
	if(!retour)
		[bouton setEnabled:NO];
	else
		[bouton setEnabled:YES];
	
	[chemin release];
	
	return retour;
}


- (BOOL)chargerArbreFullSync:(NSString *)rep
{
	NSString *chemin;
	
	if(!cle)
		return NO;
	
	chemin=[[NSString alloc] initWithFormat:@"%@/%@/%@",
			[cle objectForKey:D_BACKDIR],
			[cle objectForKey:D_IDCLE],
			rep];

	CR_ArbreFS *arbre=[uneForet arbreParIdentifiant:rep];
	if(!arbre)
	{
		arbre=[[CR_ArbreFS alloc] init];
		[uneForet ajouterArbre:arbre identifiant:rep];
		[arbre release];
	}
	
	[arbre creerRacine:chemin];
	unArbre=arbre;
	
	[chemin release];
	
	return YES;
}


- (BOOL)chargerListeSauvegardes
{
	if(!cle)
		return NO;
	
	if(listeSauvegardeIncr)
		[listeSauvegardeIncr release];
	listeSauvegardeIncr=[[NSMutableArray alloc] init];
	
	NSString *chemin=[[NSString alloc] initWithFormat:@"%@/%@/%@",[cle objectForKey:D_BACKDIR],[cle objectForKey:D_IDCLE],c_incr]; // @"%@/%@/incr"
	NSArray *rep=[[NSFileManager defaultManager] contentsOfDirectoryAtPath:chemin error:NULL];
	if(rep)
	{
		NSDate *dateSauvegarde;
		for(id o in rep)
		{
			dateSauvegarde=[[NSDate alloc] initWithString:o];
			if(dateSauvegarde)
			{
				[listeSauvegardeIncr addObject:o];
				[dateSauvegarde release];
			}
		}
	}
	[chemin release];

	return YES;
}


- (BOOL)chargerArbreIncr:(int)numSauvegarde
{
	if(!cle)
		return NO;
	
	if(numSauvegarde > ([listeSauvegardeIncr count]-1))
		return NO;

	NSString *idSauvegarde=[listeSauvegardeIncr objectAtIndex:[listeSauvegardeIncr count]-numSauvegarde-1];
	CR_ArbreFS *arbre=[uneForet arbreParIdentifiant:idSauvegarde];
	if(!arbre)
	{
		arbre=[[CR_ArbreFS alloc] init];
		[uneForet ajouterArbre:arbre identifiant:idSauvegarde];
		[arbre release];
	}

	NSString *chemin=[[NSString alloc] initWithFormat:@"%@/%@/%@/%@", // @"%@/%@/incr/%@"
					  [cle objectForKey:D_BACKDIR],
					  [cle objectForKey:D_IDCLE],
					  c_incr,
					  idSauvegarde];
	[arbre creerRacine:chemin];
	unArbre=arbre;
	
	[chemin release];
	
	return YES;
}


- (BOOL)afficher:(int)indexCle
{
	if(!fenetre)
	{
		etat_radio_full_backup=-1;
		etat_radio_sync=-1;

		id enregistrementCle=[dbCle cleParPosition:indexCle];
		if(enregistrementCle)
			[self setCle:enregistrementCle];
		else
			return NO;
		
		if (![NSBundle loadNibNamed:c_restauration owner:self])
		{
			DEBUGNSLOG(@"Can't load Nib file %@",c_restauration);
			return NO;
		}
		
		[fenetre setReleasedWhenClosed:YES];
		[fenetre setWorksWhenModal:YES];
		[fenetre setDelegate:self];


		BOOL retour;
		BOOL ret1,ret2;
		BOOL flag=NO;
		/*
		 * Préparation des Labels et Boutons
		 */
		[label_idcle setStringValue:[cle objectForKey:D_IDCLE]];
		if([[[[CI_principal moteur] enregistreur] listeDesClesMontees] objectForKey:[cle objectForKey:D_IDCLE]])
			[radio_destination_original setEnabled:YES];
		else
		{
			[radio_destination_original setEnabled:NO];
			[radio_destination selectCellWithTag:2];
		}
		[self animationBoutons];

		
		/*
		 * Onglet INCREMENTAL
		 */
		retour=[self chargerListeSauvegardes];
		if(retour)
		{
			[table_choixBackupSet reloadData];
			
			if([listeSauvegardeIncr count])
				flag=YES;
			else
				// suppression de l'onglet "incremental"
				[self sup_onglet:@"I"];
		}
		
		
		/*
		 * Onglet FULL
		 */
		ret1=[self testRep:c_full_last etDevalideBouton:radio_full_backup_last];
		ret2=[self testRep:c_full_old etDevalideBouton:radio_full_backup_old];

		if(ret1)
			[radio_full_backup selectCellWithTag:1];
		else
			if(ret2)
				[radio_full_backup selectCellWithTag:2];
		if(!(ret1+ret2))
			[self sup_onglet:@"F"];
		else
			flag=YES;

		
		/*
		 * Onglet SYNCHRONISATION
		 */
		ret1=[self testRep:c_sync_key etDevalideBouton:radio_sync_sync];
		ret2=[self testRep:c_sync_old etDevalideBouton:radio_sync_bak];
		if(ret1)
			[radio_sync selectCellWithTag:1];
		else
			if(ret2)
				[radio_sync selectCellWithTag:2];
		if(!(ret1+ret2))
			[self sup_onglet:@"S"];
		else
			flag=YES;
		
		
		if(!flag)
		{
			[listeSauvegardeIncr release];
			listeSauvegardeIncr=nil;
			[fenetre close];
			fenetre=nil;
			return NO;
		}
	}

	// arrêter l'ordonnanceur
	[[[CI_principal moteur] ordonnanceur] arreter];
	
	[onglet_choixSauvegardes selectFirstTabViewItem:nil];
	if([[[onglet_choixSauvegardes selectedTabViewItem] identifier] characterAtIndex:0]==(unichar)'I')
		[self tabView:onglet_choixSauvegardes didSelectTabViewItem:[onglet_choixSauvegardes selectedTabViewItem]];
		
	[fenetre makeKeyAndOrderFront:self];
	
	return YES;
}


- (void)changerFull
{
	int boutonSelectionne=[[radio_full_backup selectedCell] tag];
	
	if(boutonSelectionne==etat_radio_full_backup)
		return;

	if(boutonSelectionne==1)
		[self chargerArbreFullSync:c_full_last];
	else
		[self chargerArbreFullSync:c_full_old];
	[outlineview reloadItem:nil];
	[[unArbre racine] deplierOutLineView:outlineview];

	etat_radio_full_backup=boutonSelectionne;
}


- (void)changerSync
{
	int boutonSelectionne=[[radio_sync selectedCell] tag];
	
	if(boutonSelectionne==etat_radio_sync)
		return;
	
	if(boutonSelectionne==1)
		[self chargerArbreFullSync:c_sync_key];
	else
		[self chargerArbreFullSync:c_sync_old];
	[outlineview reloadItem:nil];
	[[unArbre racine] deplierOutLineView:outlineview];

	etat_radio_sync=boutonSelectionne;
}


- (void)changerIncr
{
	int row=[table_choixBackupSet selectedRow];

	[self chargerArbreIncr:row];
	[outlineview reloadItem:nil];
	[[unArbre racine] deplierOutLineView:outlineview];
}


- (IBAction)locateInFinder:(id)sender
{
	NSString *chemin=[[NSString alloc] initWithFormat:@"%@/%@/",
					  [cle objectForKey:D_BACKDIR],
					  [cle objectForKey:D_IDCLE]];
	
	[[NSWorkspace sharedWorkspace] openFile:chemin withApplication:c_finder];
	
	[chemin release];
}


- (IBAction)actionChoose:(id)sender
{
	[self choisirRepertoire];
}


- (IBAction)actionBouttons:(id)sender
{		
	[self animationBoutons];
}


- (IBAction)clickCheckBox:(id)sender
{
	NSInteger clickedCol = [sender clickedColumn];
	NSInteger clickedRow = [sender clickedRow];
	
	if (clickedRow >= 0 && clickedCol >= 0)
	{
		NSCell *cell = [sender preparedCellAtColumn:clickedCol row:clickedRow];
		
		if ([cell isKindOfClass:[NSButtonCell class]])
		{
			int etat;
			CR_NoeudFS *item=[sender itemAtRow:clickedRow];
			
			if(item==nil)
				item=[unArbre racine];
			
			etat=[cell state];
			
			if(etat==NSMixedState)
				etat=![item etat];
			
			[item setEtat:etat];
			[item ajusterSelectionsFils:etat];
			[item ajusterSelectionsParents];
			
			[sender reloadItem:[unArbre racine] reloadChildren:YES];
		}
	}
}


- (IBAction)actionRadio_full_backup:(id)sender
{
	[self changerFull];
}


- (IBAction)actionRadio_sync:(id)sender
{
	[self changerSync];
}


-(IBAction)actionProcess:(id)sender
{
	NSMutableArray *listeFics;
	
	if(!CI_progressionRestauration)
		CI_progressionRestauration=[[CI_ProgressionRestauration alloc] init];

	listeFics=[[NSMutableArray alloc] init];
	[uneForet listeFichiersSelectionnes:listeFics];
	
// attendre plus de tache en cours
/*
	id tuyaux;
	BOOL fileVide=FALSE;
	int c;
	NSDate *loopUntil = [[NSDate alloc] initWithTimeIntervalSinceNow:0.5]; 
	tuyaux=[[CI_principal moteur] tuyaux];
	do
	{
		[[tuyaux verrouSurListeDesTachesEnCours] lock];
		c=[[tuyaux listeDesTachesEnCours] count];
		[[tuyaux verrouSurListeDesTachesEnCours] unlock];
		if(!c)
			fileVide=TRUE;
		else
		{
			[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:loopUntil];
		}
	}
	while(!fileVide);
	[loopUntil release];
*/

	tache=[[PD_TacheRestauration alloc] init];
	[tache setNomTache:[cle objectForKey:D_IDCLE]];
	
	[CI_progressionRestauration setTache:tache];
	
	// ajouter tache dans fileDeTraitement
	[[[CI_principal moteur] traitementDesTaches] ajouterTacheDansFileDEntree:tache];

	BOOL retour=[CI_progressionRestauration modal:fenetre]; // attendre fin de traitement
	if(retour)
	{
	}
	else
	{
	}

	[listeFics release];
	[tache release];
	tache=nil;
}


- (void)windowWillClose:(NSNotification *)notification
{
	[outlineview collapseItem:nil collapseChildren:YES];
	[uneForet vider];
	unArbre=nil;
	fenetre=nil;
	[[CI_principal CI_listeCles] animationBoutons];

	// lancer l'ordonnanceur
	[[[CI_principal moteur] ordonnanceur] demarrer];

}


// Data Source methods
- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
	if(item==nil)
		return 1;
	else
		return [item nbFils];
}


- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
	if(item==nil)
		return YES;
	else
		return [item estDeployable];
}


- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item
{
	if(item==nil)
		return [unArbre racine];
	else
		return [item filsALIndex:index];
}


- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
	id d;
	switch ([[tableColumn identifier] characterAtIndex:0])
	{
/*
		case 'I':
			switch ([item typeNoeud])
			{
				case D_ROOT:
				case D_REPERTOIRE:
					return [[NSWorkspace sharedWorkspace] iconForFileType:NSFileTypeForHFSTypeCode(kGenericFolderIcon)];
					break;
				case D_FEUILLE_FICHIER:
				case D_FEUILLE_APPLICATION:
					return [[NSWorkspace sharedWorkspace] iconForFile:[item cheminComplet]];
					break;
				default:
					return nil;
			}
			break;
*/
		case 'S':
			switch ([item typeNoeud])
			{
				case D_FEUILLE_FICHIER:
					d=[[NSFileManager defaultManager] attributesOfItemAtPath:[item cheminComplet] error:NULL];
					return [NSNumber numberWithLongLong:[d fileSize]];
					break;
				default:
					return nil;
			}
			break;
		case 'D':
			d=[[NSFileManager defaultManager] attributesOfItemAtPath:[item cheminComplet] error:NULL];
			return [d fileModificationDate];
		default:
			return nil;
			break;
	}
	return nil;
}


// Delegate methods
- (BOOL)outlineView:(NSOutlineView *)outlineView shouldEditTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
    return NO;
}


- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item
{
	return NO;
}


- (BOOL)outlineView:(NSOutlineView *)outlineView shouldCollapseItem:(id)item
{
	return YES;
}


- (void)outlineView:(NSOutlineView *)outlineView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
	NSString *chaine;
	NSImage *icon;

	if (![cell isKindOfClass:[NSButtonCell class]])
		return;

	if(![item iconEtTexte])
	{
		switch ([item typeNoeud])
		{
			case D_FEUILLE_FICHIER:
			case D_FEUILLE_APPLICATION:
				chaine=[[item nom] stringByDeletingPathExtension];
				icon=[[NSWorkspace sharedWorkspace] iconForFile:[item cheminComplet]];
				break;
			case D_REPERTOIRE:
				chaine=[item nom];
				icon=[[NSWorkspace sharedWorkspace] iconForFileType:NSFileTypeForHFSTypeCode(kGenericFolderIcon)];
				break;
			case D_ROOT:
				chaine=[[item nom] lastPathComponent];
				icon=[[NSWorkspace sharedWorkspace] iconForFileType:NSFileTypeForHFSTypeCode(kGenericFolderIcon)];
				break;
			default:
				icon=nil;
				chaine=[item nom];
				break;
		}
		NSMutableAttributedString *iconEtTexte=[[NSMutableAttributedString alloc] init];
		combinerIconEtTexte(icon,chaine,iconEtTexte);
		[item setIconEtTexte:iconEtTexte];
		[iconEtTexte release];
	}
	
	[cell setTitle:[item iconEtTexte]];
	[cell setIntValue:[item etat]];
}


- (BOOL)outlineView:(NSOutlineView *)outlineView shouldTrackCell:(NSCell *)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
 if ([cell isKindOfClass:[NSButtonCell class]])
		return YES;
	else
		return NO;
}


- (void)outlineViewItemDidExpand:(NSNotification *)notification
{
	id item;
	
	item=[[notification userInfo] objectForKey:c_nsobject];
	[item setExpand:YES];
}


- (void)outlineViewItemDidCollapse:(NSNotification *)notification
{
	id item;
	
	item=[[notification userInfo] objectForKey:c_nsobject];
	[item setExpand:NO];
}


- (BOOL)selectionShouldChangeInTableView:(NSTableView *)aTableView
{
	return YES;
}


- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
	[self changerIncr];
} 


- (int)numberOfRowsInTableView:(NSTableView *)tableView
{
	int nb=[listeSauvegardeIncr count];
	if(nb)
		return nb;
	else 
		return 1;
}


- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(int)row
{
	if([listeSauvegardeIncr count])
		return [listeSauvegardeIncr objectAtIndex:[listeSauvegardeIncr count]-row-1];
	else
		return NSLocalizedString(@"NOINCAVAIBLE",nil); 
}

/*
- (BOOL)tabView:(NSTabView *)tabView shouldSelectTabViewItem:(NSTabViewItem *)tabViewItem
{
	return YES;
}
*/

- (void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem
{
	etat_radio_full_backup=-1;
	etat_radio_sync=-1;

	switch ((char)[[tabViewItem identifier] characterAtIndex:0])
	{
		case 'I':
			[self changerIncr];
			break;
		case 'F':
			[self changerFull];
			break;
		case 'S':
			[self changerSync];
			break;
		default:
			break;
	}
}


@end
