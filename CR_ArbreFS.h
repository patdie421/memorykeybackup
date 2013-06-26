#import <Cocoa/Cocoa.h>

#import "CR_NoeudFS.h"


@interface CR_ArbreFS : NSObject
{
	CR_NoeudFS *racine;
	NSString *base;
}

@property(readwrite, retain) NSString *base;

- (BOOL)creerRacine:(NSString *)chemin;
- (CR_NoeudFS *)racine;
- (void)setFirstItemType:(int)type;
- (void)vider;

@end
