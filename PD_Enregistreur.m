#import <Cocoa/Cocoa.h>

#import "general.h"

#import "CR_Notificateur.h"
#import "PD_Logueur.h"
#import "PD_Enregistreur.h"
#import "PD_Moteur.h"

#import "CI_Principal.h"
#import "CI_ListeCles.h"
#import "CI_ConfigCle.h"


@implementation PD_Enregistreur

@synthesize pere;
@synthesize notifEnregistrement;
@synthesize listeDesClesMontees;


-(id)init
{
	if (self = [super init])
	{
		listeDesClesMontees=[[NSMutableDictionary alloc] init];
	}
    return self;
}


-(void)dealloc
{
    [pere release];
	[listeDesClesMontees release];
	[notifEnregistrement release];
	
    [super dealloc];
}


-(void)supprimerToutesLesNotifications
{
	[notifEnregistrement release];
	notifEnregistrement=nil;
}

#ifdef D_DEBUG
-(void)afficherClesMontees
{
	id cle;
	NSEnumerator *e;
    
	@synchronized(listeDesClesMontees)
	{
		e = [listeDesClesMontees objectEnumerator];
		while(cle=[e nextObject])
		{
			NSLog(@"CLE %@",[cle idCle]);
		}
	}
}
#endif

-(id)cleMonteeParPointDeMontage:(NSString *)pointDeMontage
{
	id cle;
	NSEnumerator *e;
    
	[[pointDeMontage retain] autorelease];
	
	@synchronized(listeDesClesMontees)
	{
		e = [listeDesClesMontees objectEnumerator];
		while(cle=[e nextObject])
		{
			if([pointDeMontage isEqualToString:[cle pointDeMontage]])
				return cle;
		}
	}
	return nil;
}


-(id)cleMonteeParIdCle:(NSString *)unIdCle
{
	id cle;
	NSEnumerator *e;
    
	[[unIdCle retain] autorelease];
	
	@synchronized(listeDesClesMontees)
	{
		e = [listeDesClesMontees objectEnumerator];
		while(cle=[e nextObject])
		{
			if([unIdCle isEqualToString:[cle idCle]])
			{
				return cle;
			}
		}
	}
    return nil;
}


-(BOOL)desenregistrer:(NSString *)pointDeMontage
{
 id cle;

	[[pointDeMontage retain] autorelease];
	
    cle=[self cleMonteeParPointDeMontage:pointDeMontage];
    if(cle)
    {
		@synchronized(listeDesClesMontees)
		{
			[listeDesClesMontees removeObjectForKey:[cle idCle]];
			
			CR_Notificateur *notifSimple;
			notifSimple=[[CR_Notificateur alloc] init];
			[notifSimple envoyerNotification:notifEnregistrement];
			[notifSimple release];
		}
        return YES;
    }
    return NO;
}


-(BOOL)desenregistrerCle:(PD_Cle *)uneCle
{
	[uneCle retain];

	@synchronized(listeDesClesMontees)
	{
		[listeDesClesMontees removeObjectForKey:[uneCle idCle]];
		
		CR_Notificateur *notifSimple;
		notifSimple=[[CR_Notificateur alloc] init];
		[notifSimple envoyerNotification:notifEnregistrement];
		[notifSimple release];
	}
	
	[uneCle release];
	
    return YES;
}


-(BOOL)CleEstEnregistree:(PD_Cle *)uneCle
{
	[uneCle retain];
	
	@synchronized(listeDesClesMontees)
	{
		if([listeDesClesMontees objectForKey:[uneCle idCle]])
		{
			[uneCle release];
			return YES;
		}
		else
		{
			[uneCle release];
			return NO;
		}
	}
	
	return NO;
}


