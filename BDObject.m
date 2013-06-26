//
//  BDObject.m
//  ProgressInNSTableView
//
//  Created by Brian Dunagan on 12/6/08.
//  Copyright 2008 bdunagan.com. All rights reserved.
//

#import "BDObject.h"

@implementation BDObject

@synthesize currentStep;
@synthesize discreteProgress;

- (id) init
{
	self = [super init];
	if (self != nil)
	{
		// Set up counter.
		currentStep = 0;
		[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(incrementStep) userInfo:nil repeats:YES];

		// Set up discrete progress.
		discreteProgress = [[NSProgressIndicator alloc] init];
		[discreteProgress setStyle:NSProgressIndicatorBarStyle];
		[discreteProgress setIndeterminate:NO];
		[discreteProgress setControlSize:NSSmallControlSize];
		[discreteProgress setMinValue:0];
		[discreteProgress setMaxValue:10];
		[discreteProgress startAnimation:nil];
		[discreteProgress setHidden:NO];
	}
	return self;
}

- (void)dealloc
{
	[discreteProgress removeFromSuperview];
	
	[discreteProgress release];
	[super dealloc];
}

- (void)incrementStep
{
	currentStep += 1;
	if (currentStep > 10)
		currentStep = 0;
	
	[discreteProgress setDoubleValue:currentStep];
}

@end
