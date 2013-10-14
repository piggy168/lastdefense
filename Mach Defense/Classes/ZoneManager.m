//
//  ZoneManager.m
//  MachDefense
//
//  Created by HaeJun Byun on 10. 12. 1..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ZoneManager.h"
#import "GobHvMach.h"

@implementation ZoneManager

- (id)initWithZoneIndex:(int)index
{
	[super init];
	
	_listPlayer = [[NSMutableArray alloc] init];
	_listEnemy = [[NSMutableArray alloc] init];

	_coverageTopLeft = CGPointMake(0, 0);
	_coverageBtmRight = CGPointMake(0, 0);
	
	return self;
}


- (void)addPlayer:(GobHvMach *)mach
{
	if([_listPlayer containsObject:mach]) return;
	[_listPlayer addObject:mach];
}

- (void)removePlayer:(GobHvMach *)mach
{
	[_listPlayer removeObject:mach];
}

- (NSArray *)playerList
{
	return _listPlayer;
}

- (void)addEnemy:(GobHvMach *)mach
{
	if([_listEnemy containsObject:mach]) return;
	[_listEnemy addObject:mach];
}

- (void)removeEnemy:(GobHvMach *)mach
{
	[_listEnemy removeObject:mach];
}

- (NSArray *)enemyList
{
	return _listEnemy;
}

@end
