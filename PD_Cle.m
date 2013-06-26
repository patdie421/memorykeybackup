#import <Cocoa/Cocoa.h>

#import "general.h"

#import "PD_cle.h"
#import "adresseMac.h"

#include <sys/param.h>
#include <sys/mount.h>

@implementation PD_Cle

@synthesize idCle, pointDeMontage, infosCle, sauvegardeEnCours;

-(id)init
{
    if(self=[super init])
    {
        sauvegardeEnCours=NO;
    }
    return self;
}


-(void)dealloc
{
    @synchronized(self)
    {
        [idCle release];
        [pointDeMontage release];
        [infosCle release];
    }
    [super dealloc];
}


-(BOOL)chargerDepuisDB:(DB_Cles *)laDB
{
 NSMutableDictionary *unElem;
    
    @synchronized(self)
    {
        [[laDB retain] autorelease];
        
        unElem=[laDB cleParIndexIdCle:idCle];
        if(unElem)
        {
            [self setInfosCle:unElem];
            return YES;
        }
    }
    return NO;
}


-(BOOL)enregistrerDansDB:(DB_Cles *)laDB
{
 BOOL retour;

    @synchronized(self)
    {
        [[laDB retain] autorelease];
        
        if(idCle)
        {
            retour=[laDB ajouterEnregistrement:idCle enregistrement:infosCle];

            [laDB trier];
            
            return retour;
        }
    }
    return NO;
}


-(void)setDonneeInfoCle:(id)uneDonnee pourPropriete:(id)unePropriete
{
    @synchronized(self)
    {
        [uneDonnee retain];
        [unePropriete retain];
        
        if(!infosCle)
            infosCle=[[NSMutableDictionary alloc] init];
        
        [infosCle setObject:uneDonnee forKey:unePropriete];
        
        [unePropriete release];
        [uneDonnee release];
    }
}


-(BOOL)estEligibleALaSauvegarde:(double)tailleMaxCle conditionDeDetection:(NSArray *)condition
{
 BOOL removableFlag;
 BOOL writableFlag;
 BOOL unmountableFlag;
 BOOL isMountPoint;
 NSString *description;
 NSString *fileSystemType;
    
    [[condition retain] autorelease];
    
    isMountPoint = [ [NSWorkspace sharedWorkspace]
                         getFileSystemInfoForPath: pointDeMontage
                         isRemovable:              &removableFlag 
                         isWritable:               &writableFlag 
                         isUnmountable:            &unmountableFlag 
                         description:              &description 
                         type:                     &fileSystemType];
    

    if(isMountPoint && writableFlag && removableFlag && unmountableFlag)
    {
     NSEnumerator *e; 
     id obj;
     BOOL trouveFS=NO;
     BOOL trouveNODMCI=NO;
     BOOL trouveNOTKEY=NO;
    
        //
        // récupération des conditions pour être une clé
        //
        e = [condition objectEnumerator]; 
        while ( (obj = [e nextObject]) )
        {
            if([obj isEqual:fileSystemType])
                trouveFS=YES;
            if([obj isEqual:D_NODMCI])
                trouveNODMCI=YES;
            if([obj isEqual:D_NOTKEY])
                trouveNOTKEY=YES;
        }
        
        //
        // le type de fs n'a pas été trouvé
        //
        if(!trouveFS)
            return NO;

        //
        // recherche de DMCI
        //
        BOOL isDir;
        if(trouveNODMCI)
        {
         NSString *repertoire;

            repertoire=[pointDeMontage stringByAppendingPathComponent:@"DMCI"];
            
            if ([[NSFileManager defaultManager] fileExistsAtPath:repertoire isDirectory:&isDir] && isDir)
            {
                return NO;
            }
        }

        //
        // recherche de NOTKEY
        //
        if(trouveNOTKEY)
        {
         NSString *fichier;
            
            fichier=[pointDeMontage stringByAppendingPathComponent:@".notkey"];
            
            if ([[NSFileManager defaultManager] fileExistsAtPath:fichier isDirectory:&isDir] && !isDir)
            {
                return NO;
            }
        }
        
        //
        // Vérification de la taille
        //
        struct statfs buffer;

        if (statfs([pointDeMontage fileSystemRepresentation], &buffer) == 0)
        {
            // float z=8192;
            float z=tailleMaxCle;
            
            if( ((float)buffer.f_blocks * (float)buffer.f_bsize / 1024.0) > (z*1024.0) )
                return NO;
        }
        else
            return NO;
    }
    else
        return NO;
    
    return YES;
}


