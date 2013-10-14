//
//  GobHvM_Bot.m
//  HeavyMach2
//
//  Created by 엔비 on 09. 09. 17.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "GobHvM_Bot.h"
#import "GobHvM_Player.h"
#import "GobHvM_Enemy.h"
#import "GobFieldItem.h"

@implementation GobHvM_Bot
@synthesize slotIdx=_slotIdx;

- (id)init
{
	[super init];
	
	_enemy = false;
	_machType = MACHTYPE_AIRCRAFT;
	_speedDest = 0.f;
	_rotateDest = 0.f;
	_createTime = GWORLD.time;
	_liveTime = 12.f;
	_moveSpeed = 2.f;
	_rotSpeed = 15.f;
	
	_stopDelay = _createTime + RANDOMF(1.f) + .5f;
	
	_lastAttackTime = 0.f;
	_attackDelay = 1.f;
	
	Tile2D *tile;
	tile = [TILEMGR getTile:@"HPGauge.png"];
	[tile tileSplitX:1 splitY:2];
	
	QobImage *img = [[QobImage alloc] initWithTile:tile tileNo:1];
	[img setScale:.5f];
	[img setPosX:0 Y:20];
	[img setUseAtlas:true];
	[self addChild:img];
	[img setLayer:VLAYER_FORE];
	
	_imgHpGauge = [[QobImage alloc] initWithTile:tile tileNo:0];
	[_imgHpGauge setUseAtlas:true];
	[_imgHpGauge setScale:.5f];
	[_imgHpGauge setPosX:-1 Y:1];
	[img addChild:_imgHpGauge];
	
	return self;
}

- (void)tick
{
	if(!GWORLD.pause)
	{
		[self processAI_AirCraft];
		
		switch(_info.refType)
		{
			case BOT_ATTACKER:		[self processAI_JobAttack];		break;
			case BOT_DEFENDER:		[self processAI_JobDefence];	break;
			case BOT_PICKER:		[self processAI_JobPickItem];	break;
			case BOT_REPAIR:		[self processAI_JobRepair];		break;
		}

		[self process_Etc];
	}
	
	[super tick];
}

- (void)process_Etc
{
	if(_hp > 0 && _hp < _info.hp && GWORLD.time > _hpRefreshTime + 5.f)
	{
		_hp++;
		_hpRefreshTime = GWORLD.time;
		[self refreshHPGauge];
	}
}

- (void)processAI_AirCraft
{
/*	if((_target == nil || _moveToTarget == false))
	{
		if(GWORLD.time > _stopDelay || _machState == MACHSTATE_STOP)
		{
			CGPoint pos = CGPointMake(MYMACH.pos.x + RANDOMFC(200.f), MYMACH.pos.y + RANDOMFC(200.f));
			if((pos.x - _pos.x) * (pos.x - _pos.x) + (pos.y - _pos.y) * (pos.y - _pos.y) > 2500.f)
			{
				[self setDestPosX:pos.x Y:pos.y];
				_stopDelay = GWORLD.time + RANDOMF(.3f) + .3f;
				_jobCheckTime = 0.f;
			}
		}
	}*/
}

- (void)processAI_JobAttack
{
/*	if(_attackable)
	{
		_target = MYMACH.target;
		if(_target != nil && !_moveToTarget)
		{
			_moveToTarget = true;
		}
	}*/
}

- (void)processAI_JobDefence
{
}

- (void)processAI_JobPickItem
{
	if(_jobCheckTime == 0 || GWORLD.time > _jobCheckTime)
	{
		float mostLen = 160000.f;
		GobFieldItem *item = nil, *pickItem = nil;
		for(int i = 0; i < [GWORLD.listItem childCount]; i++)
		{
			item = (GobFieldItem *)[GWORLD.listItem childAtIndex:i];
			if(item == nil) continue;
			
			CGPoint vec = CGPointMake(_pos.x - item.pos.x, _pos.y - item.pos.y);
			float len = [QVector lengthSq:&vec];
			if(mostLen > len)
			{
				mostLen = len;
				pickItem = item;
			}
		}
		
		if(pickItem != nil)
		{
			_pickItem = pickItem;
			[self setDestPosX:pickItem.pos.x Y:pickItem.pos.y];
		}

		_jobCheckTime = GWORLD.time + RANDOMF(1.f) + 1.f;
		_stopDelay = GWORLD.time + RANDOMF(1.f) + .5f;
	}
}

- (void)processAI_JobRepair
{
}

- (void)checkObjectCollide
{
/*	bool chkEnd = false;
	GobHvM_Bot *bot;
	for(int i = 0; !chkEnd && i < [GWORLD.listBot childCount]; i++)
	{
		bot = (GobHvM_Bot *)[GWORLD.listBot childAtIndex:i];
		if(bot == nil) continue;
		
		if(bot == self) chkEnd = true;
		else [self onCollideObject:bot];
	}*/
}

- (void)useRepairItem:(ItemInfo *)item
{
	[super useRepairItem:item];
	
	int add = item.param1;
	if(item.param2 == 1) add = add * _info.hp / 100;
	_hp += add;
	if(_hp > _info.hp) _hp = _info.hp;

	[self refreshHPGauge];
}

- (void)onDamage:(int)dmg From:(GobHvMach *)from
{
	if(_hp <= 0) return;
	[super onDamage:dmg From:from];
	
	[self refreshHPGauge];
}

- (void)onCrash
{
	[super onCrash];

	[super onDestroy];
}	

- (void)pickItem:(GobFieldItem *)item
{
	if(item == _pickItem)
	{
		_pickItem = nil;
		_jobCheckTime = 0;
	}
}

- (void)refreshHPGauge
{
	if(_imgHpGauge == nil) return;
	
	float scale = _hp / (float)(_info.hp);
	[_imgHpGauge setScaleX:scale * .5f];
	[_imgHpGauge setPosX:-(10.5f - 10.5f * scale)];
}


@end
