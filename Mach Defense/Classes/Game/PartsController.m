//
//  PartsController.m
//  HeavyMach2
//
//  Created by 엔비 on 09. 07. 31.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PartsController.h"

@implementation PartsController

- (id)initWithMach:(GobHvMach *)mach Parts:(GobMachParts *)parts
{
	[super init];

	_startTime = GWORLD.time;
	_hvMach = mach;
	_baseParts = parts;
	
	return self;
}

@end
