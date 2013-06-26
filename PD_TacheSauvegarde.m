#import <Cocoa/Cocoa.h>

#import "general.h"
#import "fileutils.h"

#import "PD_Logueur.h"
#import "CR_Notificateur.h"
#import "CR_RessourceSpeciale.h"

#import "PD_TacheSauvegarde.h"
#import "PD_Moteur.h"


void selectionASupprimer(NSArray *liste, NSCalendarUnit u, SEL selecteur, NSMutableArray *toDel)
{
 int num;
 int dernier=-1;
 NSString *last=nil;

	NSCalendar *calendrier = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];

	for(id rep in liste)
	{
#ifdef D_DEBUG
		NSLog(@"REP = %@",rep);
#endif
		NSDate *dateRep=[[NSDate alloc] initWithString:rep];
		NSDateComponents *jour = [calendrier components:(u) fromDate:dateRep];
		[dateRep release];
		
		num=(int)[jour performSelector:(selecteur)];
#ifdef D_DEBUG
		NSLog(@"NUM = %d (vs dernier = %d)",num,dernier);
#endif
		if(num!=dernier)
		{
			dernier=num;
		}
		else
		{
			if(last)
			{
				[toDel addObject:last];
#ifdef D_DEBUG
				NSLog(@"   %@ ajoute à toDel",last);
#endif
			}
		}
		last=rep;
	}
	
	[calendrier release];
	NSLog(@" ");
}


@implementation PD_TacheSauvegarde

@synthesize pere;
@synthesize cle;
@synthesize aReplanifier;
@synthesize complementDInfo;
@synthesize notifDebutTacheSauvegarde;
@synthesize notifFinTacheSauvegarde;
@synthesize notifChangementTacheSauvegarde;

// durée en seconde
#define UNEHEURE 3600 // 60*60
#define UNJOUR 86400 // UNEHEURE*24
#define UNESEMAINE 604800 // UNJOUR*7
#define UNMOIS 2592000 // UNJOUR*30

-(id)init
{
	if (self = [super init])
	{
		logueur=[[PD_Logueur alloc] init];
		complementDInfo=[[NSString alloc] initWithString:@""];
	}
	return self;
}


-(void)dealloc
{
	[complementDInfo release];
    [cle release];
    [pere release];
	[logueur release];
    
	[notifDebutTacheSauvegarde release];
	[notifFinTacheSauvegarde release];
	[notifChangementTacheSauvegarde release];
	
    [super dealloc];
}


-(void)supprimerToutesLesNotifications
{
	[notifDebutTacheSauvegarde release];
	notifDebutTacheSauvegarde=nil;
	
	[notifFinTacheSauvegarde release];
	notifFinTacheSauvegarde=nil;
	
	[notifChangementTacheSauvegarde release];
	notifChangementTacheSauvegarde=nil;
}


-(void)envoyerNotification:(NSNotification *)uneNotif
{
	[uneNotif retain];
	
	[[NSNotificationQueue defaultQueue]
	 enqueueNotification: uneNotif
	 postingStyle: NSPostNow
	 coalesceMask: NSNotificationNoCoalescing
	 forModes: nil];
	
	[uneNotif release];
}


-(void)stopTache:(id)sender
{
	interrompreTache=YES;
}


