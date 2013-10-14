//
//  GobBullet.m
//  HeavyMach
//
//  Created by 엔비 on 08. 10. 28.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "GobBullet.h"
#import "GobHvMach.h"
#import "GobHvM_Player.h"
#import "GobHvM_Bot.h"
#import "GobHvM_Enemy.h"
#import "GuiGame.h"
#import "GobTrailEffect.h"
#import "WeaponInfo.h"
#import "Collider.h"
#import "QobParticle.h"
#import "SpDamageInfo.h"


@implementation GobBullet
@synthesize drop=_drop, lockOn=_lockOn;

- (id)init
{
	[super init];

	_g = 0.f;
	_toPlayer = false;
	_visual = true;
	_effectRegenTime = 0.f;
//	_effectDelay = .04f;
	_effectDelay = .06f;
	
	_smokeTrail = nil;
//	_lockonMach = nil;
//	_flameShow = true;
	
	return self;
}

- (void)dealloc
{
	[super dealloc];
}

- (void)setFireVel:(CGPoint)vel
{
	_fireVel = vel;
}

- (void)setFire:(WeaponInfo *)info Angle:(float)angle X:(float)x Y:(float)y DestX:(float)destX DestY:(float)destY
{
	_info = info;
	[self setPosX:x Y:y];
	_dest.x = destX;
	_dest.y = destY;
	_shotLen = (destX - x) * (destX - x) + (destY - y) * (destY - y);
	_prevLen = _shotLen * 10;
	
	_startTime = GWORLD.time;
	
	_speed = _info.spd + RANDOMF(_info.spd * .2f) - _info.spd * .1f;
//	angle = atan2(destY - y, destX - x);
	_rotate = angle;
	
	if(_info.wpnType == WPN_MISSILE)
	{
		_speed *= .05f;
		_spd.x = cosf(angle) * _speed;
		_spd.y = sinf(angle) * _speed;
		if(_fireVel.x == 0 && _fireVel.y == 0)
		{
			_vel.x = cosf(angle) * _speed;
			_vel.y = sinf(angle) * _speed;
		}
		
		_g = 0.f;
	}
	else
	{
		_vel.x = cosf(angle) * _speed;
		_vel.y = sinf(angle) * _speed;
	}
	
	if(_info.effectType == BULLETEFF_SMOKETRAIL || _info.effectType == BULLETEFF_LASER || _info.effectType == BULLETEFF_RAILGUN)
	{
		_smokeTrail = [[GobTrailEffect alloc] initWithTile:_info.effectTile tileNo:0];
		_smokeTrail.layer = _zLayer;
		_smokeTrail.blendType = BT_ADD;
		if(_info.effectType == BULLETEFF_SMOKETRAIL)
		{
			_smokeTrail.windEffect = 20.f / GWORLD.deviceScale;
			_smokeTrail.diffuseEffect = .05f * GWORLD.deviceScale;
			[_smokeTrail setTrailWidth:4.f * GWORLD.deviceScale Len:16.f * GWORLD.deviceScale BlockCnt:64 FadeDelay:.2f FadeTime:.5f];
		}
		else if(_info.effectType == BULLETEFF_LASER)
		{
			_smokeTrail.windEffect = 0.f;
			_smokeTrail.diffuseEffect = .05f * GWORLD.deviceScale;
			[_smokeTrail setTrailWidth:4.f * GWORLD.deviceScale Len:16.f * GWORLD.deviceScale BlockCnt:64 FadeDelay:.3f FadeTime:.3f];
		}
		else if(_info.effectType == BULLETEFF_RAILGUN)
		{
			_smokeTrail.windEffect = 40.f / GWORLD.deviceScale;
			_smokeTrail.diffuseEffect = .1f * GWORLD.deviceScale;
			[_smokeTrail setTrailWidth:32.f * GWORLD.deviceScale Len:64.f * GWORLD.deviceScale BlockCnt:64 FadeDelay:.2f FadeTime:.3f];
		}

		if(_fireVel.x == 0 && _fireVel.y == 0)
		{
			[_smokeTrail setPosX:_pos.x Y:_pos.y];
			[_smokeTrail addTrailPosX:_pos.x Y:_pos.y];
		}
		[GWORLD.objectBase addChild:_smokeTrail];
	}
	else if(_info.effectType == BULLETEFF_NORMAL || _info.effectType == BULLETEFF_SHOTGUN || _info.effectType == BULLETEFF_FLAME)
	{
		_imgEffect = [[QobImage alloc] initWithTile:_info.effectTile tileNo:0];
		[_imgEffect setUseAtlas:true];
		[_imgEffect setBlendType:BT_ADD];
		[self addChild:_imgEffect];
//		[_imgEffect setLayer:VLAYER_FORE];
	}
	
	if(_info.bulletTile != nil)
	{
		_imgBullet = [[QobImage alloc] initWithTile:_info.bulletTile tileNo:_info.bulletTileNo];
		[_imgBullet setUseAtlas:true];
		[self addChild:_imgBullet];
//		[_imgBullet setLayer:VLAYER_FORE];
	}
	
	if(_toPlayer) _effectDelay = .06f;
	else _effectDelay = .02f;
	
//	[SOUNDMGR play:_info.fireSFX X:(_pos.x-MYMACH.pos.x)/100.f Y:0];
	if(_info.fireSFX != UINT_MAX) [SOUNDMGR play:_info.fireSFX];
}

