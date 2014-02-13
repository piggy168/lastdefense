//
//  ObjectHvMach.m
//  HeavyMachinery
//
//  Created by 엔비 on 08. 10. 21.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "GobHvMach.h"
#import "SpDamageInfo.h"
#import "Collider.h"
#import "QVisualLayer.h"
#import "GobWorld.h"
#import "GuiGame.h"
#import "GobMachParts.h"
#import "PartsController_Weapon.h"
#import "PartsController_WeaponAI.h"
#import "QobParticle.h"
#import "GobHvM_Player.h"


@implementation GobHvMach

@synthesize info=_info, name=_machName, spStatusFlag=_spStatusFlag, scale=_scale, rotSpeed=_rotSpeed, radius=_radius, targetRange=_targetRange, hp=_hp, hpMax=_hpMax, atkPoint=_atkPoint, spdPoint=_spdPoint, machType=_machType, speed=_moveSpeed, state=_machState, moveInfo = _moveInfo, isBase=_isBase, enemy=_enemy, moveToTarget=_moveToTarget, weaponReady=_weaponReady, target=_target, uiModel=_uiModel;

- (id)init
{
	[super init];

//	_visual = true;
//	_layer = [[QVisualLayer alloc] initWithUnitSize:3];
//	_layer.zSort = true;
	_machState = MACHSTATE_STOP;
	_machType = MACHTYPE_BIPOD;
	_scale = 1.0f;

	_hp = 256;
	_speed = 0.f;
	_moveSpeed = .6f;
	_rotSpeed = 30.f;

	_currentCol = nil;
	_prevCol = nil;
//	_crashRotate = 0.f;
	
//	_moveState = EMOVE_STOP;
	_moveInfo.walkStep = EWALK_STOP;
	_moveInfo.walkFoot = 0;
	_moveInfo.stepSize = 10.f;
	_moveInfo.destPos.x = _moveInfo.destPos.y = 0.f;
	
//	_lockonMissile = nil;
//	_lockonEfx = nil;
	
	_moveToTarget = false;
	
	_partsList = [[QList alloc] initWithUnitSize:2];
	_listSpStatus = [[NSMutableDictionary dictionaryWithCapacity: 4] retain];

	return self;
}

- (void)dealloc
{
//	[_layer release];
	[_partsList release];
	[_listSpStatus release];
	
	[super dealloc];
}

- (bool)isPlayer
{
	return false;//(self == (GobHvMach *)MYMACH);
}

- (void)processSpDamage
{
	float time = GWORLD.time;
	if(time > _spDmgCheckTime)
	{
		_spStatusFlag = 0;
		
		NSMutableArray *delArray = [[NSMutableArray alloc] init];
		
		for(SpDamageInfo *info in [_listSpStatus allValues])
		{
			switch(info.type)
			{
				case WPN_RAILGUN:	_spStatusFlag |= SPSTATUS_PLASMA;		break;
				case WPN_EMP:		_spStatusFlag |= SPSTATUS_STUN;			break;
			}
			
			if(time > info.endTime)
			{
				[delArray addObject:info.key];
			}
			else
			{
				if((_spStatusFlag & SPSTATUS_PLASMA) && time > info.dmgTime + info.delayTime)
				{
					QobParticle *particle = [GWORLD getFreeParticle];
					if(particle)
					{
						[particle setLiveTime:.3f];
						[particle setTile:[TILEMGR getTile:@"Efx_Plasma.png"] tileNo:0];
						[particle setPosX:_pos.x Y:_pos.y];
						[particle setRotate:RANDOMF(M_PI * 2.f)];
						[particle setTileAni:8];
						[particle start];
					}
					
					[self onDamage:info.damage From:nil];
					info.dmgTime = time;
					
					[SOUNDMGR play:SND_PLASMADMG];
				}
				else if((_spStatusFlag & SPSTATUS_STUN) && time > info.dmgTime + .5f)
				{
					QobParticle *particle = [GWORLD getFreeParticle];
					if(particle)
					{
						[particle setLiveTime:.5f];
						[particle setTile:[TILEMGR getTile:@"Efx_Plasma.png"] tileNo:0];
						[particle setPosX:_pos.x Y:_pos.y];
						[particle setRotate:RANDOMF(M_PI * 2.f)];
						[particle setTileAni:8];
						[particle setAlpha:.5f];
						[particle start];
					}
					
					info.dmgTime = time;
				}
			}
		}
		
		if(delArray.count > 0) [_listSpStatus removeObjectsForKeys:delArray];
		[delArray release];

		_spDmgCheckTime = time + .1f;
	}
}

