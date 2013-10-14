//
//  GobHvM_Enemy.m
//  HeavyMach
//
//  Created by 엔비 on 08. 12. 10.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "QobParticle.h"
#import "GobHvM_Enemy.h"
#import "GobHvM_Player.h"
#import "GobHvM_Bot.h"
#import "GobBullet.h"
#import "GuiGame.h"
#import "GobFieldItem.h"
#import "GobEnemySpawner.h"


@implementation GobHvM_Enemy

@synthesize liveTime=_liveTime, spawner=_spawner;

- (id)init
{
	[super init];

	_enemy = true;
	_isBase = false;
	_isFirstAtk = RANDOM(15) == 0;
	_machType = MACHTYPE_TANK;
	_createTime = GWORLD.time;
	_liveTime = 12.f;
	_moveSpeed = .3f;
	_rotSpeed = 30.f;
	
	_stopDelay = _createTime + RANDOMF(1.f) + .5f;
	
	_imgHpGauge = nil;
	_lastAttackTime = 0.f;
	_attackDelay = 1.f;
	
	return self;
}

- (void)tick
{
	if(!GWORLD.pause && _hp > 0 && !(_spStatusFlag & SPSTATUS_STUN))
	{
		[self processAI_Attack];

		switch(_machType)
		{
		case MACHTYPE_TANK:		[self processAI_Vehicle];	break;
//		case MACHTYPE_TURRET:	[self processAI_Turret];	break;
		case MACHTYPE_AIRCRAFT:	[self processAI_AirCraft];	break;
		case MACHTYPE_TRAIN:	[self processAI_Train];		break;
		}
	}
	
	[super tick];
}

/*- (void)processAI_AirCraft
{
	if(GWORLD.time > _createTime + _liveTime)
	{
		_speedDest = RANDOMF(.4f) + .4f;
	}
	else if(RANDOM(60) == 0)
	{
		if(MYMACH.pos.x > _pos.x) _speedDest = RANDOMF(.8f) + 2.f;
		else if(MYMACH.pos.x > _pos.x - 300.f) _speedDest = RANDOMF(.8f) + 1.8f;
		else if(MYMACH.pos.x < _pos.x - 400.f) _speedDest = RANDOMF(.4f) + .4f;
		else _speedDest = RANDOMF(.5f) + .8f;
	}
	
	if(RANDOM(60) == 0)
	{
		if(MYMACH.pos.x > _pos.x)
		{
			_rotateDest = RANDOMF(.5f) - .25f;
		}
		else
		{
			_rotateDest += RANDOMF(.5f) - .25f;
			if(_rotateDest < -.5f) _rotateDest = -.5f;
			else if(_rotateDest > .5f) _rotateDest = .5f;
		}
	}
	
	EASYOUT(_speed, _speedDest, 50.f);
	EASYOUT(_rotate, _rotateDest, 50.f);
}*/

- (void)processAI_Vehicle
{
	if(GWORLD.time > _stopDelay && (_target == nil || _moveToTarget == false))
	{
		float destX = _pos.x + RANDOMFC(16.f);
		float destY = _pos.y - 160.f * GWORLD.deviceScale;
		if(destX < -110 * GWORLD.deviceScale) destX = -110 * GWORLD.deviceScale;
		else if(destX > 110 * GWORLD.deviceScale) destX = 110 * GWORLD.deviceScale;
		if(destY < -GVAL.moveLimit + _targetRange * .8f)
		{
			destY = -GVAL.moveLimit + _targetRange * .8f;
			_stopDelay = GWORLD.time + 100000;
		}
		else
		{
			_stopDelay = GWORLD.time + RANDOMF(2.f) + 1.f;
		}

		[self setDestPosX:destX Y:destY];
	}
}

- (void)processAI_Turret
{
}

- (void)processAI_AirCraft
{
	if(GWORLD.time > _stopDelay || _machState == MACHSTATE_STOP)
	{
		_stopDelay = GWORLD.time + RANDOMF(5.f) + 5.f;
		[self setDestPosX:RANDOMFC(600.f) Y:RANDOMFC(600.f)];
	}
}

- (void)processAI_Train
{
	if(GWORLD.time > _stopDelay)
	{
		_stopDelay = GWORLD.time + RANDOMF(3.f) + 2.f;
		[self setDestPosX:_pos.x Y:RANDOMFC(300.f) + 256];
	}
}

