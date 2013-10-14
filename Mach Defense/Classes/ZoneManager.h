//
//  ZoneManager.h
//  MachDefense
//
//  Created by HaeJun Byun on 10. 12. 1..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

@class GobHvMach;

@interface ZoneManager : NSObject
{
	NSMutableArray *_listPlayer, *_listEnemy;
	CGPoint _coverageTopLeft, _coverageBtmRight;
}

- (id)initWithZoneIndex:(int)index;

- (void)addPlayer:(GobHvMach *)mach;
- (void)removePlayer:(GobHvMach *)mach;
- (NSArray *)playerList;

- (void)addEnemy:(GobHvMach *)mach;
- (void)removeEnemy:(GobHvMach *)mach;
- (NSArray *)enemyList;

@end