- (void)tick
{
	if(!_show) return;
//	if([self isPlayer] && _speed == 0.f) _speed = 1.f;
	
	if(!GWORLD.pause)
	{
		switch(_machState)
		{
			case MACHSTATE_STOP:
			case MACHSTATE_MOVE:	[self processMove];			break;
			case MACHSTATE_CRASH:	[self processCrash];		break;
		}
		
		if(!_uiModel && _machState != MACHSTATE_CRASH)
		{
			if(_hp * 100 / _hpMax < 80)
			{
				int rand = _hp * 200 / _hpMax + 10;
				if(RANDOM(rand) == 0)
				{
					QobParticle *particle = [GWORLD getFreeParticle];
					if(particle)
					{
						particle.blendType = BT_NORMAL;
						[particle setLiveTime:.7f];
						[particle setTile:[TILEMGR getTile:@"Efx_Smoke.png"] tileNo:0];
						[particle setScale:RANDOMF(.2f) + .2f];
						[particle setScaleVel:RANDOMF(.003f) + .001f];
						[particle setRotate:RANDOMF(M_2PI)];
						[particle setRotVel:RANDOMF(0.02f)];
						[particle setVelX:-.5f-RANDOMF(.1f) Y:.2f+RANDOMF(.1f)];
						[particle setPosX:_pos.x + RANDOMFC(_radius*.5f) Y:_pos.y + RANDOMFC(_radius*.5f)];
						[particle setTileAni:16];
						[particle start];
					}
				}
			}

			[self processSpDamage];
		}
		/*		if(_lockonEfx != nil)
		{
			EASYOUT(_lockonEfx.rotate, -M_PI / 2.f, 16.f);
			EASYOUT(_lockonEfx.scaleX, .7f, 16.f);
			_lockonEfx.scaleY = _lockonEfx.scaleX;
		}*/
	}
	
	[super tick];			// 수퍼클래스의 틱을 나중에 호출해 주어야 한다.
}

- (void)setCurrentCol:(ColVector *)col
{
	_prevCol = _currentCol;
	_currentCol = col;
}

- (void)processCrash
{
	if(RANDOM(20) == 0)
	{
		QobParticle *particle = [GWORLD getFreeParticle];
		if(particle)
		{
			particle.blendType = BT_NORMAL;
			[particle setLiveTime:1.f];
			[particle setTile:[TILEMGR getTile:@"Efx_Smoke.png"] tileNo:0];
			[particle setScale:RANDOMF(.4f) + .4f];
			[particle setScaleVel:RANDOMF(.005f) + .001f];
			[particle setRotate:RANDOMF(M_2PI)];
			[particle setRotVel:RANDOMF(0.02f)];
			[particle setVelX:(-.5f-RANDOMF(.1f)) * GWORLD.deviceScale Y:(.2f+RANDOMF(.1f)) * GWORLD.deviceScale];
			[particle setPosX:_pos.x + RANDOMFC(_radius*.3f) Y:_pos.y + RANDOMFC(_radius*.3f)];
			[particle setTileAni:16];
			[particle start];
		}
	}
	
	if(GWORLD.time > _crashTime)
	{
		QobParticle *particle = [GWORLD getFreeParticle];
		if(particle)
		{
			particle.blendType = BT_NORMAL;
			[particle setLiveTime:1.f];
			[particle setTile:[TILEMGR getTile:@"Efx_ExplodeNPC.png"] tileNo:0];
			[particle setPosX:_pos.x Y:_pos.y];
			[particle setTileAni:16];
			[particle setScale:1.f];
			[particle start];
		}
		
//		[SOUNDMGR play:[GINFO sfxID:SND_EXPLMACH] X:sqrt(_pos.x-MYMACH.pos.x)*0.1f Y:sqrt(_pos.y-MYMACH.pos.y)*0.1f];
		[SOUNDMGR play:[GINFO sfxID:SND_EXPLMACH]];
		[self onDestroy];
	}
}

