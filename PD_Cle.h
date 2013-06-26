#import <Cocoa/Cocoa.h>

#import "DB_Cles.h"


@interface PD_Cle : NSObject
{
    NSString *idCle;
    NSString *pointDeMontage;
    BOOL sauvegardeEnCours;
    NSMutableDictionary *infosCle;
}

@property(readwrite, retain) NSString *idCle;
@property(readwrite, retain) NSString *pointDeMontage;
@property(readwrite, retain) NSMutableDictionary *infosCle;
@property(readwrite) BOOL sauvegardeEnCours;

-(BOOL)chargerDepuisTagCle;
-(BOOL)enregistrerDansTagCle;

-(BOOL)chargerDepuisDB:(DB_Cles *)laDB;
-(BOOL)enregistrerDansDB:(DB_Cles *)laDB;

-(void)genererIdCle;
-(void)setDonneeInfoCle:(id)uneDonnee pourPropriete:(id)unePropriete;

-(BOOL)estEligibleALaSauvegarde:(double)tailleMaxCle conditionDeDetection:(NSArray *)contition;

@end
