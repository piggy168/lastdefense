//
//  GobEnemySpawner.h
//  HeavyMach2
//
//  Created by 엔비 on 09. 12. 11.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

struct TSpawnInfo
{
	float startTime;
	int rate;
	char machName[16];
	int regenCount;
	float regenDelay;
};
typedef struct TSpawnInfo TSpawnInfo;

@interface GobEnemySpawner : QobBase
{
	TSpawnInfo _spawnInfo;
	int _regenCount;
	float _spawnTime, _checkTime;
}

- (id)initWithSpawnInfo:(TSpawnInfo *)info;

@end
