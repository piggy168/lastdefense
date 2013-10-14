//
//  GobHvM_Bot.h
//  HeavyMach2
//
//  Created by 엔비 on 09. 09. 17.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "GobHvMach.h"

@class GobFieldItem;

@interface GobHvM_Bot : GobHvMach
{
	int _slotIdx;
	float _speedDest;
	float _rotateDest;
	float _createTime;
	float _liveTime;
	
	float _stopDelay;
	
	float _lastAttackTime;
	float _attackDelay;
	
	float _jobCheckTime;
	float _hpRefreshTime;

	QobImage *_imgHpGauge;
	GobFieldItem *_pickItem;
}

@property(readwrite) int slotIdx;

- (void)process_Etc;

- (void)processAI_AirCraft;

- (void)processAI_JobAttack;
- (void)processAI_JobDefence;
- (void)processAI_JobPickItem;
- (void)processAI_JobRepair;

- (void)pickItem:(GobFieldItem *)item;
- (void)refreshHPGauge;

@end