- (void)processMove
{
//	if(_machType != MACHTYPE_AIRCRAFT && !_isInScreen) return;

	switch(_machType)
	{
		case MACHTYPE_BIPOD:	[self processMove_Bipod];		break;
		case MACHTYPE_TANK:		[self processMove_Vehicle];		break;
		case MACHTYPE_BOT:
		case MACHTYPE_AIRCRAFT:	[self processMove_AirCraft];	break;
		case MACHTYPE_TRAIN:	[self processMove_Train];		break;
	}
	
	if(!_uiModel)
	{
		if(_dashVel.x != 0.f || _dashVel.y != 0.f)
		{
			CGPoint dashLen = {_dashPos.x - _pos.x, _dashPos.y - _pos.y};
			CGPoint vel = { _dashVel.x * 10.f, _dashVel.y * 10.f };
			
			if(dashLen.x * dashLen.x + dashLen.y * dashLen.y > 800.f)
			{
				_dashPos = _pos;
				
				QobParticle *particle = [GWORLD getFreeParticle];
				if(particle)
				{
					Tile2D *tile = [TILEMGR getTile:@"Efx_Dash.jpg"];
					[tile tileSplitX:1 splitY:1];
					[particle setLiveTime:.2f];
					[particle setTile:tile tileNo:0];
					[particle setBlendType:BT_ADD];
					[particle setRotate:atan2(vel.y, vel.x)];
					[particle setScale:.5f];
					[particle setScaleVel:.05f];
					[particle setPosX:_pos.x Y:_pos.y];
					[particle start];
				}
			}
			
			[self addPos:&vel];
			
			[QVector easyOut:&_dashVel To:&CGPointZero Div:8.f Min:.01f];
		}

		if(_machType != MACHTYPE_AIRCRAFT && _machType != MACHTYPE_BOT && GWORLD.time > _collideCheckTime + .02f)
		{
			_collideCheckTime = GWORLD.time;
			[self checkObjectCollide];
		}
		
		if(_target != nil && GWORLD.time > _targetCheckTime + .5f && !(_spAttackFlag & SPSTATUS_STUN))
		{
			CGPoint dir = {_target.pos.x - _pos.x, _target.pos.y - _pos.y};
			
			if(_moveToTarget)
			{
				float shotRange = _targetRange * .8f;
				float len = dir.x * dir.x + dir.y * dir.y;
				
				if(len < shotRange * shotRange)
				{
					[self setDestPosX:_pos.x Y:_pos.y];
				}
				else
				{
					[self setDestPosX:_target.pos.x Y:_target.pos.y];
				}
			}
			_targetCheckTime = GWORLD.time;
		}
/*		if([self isPlayer])
		{
			if((fabs(dir.x) > 320 || fabs(dir.y) > 200) && [QVector vector:&dir Dot:&_dir] < 0.f) [self setTarget:nil];
		}*/

//		if(fabs(dir.x) > 480 || fabs(dir.y) > 300) [self setTarget:nil];
	}
}

