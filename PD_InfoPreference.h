//
//  PD_InfoPreference.h
//  memoryKeyBackup
//
//  Created by Patrice Dietsch on 02/02/09.
//  Copyright 2009 Natixis. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PD_InfoPreference : NSObject
{
    NSString *valeur;
    NSNumber *complement;
    NSNumber *flag;
}

- (void)setValeur:(NSString *)uneValeur;
- (NSString *)valeur;

- (void)setComplement:(NSNumber *)unComplement;
- (NSNumber *)complement;

- (int)flag;
- (void)setFlag:(int)f;

- (NSMutableDictionary *)creerDictionnaire;
- (void)chargerDictionnaire:(NSDictionary *)unDictionnaire;

+ (id)valeur:(NSString *)uneValeur;
+ (id)valeur:(NSString *)uneValeur etComplement:(NSNumber *)unComplement;
+ (id)valeur:(NSString *)uneValeur etComplement:(NSNumber *)unComplement etFlag:(int)unFlag;
+ (id)valeur:(NSString *)uneValeur etFlag:(int)unFlag;

@end
