#import <Cocoa/Cocoa.h>

#import "general.h"

#import "CI_Preferences.h"
#import "CI_ListeCles.h"
#import "CI_Journal.h"

static NSString *c_preferences=@"Preferences";

@implementation CI_Preferences

@synthesize CI_listeCles;
@synthesize valeursParDefaut;


- (void)dealloc
{
    [valeursParDefaut release];
    [indicateursDetection release];
	[CI_listeCles release];
    
	[super dealloc];
}


- (id) init
{
    if ((self = [super init]) != nil)
    {
		fenetre=nil;
    }
	
    return self;
}


- (void)awakeFromNib
{    
    indicateursDetection = [[NSArray alloc] initWithObjects:D_MSDOS, D_HFS, D_NTFS, D_AFPFS, D_OTHERFS, D_NODMCI, D_NOTKEY, nil];
}


- (void)afficher
{
	if(!fenetre)
	{
		if (![NSBundle loadNibNamed:c_preferences owner: self])
		{
			DEBUGNSLOG(@"Can't load Nib file %@",c_preferences);
			return;
		}
		else
		{
			[fenetre setReleasedWhenClosed:YES];
			[fenetre setWorksWhenModal:YES];
			[fenetre setDelegate:self];
			[self loadPrefs];
		}
	}
	[fenetre makeKeyAndOrderFront:self];
}


- (void)windowWillClose:(NSNotification *)notification
{
	[self updatePrefs];
	fenetre=nil;
}


- (void)loadPrefs
{
	/*
	 * Onglet "Defaults"
	 */
    [champ_repertoireSauvegarde setStringValue:[valeursParDefaut objectForKey:D_BACKDIR]];
    [boutons_typeBackup selectCellWithTag:[[valeursParDefaut objectForKey:D_BACKUPTYPE] intValue]];
    [boutons_actionsALInsertion selectCellWithTag:[[valeursParDefaut objectForKey:D_ACTIONINSERSION] intValue]];
    [champ_actionsALInsertion setIntValue:[[valeursParDefaut objectForKey:D_ACTIONINSERSION_NB] intValue]];
	[stepper_insertion setIntValue:[[valeursParDefaut objectForKey:D_ACTIONINSERSION_NB] intValue]];
    [boutonPopUp_actionALInsertion selectItemAtIndex:[[valeursParDefaut objectForKey:D_ACTIONINSERSION_UNITE] intValue]];
    [boutons_planning selectCellWithTag:[[valeursParDefaut objectForKey:D_PLANNING] intValue]];
    [champ_planning setIntValue:[[valeursParDefaut objectForKey:D_PLANNING_NB] intValue]];
	[stepper_planning setIntValue:[[valeursParDefaut objectForKey:D_PLANNING_NB] intValue]];
    [boutonPopUp_planning selectItemAtIndex:[[valeursParDefaut objectForKey:D_PLANNING_UNITE] intValue]];
	[checkBox_autodeclaration setState:[[valeursParDefaut objectForKey:D_AUTODECLARATION] intValue]];
	[checkBox_advancedOption setState:[[valeursParDefaut objectForKey:D_ADVANCED] intValue]];
	
	/*
	 * Onglet detection
	 */
    [slider_tailleMax setDoubleValue:positionSliderEnFonctionDeTaille([[valeursParDefaut objectForKey:D_MAXKEYSIZE] doubleValue])];
    [self slider_tailleMax:slider_tailleMax]; // pour mettre a jour le label
	
    NSArray *checkBoxs = [[NSArray arrayWithObjects:checkBox_msdos, checkBox_hfs, checkBox_ntfs, checkBox_afpfs, checkBox_other, checkBox_nodmci, checkBox_notkey, nil] retain];
    NSDictionary *assoccheckBoxs_DetectionFlags = [[NSDictionary dictionaryWithObjects:checkBoxs forKeys:indicateursDetection] retain];
	NSEnumerator *e; 
	id obj;
	
    e = [checkBoxs objectEnumerator]; 
    while ( (obj = [e nextObject]) )
        [obj setState:NSOffState];
	
    e = [[valeursParDefaut objectForKey:D_DETECTION] objectEnumerator]; 
    while ( (obj = [e nextObject]) )
        [[assoccheckBoxs_DetectionFlags objectForKey:obj] setState:NSOnState];
	
	[assoccheckBoxs_DetectionFlags release];
	[checkBoxs release];
	
	/*
	 * Onglet "Display"
	 */
	int i;
	NSArray *listeColonnesAffichees;
	NSArray *keys = [[NSArray alloc]  initWithObjects: D_IDCLE,D_DESCCLE,D_INIT,D_DERNSAUV,D_SAUVSUIV,D_TYPESAUV,D_BACKDIR,D_KSTATUS, nil];
	NSArray *objects = [[NSArray alloc] initWithObjects:cb_colonne1,cb_colonne2,cb_colonne3,cb_colonne4,cb_colonne5,cb_colonne6,cb_colonne7,cb_colonne8,nil];
    NSDictionary *assocColonnesCheckbox = [[NSDictionary alloc] initWithObjects:objects forKeys:keys];
	
	for(i=0;i<[objects count];i++)
		[[objects objectAtIndex:i] setState:NSOffState];
	
	listeColonnesAffichees=[CI_listeCles listeColonnesAffichees];
	[listeColonnesAffichees retain];
	
	for(i=0;i<[listeColonnesAffichees count];i++)
		[[assocColonnesCheckbox objectForKey:[listeColonnesAffichees objectAtIndex:i]] setState:NSOnState];
	
	[assocColonnesCheckbox release];
	[objects release];
	[keys release];
	[listeColonnesAffichees release];
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
        [champ_repertoireSauvegarde setStringValue:[[openDlg filenames] objectAtIndex:0]];
    }
}


