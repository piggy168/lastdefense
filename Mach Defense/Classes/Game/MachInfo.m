//
//  MachInfo.m
//  HeavyMach2
//
//  Created by 엔비 on 09. 08. 28.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "MachInfo.h"


@implementation MachInfo
@synthesize data=_data, type=_type, refType=_refType, speed=_speed, hp=_hp, exp=_exp, radius=_radius, level=_level, coinGenRate=_coinGenRate, coinGen=_coinGen, itemGen=_itemGen;

- (void)dealloc
{
	[_itemGen release];
	[super dealloc];
}

@end
