#import <Cocoa/Cocoa.h>

#import "fileutils.h"
#import "general.h"


BOOL testExistAndCreateIfNot(NSString *rep)
{
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSError *uneErreur;
	
	if(![fileManager fileExistsAtPath:rep isDirectory:NULL]) // création du répertoire (et du chemin) s'il n'existe pas.
	{
		if(![fileManager createDirectoryAtPath:rep
				   withIntermediateDirectories:YES
									attributes:nil
										 error:&uneErreur])
		{
			DEBUGNSLOG(@"Error, can't create directory %@ (%@)",rep,[uneErreur localizedDescription]);
			return NO;
		}
	}
	return YES;
}


BOOL testExistAndRemoveIfTrue(NSString *rep)
{
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSError *uneErreur;
	
	if([fileManager fileExistsAtPath:rep isDirectory:NULL])
	{
		if([fileManager removeItemAtPath:rep error:&uneErreur]==NO)
		{
			DEBUGNSLOG(@"Error, unable to delete \"%@\" (%@)", rep, [uneErreur localizedDescription]);
			return NO;
		}
	}
	return YES;
}


BOOL renameIfExist(NSString *source, NSString *dest)
{
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSError *uneErreur;
	
	if([fileManager fileExistsAtPath:source isDirectory:NULL])
	{
		if([fileManager moveItemAtPath:source toPath:dest error:&uneErreur]==NO)
		{
			DEBUGNSLOG(@"Error, unable to rename \"%@\" to \"%@\" (%@)", source, dest, [uneErreur localizedDescription]);
			return NO;
		}
	}
	return YES;
}


BOOL exitAndNotEmpty(NSString *chemin)
{
	NSFileManager *fileManager = [NSFileManager defaultManager];
	BOOL flag;
	int retour;
	
	retour=[fileManager fileExistsAtPath:chemin isDirectory:&flag];
	
	if(retour && flag)
	{
		NSArray *rep=[fileManager contentsOfDirectoryAtPath:chemin error:NULL];
		if(rep && [rep count])
		{
			return YES;
		}
	}
	return NO;
}

