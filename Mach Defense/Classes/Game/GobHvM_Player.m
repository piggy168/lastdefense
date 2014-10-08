//
//  GobHvM_Player.m
//  HeavyMach
//
//  Created by 엔비 on 09. 01. 24.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "GobHvM_Player.h"
#import "GobHvM_Enemy.h"
#import "PartsController_WeaponAI.h"
#import "QVisualLayer.h"
#import "QobParticle.h"
#import "QobLine.h"
#import "Collider.h"
#import "GobWorld.h"
#import "GobMachParts.h"
#import "GobBullet.h"
#import "GobFieldItem.h"
#import "GuiGame.h"
#import "GobHvM_Bot.h"


@implementation GobHvM_Player
@synthesize isOrder=_isOrder;

- (id)init
{
	[super init];

	_info = [GINFO getMachInfo:@"Player"];
	_machType = MACHTYPE_BIPOD;
/*	_imgHpGauge = nil;
	
	if(g_main.screen == GSCR_GAME)
	{
		Tile2D *tile;
		tile = [TILEMGR getTile:@"HPGauge.png"];
		[tile tileSplitX:1 splitY:2];
		
		QobImage *img = [[QobImage alloc] initWithTile:tile tileNo:1];
		[img setPosX:0 Y:30];
//		[img setFixedPos:true];
		[img setUseAtlas:true];
		[self addChild:img];
		[img setLayer:VLAYER_FORE];
		
		_imgHpGauge = [[QobImage alloc] initWithTile:tile tileNo:0];
		[_imgHpGauge setPosX:-1 Y:1];
		[_imgHpGauge setUseAtlas:true];
//		[_imgHpGauge setFixedPos:true];
		[img addChild:_imgHpGauge];
	}*/
	
	Tile2D *tile = [TILEMGR getTileForRetina:@"PickItem.png"];
	[tile tileSplitX:1 splitY:1];
	_imgPickItem = [[QobImage alloc] initWithTile:tile tileNo:0];
	[_imgPickItem setPosX:0 Y:50.f * GWORLD.deviceScale];
	[_imgPickItem setShow:false];
	[_imgPickItem setLayer:VLAYER_UI];
	[_imgPickItem setUseAtlas:true];
	[self addChild:_imgPickItem];
	
	_pickupTime = 0.f;

	return self;
}

- (void)dealloc
{
	[super dealloc];
}

- (void)setSpAttack:(WeaponInfo *)weapon To:(CGPoint)pos
{
	CGPoint fireVel;
	float rot = _partsBody.rotate, fireRot;
	
	for(int i = 0; i < weapon.shotCnt; i++)
	{
		if(i % 2 == 0) fireRot = RANDOMF(1.5f) + 1.5f;
		else fireRot = -RANDOMF(1.5f) - 1.5f;
		fireVel = CGPointMake(cosf(rot + fireRot) * (fabs(fireRot) + .3f) * 3.f, sinf(rot + fireRot) * (fabs(fireRot) + .3f) * 3.f);
		
		GobBullet *bullet = [[GobBullet alloc] init];
		[bullet setLayer:VLAYER_BACK];
		[bullet setOwner:self];
		[bullet setToPlayer:false];
//		[bullet setFireVel:fireVel];
		[bullet setLockOn:true];
		[bullet setFire:weapon Angle:rot + fireRot X:_pos.x Y:_pos.y DestX:pos.x + RANDOMFC(15.f) DestY:pos.y + RANDOMFC(15.f)];
		[GWORLD.objectBase addChild:bullet];
	}
}

- (void)setPostBuild:(const char *)postBuild
{
	strcpy(_postBuild, postBuild);
}