- (void)tick
{
	if(!GWORLD.pause && _show)
	{
		if(_fireVel.x != 0 || _fireVel.y != 0)
		{
			[QVector easyOut:&_fireVel To:&CGPointZero Div:15.f Min:.5f];
			[self addPos:&_fireVel];
			if(_fireVel.x == 0 && _fireVel.y == 0)
			{
				[_smokeTrail setPosX:_pos.x Y:_pos.y];
				[_smokeTrail addTrailPosX:_pos.x Y:_pos.y];
			}
		}
		else
		{
			if(_info.wpnType == WPN_MISSILE)
			{
				[QVector vector:&_vel Add:&_spd];
				if(_lockOn)
				{
					float rot = atan2(_dest.y - _pos.y, _dest.x - _pos.x);
					float spdRot = atan2(_spd.y, _spd.x);
					if(rot - spdRot > M_PI) spdRot += M_PI * 2.f;
					else if(rot - spdRot < -M_PI) spdRot -= M_PI * 2.f;
					rot = (rot - spdRot) / 15.f;
					float x1 = _spd.x, y1 = _spd.y;
					float cr = cosf(rot), sr = sinf(rot);
					_spd = CGPointMake(x1 * cr - y1 * sr, x1 * sr + y1 * cr);

					rot = atan2(_dest.y - _pos.y, _dest.x - _pos.x);
					if(rot - _rotate > M_PI) _rotate += M_PI * 2.f;
					else if(rot - _rotate < -M_PI) _rotate -= M_PI * 2.f;
					rot = (rot - _rotate) / 20.f;
//					_rotate += rot;
					
					x1 = _vel.x, y1 = _vel.y;
					 cr = cosf(rot), sr = sinf(rot);
					_vel = CGPointMake(x1 * cr - y1 * sr, x1 * sr + y1 * cr);
					_rotate = atan2(_vel.y, _vel.x);
				}
			}
			else if(_info.wpnType == WPN_RAILGUN)
			{
				_rotate += .1f;
			}
			else
			{
				_rotate = atan2(_vel.y, _vel.x);
			}
			
			_velTick.x = _vel.x / TICK_INTERVAL;
			_velTick.y = _vel.y / TICK_INTERVAL;
			[self addPos:&_velTick];
		}
		
		if(!_remove && _fireVel.x == 0 && _fireVel.y == 0)
		{
			float len = (_dest.x - _pos.x) * (_dest.x - _pos.x) + (_dest.y - _pos.y) * (_dest.y - _pos.y);
			if(len < _shotLen / 3.f && (len > _prevLen || len < _velTick.x * _velTick.x + _velTick.y * _velTick.y)) [self setCollide:false];
			if(_drop && _imgBullet != nil)
			{
				_imgBullet.scaleX = len / _shotLen * 1.f + .3f;
				_imgBullet.scaleY = len / _shotLen * .7f + .6f;
				if(_imgBullet.scaleX < .1f) _imgBullet.scaleX = .1f;
				if(_imgBullet.scaleY < .1f) _imgBullet.scaleY = .1f;
			}
			_prevLen = len;
		}
		
		if(_imgBullet != nil) _imgBullet.rotate = _rotate;
		if(_imgEffect != nil)
		{
			_imgEffect.rotate = _rotate;
			
			if(_info.effectType == BULLETEFF_FLAME) [_imgEffect setShow:!_imgEffect.isShow];
		}
	}

	[super tick];			// 수퍼클래스의 틱을 나중에 호출해 주어야 한다.
}

