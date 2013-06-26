#import <Cocoa/Cocoa.h>

#import "general.h"

#import "CI_ConfigCle.h"
#import "CI_Principal.h"

#import "DB_Cles.h"

#import "PD_Cle.h"

static NSString *c_configCle=@"ConfigCle";


@implementation CI_ConfigCle

@synthesize enregistrementAModifier;
@synthesize db_cles;
@synthesize CI_principal;

- init
{
    if(self=[super init])
    {
		fenetre_configCle=nil;
    }
    return self;
}


-(void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
    [enregistrementAModifier release];
    
	[super dealloc];
}


- (void)awakeFromNib
{
}


- (void)windowWillClose:(NSNotification *)notification
{
	fenetre_configCle=nil;
}


- (void)griserActionsALInsersion:(BOOL)etat
{
    [champ_actionsALInsertion setEnabled:etat];
    [boutonPopUp_actionALInsertion setEnabled:etat];
    [stepper_actionsALInsertion setEnabled:etat];
    [bouton_labelNever1 setEnabled:etat];
    [bouton_labelImmediatly setEnabled:etat];
    [bouton_labelIf setEnabled:etat];
    [bouton_labelWhere setEnabled:etat];
}


- (void)griserPlanning:(BOOL)etat
{
    [champ_planning setEnabled:etat];
    [boutonPopUp_planning setEnabled:etat];
    [stepper_planning setEnabled:etat];
    [bouton_labelNever2 setEnabled:etat];
    [bouton_labelAfterLastBackup setEnabled:etat];
}


- (void)griserBoutons
{
    if([[boutons_typeSauvegarde selectedCell] tag] == 1)
    {
        [boutons_actionsALInsertion setEnabled:NO];
        [boutons_planning setEnabled:NO];
        [self griserActionsALInsersion:NO];
        [self griserPlanning:NO];
    }
    else
    {
        [boutons_actionsALInsertion setEnabled:YES];
        [boutons_planning setEnabled:YES];
        
        if([[boutons_actionsALInsertion selectedCell] tag] != 3)
        {
            [champ_actionsALInsertion setEnabled:NO];
            [boutonPopUp_actionALInsertion setEnabled:NO];
            [stepper_actionsALInsertion setEnabled:NO];
            [bouton_labelNever1 setEnabled:YES];
            [bouton_labelImmediatly setEnabled:YES];
            [bouton_labelIf setEnabled:YES];
            [bouton_labelWhere setEnabled:YES];
        }
        else
            [self griserActionsALInsersion:YES];
		
        [self griserPlanning:YES];
        if([[boutons_planning selectedCell] tag] == 1)
        {
            [champ_planning setEnabled:NO];
            [boutonPopUp_planning setEnabled:NO];
            [stepper_planning setEnabled:NO];
            [bouton_labelNever2 setEnabled:YES];
            [bouton_labelAfterLastBackup setEnabled:YES];
        }
        else
            [self griserPlanning:YES];
    }
}


