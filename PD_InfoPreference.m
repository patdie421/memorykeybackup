//
//  PD_InfoPreference.m
//  memoryKeyBackup
//
//  Created by Patrice Dietsch on 02/02/09.
//  Copyright 2009 Natixis. All rights reserved.
//

#import "PD_InfoPreference.h"


@implementation PD_InfoPreference


-(id)init
{
    if(self=[super init])
    {
    }
    return self;
}


- (id)initValeur:(NSString *)uneValeur etComplement:(NSNumber *)unComplement
{
    self=[self init];
    
    [self setValeur:uneValeur];
    [self setComplement:unComplement];
    
    return self;
}


+ (id)valeur:(NSString *)uneValeur etComplement:(NSNumber *)unComplement
{
    PD_InfoPreference *info;
    
    info=[[PD_InfoPreference alloc] initValeur:uneValeur etComplement:unComplement];
    [info autorelease];
    
    return info;
}


+ (id)valeur:(NSString *)uneValeur etComplement:(NSNumber *)unComplement etFlag:(int)unFlag;
{
    PD_InfoPreference *info;
    
    info=[[PD_InfoPreference alloc] initValeur:uneValeur etComplement:unComplement];
    [info setFlag:unFlag];
    [info autorelease];
    
    return info;
}


+ (id)valeur:(NSString *)uneValeur etFlag:(int)unFlag
{
    PD_InfoPreference *info;
    
    info=[[PD_InfoPreference alloc] initValeur:uneValeur etComplement:[NSNumber numberWithInt:-1]];
    [info setFlag:unFlag];
    [info autorelease];
    
    return info;
}


+ (id)valeur:(NSString *)uneValeur
{
    PD_InfoPreference *info;
    
    info=[[PD_InfoPreference alloc] initValeur:uneValeur etComplement:[NSNumber numberWithInt:-1]];
    [info autorelease];
    
    return info;
}


- (void)dealloc
{
    [valeur release];
    [complement release];
    
    [super dealloc];
}

- (void)setValeur:(NSString *)uneValeur
{
    [uneValeur retain];
    [valeur release];
    valeur=uneValeur;
}


- (NSString *)valeur
{
    return valeur;
}


- (void)setComplement:(NSNumber *)unComplement
{
    [unComplement retain];
    [complement release];
    complement=unComplement;
}


- (NSNumber *)complement
{
    return complement;
}


- (NSMutableDictionary *)creerDictionnaire
{
 NSMutableDictionary *dico;
    
    dico=[[NSMutableDictionary alloc] init];
    [dico setObject:valeur forKey:@"valeur"];
    [dico setObject:complement forKey:@"complement"];
    [dico setObject:flag forKey:@"flag"];

    [dico autorelease];
    return dico;
}


- (void)chargerDictionnaire:(NSDictionary *)unDictionnaire;
{
    [self setValeur:[unDictionnaire objectForKey:@"valeur"]];
    [self setComplement:[unDictionnaire objectForKey:@"complement"]];
    [self setFlag:[[unDictionnaire objectForKey:@"flag"] intValue]];
}


- (void)setFlag:(int)f
{
 NSNumber *n;
    
    n=[NSNumber numberWithInt:f];
    [n retain];
    [flag release];
    flag=n;
}


- (int)flag
{
    return [flag intValue];
}


- (void)print
{
    NSLog(@"## %@ %@",valeur,complement);
}

@end