-(BOOL)chargerDepuisTagCle:(NSString *)cheminCle adresseMac:(NSString *)adresseMac nomUtilisateur:(NSString *)nomUtilisateur
{
 NSString *tagCle_idCle;
 NSMutableDictionary *D_tagCle_machines;
 NSMutableDictionary *D_tagCle_utilisateurs;
    
    @synchronized(self)
    {
        [cheminCle retain];
        [adresseMac retain];
        [nomUtilisateur retain];
        
        [self setIdCle:nil];
        
        D_tagCle_machines = [[NSDictionary alloc] initWithContentsOfFile:[cheminCle stringByAppendingPathComponent:D_FICHIERTAG]];
        if (nil != D_tagCle_machines)
        {
            D_tagCle_utilisateurs=[D_tagCle_machines objectForKey:adresseMac];
            if(D_tagCle_utilisateurs != nil)
            {
                tagCle_idCle=[D_tagCle_utilisateurs objectForKey:nomUtilisateur];
                if(tagCle_idCle!=nil)
                {
                    [self setIdCle:tagCle_idCle];
                }
            }
            [D_tagCle_machines release];
        }
        
        [cheminCle release];
        [adresseMac release];
        [nomUtilisateur release];
    }
    return YES;
}


-(BOOL)chargerDepuisTagCle
{
 BOOL retour;
 NSString *uneAdresse;
 unsigned char addr[6];
        
    retour=adresseMac(addr);
    if(!retour)
        uneAdresse=[[NSString alloc] initWithFormat:@"%x:%x:%x:%x:%x:%x",addr[0],addr[1],addr[2],addr[3],addr[4],addr[5]];
    else
    {
        DEBUGNSLOG(@"Can't retrieve MAC adress of this computer");
        return NO;
    }
    
	retour=[self chargerDepuisTagCle:pointDeMontage adresseMac:uneAdresse nomUtilisateur:NSFullUserName()];
	
    [uneAdresse release];
    
    return retour;    
}


-(void)creerTagCle:(NSString *)cheminCle adresseMac:(NSString *)adresseMac nomUtilisateur:(NSString *)nomUtilisateur
{
 NSMutableDictionary *D_tagCle_machines;
 NSMutableDictionary *D_tagCle_utilisateurs;
    
    D_tagCle_utilisateurs=[[NSMutableDictionary alloc] init];
    [D_tagCle_utilisateurs setObject:idCle forKey:nomUtilisateur];
    
     D_tagCle_machines=[[NSMutableDictionary alloc] init];
    [D_tagCle_machines setObject:D_tagCle_utilisateurs forKey:adresseMac];
    
    [D_tagCle_machines writeToFile:[cheminCle stringByAppendingPathComponent:D_FICHIERTAG] atomically:YES];
    
    [D_tagCle_machines release];
    [D_tagCle_utilisateurs release];
}


-(BOOL)enregistrerDansTagCle:(NSString *)cheminCle adresseMac:(NSString *)adresseMac nomUtilisateur:(NSString *)nomUtilisateur
{
 NSMutableDictionary *D_tagCle_machines;
 NSMutableDictionary *D_tagCle_utilisateurs;

    @synchronized(self)
    {
        D_tagCle_machines = [[NSMutableDictionary alloc] initWithContentsOfFile:[cheminCle stringByAppendingPathComponent:D_FICHIERTAG]]; 
        if (nil == D_tagCle_machines)
        {
            [self creerTagCle:cheminCle adresseMac:adresseMac nomUtilisateur:nomUtilisateur];
        }
        else
        {
            D_tagCle_utilisateurs=[D_tagCle_machines objectForKey:adresseMac];
            if(D_tagCle_utilisateurs == nil)
            {
                D_tagCle_utilisateurs=[[NSMutableDictionary alloc] init];
                [D_tagCle_machines setObject:D_tagCle_utilisateurs forKey:adresseMac];
            }
            else
            {
                [D_tagCle_utilisateurs retain];
            }
            [D_tagCle_utilisateurs setObject:idCle forKey:nomUtilisateur];            
            
            [D_tagCle_machines writeToFile:[cheminCle stringByAppendingPathComponent:D_FICHIERTAG] atomically:YES];
            
            [D_tagCle_machines release];
            [D_tagCle_utilisateurs release];
        }
    }
    return YES;
}


-(BOOL)enregistrerDansTagCle
{
 BOOL retour;
 NSString *uneAdresse;
 unsigned char addr[6];
    
    retour=adresseMac(addr);
    if(!retour)
        uneAdresse=[[NSString alloc] initWithFormat:@"%x:%x:%x:%x:%x:%x",addr[0],addr[1],addr[2],addr[3],addr[4],addr[5]];
    else
	{
        DEBUGNSLOG(@"Can't retrieve MAC adress of this computer");
		return NO;
	}
    
    retour=[self enregistrerDansTagCle:pointDeMontage adresseMac:uneAdresse nomUtilisateur:NSFullUserName()];
    
    [uneAdresse release];
    
    return retour;
}


-(void)genererIdCle
{
 int i;
 unsigned char c[6];
    
    srandomdev();
    for(i=0;i<6;i++)
        c[i]=random() & 0x000F;

    [self setIdCle:[[NSString alloc] initWithFormat:@"U%X%X%X%X%X%X",c[0],c[1],c[2],c[3],c[4],c[5]]];
}

@end
