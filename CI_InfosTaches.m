#import <Cocoa/Cocoa.h>

#import "general.h"
#import "CR_File.h"

#import "CI_InfosTaches.h"
#import "CI_Principal.h"
#import "CI_InfosTachesCelluleInfoControleur.h"

#import "PD_Cle.h"
#import "PD_TacheSauvegarde.h"
#import "PD_TacheRestauration.h"


static NSString *c_infoTaches=@"InfosTaches";

@implementation CI_InfosTaches

@synthesize lesTuyaux;
@synthesize CI_principal;
@synthesize db_cles;


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

	[CI_principal release];

    [db_cles release];
	[lesTuyaux release];
	[verrouReload release];

	[controleurListe release];
    [listeDesControleursDeCellules release];
	
	[super dealloc];
}


- (void)afficher:(BOOL)flag
{
	if(!fenetre)
	{
		if (![NSBundle loadNibNamed:c_infoTaches owner: self])
		{
			DEBUGNSLOG(@"Can't load Nib file %@",c_infoTaches);
			return;
		}
		else
		{
			[fenetre setReleasedWhenClosed:NO];
			[fenetre setWorksWhenModal:YES];
			[fenetre setDelegate:self];
		}
	}
	
	[label_info setStringValue:@""];
	
	if(flag)
		[fenetre makeKeyAndOrderFront:self];
}


- (void)windowWillClose:(NSNotification *)notification
{
}


-(BOOL)majLigne:(int)row
{
 id ligne;
 id unObjet;
	
	ligne=[listeDesControleursDeCellules objectAtIndex:row];
	unObjet=[lesTuyaux objectAtIndex:row];
	
	/*
	 * tache de sauvegarde
	 */
	if([unObjet isMemberOfClass:[PD_TacheSauvegarde class]])
	{
		/*
		 * traitement en cours
		 */
		if([unObjet traitementEnCours]==TRUE)
		{
			[ligne activeIndicateurAvancement];
			[ligne messageLigne1:[[unObjet cle] idCle]];
			if([unObjet avancement]>0.0)
			{
				[[ligne indicateurAvancement] setIndeterminate:NO];
				[[ligne indicateurAvancement] setDoubleValue:(double)[unObjet avancement]];
			}
			else
			{
				[[ligne indicateurAvancement] setIndeterminate:YES];
			}
			[[ligne indicateurAvancement] startAnimation:self];
			[ligne messageLigne3:[unObjet complementDInfo]];
			[ligne boutonArretTacheSetTarget:unObjet setAction:@selector(stopTache:)];
			
			return YES;
		}
		/*
		 * traitement terminé
		 */
		else if([unObjet traitementTerminer]==TRUE)
		{
			DEBUGNSLOG(@"A task is finished : %@",[unObjet idTache]);
		}
		/*
		 * tache en attente du moteur
		 */
		else
		{
			[ligne desactiveIndicateurAvancement];
			[ligne messageLigne1:[[unObjet cle] idCle]];
			[ligne messageLigne2:NSLocalizedString(@"INJOBQUEUE",nil)];
			[ligne messageLigne3:@""];

			return YES;
		}
	}
	/*
	 * tache de retauration
	 */
	else if([unObjet isMemberOfClass:[PD_TacheRestauration class]])
	{
		[ligne activeIndicateurAvancement];
		[[ligne indicateurAvancement] setIndeterminate:YES];
		[[ligne indicateurAvancement] startAnimation:self];
		[ligne messageLigne1:[unObjet nomTache]];
		[ligne messageLigne3:@"Restauration en cours"];
		[ligne boutonArretTacheSetTarget:unObjet setAction:@selector(stopTache:)];

		return YES;
	}
	/*
	 * cle en attente
	 */
	else
	{
		[ligne desactiveIndicateurAvancement];
		[ligne messageLigne1:[[unObjet objectAtIndex:1] idCle]];
		[ligne messageLigne2:[NSString stringWithFormat:NSLocalizedString(@"STARTNEXTBACKUPAT",nil)]];
		[ligne messageLigne3:[unObjet objectAtIndex:0]];
		
		return YES;
	}
	
	
	return NO;
}


- (NSMutableArray *) listeDesControleursDeCellules
{
    if (listeDesControleursDeCellules == nil)
        listeDesControleursDeCellules = [[NSMutableArray alloc] init];
    
    return listeDesControleursDeCellules;
}


- (void) ajouterLigne:(id)sender
{	
	CI_InfosTachesCelluleInfoControleur *uneLigne;
	
	uneLigne=[[CI_InfosTachesCelluleInfoControleur alloc] init];
	[uneLigne desactiveIndicateurAvancement];
	[uneLigne messageLigne1:@""];
	[uneLigne messageLigne2:@""];
	[uneLigne messageLigne3:@""];
	[[uneLigne indicateurAvancement] setMinValue:0.0];
	[[uneLigne indicateurAvancement] setMaxValue:1.0];
	[[uneLigne indicateurAvancement] setDoubleValue:0.0];
	[[uneLigne indicateurAvancement] setIndeterminate:YES];
 
	[listeDesControleursDeCellules addObject: uneLigne];
 	
	[uneLigne release];
}