- (void)processMove_Bipod
{
	if(_machState == MACHSTATE_MOVE)
	{
		if(fabs(_pos.x - _moveInfo.destPos.x) > 4.f || fabs(_pos.y - _moveInfo.destPos.y) > 4.f)
		{
			if(_moveInfo.walkStep == EWALK_CALCPOS)
			{
				CGPoint dir = {_moveInfo.destPos.x - _pos.x, _moveInfo.destPos.y - _pos.y};
				float rot;
				
				if(_currentCol != nil && [QVector vec:_currentCol.normal Dot:dir] > 0)
				{
					rot = atan2(_currentCol.dir.y, _currentCol.dir.x);
					if([QVector vec:_currentCol.dir Dot:dir] < 0) rot += M_PI + .1f;
					else rot -= .1f;
				}
				else
				{
					rot = atan2(dir.y, dir.x);
				}
				
				if(rot - _rotate > M_PI) _rotate += M_PI * 2.f;
				else if(rot - _rotate < -M_PI) _rotate -= M_PI * 2.f;
				
				if(!_moveInfo.blocked) _moveInfo.walkStep = EWALK_FOOTCHANGE;
				else if(fabs(_rotate - rot) > 1.f) _moveInfo.walkStep = EWALK_FOOTCHANGE;
				
				if(_moveInfo.walkStep == EWALK_FOOTCHANGE)
				{
					if(_rotate > rot)	_rotate += -MIN(.5f, _rotate - rot);
					else				_rotate += MIN(.5f, rot - _rotate);
//					_rotate = rot;

					[self bipodFootChange];
				}
			}
			else if(_moveInfo.walkStep == EWALK_MOVESTEP)
			{
				if(_rotate - _moveInfo.curStep.rotate > M_PI) _moveInfo.curStep.rotate += M_2PI;
				else if(_rotate - _moveInfo.curStep.rotate < -M_PI) _moveInfo.curStep.rotate -= M_2PI;
				EASYOUT(_moveInfo.curStep.rotate, _rotate, 10.f);
				if(fabs(_moveInfo.curStep.rotate - _rotate) < .01f) _moveInfo.curStep.rotate = _rotate;
				
				EASYOUTE(_moveInfo.stepLen, _moveInfo.stepSize, 8.f, .5f);
				if(_moveInfo.stepSize == _moveInfo.stepLen)
				{
					_moveInfo.stepLen = _moveInfo.stepSize;
					_moveInfo.walkStep = EWALK_CALCPOS;
				}
				
				float scale = sinf(_moveInfo.stepLen / _moveInfo.stepSize * M_PI);
				[_moveInfo.curStep setScale:scale * .2f + 1.f];
				[_partsBody setScale:scale * .04f + 1.f];
				
				float topPos = 0.f;
				if(_moveInfo.walkFoot == 0) topPos = _moveInfo.stepLen * .1f;
				else topPos = -_moveInfo.stepLen * .1f;
				
				[_partsBody setAddPosY:topPos];
				[_partsWpnL setAddPosY:topPos];
				[_partsWpnR setAddPosY:topPos];
			}
			else if(_moveInfo.walkStep == EWALK_TURN)
			{
				if(_rotate - _moveInfo.curStep.rotate > M_PI) _moveInfo.curStep.rotate += M_2PI;
				else if(_rotate - _moveInfo.curStep.rotate < -M_PI) _moveInfo.curStep.rotate -= M_2PI;
				EASYOUT(_moveInfo.curStep.rotate, _rotate, 12.f);
				if(fabs(_moveInfo.curStep.rotate - _rotate) < .01f) _moveInfo.curStep.rotate = _rotate;

				EASYOUT(_moveInfo.stepLen, 0.f, 16.f);
				if(_moveInfo.curStep.rotate == _rotate) _moveInfo.walkStep = EWALK_CALCPOS;
			}
		}
		else
		{
			[self bipodFootChange];
			_machState = MACHSTATE_STOP;
		}
	}
	else
	{
		EASYOUT(_moveInfo.stepLen, 0.f, 6.f);
	}
	
	float prevStep = _moveInfo.moveLen;
	EASYOUT(_moveInfo.moveLen, _moveInfo.stepLen, 6.f);
	[_moveInfo.curStep setAddPosX:_moveInfo.stepLen - _moveInfo.moveLen];
	[_moveInfo.elseStep setAddPosX:-_moveInfo.moveLen];
	_speed = _moveInfo.moveLen - prevStep;
	_dir.x = cosf(_rotate) * _speed;
	_dir.y = sinf(_rotate) * _speed;
	[self addPos:&_dir];
//	_pos.x += _dir.x * _speed;
//	_pos.y += _dir.y * _speed;
	
	if(_target != nil)
	{
		float lenX = _target.pos.x - _pos.x, lenY = _target.pos.y - _pos.y;
		float len = lenX * lenX + lenY * lenY;
		
		float rot = atan2(_target.pos.y - _pos.y, _target.pos.x - _pos.x);
		if(rot - _partsBody.rotate > M_PI) _partsBody.rotate += M_2PI;
		else if(rot - _partsBody.rotate < -M_PI) _partsBody.rotate -= M_2PI;
		EASYOUT(_partsBody.rotate, rot, 10.f);
		_partsWpnL.rotate = _partsBody.rotate;
		_partsWpnR.rotate = _partsBody.rotate;
		
		if(fabs(rot - _partsBody.rotate) < 0.1f) _weaponReady = true;
		else _weaponReady = false;
		
		if(len < 20000.f)
		{
			_partsWpnL.rotate -= 0.25f - len / 80000.f;
			_partsWpnR.rotate += 0.25f - len / 80000.f;
		}
		
		EASYOUT(_partsBase.rotate, _rotate, 10.f);
	}
	else
	{
		if(_rotate - _partsBody.rotate > M_PI) _partsBody.rotate += M_2PI;
		else if(_rotate - _partsBody.rotate < -M_PI) _partsBody.rotate -= M_2PI;
		EASYOUT(_partsBody.rotate, _rotate, 10.f);
		_partsWpnL.rotate = _partsBody.rotate;
		_partsWpnR.rotate = _partsBody.rotate;
		_partsBase.rotate = _partsBody.rotate;
	}
}