-(int)menageApresIncrementale:(NSString *)rep etNotif:(NSNotification *)notif
{
 NSArray *contenuRepertoire;
 NSError *uneErreur = nil;
 int cptr=0;
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	if(contenuRepertoire=[fileManager contentsOfDirectoryAtPath:rep error:&uneErreur])
	{
	 NSDate *dateRep;
		
#ifdef D_DEBUG
		NSLog(@"ContenuRepertoire %@",rep);
		NSLog(@"======================================================================================");
		for(id o in contenuRepertoire)
		{
			NSLog(@"   %@",o);
		}
#endif
		NSMutableArray *listeMoins1Heure=[[NSMutableArray alloc] init];
		NSMutableArray *listeMoins1Jour=[[NSMutableArray alloc] init];;
		NSMutableArray *listeMoins7Jours=[[NSMutableArray alloc] init];;
		NSMutableArray *listeMoins30Jours=[[NSMutableArray alloc] init];;
		NSMutableArray *listeSuperieur30Jours=[[NSMutableArray alloc] init];;
		
		NSDate *maintenant = [NSDate date];
		
		NSDate *maintenantMoins1Heure=[[NSDate alloc] initWithTimeInterval:-1*UNEHEURE sinceDate:maintenant];
		NSDate *maintenantMoins1Jour=[[NSDate alloc] initWithTimeInterval:-1*UNJOUR sinceDate:maintenant];
		NSDate *maintenantMoins7Jours=[[NSDate alloc] initWithTimeInterval:-1*UNESEMAINE sinceDate:maintenant];
		NSDate *maintenantMoins30Jours=[[NSDate alloc] initWithTimeInterval:-1*UNMOIS sinceDate:maintenant];
#ifdef D_DEBUG		
		NSLog(@" ");
		NSLog(@"maintenantMoins1Heure %@",maintenantMoins1Heure);
		NSLog(@"maintenantMoins1Jour %@",maintenantMoins1Jour);
		NSLog(@"maintenantMoins7Jours %@",maintenantMoins7Jours);
		NSLog(@"maintenantMoins30Jours %@",maintenantMoins30Jours);
#endif		
		for(id r in contenuRepertoire)
		{
            dateRep=[[NSDate alloc] initWithString:r];
			if(dateRep)
			{
				// si datefic<=maintenant et datefic>maintenant-1HEURE
				if([dateRep compare:maintenantMoins1Heure]==NSOrderedDescending)
					[listeMoins1Heure addObject:r];
				// si datefic<=maintenant-1HEURE et datefic>maintenant-1JOUR
				else if ([dateRep compare:maintenantMoins1Jour]==NSOrderedDescending)
					[listeMoins1Jour addObject:r];
				// si datefic<=maintenant-1JOUR et datefic>maintenant-7JOUR
				else if ([dateRep compare:maintenantMoins7Jours]==NSOrderedDescending)
					[listeMoins7Jours addObject:r];
				// si dtefic<=maintenant-7JOUR et datefic>maintenant-30JOUR
				else if ([dateRep compare:maintenantMoins30Jours]==NSOrderedDescending)
					[listeMoins30Jours addObject:r];
				else
					[listeSuperieur30Jours addObject:r];
		    }
			else
			{
				DEBUGNSLOG(@"directory (%@) is not a date",r);
			}
			[dateRep release];
        }
		
#ifdef D_DEBUG
		NSLog(@" ");
		NSLog(@"listeMoins1Heure %@",rep);
		NSLog(@"======================================================================================");
		for(id o in listeMoins1Heure)
			NSLog(@"   %@",o);

		NSLog(@" ");
		NSLog(@"listeMoins1Jour %@",rep);
		NSLog(@"======================================================================================");
		for(id o in listeMoins1Jour)
			NSLog(@"   %@",o);
		
		NSLog(@" ");
		NSLog(@"listeMoins7Jours %@",rep);
		NSLog(@"======================================================================================");
		for(id o in listeMoins7Jours)
			NSLog(@"   %@",o);
		
		NSLog(@" ");
		NSLog(@"listeMoins30Jours %@",rep);
		NSLog(@"======================================================================================");
		for(id o in listeMoins30Jours)
			NSLog(@"   %@",o);
		
		NSLog(@" ");
		NSLog(@"listeSuperieur30Jours %@",rep);
		NSLog(@"======================================================================================");
		for(id o in listeSuperieur30Jours)
			NSLog(@"   %@",o);
#endif
		
		[maintenantMoins30Jours release];
		[maintenantMoins7Jours release];
		[maintenantMoins1Jour release];
		[maintenantMoins1Heure release];
		
		NSMutableArray *toDel=[[NSMutableArray alloc] init];

#ifdef D_DEBUG
		NSLog(@"selectionASupprimer listeMoins1Jour hour");
#endif
		selectionASupprimer(listeMoins1Jour,NSHourCalendarUnit,@selector(hour),toDel);
#ifdef D_DEBUG
		NSLog(@"selectionASupprimer listeMoins7Jours day");
#endif
		selectionASupprimer(listeMoins7Jours,NSDayCalendarUnit,@selector(day),toDel);
#ifdef D_DEBUG
		NSLog(@"selectionASupprimer listeMoins30Jours week");
#endif
		selectionASupprimer(listeMoins30Jours,NSWeekCalendarUnit,@selector(week),toDel);
#ifdef D_DEBUG
		NSLog(@"selectionASupprimer listeSuperieur30Jours month");
#endif
		selectionASupprimer(listeSuperieur30Jours,NSMonthCalendarUnit,@selector(month),toDel);

		NSString *repToDel;
		for(id r in toDel)
		{
			DEBUGNSLOG(@"File \"%@\" will be delete",r);
			repToDel=[[NSString alloc] initWithFormat:@"%@/%@",rep,r];
			testExistAndRemoveIfTrue(repToDel);
			
			[complementDInfo release];
			complementDInfo=[NSString stringWithFormat:NSLocalizedString(@"DELETINGDIRECTORY:",nil),[repToDel lastPathComponent]];
			[complementDInfo retain];
			
			cptr++;
			[repToDel release];
		}
		
		[toDel release];
		[listeSuperieur30Jours release];
		[listeMoins30Jours release];
		[listeMoins7Jours release];
		[listeMoins1Jour release];
		[listeMoins1Heure release];
	}
	else
	{
		// traitement de l'erreur
	}
	
	[pool release];
	
	return cptr;
}