- (void)checkMoveAhead:(CGPoint)pos
{
	GobHvM_Player *mach;
	NSMutableArray *array = [[NSMutableArray alloc] init];
	CGPoint vec = CGPointMake(pos.x - _pos.x, pos.y - _pos.y);
	CGPoint aheadVec, machVec;
	float checkLen = 160.f * GWORLD.deviceScale;
	float dot, cross, angle = 0;
	int dir = 0;
	[QVector normalize:&vec];
	aheadVec = vec;
	
	for(int i = 0; i < [GWORLD.listPlayer childCount]; i++)
	{
		mach = (GobHvM_Player *)[GWORLD.listPlayer childAtIndex:i];
		if(mach != nil && mach != self && mach.hp > 0 && mach.pos.y > _pos.y + _radius && mach.pos.y < _pos.y + checkLen && fabs(mach.pos.x - _pos.x) < checkLen)
		{
			[array addObject:mach];
		}
	}
	
	if(array.count > 0)
	{
		bool col = true;
		while(col)
		{
			col = false;
			for(int i = 0; i < array.count && !col; i++)
			{
				mach = [array objectAtIndex:i];
				machVec = CGPointMake(mach.pos.x - _pos.x, mach.pos.y - _pos.y);
				dot = [QVector vec:aheadVec Dot:machVec];
				cross = [QVector vec:aheadVec Cross:machVec];
				if(dot > _radius && dot < checkLen && fabs(cross) < mach.radius) col = true;
			}
			
			if(col)
			{
				if(dir == 0)
				{
					angle += .2f;
					aheadVec = [QVector vector:&vec Rotate:angle];
					dir++;
				}
				else if(dir == 1)
				{
					aheadVec = [QVector vector:&vec Rotate:-angle];
					dir = 0;
				}
				
				if(angle > M_PI / 3) col = false;
			}
			else
			{
				pos = CGPointMake(_pos.x + aheadVec.x * checkLen, _pos.y + aheadVec.y * checkLen);
			}
		}
	}
	
	[array release];
	
	[self setDestPosX:pos.x Y:pos.y];
}

- (void)aiMove
{
	if(GWORLD.time > _stopDelay && !_isOrder && (_target == nil || _moveToTarget == false) && _pos.y < GVAL.moveLimit - _targetRange * .8f)
	{
		float destX = _pos.x + RANDOMFC((16.f * GWORLD.deviceScale));
		float destY = _pos.y + 160.f * GWORLD.deviceScale;
		if(destX < -110 * GWORLD.deviceScale) destX = -110 * GWORLD.deviceScale;
		else if(destX > 110 * GWORLD.deviceScale) destX = 110 * GWORLD.deviceScale;
		if(destY > GVAL.moveLimit - _targetRange * .8f)
		{
			destY = GVAL.moveLimit - _targetRange * .8f;
		}

		_stopDelay = GWORLD.time + RANDOMF(2.f) + 1.f;
		[self checkMoveAhead:CGPointMake(destX, destY)];
//		[self setDestPosX:destX Y:_pos.y + 160.f];
	}
	
	float xx = fabs(_pos.x - _moveInfo.destPos.x), yy = fabs(_pos.y - _moveInfo.destPos.y);
	if(_isOrder && xx <= 4.f && yy <= 4.f)
	{
		_isOrder = false;
		_stopDelay = GWORLD.time + RANDOMF(1.f) + 1.f;
	}

	if(_pos.y > GWORLD.topPlayerPos) GWORLD.topPlayerPos = _pos.y;
}

- (void)aiAttack
{
	bool spAttackStatus = false;
	if(GWORLD.time > _attackCheckTime && (_target == nil || _spAttackFlag != 0))
	{
		float len, nearLen = _targetRange * _targetRange;
		GobHvM_Enemy *enemy = nil;
		
		for(int i = 0; i < [GWORLD.listEnemy childCount]; i++)
		{
			enemy = (GobHvM_Enemy *)[GWORLD.listEnemy childAtIndex:i];
			if(enemy != nil && enemy.hp > 0)
			{
				len = (_pos.x - enemy.pos.x) * (_pos.x - enemy.pos.x) + (_pos.y - enemy.pos.y) * (_pos.y - enemy.pos.y);
				if(len < nearLen)
				{
					if(_spAttackFlag != 0)
					{
						if((enemy.spStatusFlag & _spAttackFlag) == 0)
						{
							nearLen = len;
							[self setTarget:enemy];
//							_moveToTarget = true;
							_isOrder = false;
							spAttackStatus = true;
						}
						else if(!spAttackStatus)
						{
//							nearLen = len;
							[self setTarget:enemy];
							if(enemy.pos.y < GVAL.moveLimit + _targetRange * .8f) _moveToTarget = true;
							else _moveToTarget = false;
							_isOrder = false;
						}
					}
					else
					{
						nearLen = len;
						[self setTarget:enemy];
						if(enemy.pos.y < GVAL.moveLimit + _targetRange * .8f) _moveToTarget = true;
						else _moveToTarget = false;
						_isOrder = false;
					}
				}
			}
		}

		_attackCheckTime = GWORLD.time + 1.f;
	}
}

- (void)aiBot
{
	float xx = fabs(_pos.x - _moveInfo.destPos.x), yy = fabs(_pos.y - _moveInfo.destPos.y);
	if(xx <= 4.f && yy <= 4.f && _machState == MACHSTATE_STOP && strlen(_postBuild) > 0)
	{
		_hp = 0;
		_isTransform = true;
		[GWORLD killPlayer:self];
		[GWORLD addPlayerMachWithName:_postBuild X:_moveInfo.destPos.x Y:_moveInfo.destPos.y];
//		[GWORLD addPlayerMachX:_buildInfo.buildPos.x Y:_buildInfo.buildPos.y Info:&_buildInfo];
	}
}