- (void) ajouterXlignes:(NSInteger)nbLignes
{
	NSInteger i;
	
	for(i=0;i<nbLignes;i++)
	{
		[self ajouterLigne:nil];
	}
}


- (void) supprimerLigne:(id)sender
{
	if([listeDesControleursDeCellules count]>0)
		[listeDesControleursDeCellules removeLastObject];
}


- (void) supprimerXlignes:(NSInteger)nbLignes
{
 NSInteger i;
	
	for(i=0;i<nbLignes;i++)
		[self supprimerLigne:nil];
}


- (void)_reload:(id)unObjet
{
	BOOL sortie=NO;
	do
	{
		if([lesTuyaux tryLockAll])
		{
			NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
			
			int nbObj = [lesTuyaux count];
			int nbLigne = [listeDesControleursDeCellules count];
			
			if(nbObj>nbLigne)
				[self ajouterXlignes:(nbObj-nbLigne)];
			else if (nbObj<nbLigne)
				[self supprimerXlignes:(nbLigne-nbObj)];
			
			int i;
			nbLigne=[listeDesControleursDeCellules count];
			for(i=0;i<nbLigne;i++)
			{
				[self majLigne:i];
			}
			
			[lesTuyaux unlockAll];
			
			[controleurListe reloadTableView];
			
			sortie=YES;
			
			[pool release];
		}
		else
		{
			DEBUGNSLOG(@"We haven't the locks, retry in 0.1 second");
			NSDate *loopUntil = [[NSDate alloc] initWithTimeIntervalSinceNow:0.1];
			
			[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:loopUntil];
			[loopUntil release];
		}
	}
	while(!sortie);
}


-(void)_updateStatutTache:(id)unObjet
{
	NSInteger i;
	id ligne;
	
	if([lesTuyaux tryLockAll])
	{
	 id tache=[unObjet object];
		
		i=[[lesTuyaux listeDesTachesEnCours] indexOfObject:tache];
		if(i<[listeDesControleursDeCellules count])
		{
			ligne=[listeDesControleursDeCellules objectAtIndex:i];
			[ligne retain];

			[ligne activeIndicateurAvancement];
			if([tache avancement]<0.0)
			{
				[[ligne indicateurAvancement] setIndeterminate:YES];
				[[ligne indicateurAvancement] startAnimation:nil];
			}
			else
			{
				[[ligne indicateurAvancement] setIndeterminate:NO];
				[[ligne indicateurAvancement] setDoubleValue:(double)[tache avancement]];
				[[ligne indicateurAvancement] startAnimation:nil];
			}
			[ligne messageLigne3:[tache complementDInfo]];
			
			[ligne release];
		}
		
		[lesTuyaux unlockAll];
	}
}


-(void)updateStatutTache:(id)unObjet
{
	[self performSelectorOnMainThread:@selector(_updateStatutTache:) withObject:unObjet waitUntilDone:YES];
}


-(void)reload:(id)unObjet
{
	[self performSelectorOnMainThread:@selector(_reload:) withObject:unObjet waitUntilDone:YES];
}


-(void)receptionNotifTache:(id)unObjet
{
	[self updateStatutTache:unObjet];
}


- (void) awakeFromNib
{
    // Creating the SubviewTableViewController
	verrouReload=[[NSLock alloc] init];
	
    controleurListe = [[CI_InfosTachesControleurListe controllerWithViewColumn: colonne_status] retain];
    [controleurListe setDelegate: self];
		
	// abonnement aux notifications
	NSNotificationCenter *nofifcenter=[NSNotificationCenter defaultCenter];
	[nofifcenter addObserver:self
					selector:@selector(receptionNotifTache:)
						name:D_NOTIFICHANGEMENTTACHESAUVEGARDE
					  object:nil];
	[nofifcenter addObserver:self
					selector:@selector(receptionNotifTache:)
						name:D_NOTIFCHANGEMENTRESTAURATION
					  object:nil];
		
	[controleurListe reloadTableView];
}


// Methods from SubviewTableViewControllerDataSourceProtocol
- (NSView *) tableView:(NSTableView *) tableView viewForRow:(int) row
{
    return [[[self listeDesControleursDeCellules] objectAtIndex: row] view];
}


// Methods from NSTableViewDelegate category
- (void) tableViewSelectionDidChange:(NSNotification *) notification
{
}


// Methods from NSTableDataSource protocol
- (int) numberOfRowsInTableView:(NSTableView *) tableView
{
    return [[self listeDesControleursDeCellules] count];
}


- (id) tableView:(NSTableView *) tableView objectValueForTableColumn:(NSTableColumn *) tableColumn row:(int) row
{
	if([lesTuyaux tryLockAll])
	{
		[self majLigne:row];
		[lesTuyaux unlockAll];
	}
    return nil;
}


@end