- (void)bipodFootChange
{
	_moveInfo.walkFoot = !_moveInfo.walkFoot;
	if(_moveInfo.walkFoot == 0)
	{
		_moveInfo.curStep = _partsFootL;
		_moveInfo.elseStep = _partsFootR;
	}
	else
	{
		_moveInfo.curStep = _partsFootR;
		_moveInfo.elseStep = _partsFootL;
	}
	
	_moveInfo.stepLen = _moveInfo.curStep.addPos.x;
	_moveInfo.moveLen = 0;
	
	if(!_moveInfo.blocked) _moveInfo.walkStep = EWALK_MOVESTEP;
	else _moveInfo.walkStep = EWALK_TURN;
}

- (void)processMove_Vehicle
{
	if(_machState == MACHSTATE_MOVE)
	{
		if(fabs(_pos.x - _moveInfo.destPos.x) > 4.f || fabs(_pos.y - _moveInfo.destPos.y) > 4.f)
		{
			CGPoint dir = {_moveInfo.destPos.x - _pos.x, _moveInfo.destPos.y - _pos.y};
			float rot;
			
			if(_currentCol != nil && [QVector vec:_currentCol.normal Dot:dir] > 0)
			{
				rot = atan2(_currentCol.dir.y, _currentCol.dir.x);
				if([QVector vec:_currentCol.dir Dot:dir] < 0) rot += M_PI + .1f;
				else rot -= .1f;
			}
			else
			{
				rot = atan2(dir.y, dir.x);
			}

			if(rot - _rotate > M_PI) _rotate += M_2PI;
			else if(rot - _rotate < -M_PI) _rotate -= M_2PI;
			
			EASYOUT(_rotate, rot, _rotSpeed);
			if(dir.x * dir.x + dir.y * dir.y > 900) EASYOUT(_speed, _moveSpeed, 100.f);
			else EASYOUT(_speed, 0.5f, 60.f);
			_dir.x = cosf(_rotate) * _speed;
			_dir.y = sinf(_rotate) * _speed;
			[self addPos:&_dir];
			
			if(RANDOM(5) == 0)
			{
				CGPoint pt = {RANDOMF(1.f) - .5f, RANDOMF(1.f) - .5f };
				[self addPos:&pt];
				_scale = 1.f + (RANDOMF(.02f) - .01f);
			}
		}
		else
		{
			_machState = MACHSTATE_STOP;
			_speed = 0;
//			_scale = 1.f;
		}
	}
}

- (void)processMove_AirCraft
{
	if(_machState == MACHSTATE_MOVE)
	{
		if(fabs(_pos.x - _moveInfo.destPos.x) > 4.f || fabs(_pos.y - _moveInfo.destPos.y) > 4.f)
		{
			CGPoint dir = {_moveInfo.destPos.x - _pos.x, _moveInfo.destPos.y - _pos.y};
			float rot = atan2(dir.y, dir.x);

			if(rot - _rotate > M_PI) _rotate += M_2PI;
			else if(rot - _rotate < -M_PI) _rotate -= M_2PI;
			
			EASYOUT(_rotate, rot, _rotSpeed);
			if(dir.x * dir.x + dir.y * dir.y > 900) EASYOUT(_speed, _moveSpeed, 100.f);
			else EASYOUT(_speed, 0.5f, 60.f);
			_dir.x = cosf(_rotate) * _speed;
			_dir.y = sinf(_rotate) * _speed;
			[self addPos:&_dir];
		}
		else
		{
//			_speed = 0.f;
			_machState = MACHSTATE_STOP;
		}
	}
}

- (void)processMove_Train
{
	if(_machState == MACHSTATE_MOVE)
	{
		if(fabs(_pos.x - _moveInfo.destPos.x) > 4.f || fabs(_pos.y - _moveInfo.destPos.y) > 4.f)
		{
			CGPoint dir = {_moveInfo.destPos.x - _pos.x, _moveInfo.destPos.y - _pos.y};
			
			if(dir.x * dir.x + dir.y * dir.y > 900) EASYOUT(_speed, _moveSpeed, 100.f);
			else EASYOUT(_speed, 0.5f, 60.f);
			
			[QVector normalize:&dir];
			_dir.x = dir.x * _speed;
			_dir.y = dir.y * _speed;
			[self addPos:&_dir];
			
		}
		else
		{
			_machState = MACHSTATE_STOP;
			_speed = 0;
		}
	}
}