- (void)tick
{
	if(!_uiModel)
	{
		if(_hp > 0)
		{
			switch(_machType)
			{
				case MACHTYPE_TANK:
				case MACHTYPE_BIPOD:
					[self aiAttack];
					[self aiMove];
					break;
				case MACHTYPE_TURRET:
					[self aiAttack];
					break;
				case MACHTYPE_BOT:
					[self aiBot];
					break;
			}
		}
		else if(_isTransform)
		{
			[self remove];
		}
		
		if(_pickupTime != 0.f)
		{
			float t = GWORLD.time - _pickupTime;
			if(t <= .5f)
			{
				[_imgPickItem setPosY:(fabs(sinf(t / .6f * M_PI * 3.f) * (20.f * (.6f - t))) + 50.f) * GWORLD.deviceScale];
			}
			else
			{
                [_imgPickItem setShow:false];
                _pickupTime = 0.f;
                _pickupCoin = 0.f;
			}
		}
	}
	
	[super tick];
}

- (GobMachParts *)setParts:(NSString *)partsName partsType:(int)type
{
	WeaponInfo *wpnInfo = nil;
	PartsInfo *partsInfo = [GINFO getPartsInfo:partsName];
	if(partsInfo == nil) return nil;
	
	GobMachParts *parts = nil;
	
	switch(type)
	{
		case PARTS_BASE:
			parts = [self addParts:partsInfo];
			parts.rotate = _rotate;
			parts.useBaseRot = false;
			if(_partsBase != nil) [_partsBase remove];
			_partsBase = parts;
			if(_partsBtm != nil) [_partsBase setChildParts:_partsBtm Socket:3];
			if(_partsFootL != nil) [_partsBase setChildParts:_partsFootL Socket:1];
			if(_partsFootR != nil) [_partsBase setChildParts:_partsFootR Socket:2];
			if(_partsBody != nil) [_partsBase setChildParts:_partsBody Socket:3];
			break;
		case PARTS_BTM:
			parts = [self addParts:partsInfo];
			parts.rotate = _rotate;
			parts.useBaseRot = false;
			if(_partsBtm != nil) [_partsBtm remove];
			_partsBtm = parts;
			if(_partsBase != nil) [_partsBase setChildParts:_partsBtm Socket:1];
			break;
		case PARTS_FOOT:
			parts = [self addParts:partsInfo];
			parts.rotate = _rotate;
			parts.useBaseRot = false;
			if(_partsFootL != nil) [_partsFootL remove];
			_partsFootL = parts;
			if(_partsBase != nil) [_partsBase setChildParts:_partsFootL Socket:1];
			
			parts = [self addParts:partsInfo];
			parts.rotate = _rotate;
			parts.useBaseRot = false;
//			parts.layer--;
			if(_partsFootR != nil) [_partsFootR remove];
			_partsFootR = parts;
			if(_partsBase != nil) [_partsBase setChildParts:_partsFootR Socket:2];
			break;
		case PARTS_BODY:
			parts = [self addParts:partsInfo];
			parts.rotate = _rotate;
			parts.useBaseRot = false;
			if(_partsBody != nil) [_partsBody remove];
			_partsBody = parts;
			if(_partsBase != nil) [_partsBase setChildParts:_partsBody Socket:3];
			if(_partsWpnL != nil) [_partsBody setChildParts:_partsWpnL Socket:1];
			if(_partsWpnR != nil) [_partsBody setChildParts:_partsWpnR Socket:2];
			if(_partsProp != nil) [_partsBody setChildParts:_partsWpnR Socket:3];
			break;
		case PARTS_WPN:
			parts = [self addParts:partsInfo];
			parts.rotate = _rotate;
			parts.useBaseRot = false;
			if(_partsWpnL != nil) [_partsWpnL remove];
			_partsWpnL = parts;
			if(_partsBody != nil) [_partsBody setChildParts:_partsWpnL Socket:1];
			wpnInfo = [GINFO getWeaponInfo:partsName];
			if(wpnInfo != nil)
			{
				_wpnControllerL = [[PartsController_WeaponAI alloc] initWithMach:self Parts:parts];
				[_wpnControllerL setWeaponInfo:wpnInfo];
				[_wpnControllerL setIsUiWpnL:YES];
				[_wpnControllerL setReload];
				[parts addChild:_wpnControllerL];

				[wpnInfo calcAtkPoint];
				_atkPoint = wpnInfo.atkPoint * 2;
				_targetRange = wpnInfo.shotRange;
				
				switch(wpnInfo.wpnType)
				{
					case WPN_RAILGUN:	_spAttackFlag |= SPSTATUS_PLASMA;	break;
				}
			}
			
			parts = [self addParts:partsInfo];
			parts.rotate = _rotate;
			parts.reverse = REVERSE_V;
			parts.useBaseRot = false;
			if(_partsWpnR != nil) [_partsWpnR remove];
			_partsWpnR = parts;
			if(_partsBody != nil) [_partsBody setChildParts:_partsWpnR Socket:2];
			if(wpnInfo != nil)
			{
				_wpnControllerR = [[PartsController_WeaponAI alloc] initWithMach:self Parts:parts];
				[_wpnControllerR setWeaponInfo:wpnInfo];
				[_wpnControllerR setIsUiWpnR:YES];
				[_wpnControllerR setReload];
				[parts addChild:_wpnControllerR];
			}
			break;
		case PARTS_PROP:
			parts = [self addParts:partsInfo];
			parts.rotate = _rotate;
			parts.useBaseRot = false;
			if(_partsProp != nil) [_partsProp remove];
			_partsProp = parts;
			if(_partsBody != nil) [_partsBody setChildParts:_partsProp Socket:3];
			break;
	}
	
	return parts;
}