- (IBAction)slider_tailleMax:(id)sender
{
 double taille;
 double a,v;
 NSString *s;
    
    v=[sender doubleValue];
    a=(double)((long)v);

    if(v>(a+0.925))
    {
        [sender setDoubleValue:a+1];
        v=a+1;
    }
    else if (v<(a+0.075))
    {
        [sender setDoubleValue:a];
        v=a;
    }
    
    taille=tailleEnFonctionDePositionSlider(v);
    
    if(taille<0)
        s=NSLocalizedString(@"NOLIMIT",nil);
    else
    {
        if(taille<1024.0)
            s=[NSString stringWithFormat:@"%.1f Mo",taille];
        else
            s=[NSString stringWithFormat:@"%.1f Go",taille/1024];
    }
    
    [label_tailleMax setStringValue:s];
}


- (IBAction)actionCaseACocher:(id)sender
{
	if([sender state]==NSOnState)
		[CI_listeCles activerColonneTable:[[CI_listeCles listeIdentifiantsDeToutesLesColonnes] objectAtIndex:[sender tag]-1]];
	else
		[CI_listeCles desactiverColonneTable:[[CI_listeCles listeIdentifiantsDeToutesLesColonnes] objectAtIndex:[sender tag]-1]];
}


- (IBAction)bouton_choose:(id)sender
{
    [self choisirRepertoire];
}


- (IBAction)checkBoxs:(id)sender
{
    NSMutableArray *detection=[[[NSUserDefaults standardUserDefaults] dictionaryForKey:D_DEFAULTS] objectForKey:D_DETECTION];
    id obj=[indicateursDetection objectAtIndex:[sender tag]-1];
    switch ([sender state])
    {
        case NSOnState:
            if(![detection containsObject:obj])
                [detection addObject:obj];
            break;

        case NSOffState:
            if([detection containsObject:obj])
                [detection removeObject:obj];
            break;

        default:
            break;
    }
}


- (IBAction)checkAdvancedOption:(id)sender;
{
	[valeursParDefaut setObject:[NSNumber numberWithInt:[checkBox_advancedOption state]] forKey:D_ADVANCED];
	[CI_listeCles checkDefaultsEndUpdateButton];
}


- (IBAction)bouton_fermer:(id)sender
{
	[fenetre performClose:self];
}


- (void)updatePrefs
{
	[valeursParDefaut setObject:[champ_repertoireSauvegarde stringValue] forKey:D_BACKDIR];
	[valeursParDefaut setObject:[NSNumber numberWithInt:[[boutons_typeBackup selectedCell] tag]] forKey:D_BACKUPTYPE];
	[valeursParDefaut setObject:[NSNumber numberWithInt:[[boutons_actionsALInsertion selectedCell] tag]] forKey:D_ACTIONINSERSION];
	[valeursParDefaut setObject:[NSNumber numberWithInt:[champ_actionsALInsertion intValue]] forKey:D_ACTIONINSERSION_NB];
	[valeursParDefaut setObject:[NSNumber numberWithInt:[boutonPopUp_actionALInsertion indexOfSelectedItem]] forKey:D_ACTIONINSERSION_UNITE];
	[valeursParDefaut setObject:[NSNumber numberWithInt:[[boutons_planning selectedCell] tag]] forKey:D_PLANNING];
	[valeursParDefaut setObject:[NSNumber numberWithInt:[champ_planning intValue]] forKey:D_PLANNING_NB];
	[valeursParDefaut setObject:[NSNumber numberWithInt:[boutonPopUp_planning indexOfSelectedItem]] forKey:D_PLANNING_UNITE];
	[valeursParDefaut setObject:[NSNumber numberWithDouble:tailleEnFonctionDePositionSlider([slider_tailleMax doubleValue])] forKey:D_MAXKEYSIZE];
	[valeursParDefaut setObject:[NSNumber numberWithInt:[checkBox_autodeclaration state]] forKey:D_AUTODECLARATION];
	[valeursParDefaut setObject:[NSNumber numberWithInt:[checkBox_advancedOption state]] forKey:D_ADVANCED];
}


@end