- (void)addSpDamage:(SpDamageInfo *)spDmg
{
	SpDamageInfo *info = [_listSpStatus objectForKey:spDmg.key];
	if(info == nil)
	{
		[_listSpStatus setObject:spDmg forKey:spDmg.key];
		info = spDmg;
	}
	else
	{
		info.endTime = spDmg.endTime;
		info.dmgTime = spDmg.dmgTime;
	}
	
	if(info.type == WPN_EMP)
	{
		[self setTarget:nil];
		[self setDestPosX:_pos.x Y:_pos.y];
	}
}

- (void)checkObjectCollide
{
	_currentCol = nil;
	ColVector *col;
	float colLen;
	QList *colList = [GWORLD getColListFromPos:&_pos];
	unsigned int count = colList.size;
	CGPoint sub;
	if(count > 0)
	{
		do
		{
			col = (ColVector *)[colList getData:count-1];
			if(col != nil)
			{
				colLen = [col checkCollide:&_pos ColRadius:16.f];
				if(colLen != 0.f)
				{
					sub.x = col.normal.x * colLen;
					sub.y = col.normal.y * colLen;
					[self subPos:&sub];
					[self setCurrentCol:col];
				}
			}
		} while(--count);
	}
}

- (void)onCollideObject:(GobHvMach *)mach
{
	float radius = _radius + mach.radius, vecScale;
	CGPoint vec = CGPointMake(_pos.x - mach.pos.x, _pos.y - mach.pos.y);
	CGPoint tmpVec;
	if(fabs(vec.x) < radius && fabs(vec.y) < radius)
	{
		float len = [QVector lengthSq:&vec];
		
		if(len != 0.f && len < radius * radius)
		{
			len = sqrt(len);
			[QVector vector:&vec Div:len];
			len = (radius - len) * .3f;
			[QVector vector:&vec Mul:len];
			
			if(_info.type == MACHTYPE_TURRET) [mach subPos:&vec];
			else if(mach.info.type == MACHTYPE_TURRET) [self addPos:&vec];
			else
			{
				tmpVec = vec;
				vecScale = _radius / (float)(_radius + mach.radius);
				[QVector vector:&tmpVec Mul:vecScale];
				[self addPos:&tmpVec];
				tmpVec = vec;
				vecScale = mach.radius / (float)(_radius + mach.radius);
				[QVector vector:&tmpVec Mul:vecScale];
				[mach subPos:&tmpVec];
			}
		}
	}
}

- (void)setTarget:(GobHvMach *)target
{
	if(target != nil && target.hp <= 0) _target = nil;
	else _target = target;
}

- (void)setDestPosX:(float)x Y:(float)y
{
	_moveInfo.destPos.x = x;
	_moveInfo.destPos.y = y;
	
	_machState = MACHSTATE_MOVE;
	if(_moveInfo.walkStep == EWALK_STOP) _moveInfo.walkStep = EWALK_CALCPOS;
}

- (void)setDir:(float)dir
{
	_rotate = dir;
	if(_partsBody != nil) _partsBody.rotate = dir;
	if(_partsFootL != nil) _partsFootL.rotate = dir;
	if(_partsFootR != nil) _partsFootR.rotate = dir;
}

- (void)setDashVel:(CGPoint *)vel
{
	_dashVel = *vel;
}

- (void)setStepSize:(float)len
{
	_moveInfo.stepSize = len;

	float step = 0, time = 0, tmpLen = 0, moveLen = 0;
	while(step != len)
	{
		tmpLen = step;
		EASYOUTE(step, len, 8.f, .5f);
		moveLen += step - tmpLen;
		time += TICK_INTERVAL;
	}
	
	_spdPoint = moveLen / time;
}

- (void)useRepairItem:(ItemInfo *)item
{
	QobParticle *particle;
	
//	for(int i = 0; i < 5; i++)
	{
		particle = [GWORLD getFreeParticle];
		if(particle)
		{
			[particle setLiveTime:1.f];
			[particle setTile:[TILEMGR getTile:[NSString stringWithFormat:@"Icon%05d.png", item.icon]] tileNo:0];
//			[particle setBlendType:BT_ADD];
			[particle setScale:.5f];
			[particle setScaleVel:.01f];
//			[particle setVelX:RANDOMFC(.2f) Y:RANDOMFC(.2f)];
			[particle setPosX:_pos.x Y:_pos.y];
			[particle start];
		}
	}
}