-(int)anaRysnc:(NSMutableString *)donneesDuTubeConcatenees etNotif:(NSNotification *)notif
{
 NSRange unePlage;
 NSUInteger finSansDelimiteurDeLigne;
 NSUInteger finAvecDelimiteurDeLigne;
 NSString *uneChaine;
 float pourcentageFichier;
 float a,b;
	
	for(;;)
	{
		// lecture d'une ligne
		unePlage.location=0;
		unePlage.length=0;
		[donneesDuTubeConcatenees getLineStart:NULL end:&finAvecDelimiteurDeLigne contentsEnd:&finSansDelimiteurDeLigne forRange:unePlage];
		
		if(finAvecDelimiteurDeLigne>finSansDelimiteurDeLigne) // si on est sur qu'on a une ligne complete
		{
			// récupération de la chaine à traiter sans le délimiteur de fin de ligne
			unePlage.length=finSansDelimiteurDeLigne;
			
			uneChaine=[[NSString alloc] initWithString:[donneesDuTubeConcatenees substringWithRange:unePlage]];
			// DEBUGNSLOG(@"RYNC : %@",uneChaine);
			// traitement des lignes de type :
			//    655360000 100%   56.08MB/s    0:00:11 (xfer#1, to-check=4/12)
			// pour calculer l'avancement approximatif
			NSScanner *unScanneur=[[NSScanner alloc] initWithString:uneChaine];
			if([unScanneur scanString:@"[PR]" intoString:NULL])
			{
				[unScanneur scanDouble:NULL];
				[unScanneur scanFloat:&pourcentageFichier];
				
				[unScanneur scanUpToString:@"to-check=" intoString:NULL];
				if(![unScanneur isAtEnd])
				{
					[unScanneur scanString:@"to-check=" intoString:NULL];
					[unScanneur scanFloat:&a];
					[unScanneur scanString:@"/" intoString:NULL];
					[unScanneur scanFloat:&b];
					avancement=(b-a)/b;
				}
				
				if(tmpNomFichier)
				{
					[complementDInfo release];
					complementDInfo=[NSString stringWithFormat:NSLocalizedString(@"PROCESSINGFILE::",nil),
									 [tmpNomFichier lastPathComponent],
									 pourcentageFichier];

					[complementDInfo retain];
				}
				
				if(notif) [self envoyerNotification:notif];
			}
			else
			{
				[unScanneur scanUpToString:@"" intoString:&tmpNomFichier];
			}
			
			[unScanneur release];
			[uneChaine release];
			
			// suppression de la chaine "buffer", délimiteur de fin de ligne compris
			unePlage.length=finAvecDelimiteurDeLigne;
			[donneesDuTubeConcatenees deleteCharactersInRange:unePlage];
		}
		else
			break;
	}
	
	if(interrompreTache==YES)
		return ER_TASKSTOPED;
	
	return ER_NOERROR;
}