- (void)useRepairItem:(ItemInfo *)item
{
	[super useRepairItem:item];
	
	int add = item.param1;
	_hp += add;
}

- (void)checkObjectCollide
{
	[super checkObjectCollide];
	
	if(_machType == MACHTYPE_AIRCRAFT || _machType == MACHTYPE_BOT || _isBase) return;
	
	bool chkEnd = false;
	GobHvM_Player *player;
	for(int i = 0; !chkEnd && i < [GWORLD.listPlayer childCount]; i++)
	{
		player = (GobHvM_Player *)[GWORLD.listPlayer childAtIndex:i];
		if(player == nil || player.hp <= 0 || player.isBase || player.machType == MACHTYPE_AIRCRAFT || player.machType == MACHTYPE_BOT) continue;
		
		if(player == self) chkEnd = true;
		else [self onCollideObject:player];
	}
}

- (void)pickupItem:(ItemInfo *)item Count:(int)count
{
	[_imgPickItem setScale:1.f];
	[_imgPickItem setShow:true];
	
	if(_txtPickItem != nil) [_txtPickItem remove];
	NSString *text;
	
	switch(item.type)
	{
		case ITEM_COIN:
			GSLOT->cr += count;
			text = [[NSString alloc] initWithFormat:@"%d cr", count];
			break;
		case ITEM_ENERGYCELL:
			GVAL.mineral += count;
			if(GVAL.mineral > GVAL.maxMineral) GVAL.mineral = GVAL.maxMineral;
			text = [[NSString alloc] initWithFormat:@"%d cell", count];
			break;
		default:
			text = [[NSString alloc] initWithString:item.name];
			break;
	}
	_txtPickItem = [[QobText alloc] initWithString:text Size:CGSizeMake(120, 14) Align:UITextAlignmentCenter Font:@"TrebuchetMS-Bold" FontSize:12 Retina:true];
	[_txtPickItem setScale:1.f];
	[_imgPickItem addChild:_txtPickItem];
	[_txtPickItem setLayer:VLAYER_FORE_UI];
	[text release];
	
	_pickupTime = GWORLD.time;
	[SOUNDMGR play:[GINFO sfxID:SND_GETITEM]];
}


- (void)onDamage:(int)dmg From:(GobHvMach *)from
{
//	if(GVAL.bodyDef + GVAL.armorDef != 0) dmg -= dmg * (RANDOM((GVAL.bodyDef + GVAL.armorDef)) + 1) / 100;
		
	[super onDamage:dmg From:from];
//	GSLOT->hp = _hp;
	
//	if(dmg > 10.f) [_cam setQuake:MAX(dmg / 5.f, 10.f) Count:4 Delay:.3f];
}

- (void)onCrash
{
	[super onCrash];
	
	for(int i = 0; i < _partsList.size; i++)
	{
		GobMachParts *parts = (GobMachParts *)[_partsList getData:i];
		if(parts != nil)
		{
			[parts setLayer:VLAYER_BACK];
			if(_machType != MACHTYPE_BIPOD && i != 0) [parts remove];
		}
	}
	
	if(_machType == MACHTYPE_BIPOD)
	{
		[_partsWpnL remove];
		[_partsWpnR remove];
	}
	
	[GWORLD killPlayer:self];
	
	_crashTime = GWORLD.time + 3.f + RANDOMF(2.f);
}

@end