- (void)setOwner:(GobHvMach *)owner
{
	_owner = owner;
}

- (void)setToPlayer:(bool)toPlayer
{
	_toPlayer = toPlayer;
}

- (void)setSpDamage:(GobHvMach *)mach
{
	NSString *key = nil;
	switch(_info.wpnType)
	{
		case WPN_LASER:
			break;
		case WPN_RAILGUN:
			key = @"plasma";
			break;
		case WPN_EMP:
			key = @"EMP";
			break;
	}
	
	if(key != nil)
	{
		SpDamageInfo *spDmg = [[SpDamageInfo alloc] init];
		spDmg.key = key;
		spDmg.type = _info.wpnType;
		spDmg.delayTime = 1.f;
		spDmg.endTime = GWORLD.time + _info.spParam1;
		spDmg.damage = _info.spParam2;
		spDmg.dmgTime = GWORLD.time;
		[mach addSpDamage:spDmg];
		[spDmg release];
	}
}

- (void)set2ndDamage:(GobHvM_Enemy *)enemy
{
	Tile2D *tile;
	QobParticle *particle;
	GobHvM_Enemy *child = nil;
	for(int i = 0; i < [GWORLD.listEnemy childCount]; i++)
	{
		child = (GobHvM_Enemy *)[GWORLD.listEnemy childAtIndex:i];
		if(child != nil && child!= enemy && child.hp > 0)
		{
			CGPoint len = {_pos.x - child.pos.x, _pos.y - child.pos.y};
			float fLen = len.x * len.x + len.y * len.y;
			if(fLen < _info.spParam1 * _info.spParam1)
			{
				[child onDamage:_info.dmg * .5f From:_owner];
				[self setSpDamage:child];

				particle = [GWORLD getFreeParticle];
				if(particle)
				{
					fLen = sqrt(fLen);
					
					tile = [TILEMGR getTile:@"Efx_Lightning.png"];
					[particle setBlendType:BT_NORMAL];
					[particle setLiveTime:tile.tileCnt * 0.04f];
					[particle setTile:tile tileNo:0];
					[particle setPosX:_pos.x - len.x / 2.f Y:_pos.y - len.y / 2.f];
					[particle setTileAni:tile.tileCnt];
					[particle setRotate:atan2(len.y, len.x)];
					[particle setScaleX:fLen / 128.f];
					[particle setScaleY:GWORLD.deviceScale];
					[particle start];
				}

				if(_info.explodeTile != nil)
				{
					particle = [GWORLD getFreeParticle];
					if(particle)
					{
						[particle setBlendType:BT_NORMAL];
						[particle setLiveTime:_info.explodeTile.tileCnt * 0.04f];
						[particle setTile:_info.explodeTile tileNo:0];
						[particle setPosX:child.pos.x Y:child.pos.y];
						[particle setTileAni:_info.explodeTile.tileCnt];
						[particle setScale:_info.explodeScale * .8f];
						[particle start];
					}
				}
			}
		}
	}
}