-(int)anaUnison:(NSMutableString *)donneesDuTubeConcatenees etNotif:(NSNotification *)notif
{
 NSRange unePlage;
 NSUInteger finSansDelimiteurDeLigne;
 NSUInteger finAvecDelimiteurDeLigne;
 NSString *uneChaine;
 float f;
	
	for(;;)
	{
		// lecture d'une ligne
		unePlage.location=0;
		unePlage.length=0;
		[donneesDuTubeConcatenees getLineStart:NULL end:&finAvecDelimiteurDeLigne contentsEnd:&finSansDelimiteurDeLigne forRange:unePlage];
		
		if(finAvecDelimiteurDeLigne>finSansDelimiteurDeLigne) // si on est sur qu'on a une ligne complete
		{
			unePlage.length=finSansDelimiteurDeLigne;
			
			uneChaine=[[NSString alloc] initWithString:[donneesDuTubeConcatenees substringWithRange:unePlage]];
			NSScanner *unScanneur=[[NSScanner alloc] initWithString:uneChaine];
			
			if([unScanneur scanFloat:&f])
			{
				avancement=f/100;
				if(notif) [self envoyerNotification:notif];
			}
			
			[unScanneur release];
			[uneChaine release];
			
			unePlage.length=finAvecDelimiteurDeLigne;
			[donneesDuTubeConcatenees deleteCharactersInRange:unePlage];
		}
		else
			break;
	}
	
	if(interrompreTache==YES)
	{
		return ER_TASKSTOPED;
	}
	return ER_NOERROR;
}


-(int)tacheAvecComnande:(NSString *)commande
			  arguments:(NSArray *)args
		  environnement:(NSDictionary *)env
		   notification:(NSNotification *)notif
			etAnalyseur:(SEL)analyseur
{
	int retour;
	
	[commande retain];
	[args retain];
	[env retain];
	[notif retain];
	
	NSTask *tache =  [[NSTask alloc] init];
	NSPipe *tube = [[NSPipe alloc] init];
	
	retour=ER_NOERROR;
	@try
	{
		// lancement de la tâche
		if(env)
			[tache setEnvironment: env];
		[tache setLaunchPath: commande]; 
		[tache setArguments: args];
		[tache setStandardOutput: tube];
		[tache launch];
		
		@try
		{
			NSData *donneesDuTube = nil;
			NSMutableString *donneesDuTubeConcatenees;
			NSString *uneChaine = nil;
			
			avancement = 0.0;
			if(notif) [self envoyerNotification:notif];
			
			NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

			donneesDuTubeConcatenees = [[NSMutableString alloc] init];
			
			while ( (donneesDuTube = [[tube fileHandleForReading] availableData]) && [donneesDuTube length] ) 
			{
				uneChaine = [[NSString alloc] initWithData:donneesDuTube encoding:NSASCIIStringEncoding];
				[donneesDuTubeConcatenees appendString:uneChaine];
				[uneChaine release];
				
				retour=(int)[self performSelector:analyseur withObject:donneesDuTubeConcatenees withObject:notif];
				
				if(retour)
					break;
			}
			
			[donneesDuTubeConcatenees release];

			[pool release];
		}
		@catch (NSException *exception)
		{
			retour=ER_READINGPIPE;
			DEBUGNSLOG(@"Error while reading the output pipe of the rsync task (%@ : %@)", [exception name], [exception reason]);
			
			/* Exception à traiter
			 NSFileHandleOperationException
			 */
		}
	}
	@catch (NSException *exception)
	{
		retour=ER_TASKCANTBELAUNCHED;
		DEBUGNSLOG(@"Error, the task can't be launched (%@ : %@)", [exception name], [exception reason]);
		
		/* Exception à traiter
		 NSInvalidArgumentException
		 */
	}
	
	if([tache isRunning])
		[tache interrupt];
	
	[tube release];
	[tache release];
	
	[notif release];
	[env release];
	[args release];
	[commande release];
	
	return retour;
}


