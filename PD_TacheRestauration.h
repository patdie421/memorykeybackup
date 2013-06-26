//
//  PD_TacheRestauration.h
//  memoryKeyBackup
//
//  Created by Patrice Dietsch on 02/03/11.
//  Copyright 2011 -. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "CR_Tache.h"
#import "CI_ProgressionRestauration.h"


@interface PD_TacheRestauration : CR_Tache
{
	NSString *complementDInfo;
}

@property(readwrite, retain) NSString *complementDInfo;

-(void)stopTache:(id)sender;

@end
