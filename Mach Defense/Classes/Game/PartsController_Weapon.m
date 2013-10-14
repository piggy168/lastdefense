//
//  PartsController_Weapon.m
//  HeavyMach2
//
//  Created by 엔비 on 09. 07. 31.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PartsController_Weapon.h"
#import "GobHvM_Player.h"
#import "GobHvM_Enemy.h"
#import "GobBullet.h"
#import "QobParticle.h"
#import "GobTrailEffect.h"
#import "GuiGame.h"

@implementation PartsController_Weapon
@synthesize isUiWpnL=_isUiWpnL, isUiWpnR=_isUiWpnR;

- (void)tick
{
	if(_hvMach != nil && _baseParts != nil && _wpnInfo != nil && ((_hvMach.target != nil && _hvMach.target.hp > 0) || _isFire) && !(_hvMach.spStatusFlag & SPSTATUS_STUN))
	{
		float dt = GWORLD.time - _fireTime;
		if(_fireLeft <= 0 && dt >= _wpnInfo.reloadDly) _fireLeft = _wpnInfo.shotCnt;
		
		if(_fireLeft > 0 && dt >= _wpnInfo.shotDly && _hvMach.weaponReady)
		{
			bool bFire = true;
			CGPoint destPos, muzzlePos;
			
			if(_hvMach.target != nil)
			{
				float lenX = _hvMach.pos.x - _hvMach.target.pos.x;
				float lenY = _hvMach.pos.y - _hvMach.target.pos.y;
				if(lenX * lenX + lenY * lenY < _wpnInfo.shotRange * _wpnInfo.shotRange)
				{
					bFire = true;
					
					muzzlePos = [_baseParts getMuzzlePos];
					muzzlePos.x += _hvMach.pos.x;		muzzlePos.y += _hvMach.pos.y;
					[_baseParts setNextMuzzle];
					
					CGPoint dir = { sinf(_baseParts.rotate), -cosf(_baseParts.rotate) };
					CGPoint pos = { _hvMach.target.pos.x - muzzlePos.x, _hvMach.target.pos.y - muzzlePos.y };
					float frd = [QVector vector:&dir Cross:&pos] * .1f * _wpnInfo.aimRate;
					float len = [QVector vector:&dir Dot:&pos] * .5f * _wpnInfo.aimRate;

					destPos.x = _hvMach.target.pos.x - dir.x * len + RANDOMFC(frd);
					destPos.y = _hvMach.target.pos.y - dir.y * len + RANDOMFC(frd);
					
					lenX = destPos.x - _hvMach.target.pos.x;
					lenY = destPos.y - _hvMach.target.pos.y;
				}
				else
				{
					bFire = false;
				}
			}
			else
			{
				muzzlePos = [_baseParts getMuzzlePos];
				muzzlePos.x += _hvMach.pos.x;		muzzlePos.y += _hvMach.pos.y;
				[_baseParts setNextMuzzle];
				
				float rnd =  RANDOMFC(.05f);
				float len = _wpnInfo.shotRange * .8f + RANDOMF(_wpnInfo.shotRange * .2f);
				destPos.x = muzzlePos.x + cosf(_baseParts.rotate + rnd) * len;
				destPos.y = muzzlePos.y + sinf(_baseParts.rotate + rnd) * len;
			}

			if(bFire)
			{
				Tile2D *tile;
				QobParticle *particle;
				while(_fireLeft > 0 && GWORLD.time >= _fireTime + _wpnInfo.shotDly)
				{
					_fireLeft--;
					_fireTime = GWORLD.time;// + RANDOMFC(_wpnInfo.shotDly * .2f);
					
					particle = [GWORLD getFreeParticle];
					if(particle)
					{
						[particle setLiveTime:.1f];
						[particle setTile:[TILEMGR getTile:@"Efx_Fire.png"] tileNo:RANDOM(12)];
						[particle setPosX:muzzlePos.x Y:muzzlePos.y];
						[particle setRotate:RANDOMF(M_PI * 2.f)];
						[particle start];
					}
					
					if(_wpnInfo.wpnType == WPN_NORMAL)
					{
						if(_wpnInfo.explodeTile != nil)
						{
							particle = [GWORLD getFreeParticle];
							if(particle)
							{
								particle.blendType = BT_NORMAL;
								[particle setLiveTime:_wpnInfo.explodeTile.tileCnt * .03f];
								[particle setTile:_wpnInfo.explodeTile tileNo:0];
								[particle setPosX:destPos.x Y:destPos.y];
								[particle setRotate:atan2(destPos.y - muzzlePos.y, destPos.x - muzzlePos.x)];
								[particle setScale:_wpnInfo.explodeScale];
								[particle setTileAni:_wpnInfo.explodeTile.tileCnt];
								[particle start];
							}
						}

						CGPoint len = { destPos.x - muzzlePos.x, destPos.y - muzzlePos.y };
						float fLen = len.x * len.x + len.y * len.y;
						particle = [GWORLD getFreeParticle];
						if(particle)
						{
							fLen = sqrt(fLen);
							
							tile = [TILEMGR getTile:@"Efx_BulletTrail.png"];
							[particle setBlendType:BT_ADD];
							[particle setLiveTime:0.1f];
							[particle setTile:tile tileNo:0];
							[particle setPosX:muzzlePos.x + len.x / 2.f Y:muzzlePos.y + len.y / 2.f];
							[particle setRotate:atan2(len.y, len.x)];
							[particle setScaleX:fLen / 64.f];
							[particle setScaleY:GWORLD.deviceScale];
							[particle start];
						}

						particle = [GWORLD getFreeParticle];
						if(particle)
						{
							float dir = _baseParts.rotate + (_isUiWpnL ? M_PI/2.f : -M_PI/2.f) + RANDOMFC(1.f);
							float vel = RANDOMF(2.f) + 1.5f;
							if(_glView.deviceType != DEVICE_IPAD) vel *= .5f;
							tile = [TILEMGR getTileForRetina:@"BulletShell.png"];
							[tile tileSplitX:2 splitY:1];
							[particle setLiveTime:.3f + RANDOMF(.3f)];
							[particle setTile:tile tileNo:0];
							[particle setPosX:_hvMach.pos.x+_baseParts.rotPos.x Y:_hvMach.pos.y+_baseParts.rotPos.y];
							[particle setScale:.6f];
							[particle setScaleVel:-.004];
							[particle setRotVel:.4f];
							[particle setVelX:cosf(dir) * vel Y:sinf(dir) * vel];
							[particle setVelAdd:-.05f];
							[particle start];
						}
						
						if(_hvMach.target != nil)
						{
							int dmg = _wpnInfo.dmg;
//							if(_hvMach == MYMACH) dmg += GVAL.lvAtk * dmg / 100;
							[_hvMach.target onDamage:dmg From:_hvMach];
						}
					}
					else if(_wpnInfo.wpnType == WPN_SNIPER)
					{
						if(_wpnInfo.explodeTile != nil)
						{
							particle = [GWORLD getFreeParticle];
							if(particle)
							{
								particle.blendType = BT_NORMAL;
								[particle setLiveTime:_wpnInfo.explodeTile.tileCnt * .05f];
								[particle setTile:_wpnInfo.explodeTile tileNo:0];
								[particle setPosX:destPos.x Y:destPos.y];
								[particle setTileAni:_wpnInfo.explodeTile.tileCnt];
								[particle start];
							}
						}
								
						CGPoint len = { destPos.x - muzzlePos.x, destPos.y - muzzlePos.y };
						float fLen = len.x * len.x + len.y * len.y;
						particle = [GWORLD getFreeParticle];
						if(particle)
						{
							fLen = sqrt(fLen);
							
							tile = [TILEMGR getTile:@"Efx_BulletTrail.png"];
							[particle setBlendType:BT_ADD];
							[particle setLiveTime:0.1f];
							[particle setTile:tile tileNo:0];
							[particle setPosX:muzzlePos.x + len.x / 2.f Y:muzzlePos.y + len.y / 2.f];
							[particle setRotate:atan2(len.y, len.x)];
							[particle setScaleX:fLen / 64.f];
							[particle start];
						}
						
						particle = [GWORLD getFreeParticle];
						if(particle)
						{
							float dir = _baseParts.rotate + (_isUiWpnL ? M_PI/2.f : -M_PI/2.f) + RANDOMFC(1.f);
							float vel = RANDOMF(2.f) + 1.5f;
							tile = [TILEMGR getTileForRetina:@"BulletShell.png"];
							[tile tileSplitX:2 splitY:1];
							[particle setLiveTime:.7f + RANDOMF(.7f)];
							[particle setTile:tile tileNo:0];
							[particle setPosX:_hvMach.pos.x+_baseParts.rotPos.x Y:_hvMach.pos.y+_baseParts.rotPos.y];
							[particle setScale:.7f];
							[particle setScaleVel:-.004];
							[particle setRotVel:.4f];
							[particle setVelX:cosf(dir) * vel Y:sinf(dir) * vel];
							[particle setVelAdd:-.05f];
							[particle start];
						}
						
						if(_hvMach.target != nil)
						{
							int dmg = _wpnInfo.dmg;
							[_hvMach.target onDamage:dmg From:_hvMach];
						}
					}
					else
					{
						float rot = atan2(destPos.y - muzzlePos.y, destPos.x - muzzlePos.x);
						GobBullet *bullet = [[GobBullet alloc] init];
						[bullet setLayer:VLAYER_FORE];
						[bullet setOwner:_hvMach];
						[bullet setToPlayer:_hvMach.enemy];
						[bullet setFire:_wpnInfo Angle:rot X:muzzlePos.x Y:muzzlePos.y DestX:destPos.x DestY:destPos.y];
						[GWORLD.objectBase addChild:bullet];
					}
				}
				
				_fireBound = -5.f * GWORLD.deviceScale;
//				[SOUNDMGR play:_wpnInfo.fireSFX X:(_hvMach.pos.x-MYMACH.pos.x)*0.01f Y:(_hvMach.pos.y-MYMACH.pos.y)*0.01f];
				if(_wpnInfo.fireSFX != UINT_MAX) [SOUNDMGR play:_wpnInfo.fireSFX];
			}
		}
	}
	
	if(_fireBound != 0.f)
	{
		EASYOUTE(_fireBound, 0.f, 10.f, 0.01f);
		[_baseParts setAddPosX:_fireBound];
	}
	[super tick];
}

- (void)setReload
{
	_fireLeft = 0;
	_fireTime = GWORLD.time;
}

- (void)setWeaponInfo:(WeaponInfo *)wpnInfo
{
	_wpnInfo = wpnInfo;
}

- (void)setFire:(BOOL)isFire
{
	_isFire = isFire;
}

@end
