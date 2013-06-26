#import <Cocoa/Cocoa.h>


#define EST_VIDE 0
#define NON_VIDE 1

@interface CR_File : NSObject
{
	NSMutableArray *laFile;
	NSConditionLock *verrou;
}

- (void)inWithLock:(id)element;
- (id)outWithLockAndTimeOut:(NSInteger)timeOut;
- (id)outWithLock;

- (NSConditionLock *)verrou;

- (int)nbElem;
- (id)elemALaPosition:(int)unePosition;
-(void)supprimerElemALaPosition:(int)unePosition;

@end