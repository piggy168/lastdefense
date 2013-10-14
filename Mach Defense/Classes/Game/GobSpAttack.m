//
//  GobSpAttack.m
//  HeavyMach2
//
//  Created by 엔비 on 09. 09. 29.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "GobSpAttack.h"
#import "GobHvM_Player.h"
#import "GobBullet.h"
#import "QobParticle.h"

@implementation GobSpAttack

- (id)initWithItem:(ItemInfo *)item
{
	[super initWithTile:[TILEMGR getTile:@"Airplane.png"] tileNo:0];
	
	_item = item;
	if([_item.strParam isEqualToString:@"AS_BOMB"]) _type = SPATK_AIRSTRIKE_BOMB;
	else if([_item.strParam isEqualToString:@"AS_MISSILE"]) _type = SPATK_AIRSTRIKE_MISSILE;
	else if([_item.strParam isEqualToString:@"AS_LASER"]) _type = SPATK_AIRSTRIKE_LASER;
	else if([_item.strParam isEqualToString:@"AS_NUCLEAR"]) _type = SPATK_AIRSTRIKE_NUCLEAR;
	
	_weapon = [GINFO getWeaponInfo:[NSString stringWithFormat:@"%@_%02d", _item.strParam, _item.param1]];
	_attackCount = _weapon.shotCnt;
	_fireTime = item.param2;
	return self;
}

- (void)setAttackPosX:(float)x Y:(float)y
{
	_attackPos.x = x;
	_attackPos.y = y;
	
	_vec.x = _attackPos.x - MYMACH.pos.x;
	_vec.y = _attackPos.y - MYMACH.pos.y;
	[QVector normalize:&_vec];
	
	[self setPosX:x - _vec.x * 600.f Y:y - _vec.y * 600.f];
	
	_rotate = atan2(_vec.y, _vec.x);
	[self setScale:1.3f];
	
	_startTime = GWORLD.time;
}

- (void)tick
{
	_pos.x += _vec.x;
	_pos.y += _vec.y;
	
	_vec.x += _vec.x * .015f;
	_vec.y += _vec.y * .015f;
	if(GWORLD.time > _startTime + _fireTime && _attackCount > 0)
	{
		if(RANDOM(4) == 0)
		{
			float dir = RANDOMF(M_PI * 2.f);
			float range = RANDOMF(120.f) + RANDOMF(120.f) - 120.f;
			float x = cosf(dir) * range;
			float y = sinf(dir) * range;
			
			GobBullet *bullet = [[GobBullet alloc] init];
			[bullet setToPlayer:false];
			[bullet setFire:_weapon Angle:_rotate X:_pos.x + x * .3f Y:_pos.y + y * .3f DestX:_attackPos.x + x DestY:_attackPos.y + y];
			[GWORLD.objectBase addChild:bullet];
			_attackCount--;
		}
	}
	else if(GWORLD.time > _startTime + 3.f)
	{
		[self remove];
	}
	
	[super tick];
}

@end