-(int)synchronisation:(PD_Cle *)uneCle notification:(NSNotification *)maNotif
{
 int retour;

	[uneCle retain];
	[maNotif retain];

	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	[logueur loguerMessage:[NSString stringWithFormat:NSLocalizedString(@"SYNCHROSTART:",nil), [uneCle idCle]]];
	
	NSString *repertoireSource =      [[NSString alloc] initWithFormat:@"%@/",[uneCle pointDeMontage]];
	NSString *repertoireDestination = [[NSString alloc] initWithFormat:@"%@/%@/",[[uneCle infosCle] objectForKey:D_BACKDIR],[uneCle idCle]];
	NSString *repertoireBackup =      [[NSString alloc] initWithFormat:@"%@/sync/%@",repertoireDestination,@"old"];
	NSString *repertoireDestCle =     [[NSString alloc] initWithFormat:@"%@/sync/%@",repertoireDestination,@"key"];
	NSString *repertoireUnison =	  [[NSString alloc] initWithFormat:@"%@/sync/%@",repertoireDestination,@".syncdb"];
	
	NSString *commande = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"unison"];
	NSArray *arguments = [[NSArray alloc] initWithObjects: 
						  repertoireSource,
						  repertoireDestCle,
						  @"-batch",
						  @"-backup",
						  @"Name *",
						  @"-maxbackups",@"3",
						  @"-backupdir",repertoireBackup,
						  @"-fat",
						  nil];   
	NSDictionary *env = [[NSDictionary alloc] initWithObjectsAndKeys:repertoireUnison,@"UNISON",NSHomeDirectory(),@"HOME",nil];

	retour=ER_CREATEDESTDIR;
	if(!testExistAndCreateIfNot(repertoireDestination))
		goto Sortie;
	if(!testExistAndCreateIfNot(repertoireBackup))
		goto Sortie;
	if(!testExistAndCreateIfNot(repertoireDestCle))
		goto Sortie;

	complementDInfo=[[NSString alloc] initWithString:@"Synchronisation in progress ..."];
	if(maNotif) [self envoyerNotification:maNotif];

	retour=[self tacheAvecComnande:commande
						 arguments:arguments
					 environnement:env
					  notification:maNotif
					   etAnalyseur:@selector(anaUnison:etNotif:)];
	[complementDInfo release];
	
Sortie:
	[repertoireDestination release];
	[repertoireSource release];
	[repertoireBackup release];
	[repertoireDestCle release];
	[repertoireUnison release];
	
	[arguments release];
	[env release];
	[maNotif release];
	[uneCle release];
	
	[pool release];
	
	return retour;
}


-(int)sauvegardeFull:(PD_Cle *)uneCle notification:(NSNotification *)maNotif
{
 int retour;
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	[uneCle retain];
	[maNotif retain];
	
	[logueur loguerMessage:[NSString stringWithFormat:NSLocalizedString(@"FULLSTART:",nil), [uneCle idCle]]];
	
	NSString *repertoireSource =      [[NSString alloc] initWithFormat:@"%@/",[uneCle pointDeMontage]];
	NSString *repertoireDestination = [[NSString alloc] initWithFormat:@"%@/%@/full/",[[uneCle infosCle] objectForKey:D_BACKDIR],[uneCle idCle]];
	NSString *repertoireINPROGRESS =  [repertoireDestination stringByAppendingPathComponent:@".inprogress"];
	NSString *repertoireOLD =         [repertoireDestination stringByAppendingPathComponent:@"old"];
	NSString *repertoireFULL =        [repertoireDestination stringByAppendingPathComponent:@"last"];

	NSArray *arguments = [[NSArray alloc] initWithObjects: @"-av", @"--progress", repertoireSource, repertoireINPROGRESS, nil];   
	NSString *commande = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"rsync"];

	retour=ER_CREATEDESTDIR;
	if(!testExistAndCreateIfNot(repertoireDestination))
		goto Sortie;
	
	// Faire sauvegarde vers INPROGRESS
	retour=[self tacheAvecComnande:commande
						 arguments:arguments
					 environnement:nil
					  notification:maNotif
					   etAnalyseur:@selector(anaRysnc:etNotif:)];
	
	avancement = -1.0;
	if(maNotif) [self envoyerNotification:maNotif];

	if(retour==ER_TASKSTOPED)
		goto SortieDelINPROGRESS;
	
	// si fin OK Supprimer OLD
	if(!testExistAndRemoveIfTrue(repertoireOLD))
		retour=ER_DELOLD;

	// renomer FULL vers OLD
	if(!renameIfExist(repertoireFULL, repertoireOLD))
	{
		retour=ER_RENAMEFULL;
		goto SortieDelINPROGRESS;
	}

	// renomer INPROGRESS vers FULL
	if(!renameIfExist(repertoireINPROGRESS, repertoireFULL))
		retour=ER_RENAMEINPROGRESS;
	