- (void)setCollide:(bool)enemy
{
	if(_info.effectType == BULLETEFF_LASER || _info.effectType == BULLETEFF_SMOKETRAIL)
	{
		[_smokeTrail addTrailPosX:_pos.x Y:_pos.y];
	}
	
	if(_info.dmgRange != 0)
	{
		if(_info.wpnType == WPN_NUCLEAR)
		{
			QobParticle *particle = [GWORLD getFreeParticle];
			if(particle)
			{
				[particle setBlendType:BT_ADD];
				[particle setLiveTime:.25f];
				[particle setTile:[TILEMGR getTile:@"Efx_Nuclear.png"] tileNo:0];
				[particle setPosX:_pos.x Y:_pos.y];
				[particle setScale:.1f];
				[particle setScaleVel:.25f];
				[particle start];
			}
		}
		else if(_info.wpnType == WPN_EMP)
		{
			QobParticle *particle = [GWORLD getFreeParticle];
			if(particle)
			{
				[particle setBlendType:BT_ADD];
				[particle setLiveTime:.15f];
				[particle setTile:[TILEMGR getTile:@"Efx_EMP.png"] tileNo:0];
				[particle setPosX:_pos.x Y:_pos.y];
				[particle setScale:.1f];
				[particle setScaleVel:.25f];
				[particle start];
			}
			
			Tile2D *tile = [TILEMGR getTile:@"Efx_ExplodeBoss.png"];
			particle = [GWORLD getFreeParticle];
			if(particle)
			{
				[particle setBlendType:BT_ADD];
				[particle setLiveTime:tile.tileCnt * 0.04f];
				[particle setTile:tile tileNo:0];
				[particle setPosX:_pos.x Y:_pos.y];
				[particle setTileAni:tile.tileCnt];
				[particle setScale:2.f];
				[particle start];
			}
		}
		
//		[SOUNDMGR play:[GINFO sfxID:SND_EXPLGROUND] X:(_pos.x-_cam.pos.x)/100.f Y:(_pos.y-_cam.pos.y)/100.f];
		[SOUNDMGR play:[GINFO sfxID:SND_EXPLGROUND]];

		CGPoint len;
		float dmg;
		if(_toPlayer)
		{
			float dmgScale;
			GobHvM_Player *child = nil;
			for(int i = 0; i < [GWORLD.listPlayer childCount]; i++)
			{
				child = (GobHvM_Player *)[GWORLD.listPlayer childAtIndex:i];
				if(child != nil && child.hp > 0)
				{
					len = CGPointMake(fabs(_pos.x - child.pos.x), fabs(_pos.y - child.pos.y));
					if(len.x < _info.dmgRange && len.y < _info.dmgRange)
					{
						dmgScale = (1.f - ([QVector length:&len] / _info.dmgRange));
						if(dmgScale > 0)
						{
							dmgScale += .5f;
							if(dmgScale > 1.f) dmgScale = 1.f;
							dmg = _info.dmg * dmgScale;
//							if(GVAL.lvAtk > 0) dmg += GVAL.lvAtk * dmg / 100;
							[child onDamage:dmg From:_owner];
							[self setSpDamage:child];
						}
					}
				}
			}
		}
		else
		{
			float dmgScale;
			GobHvM_Enemy *child = nil;
			for(int i = 0; i < [GWORLD.listEnemy childCount]; i++)
			{
				child = (GobHvM_Enemy *)[GWORLD.listEnemy childAtIndex:i];
				if(child != nil && child.hp > 0)
				{
					len = CGPointMake(fabs(_pos.x - child.pos.x), fabs(_pos.y - child.pos.y));
					if(len.x < _info.dmgRange && len.y < _info.dmgRange)
					{
						dmgScale = (1.f - ([QVector length:&len] / _info.dmgRange));
						if(dmgScale > 0)
						{
							dmgScale += .5f;
							if(dmgScale > 1.f) dmgScale = 1.f;
							dmg = _info.dmg * dmgScale;
//							if(GVAL.lvAtk > 0) dmg += GVAL.lvAtk * dmg / 100;
							[child onDamage:dmg From:_owner];
							[self setSpDamage:child];
						}
					}
				}
			}
		}
	}
	else
	{
		GobHvM_Enemy *child = nil;
		
		for(int i = 0; i < [GWORLD.listEnemy childCount]; i++)
		{
			child = (GobHvM_Enemy *)[GWORLD.listEnemy childAtIndex:i];
			if(child != nil && child.hp > 0)
			{
				float rad = child.info.radius;
				CGPoint len = {_pos.x - child.pos.x, _pos.y - child.pos.y};
				float fLen = len.x * len.x + len.y * len.y;
//				if(MYMACH.target == child) rad *= 2.f;
				if(fLen < rad * rad)
				{
					[child onDamage:_info.dmg From:_owner];
					[self setSpDamage:child];
					if(_info.wpnType == WPN_LASER) [self set2ndDamage:child];
				}
			}
		}
	}

	if(_info.explodeTile != nil)
	{
		QobParticle *particle = [GWORLD getFreeParticle];
		if(particle)
		{
			[particle setBlendType:BT_NORMAL];
			[particle setLiveTime:_info.explodeTile.tileCnt * 0.04f];
			[particle setTile:_info.explodeTile tileNo:0];
			[particle setPosX:_pos.x Y:_pos.y];
			[particle setTileAni:_info.explodeTile.tileCnt];
//			[particle setRotate:RANDOMF(M_PI * 2.f)];
			[particle setScale:_info.explodeScale];
			[particle start];
		}
	}
	
//	if(_lockonMach != nil) [_lockonMach setLockon:nil];
	[self remove];
}

- (bool)isInCam
{
	return true;
}

