//
//  GobEnemySpawner.m
//  HeavyMach2
//
//  Created by 엔비 on 09. 12. 11.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "GobEnemySpawner.h"
#import "GobHvM_Player.h"
#import "GobHvM_Enemy.h"

@implementation GobEnemySpawner

- (id)initWithSpawnInfo:(TSpawnInfo *)info
{
	[super init];

	memcpy(&_spawnInfo, info, sizeof(TSpawnInfo));
	if(_spawnInfo.startTime == -1) _spawnInfo.regenCount = info->regenCount / 2.f + RANDOMF(info->regenCount / 2.f) + .5f;
	else _spawnInfo.regenCount = info->regenCount;
	if(_spawnInfo.regenCount < 1) _spawnInfo.regenCount = 1;
	_regenCount = 0;
	_checkTime = -1.f;
	_spawnTime = GWORLD.time + _spawnInfo.startTime;
	
	return self;
}

- (void)dealloc
{
	[super dealloc];
}

- (void)tick
{
	if(GWORLD.time > _spawnTime && GWORLD.state == GSTATE_PLAY)
	{
		_checkTime = GWORLD.time;
		GobHvM_Enemy *enemy = [GWORLD addEnemyMach:_spawnInfo.machName X:RANDOMFC(220.f * GWORLD.deviceScale) Y:GWORLD.mapHalfLen + 32 * GWORLD.deviceScale];
		enemy.spawner = self;
		_regenCount++;
		_spawnTime = GWORLD.time + _spawnInfo.regenDelay / 2.f + RANDOMF((_spawnInfo.regenDelay / 2.f));

		if(_regenCount >= _spawnInfo.regenCount) [self remove];
	}
	
	[super tick];
}

@end