SortieDelINPROGRESS:
	//   suppression de INPROGRESS s'il n'a pas ete renome
	if(!testExistAndRemoveIfTrue(repertoireINPROGRESS))
		retour=ER_DELINPROGRESS;
	
Sortie:
	[repertoireDestination release];
	[arguments release];
	[repertoireSource release];
	[maNotif release];
	[uneCle release];

	[logueur loguerMessage:[NSString stringWithFormat:NSLocalizedString(@"FULLCOMLETED:",nil), [uneCle idCle]]];

	[pool release];
	
	return retour;
}


-(int)sauvegardeIncrementale:(PD_Cle *)uneCle notification:(NSNotification *)maNotif
{
 int retour;
 NSDate *maintenant;
 NSError *uneErreur = nil;

	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	[uneCle retain];
	[maNotif retain];

	[logueur loguerMessage:[NSString stringWithFormat:NSLocalizedString(@"INCREMENTALSTART:",nil), [uneCle idCle]]];

	// Chemins et Parametres
	maintenant=[NSDate date];
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSMutableString *repertoireDestination = [[NSString alloc] initWithFormat:@"%@/%@/incr/",[[uneCle infosCle] objectForKey:D_BACKDIR],[uneCle idCle]];
	NSString *repertoireSource = [[NSString alloc] initWithFormat:@"%@/",[uneCle pointDeMontage]];
	NSString *repertoireSauvegarde = [repertoireDestination stringByAppendingPathComponent:[maintenant description]];	
	NSString *repertoireDerniereSauvegarde = [repertoireDestination stringByAppendingPathComponent:@"current"];

	NSString *optionLinkDest = [[NSString alloc] initWithFormat:@"--link-dest=%@",repertoireDerniereSauvegarde];

	NSString *commande = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"rsync"];
	NSArray *arguments = [[NSArray alloc] initWithObjects: @"-av",@"--progress",@"--delete",optionLinkDest,repertoireSource,repertoireSauvegarde,nil];   

	// préparation des repertoires
	if(!testExistAndCreateIfNot(repertoireDestination))
	{
		retour=ER_CREATEDESTDIR;
		goto SortieErreur;
	}

	// lancement du traitement
	retour=[self tacheAvecComnande:commande
						 arguments:arguments
					 environnement:nil
					  notification:maNotif
					   etAnalyseur:@selector(anaRysnc:etNotif:)];
	
	avancement = -1.0;
	if(maNotif) [self envoyerNotification:maNotif];

	if(retour==ER_TASKSTOPED)
	{
		if(!testExistAndRemoveIfTrue(repertoireSauvegarde))
			retour=ER_DELREPSAV;
	}
	
	// pas d'erreur, modification du lien symbolique
	if(retour==ER_NOERROR)
	{
		// - suppression du lien sur "current" s'il existe (removeItemAtPath:error:)
		if(!testExistAndRemoveIfTrue(repertoireDerniereSauvegarde))
			retour=ER_DELREPSAV;		

		if ([fileManager createSymbolicLinkAtPath:repertoireDerniereSauvegarde
							  withDestinationPath:[repertoireSauvegarde lastPathComponent]
							                error:&uneErreur]==NO)
		{
			DEBUGNSLOG(@"Unable to create link \"%@ -> %@\" (%@)",repertoireDerniereSauvegarde,repertoireSauvegarde,[uneErreur localizedDescription]);
			retour=ER_CREATESYMLINK;
		}
		else
		{
		 int nbFilesDeleted;
			
			nbFilesDeleted=[self menageApresIncrementale:repertoireDestination etNotif:maNotif];
			[logueur loguerMessage:[NSString stringWithFormat:NSLocalizedString(@"NBDIRECTORYDELETED::",nil), [uneCle idCle], nbFilesDeleted]];
		}
	}
	
	if(retour!=ER_NOERROR)
	{
		DEBUGNSLOG(@"Error during rsync task (%d)",retour);
		[logueur loguerMessage:[NSString stringWithFormat:NSLocalizedString(@"INCREMENTALERROR::",nil), [uneCle idCle], retour]];
	}
	