- (void)ouvrirModal:(id)mere avecCleParIndex:(int)indexCle
{
	id valeursParDefaut;
	id obj;
    
	if(!fenetre_configCle)
	{
		if (![NSBundle loadNibNamed:c_configCle owner: self])
		{
			DEBUGNSLOG(@"Can't load Nib file %@",c_configCle);
			return;
		}
		else
		{
			[fenetre_configCle setReleasedWhenClosed:YES];
			[fenetre_configCle setDelegate:self];
		}
	}
	
	obj=[db_cles cleParPosition:indexCle];
	
	enregistrementAModifier=obj;
	if(enregistrementAModifier == nil)
		return;
    [enregistrementAModifier retain];
	
    valeursParDefaut=[CI_principal valeursParDefaut];
	[valeursParDefaut retain];
    
    [label_identifiantCle setStringValue:[enregistrementAModifier objectForKey:D_IDCLE]];
	[champ_descriptionCle setStringValue:[enregistrementAModifier objectForKey:D_DESCCLE]];
	
    if ( (obj = [enregistrementAModifier objectForKey:D_BACKDIR]) != nil)
	{
        [champ_repertoireSauvegarde setStringValue:obj];
		ancienRepertoireBackup=[[NSString alloc] initWithString:obj];
	}
    else
        [champ_repertoireSauvegarde setStringValue:[valeursParDefaut objectForKey:D_BACKDIR]];
    
    if ( (obj = [enregistrementAModifier objectForKey:D_BACKUPTYPE]) != nil)
        [boutons_typeSauvegarde selectCellWithTag:[obj intValue]];
    else
        [boutons_typeSauvegarde selectCellWithTag:[[valeursParDefaut objectForKey:D_BACKUPTYPE] intValue]];
	
    
    if ( (obj = [enregistrementAModifier objectForKey:D_ACTIONINSERSION]) != nil)
        [boutons_actionsALInsertion selectCellWithTag:[obj intValue]];
    else
        [boutons_actionsALInsertion selectCellWithTag:[[valeursParDefaut objectForKey:D_ACTIONINSERSION] intValue]];
	
    if ( (obj = [enregistrementAModifier objectForKey:D_ACTIONINSERSION_NB]) != nil) {
		[champ_actionsALInsertion setIntValue:[obj intValue]];
		[stepper_actionsALInsertion setIntValue:[obj intValue]]; }
    else {
		[champ_actionsALInsertion setIntValue:[[valeursParDefaut objectForKey:D_ACTIONINSERSION_NB] intValue]];
		[stepper_actionsALInsertion setIntValue:[[valeursParDefaut objectForKey:D_ACTIONINSERSION_NB] intValue]]; }
	
    if ( (obj = [enregistrementAModifier objectForKey:D_ACTIONINSERSION_UNITE]) != nil)
        [boutonPopUp_actionALInsertion selectItemAtIndex:[obj intValue]];
    else
        [boutonPopUp_actionALInsertion selectItemAtIndex:[[valeursParDefaut objectForKey:D_ACTIONINSERSION_UNITE] intValue]];
	
    if( (obj = [enregistrementAModifier objectForKey:D_PLANNING]) !=nil)
        [boutons_planning selectCellWithTag:[obj intValue]];
    else
        [boutons_planning selectCellWithTag:[[valeursParDefaut objectForKey:D_PLANNING] intValue]];
	
    if( (obj = [enregistrementAModifier objectForKey:D_PLANNING_NB]) != nil) {
		[champ_planning setIntValue:[obj intValue]];
		[stepper_planning setIntValue:[obj intValue]]; }
    else {
		[champ_planning setIntValue:[[valeursParDefaut objectForKey:D_PLANNING_NB] intValue]];
		[stepper_planning setIntValue:[[valeursParDefaut objectForKey:D_PLANNING_NB] intValue]]; }
    
    if( (obj = [enregistrementAModifier objectForKey:D_PLANNING_UNITE]) != nil)
        [boutonPopUp_planning selectItemAtIndex:[obj intValue]];
    else
        [boutonPopUp_planning selectItemAtIndex:[[valeursParDefaut objectForKey:D_PLANNING_UNITE] intValue]];
	
    [self griserBoutons];
	
	[valeursParDefaut release];
	
	[NSApp beginSheet: fenetre_configCle
       modalForWindow: mere
        modalDelegate: nil
       didEndSelector: nil
          contextInfo: nil];
    [NSApp runModalForWindow:fenetre_configCle];
	
    [NSApp endSheet:fenetre_configCle];
	
    [fenetre_configCle orderOut:self]; 
}


- (void)ouvrirModal:(id)mere avecCleParIdCle:(id)idCle
{
	int index;
	
    [idCle retain];
	
    index=[db_cles indexPourIdCle:idCle];
    if(index>=0)
        [self ouvrirModal:mere avecCleParIndex:index];
	
	[idCle release];
}


- (BOOL)validerRepertoire
{
    BOOL isDir;
    NSFileManager *fileManager;
    NSString *repertoire;
    int status;
    
    fileManager = [NSFileManager defaultManager];
    repertoire = [[champ_repertoireSauvegarde stringValue] stringByExpandingTildeInPath];
    
    if ([fileManager fileExistsAtPath:repertoire isDirectory:&isDir] && isDir)
    {
        if([fileManager isWritableFileAtPath:repertoire])
        {
            [champ_repertoireSauvegarde setStringValue:repertoire];
            return YES;
        }
        
        NSBeep();
        status = NSRunAlertPanel(NSLocalizedString(@"INVALID_DIR",nil),
                                 NSLocalizedString(@"DIRNOTWRITABLE",nil),
                                 NSLocalizedString(@"B_OK",nil),
                                 nil,
                                 nil); 
        return NO;
    }
    
    NSBeep();
    status = NSRunAlertPanel(NSLocalizedString(@"INVALID_DIR",nil),
                             NSLocalizedString(@"DIRNOTEXIST",nil),
                             NSLocalizedString(@"B_OK",nil),
                             nil,
                             nil); 
    return NO;
}


