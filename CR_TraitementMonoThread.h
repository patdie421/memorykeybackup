#import <Cocoa/Cocoa.h>

#import "CR_Consommateur.h"
#import "CR_File.h"

#import "CR_Tache.h"

@interface CR_TraitementMonoThread : CR_Consommateur
{
}

- (id)initWithNom:(NSString *)unNom;
- (BOOL)wait:(NSInteger)timeout;
- (void)ajouterTacheDansFileDEntree:(CR_Tache *)uneTache;

@end
