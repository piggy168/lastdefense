//
//  GobHvM_Enemy.h
//  HeavyMach
//
//  Created by 엔비 on 08. 12. 10.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "GobHvMach.h"

@class GobEnemySpawner;

@interface GobHvM_Enemy : GobHvMach
{
	BOOL _isFirstAtk;
	float _createTime;
	float _liveTime;
	
	float _stopDelay;
	float _lastAttackTime;
	float _attackDelay;
	
	float _colCheckTime;
	
	QobImage *_imgHpGauge;
	GobEnemySpawner *_spawner;
}

@property(readwrite) float liveTime;
@property(readwrite, assign) GobEnemySpawner *spawner;

- (void)processAI_Vehicle;
- (void)processAI_Turret;
- (void)processAI_AirCraft;
- (void)processAI_Train;

- (void)processAI_Attack;


@end