-(BOOL)enregistrer:(PD_Cle *)uneCle
{
 id elementDeLaDb;
 id idCle;
 int status=0;
 id db;
 id prefs;
 NSDictionary *valeursParDefaut;
 PD_Logueur *logueur;
	
	[uneCle retain];
	logueur=[[PD_Logueur alloc] init];
	
    db=[pere db_cles];
	prefs=[[[pere pere] prefs] dictionaryForKey:D_DEFAULTS]; // le pere de mon pere est CI_Principal
	
    idCle=[uneCle idCle];
    if(!idCle) // la cle n'a pas d'identifiant => c'est une nouvelle clé
    { 
		[logueur loguerMessage:NSLocalizedString(@"UNKNOWKEYDETECTED",nil)];
		
		if([[prefs objectForKey:D_AUTODECLARATION] intValue]==NSOffState)
		{
			// que doit on faire ?
			status=[[pere pere] dialog: NSLocalizedString(@"NEWKEYDETECTED",nil)
							   message: NSLocalizedString(@"NEWKEYDETECTED+",nil)
					   boutonParDefaut: NSLocalizedString(@"B_CONFIGURE",nil)
					  boutonAlternatif: NSLocalizedString(@"B_NO",nil)
						   autreBouton: NSLocalizedString(@"B_DEFAUTLCONFIG",nil)];
			if(!status)
			{
				[logueur loguerMessage:NSLocalizedString(@"KEYNOTCONGIGURED",nil)];

				[uneCle release];
				[logueur release];
				return NO; // on ne fait rien
			}
        }
		else
			status=0;

        do // pour les deux autres choix, il faut d'abord générer un idCle
        {
            elementDeLaDb=nil;
            [uneCle genererIdCle];
            idCle=[uneCle idCle];
            elementDeLaDb=[db cleParIndexIdCle:idCle];
        }
        while (elementDeLaDb);
		[logueur loguerMessage:[NSString stringWithFormat:NSLocalizedString(@"NEWKEY:",nil), idCle]];

        // et enregistrer le "tag" sur la clé
        [uneCle enregistrerDansTagCle];
    }
    
    // la cle existe t'elle dans la base
    elementDeLaDb=[db cleParIndexIdCle:idCle];
    if(!elementDeLaDb)
    { 
        // Non : récupération des informations pour créer la clé dans la base
        [uneCle setDonneeInfoCle:idCle pourPropriete:D_IDCLE];
        [uneCle setDonneeInfoCle:[NSDate date] pourPropriete:D_INIT];
        [uneCle setDonneeInfoCle:[NSDate distantPast] pourPropriete:D_SAUVSUIV];
        [uneCle setDonneeInfoCle:[NSDate distantPast] pourPropriete:D_DERNSAUV];
        [uneCle setDonneeInfoCle:@"" pourPropriete:D_DESCCLE];
        [uneCle setDonneeInfoCle:@"" pourPropriete:D_BACKDIR];

        // et création de la clé dans la base
		[logueur loguerMessage:[NSString stringWithFormat:NSLocalizedString(@"ADDTODATABASE:",nil), idCle]];

        [uneCle enregistrerDansDB: db];
        
        if(status == 1)
        {
            // configuration de la cle via l'interface
			[logueur loguerMessage:[NSString stringWithFormat:NSLocalizedString(@"STARTINTERATIVECONFIG:",nil), idCle]];
			
            [[[pere pere] CI_listeCles] editerCle:idCle];
			
			[logueur loguerMessage:[NSString stringWithFormat:NSLocalizedString(@"ENDINTERACTIVECONFIG:",nil), idCle]];
        }
        else
        {

            // chargement des valeurs par defaut
            valeursParDefaut=[[NSUserDefaults standardUserDefaults] dictionaryForKey:D_DEFAULTS];
            if(valeursParDefaut)
            {
				[logueur loguerMessage:[NSString stringWithFormat:NSLocalizedString(@"CONFIGDEFAULT:",nil), idCle]];

                [uneCle setDonneeInfoCle:[[valeursParDefaut objectForKey:D_BACKDIR] stringByExpandingTildeInPath] pourPropriete:D_BACKDIR];
                [uneCle setDonneeInfoCle: [valeursParDefaut objectForKey:D_BACKUPTYPE] pourPropriete:D_BACKUPTYPE];
                [uneCle setDonneeInfoCle: [valeursParDefaut objectForKey:D_ACTIONINSERSION] pourPropriete:D_ACTIONINSERSION];
                [uneCle setDonneeInfoCle: [valeursParDefaut objectForKey:D_ACTIONINSERSION_NB] pourPropriete:D_ACTIONINSERSION_NB];
                [uneCle setDonneeInfoCle: [valeursParDefaut objectForKey:D_ACTIONINSERSION_UNITE] pourPropriete:D_ACTIONINSERSION_UNITE];
                [uneCle setDonneeInfoCle: [valeursParDefaut objectForKey:D_PLANNING] pourPropriete:D_PLANNING];
                [uneCle setDonneeInfoCle: [valeursParDefaut objectForKey:D_PLANNING_NB] pourPropriete:D_PLANNING_NB];
                [uneCle setDonneeInfoCle: [valeursParDefaut objectForKey:D_PLANNING_UNITE] pourPropriete:D_PLANNING_UNITE];
            }
            else
            {
				[logueur loguerMessage:[NSString stringWithFormat:NSLocalizedString(@"ERRORNODEFAULT:",nil), idCle]];

                DEBUGNSLOG(@"Error : no default value exist");

				[uneCle release];
				[logueur release];
				
				return NO;
            }
        }
    }
    else
    {
        [uneCle chargerDepuisDB:db];
    }
	
    // mettre la cle dans la liste des cles "montées"
	@synchronized(listeDesClesMontees)
	{
		[listeDesClesMontees setObject:uneCle forKey:idCle];
		
		CR_Notificateur *notifSimple=[[CR_Notificateur alloc] init];
		[notifSimple envoyerNotification:notifEnregistrement];
		[notifSimple release];
	}
	
	[uneCle release];
	[logueur release];
	
    return YES;
}

@end
