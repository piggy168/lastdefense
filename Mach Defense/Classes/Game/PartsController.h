//
//  PartsController.h
//  HeavyMach2
//
//  Created by 엔비 on 09. 07. 31.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "GobHvMach.h"
#import "GobMachParts.h"

@interface PartsController : QobBase
{
	float _startTime;
	GobHvMach *_hvMach;
	GobMachParts *_baseParts;
}

- (id)initWithMach:(GobHvMach *)mach Parts:(GobMachParts *)parts;

@end