SortieErreur:
	[arguments release];
	[optionLinkDest release];

	[repertoireSource release];
	[repertoireDestination release];
	
	[maNotif release];
	[uneCle release];

	[logueur loguerMessage:[NSString stringWithFormat:NSLocalizedString(@"INCREMENTALCOMLETED:",nil), [uneCle idCle]]];

	[pool release];

	return retour;
}


-(void)executerTache:(id)unObjet
{
 PD_Moteur *moteur;
 CR_Notificateur *notif;
 NSNotification *maNotif=nil;
 BOOL retour;
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    [unObjet retain];

	CR_RessourceSpeciale *ressource=[[CR_RessourceSpeciale alloc] init];
	
    [logueur loguerMessage:[NSString stringWithFormat:NSLocalizedString(@"STARTBACKUP:",nil),[cle idCle]]];

    [cle setSauvegardeEnCours:YES];
	
	traitementEnCours=TRUE;
	traitementTerminer=FALSE;
	avancement=-1.0;
	[complementDInfo release];
	complementDInfo=@"Attente fin de traitement pour la même clé";

	
	notif=[[CR_Notificateur alloc] init];
	if(notifChangementTacheSauvegarde)
	{
		maNotif=[NSNotification notificationWithName:notifChangementTacheSauvegarde object:self];
		[maNotif retain];
	}
 	[notif envoyerNotification:notifDebutTacheSauvegarde];
	if(maNotif) [self envoyerNotification:maNotif];

	NSDate *loopUntil = [[NSDate alloc] initWithTimeIntervalSinceNow:0.25]; 
	while(![ressource testEtPrendre:[cle idCle]])
	{
		if(interrompreTache)
			break;
		else
		{
			[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:loopUntil];
		}
	}
	[loopUntil release];
	
	retour=0;
	switch ([[[cle infosCle] objectForKey:D_BACKUPTYPE] intValue])
	{
		case 1: // Notbackup
			[logueur loguerMessage:[NSString stringWithFormat:NSLocalizedString(@"NOTBACKUPED:",nil),[cle idCle]]];
			break;
			
		case 2: // full
			retour=[self sauvegardeFull:cle notification:maNotif];
			break;
			
		case 3: // Incrementale
			retour=[self sauvegardeIncrementale:cle notification:maNotif];
			break;
			
		case 4: // synchro
			retour=[self synchronisation:cle notification:maNotif];
			break;
			
		default: // ???
			break;
	}
	
	if(retour)
		[logueur loguerMessage:[NSString stringWithFormat:NSLocalizedString(@"ERRORDURINGBACKUP::",nil),[cle idCle],retour]];
	else
		[logueur loguerMessage:[NSString stringWithFormat:NSLocalizedString(@"BACKUPCOMPLETE:",nil),[cle idCle]]];
	
	traitementEnCours=FALSE;
	traitementTerminer=TRUE;
	avancement=-1.0;
	[cle setSauvegardeEnCours:NO];

	if(maNotif) [self envoyerNotification:maNotif];
	[notif envoyerNotification:notifFinTacheSauvegarde];

    [[cle infosCle] setObject:[NSDate date] forKey:D_DERNSAUV];
    
    if(aReplanifier)
    {
        if([[[cle infosCle] objectForKey:D_PLANNING] intValue] == 2)
		{
			moteur=[[unObjet infosComplementaires] pere];
			[moteur retain];
			
            if([[moteur enregistreur] CleEstEnregistree:cle])
                [[moteur planificateur] replanifier:cle];
			
			[moteur release];
		}
    }
	
	[ressource rendre:[cle idCle]];

	[ressource release];
	[notif release];
	[maNotif release];
    [unObjet release];
	[pool release];
}

@end