- (void)processAI_Attack
{
	if(_target == nil && GWORLD.time > _attackCheckTime)
	{
		float len, nearLen = _targetRange * _targetRange;
		GobHvM_Player *player = nil;
		
		for(int i = 0; i < [GWORLD.listPlayer childCount]; i++)
		{
			player = (GobHvM_Player *)[GWORLD.listPlayer childAtIndex:i];
			if(player != nil && player.hp > 0)
			{
				len = (_pos.x - player.pos.x) * (_pos.x - player.pos.x) + (_pos.y - player.pos.y) * (_pos.y - player.pos.y);
				if(len < nearLen)
				{
					nearLen = len;
					_target = player;
					if(player.pos.y > -GVAL.moveLimit - _targetRange * .8f) _moveToTarget = true;
					else _moveToTarget = false;
				}
			}
		}
		
		_attackCheckTime = GWORLD.time + 1.f;
	}
	/*	if(_target == nil && (_isFirstAtk || _info.attack) && GWORLD.time > _attackCheckTime + .5f)
	{
		float len = (_pos.x - MYMACH.pos.x) * (_pos.x - MYMACH.pos.x) + (_pos.y - MYMACH.pos.y) * (_pos.y - MYMACH.pos.y);
		if(len < 40000.f) _target = MYMACH;
	}*/
}

- (void)checkObjectCollide
{
	[super checkObjectCollide];

	if(_machType == MACHTYPE_AIRCRAFT || _isBase) return;
	
	bool chkEnd = false;
	GobHvM_Enemy *enemy;
	for(int i = 0; !chkEnd && i < [GWORLD.listEnemy childCount]; i++)
	{
		enemy = (GobHvM_Enemy *)[GWORLD.listEnemy childAtIndex:i];
		if(enemy == nil || enemy.machType == MACHTYPE_AIRCRAFT || enemy.isBase || enemy.hp <= 0) continue;
		
		if(enemy == self) chkEnd = true;
		else [self onCollideObject:enemy];
	}
}

- (void)onDamage:(int)dmg From:(GobHvMach *)from
{
//	float gaugeScale = _hp / (float)_info.hp;
	[super onDamage:dmg From:from];
//	[self setTarget:MYMACH];
}

- (void)onCrash
{
	[super onCrash];

	int coinGenRate = _info.coinGenRate;
	if(RANDOM(100) < coinGenRate)
	{
		NSString *coinID;
		int coin = (int)((_info.coinGen + RANDOMF((_info.coinGen / 3.f))));
		if(coin >= 2000) coinID = @"00105";
		else if(coin >= 1000) coinID = @"00104";
		else if(coin >= 500) coinID = @"00103";
		else if(coin >= 50) coinID = @"00102";
		else coinID = @"00101";
		GobFieldItem *item = [[GobFieldItem alloc] initWithItem:[GINFO getItemInfo:coinID]];
		[item setPosX:_pos.x Y:_pos.y];
		[item setValue:coin];
		[GWORLD.listItem addChild:item];
		[item setLayer:VLAYER_BG];

		if(RANDOM(2) == 0)
		{
			coin = (int)((_info.coinGen + RANDOMF((_info.coinGen / 3.f))) * GVAL.crGen);
			if(coin >= 2000) coinID = @"00005";
			else if(coin >= 1000) coinID = @"00004";
			else if(coin >= 500) coinID = @"00003";
			else if(coin >= 50) coinID = @"00002";
			else coinID = @"00001";
			
			item = [[GobFieldItem alloc] initWithItem:[GINFO getItemInfo:coinID]];
			[item setPosX:_pos.x Y:_pos.y];
			[item setValue:coin];
			[GWORLD.listItem addChild:item];
			[item setLayer:VLAYER_BG];
		}
	}
	
	for(int i = 0; i < _partsList.size; i++)
	{
		GobMachParts *parts = (GobMachParts *)[_partsList getData:i];
		if(parts != nil)
		{
			if(i == 0) [parts setLayer:VLAYER_BACK];
			else [parts remove];
		}
	}
	
	[GWORLD killEnemy:self];
	
	_crashTime = GWORLD.time + 3.f + RANDOMF(2.f);
	GSLOT->score += _info.coinGen;
//	if(!_isBoss) [self onDestroy];
}

@end