- (BOOL)quidAncienRepertoire
{
	int status;
	
	if(ancienRepertoireBackup)
	{
		if([ancienRepertoireBackup compare:[champ_repertoireSauvegarde stringValue]]!=NSOrderedSame)
		{
			status = NSRunAlertPanel(NSLocalizedString(@"DESTDIRCHANGE",nil),
									 NSLocalizedString(@"DESTDIRCHANGE+",nil),
									 NSLocalizedString(@"B_KEEP",nil),
									 NSLocalizedString(@"B_DELETE",nil),
									 nil);
			return !status;
		}
	}
	return NO;
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


- (IBAction)bouton_choisir:(id)sender
{
    [self choisirRepertoire];
}


- (IBAction)bouton_annuler:(id)sender
{
	[NSApp stopModal];
}


- (IBAction)bouton_labelNever1:(id)sender
{
    [boutons_actionsALInsertion selectCellWithTag:1];
    [self griserBoutons];
}


- (IBAction)bouton_labelImmediatly:(id)sender
{
    [boutons_actionsALInsertion selectCellWithTag:2];
    [self griserBoutons];
}


- (IBAction)bouton_labelIfWhere:(id)sender
{
    [boutons_actionsALInsertion selectCellWithTag:3];
    [self griserBoutons];
}


- (IBAction)bouton_labelNever2:(id)sender
{
    [boutons_planning selectCellWithTag:1];
    [self griserBoutons];
}


- (IBAction)bouton_labelAfterLastBackup:(id)sender
{
    [boutons_planning selectCellWithTag:2];
    [self griserBoutons];
}


- (IBAction)bouton_ok:(id)sender
{
	// mise a jour de l'enregistrement
    if(![self validerRepertoire])
        return;

	if([self quidAncienRepertoire])
	{
		NSString *chemin=[[NSString alloc] initWithFormat:@"%@/%@",
						  [champ_repertoireSauvegarde stringValue],
						  [enregistrementAModifier objectForKey:D_IDCLE]];
		DEBUGNSLOG(@"Deleting %@",chemin);
		testExistAndRemoveIfTrue(chemin);
		[chemin release];		
	}
    
    [enregistrementAModifier setObject:[champ_descriptionCle stringValue] forKey:D_DESCCLE];
    [enregistrementAModifier setObject:[champ_repertoireSauvegarde stringValue] forKey: D_BACKDIR];
    
    [enregistrementAModifier setObject:[NSNumber numberWithInt:[[boutons_typeSauvegarde selectedCell] tag]] forKey:D_BACKUPTYPE];
    
    [enregistrementAModifier setObject:[NSNumber numberWithInt:[[boutons_actionsALInsertion selectedCell] tag]] forKey:D_ACTIONINSERSION];
    [enregistrementAModifier setObject:[NSNumber numberWithInt:[champ_actionsALInsertion intValue]] forKey:D_ACTIONINSERSION_NB];
    [enregistrementAModifier setObject:[NSNumber numberWithInt:[boutonPopUp_actionALInsertion indexOfSelectedItem]] forKey:D_ACTIONINSERSION_UNITE];

    [enregistrementAModifier setObject:[NSNumber numberWithInt:[[boutons_planning selectedCell] tag]] forKey:D_PLANNING];
    [enregistrementAModifier setObject:[NSNumber numberWithInt:[champ_planning intValue]] forKey:D_PLANNING_NB];
    [enregistrementAModifier setObject:[NSNumber numberWithInt:[boutonPopUp_planning indexOfSelectedItem]] forKey:D_PLANNING_UNITE];
    
    [db_cles sauvegarder];

    [enregistrementAModifier release];
    
	[NSApp stopModal];

    // déplanifier et replanifier la cle ici
}


- (IBAction)boutons:(id)sender
{
	[self griserBoutons];
}

@end
