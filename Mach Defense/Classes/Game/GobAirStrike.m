//
//  GobSpAttack.m
//  HeavyMach2
//
//  Created by 엔비 on 09. 09. 29.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "GobAirStrike.h"
#import "GobHvM_Player.h"
#import "GobBullet.h"
#import "QobParticle.h"

@implementation GobAirStrike

- (id)initWithItem:(ItemInfo *)item
{
	[super initWithTile:[TILEMGR getTileForRetina:@"Airplane.png"] tileNo:0];
	
	_item = item;
	
	_weapon = [GINFO getWeaponInfo:[NSString stringWithFormat:@"%@_%02d", _item.strParam, (int)_item.param1]];
	_attackCount = _weapon.shotCnt;
	_fireTime = item.param2;
	return self;
}

- (void)setAttackPosX:(float)x Y:(float)y
{
	_attackPos.x = x;
	_attackPos.y = y;
	
	_vec.x = RANDOMFC(.2f);
	_vec.y = 1.f;
	[QVector normalize:&_vec];
	_vec.x *= GWORLD.deviceScale;
	_vec.y *= GWORLD.deviceScale;
	
	[self setPosX:x - _vec.x * 1200.f Y:y - _vec.y * 1200.f];
	
	_rotate = atan2(_vec.y, _vec.x);
	[self setScale:1.3f];
	
	QobParticle *particle = [GWORLD getFreeParticle];
	if(particle)
	{
		Tile2D *tile = [TILEMGR getTileForRetina:@"Target.png"];
		[tile tileSplitX:2 splitY:1];
		
		[particle setBlendType:BT_ADD];
		[particle setLiveTime:3.f];
		[particle setTile:tile tileNo:0];
		[particle setPosX:x Y:y];
		[particle setScale:15.f];
		[particle setEasyOutScale:1.5f];
		[particle setEasyOutValue:6.f];
		[particle setRotVel:.1f];
		[particle start];
	}
	
	_vec.x *= 4.f;
	_vec.y *= 4.f;
	
	[SOUNDMGR play:[GINFO sfxID:SND_AIRSTRIKE]];
	_startTime = GWORLD.time + _fireTime;
	_fireDelay = .3f / (float)_attackCount;
	_fireTime = 0.f;
}

- (void)tick
{
	[self addPos:&_vec];
	
	_vec.x += _vec.x * .01f;
	_vec.y += _vec.y * .01f;
	
	if(GWORLD.time > _startTime && _attackCount > 0)
	{
		if(GWORLD.time > _fireTime)
		{
			float dir = RANDOMF(M_PI * 2.f);
			float range = (RANDOMF(_weapon.aimRate * 120.f) + RANDOMF(_weapon.aimRate * 120.f) - _weapon.aimRate * 120.f) * GWORLD.deviceScale;
			float x = cosf(dir) * range;
			float y = sinf(dir) * range;
			
			GobBullet *bullet = [[GobBullet alloc] init];
			[bullet setToPlayer:false];
			[bullet setFire:_weapon Angle:_rotate X:_pos.x + x * .3f Y:_pos.y + y * .3f DestX:_attackPos.x + x DestY:_attackPos.y + y];
			[bullet setDrop:true];
			[GWORLD.objectBase addChild:bullet];
			_attackCount--;
			_fireTime = GWORLD.time + _fireDelay;
		}
	}
	else if(GWORLD.time > _startTime + 4.f)
	{
		[self remove];
	}
	
	[super tick];
}

@end