- (void)onDamage:(int)dmg From:(GobHvMach *)from
{
	_hp -= dmg;
	if(_hp <= 0)
	{
		_hp = 0;
		[self onCrash];
	}
	else if(_target != nil && _target.isBase)
	{
		[self setTarget:from];
	}
	
	if(_isBase)
	{
		if(_enemy) [GAMEUI refreshEnemyGauge:(float)_hp / (float)_hpMax];
		else [GAMEUI refreshMyGauge:(float)_hp / (float)_hpMax];
	}
	
	[SOUNDMGR play:[GINFO sfxID:SND_HITMACH_01+RANDOM(3)] X:sqrt(_pos.x-_cam.pos.x)/10.f Y:sqrt(_pos.y-_cam.pos.y)/10.f];
//	[SOUNDMGR play:[GINFO sfxID:SND_HITMACH_01+RANDOM(3)]];
}

- (void)onCrash
{
//	[SOUNDMGR play:[GINFO sfxID:SND_EXPLMACH] X:sqrt(_pos.x-MYMACH.pos.x)*0.1f Y:sqrt(_pos.y-MYMACH.pos.y)*0.1f];
	[SOUNDMGR play:[GINFO sfxID:SND_EXPLMACH]];

	QobParticle *particle = [GWORLD getFreeParticle];
	if(particle)
	{
		particle.blendType = BT_NORMAL;
		[particle setLiveTime:1.f];
		[particle setTile:[TILEMGR getTile:@"Efx_ExplodeNPC.png"] tileNo:0];
		[particle setPosX:_pos.x Y:_pos.y];
		[particle setTileAni:16];
		[particle setScale:1.f];
		[particle start];
	}

/*	if(MYMACH.target == self)
	{
		[MYMACH setTarget:nil];
		[MYMACH setMoveToTarget:false];
	}*/

	if(_target != nil)
	{
		[self setTarget:nil];
		[self setMoveToTarget:false];
	}

	_machState = MACHSTATE_CRASH;
//	if(_lockonMissile != nil) [_lockonMissile setLockon:nil];
}

- (void)onDestroy
{
//	if(_lockonMissile != nil) [_lockonMissile setLockon:nil];
	[self remove];
}

- (void)setMoveVel:(float)vel
{
	_speed = vel * _moveSpeed;
	
//	if([self isPlayer] && [GAMEUI isActivePassive:PASSIVE_SPEED]) _speed *= 1.3f;
}

- (void)insertPartsToLayer:(GobMachParts *)parts
{
//	[_layer insertObject:parts];
}

- (void)setLayer:(int)layer
{
	[super setLayer:layer];

	GobMachParts *parts = nil;
	int listSize = _partsList.size;
	for(int i = 0; i < listSize; i++)
	{
		parts = (GobMachParts *)[_partsList getData:i];
		if(parts)
		{
			if(parts.baseParts != nil) [parts setLayer:_zLayer + 1];
			else [parts setLayer:_zLayer];
		}
	}
}

- (GobMachParts *)addParts:(PartsInfo *)partsInfo
{
	GobMachParts *parts = nil;
	
	parts = [[GobMachParts alloc] init];
	[parts setHvMach:self];
	[parts setPartsInfo:partsInfo];
	[parts setRotate:_rotate];
	[self addChild:parts];
	[parts setLayer:_zLayer];
	
	if(_machType != MACHTYPE_BIPOD)
	{
		[_partsList addData:parts];
	}
	
	_boundRect.origin.x = MIN(_boundRect.origin.x, parts.rotPos.x + parts.boundRect.origin.x);
	_boundRect.origin.y = MIN(_boundRect.origin.y, parts.rotPos.y + parts.boundRect.origin.y);
	_boundRect.size.width = MAX(_boundRect.size.width, parts.rotPos.x + parts.boundRect.size.width);
	_boundRect.size.height = MAX(_boundRect.size.height, parts.rotPos.y + parts.boundRect.size.height);
	
	return parts;
}

- (GobMachParts *)addParts:(PartsInfo *)partsInfo BaseParts:(GobMachParts *)parts BaseSocket:(unsigned char)socket
{
	GobMachParts *newParts = [self addParts:partsInfo];
	
	if(parts != nil)
	{
		[parts setChildParts:newParts Socket:socket];
		[newParts setLayer:_zLayer + 1];
	}
	
	return newParts;
}

