//
//  CI_ProgressionRestauration.h
//  memoryKeyBackup
//
//  Created by Patrice Dietsch on 02/03/11.
//  Copyright 2011 -. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "general.h"


@interface CI_ProgressionRestauration : NSObject
{
	IBOutlet id fenetre;
	IBOutlet id info;
	IBOutlet id progress;
	
	id tache;
	unsigned char flag;
}

@property(readonly) id progress;
@property(readwrite, retain) id tache;

-(IBAction)bouton_annuler:(id)sender;
-(BOOL)modal:(id)mere;

-(void)finTache;

@end