- (void)draw
{
//	if(_info.bulletTile != nil) [_info.bulletTile drawTile:0 x:SCRPOS_X y:SCRPOS_Y scaleX:_scaleX scaleY:_scaleY rotate:_rotate];

	switch(_info.effectType)
	{
/*		case BULLETEFF_NORMAL:
			[_info.effectTile drawTile:0 x:SCRPOS_X y:SCRPOS_Y blendType:BT_ADD alpha:_alpha scaleX:1.f scaleY:1.f rotate:_rotate];
			break;
		case BULLETEFF_FLAME:
			if(_flameShow) [_info.effectTile drawTile:0 x:SCRPOS_X y:SCRPOS_Y blendType:BT_ADD alpha:_alpha scaleX:1.f scaleY:1.f rotate:_rotate];
			_flameShow = !_flameShow;
			break;*/
		case BULLETEFF_ION:
			if(GWORLD.time > _effectRegenTime + _effectDelay)
			{
				_effectRegenTime = GWORLD.time;
//				for(int i = 0; i < 2; i++)
				{
					QobParticle *particle = [GWORLD getFreeParticle];
					if(particle)
					{
						[particle setBlendType:BT_ADD];
						[particle setLiveTime:.4f];
						[particle setTile:_info.effectTile tileNo:_tileNo];
						[particle setPosX:_pos.x + RANDOMFC(6.f) Y:_pos.y + RANDOMFC(6.f)];
						[particle setScale:RANDOMF(.4f) + .6f];
						[particle setScaleVel:-(RANDOMF(0.008f) + .008f)];
						[particle setRotate:RANDOMF(M_PI * 2.f)];
						[particle setRotVel:RANDOMF(0.05f) + 0.1f];
						[particle start];
					}
				}
			}
			break;
		case BULLETEFF_SMOKE:
			if(GWORLD.time > _effectRegenTime + _effectDelay)
			{
				_effectRegenTime = GWORLD.time;
				QobParticle *particle = [GWORLD getFreeParticle];
				if(particle)
				{
					if(_toPlayer)
					{
						[particle setLiveTime:.5f];
						[particle setTile:_info.effectTile tileNo:_tileNo];
						[particle setPosX:_pos.x Y:_pos.y];
						[particle setScale:RANDOMF(.2f) + .1f];
						[particle setScaleVel:RANDOMF(.5f) + .5f];
						[particle setRotate:RANDOMF(M_PI * 2.f)];
						[particle setRotVel:RANDOMF(3.f) - 1.5f];
						[particle start];
					}
					else
					{
						[particle setLiveTime:.6f];
						[particle setTile:_info.effectTile tileNo:_tileNo];
						[particle setPosX:_pos.x Y:_pos.y];
						[particle setScale:RANDOMF(.4f) + .2f];
						[particle setScaleVel:RANDOMF(0.015f) + .005f];
						[particle setRotate:RANDOMF(M_PI * 2.f)];
						[particle setRotVel:RANDOMF(0.5f) - 0.25f];
						[particle start];
					}
				}
			}
			break;
/*		case BULLETEFF_RAILGUN:
			if(GWORLD.time > _effectRegenTime + _effectDelay)
			{
				_effectRegenTime = GWORLD.time;
				QobParticle *particle = [GWORLD getFreeParticle];
				if(particle)
				{
					[particle setLiveTime:.4f];
					[particle setTile:_info.effectTile tileNo:_tileNo];
					[particle setTileAni:16];
					[particle setPosX:_pos.x Y:_pos.y];
					[particle setScale:.3f];
					[particle setScaleVel:RANDOMF(0.05f) + .05f];
					[particle setRotate:RANDOMF(M_PI * 2.f)];
					[particle setRotVel:RANDOMF(3.f) + 2.f];
					[particle setVelX:RANDOMF(.02f) - .01f Y:RANDOMF(.02f) - .01f];
					[particle start];
				}
			}
			break;*/
		case BULLETEFF_LASER:
		case BULLETEFF_SMOKETRAIL:
		case BULLETEFF_RAILGUN:
		case BULLETEFF_SHOTGUN:
			if(_smokeTrail != nil && _fireVel.x == 0 && _fireVel.y == 0)
			{
				[_smokeTrail addTrailPosX:_pos.x Y:_pos.y];
			}
			break;
	}
}

/*- (void)setLockon:(GobHvMach *)mach
{
	_lockonMach = mach;
}*/


@end