- (int)decodeChunk:(GobMachParts *)baseParts Data:(char *)data Pos:(int)pos
{
	GobMachParts *newParts = nil;
	char *pData = NULL;
	/*int size = *(int *)(data + pos);*/		pos += sizeof(int);
	int type = *(int *)(data + pos);			pos += sizeof(int);
	int dataSize = *(int *)(data + pos);		pos += sizeof(int);
	if(dataSize > 0)
	{
		int dataPos = 0;
		pData = data + pos;
		
		if(type == MCNK_MACH)
		{
			dataPos += 24;
			/*_hp = *(int *)(pData + dataPos);*/								dataPos += sizeof(int);
			/*_exp = *(int *)(pData + dataPos);*/								dataPos += sizeof(int);
			/*_machType = *(unsigned char *)(pData + dataPos);*/				dataPos += sizeof(unsigned char);
		}
		else if(type == MCNK_MACHPARTS)
		{
			char szPartsName[24];
			strcpy(szPartsName, pData);											dataPos += 24;
			unsigned char baseSocket = *(unsigned char *)(pData + dataPos);		dataPos += 1;
			unsigned char z = *(unsigned char *)(pData + dataPos);				dataPos += 1;
			PartsInfo *partsInfo = [GINFO getPartsInfo:[NSString stringWithUTF8String:szPartsName]];
			
			if(partsInfo != nil)
			{
				newParts = [self addParts:partsInfo BaseParts:baseParts BaseSocket:baseSocket];
				if(partsInfo.partsType == PARTS_WPN)
				{
					WeaponInfo *wpnInfo = [GINFO getWeaponInfo:partsInfo.name];
					if(wpnInfo != nil)
					{
						if(!_uiModel)
						{
							PartsController_WeaponAI *controller = [[PartsController_WeaponAI alloc] initWithMach:self Parts:newParts];
							[controller setWeaponInfo:wpnInfo];
							[newParts addChild:controller];
						}
						
						newParts.useBaseRot = false;
						
						[wpnInfo calcAtkPoint];
						_atkPoint = wpnInfo.atkPoint;
						_targetRange = wpnInfo.shotRange;

						switch(wpnInfo.wpnType)
						{
							case WPN_RAILGUN:	_spAttackFlag |= SPSTATUS_PLASMA;	break;
						}
					}
				}
				else if(partsInfo.partsType == PARTS_BODY)
				{
					_partsBody = newParts;
				}
				[newParts setZOrder:z];
//				[self insertPartsToLayer:newParts];
			}
		}
		
		pos += dataSize;
	}
	
	int subCnt = *(int *)(data + pos);		pos += sizeof(int);
	for(int i = 0; i < subCnt; i++)
	{
		pos = [self decodeChunk:newParts Data:data Pos:pos];
	}
	
	return pos;
}

- (bool)makeMachFromName:(const char *)machName
{
	_info = [GINFO getMachInfo:[NSString stringWithUTF8String:machName]];
	if(_info == nil || _info.data == nil) return false;
	int len = [_info.data length];
	if(len <= 0) return false;
	
	_hp = _hpMax = _info.hp;
	_machType = _info.type;
	_radius = _info.radius;
	_moveSpeed = _info.speed;
	_spdPoint = _moveSpeed / TICK_INTERVAL;
	
	char *buffer =  malloc(len);
	[_info.data getBytes:buffer length:len];

	[self decodeChunk:nil Data:buffer Pos:0];
	if(_machName != nil) [_machName release];
	_machName = [[NSString alloc] initWithUTF8String:machName];
	
	free(buffer);
	
	if(!_uiModel) [self setDir:RANDOMF((M_PI * 2.f))];
	
	return true;
}

/*- (void)draw
{
	if(_machType == MACHTYPE_BIPOD)
	{
		if(_partsBody != nil) [_partsBody drawShadow];
		if(_partsFootL != nil) [_partsFootL drawShadow];
		if(_partsFootR != nil) [_partsFootR drawShadow];
		if(_partsWpnL != nil) [_partsWpnL drawShadow];
		if(_partsWpnR != nil) [_partsWpnR drawShadow];
	}
	else if(_hp > 0)
	{
		GobMachParts *parts = nil;
		int listSize = _partsList.size;
		for(int i = 0; i < listSize; i++)
		{
			parts = (GobMachParts *)[_partsList getData:i];
			if(parts) [parts drawShadow];
		}
	}
	
	[super draw];
}*/

@end
