//
//  GobMap.m
//  HeavyMach
//
//  Created by 엔비 on 08. 11. 08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "GobWorld.h"
#import "DefaultAppDelegate.h"
#import "GobTrailEffect.h"
#import "GobHvM_Player.h"
#import "GobHvM_Enemy.h"
#import "GobHvM_Bot.h"
#import "ZoneManager.h"
#import "GobAirStrike.h"
#import "GobEnemySpawner.h"
#import "GobFieldItem.h"
#import "GuiGame.h"
#import "GuiHelp.h"
#import "DlgRadar.h"
#import "DlgSummary.h"
#import "GuiMapLoading.h"
#import "Collider.h"
#import "QobParticle.h"
#import "QobButton.h"
#import "QobLine.h"
#import "PartsManager.h"
#import "BaseUpgradeSet.h"

extern DefaultAppDelegate *_appDelegate;

@implementation GobWorld

@synthesize time=_gameTime, state=_gameState, stageStartTime=_stageStartTime, deviceScale=_deviceScale, mapHalfLen=_mapHalfLen, pause=_pause, isSave=_isSave, killCount=_killCount, topPlayerPos=_topPlayerPos, objectBase=_objectBase, listEnemy=_listEnemy, listPlayer=_listPlayerMach, listBot=_listBot, listItem=_listItem, baseMach=_baseMach, colList=_colList, partsMgr=_partsMgr;

- (id)init
{
	[super init];
	[self setUiReceiver:true];
	
	if(_glView.deviceType == DEVICE_IPAD)
	{
		_deviceScale = 1.f;
		_mapLen = 2048.f;
		_mapHalfLen = 1024.f;
		_leftUIPos = 128;
		_rightUIPos = 640;
		_camCenter = 512;
		
		_radarPos = CGPointMake(55, 824);
		_radarSize = CGSizeMake(32, 128);
	}
	else
	{
		_deviceScale = .5f;
		_mapLen = 1024.f;
		_mapHalfLen = 512.f;
		_leftUIPos = 0;
		_rightUIPos = 256;
		_camCenter = 240;
		
		_radarPos = CGPointMake(18, 398);
		_radarSize = CGSizeMake(16, 64);
	}
	_colUnitSize = 128.f * _deviceScale;
	
	_tileResMgr = [[ResMgr_Tile alloc] init];
	_partsMgr = [[PartsManager alloc] init];
	
	_gameState = GSTATE_PLAY;
	_changeStateTime = 0.f;
	_tapState = TAPSTATE_NORMAL;
	
	_colList = [[NSMutableArray alloc] init];
//	_listZonePlayer = [[NSMutableArray alloc] init];
	
	_gameTime = 0;
	_pause = false;
	_show = true;

	Tile2D *tile = nil;
	tile = [TILEMGR getTile:@"Efx_BulletTrail_green.png"];			[tile tileSplitX:1 splitY:1];
    tile = [TILEMGR getTile:@"Efx_BulletTrail_red.png"];			[tile tileSplitX:1 splitY:1];
	tile = [TILEMGR getTile:@"Efx_Lightning.png"];				[tile tileSplitX:2 splitY:4];
	tile = [TILEMGR getTileForRetina:@"Efx_Explode01.png"];		[tile tileSplitX:4 splitY:2];
	tile = [TILEMGR getTileForRetina:@"Efx_Explode02.png"];		[tile tileSplitX:6 splitY:4];	[tile setOriginY:-44];
	tile = [TILEMGR getTileForRetina:@"Efx_Explode03.png"];		[tile tileSplitX:4 splitY:4];
	tile = [TILEMGR getTileForRetina:@"Efx_Explode04.png"];		[tile tileSplitX:4 splitY:4];
	tile = [TILEMGR getTileForRetina:@"Efx_ExplodeIon.png"];	[tile tileSplitX:4 splitY:4];
	tile = [TILEMGR getTileForRetina:@"Efx_ExplodePlasma.png"];	[tile tileSplitX:4 splitY:4];
	tile = [TILEMGR getTileForRetina:@"Efx_ExplodeGround.png"];	[tile tileSplitX:4 splitY:5];
	tile = [TILEMGR getTileForRetina:@"Efx_ExplodeBoss.png"];	[tile tileSplitX:4 splitY:4];
	tile = [TILEMGR getTileForRetina:@"Efx_ExplodeNPC.png"];	[tile tileSplitX:4 splitY:4];
	tile = [TILEMGR getTileForRetina:@"Efx_Fire.png"];			[tile tileSplitX:4 splitY:4];
	tile = [TILEMGR getTileForRetina:@"Efx_Damage.png"];		[tile tileSplitX:6 splitY:1];
	tile = [TILEMGR getTileForRetina:@"Efx_DamageHMG.png"];		[tile tileSplitX:8 splitY:1];	[tile setOriginX:-24];
	tile = [TILEMGR getTileForRetina:@"Efx_Plasma.png"];		[tile tileSplitX:8 splitY:1];
	tile = [TILEMGR getTileForRetina:@"Efx_Smoke.png"];			[tile tileSplitX:4 splitY:4];
	tile = [TILEMGR getTileForRetina:@"Efx_RailgunEx.png"];		[tile tileSplitX:4 splitY:4];
	tile = [TILEMGR getTileForRetina:@"Efx_Nuclear.png"];		[tile tileSplitX:1 splitY:1];
	tile = [TILEMGR getTileForRetina:@"Efx_EMP.png"];			[tile tileSplitX:1 splitY:1];
	tile = [TILEMGR getTileForRetina:@"Blt_Bullet.png"];		[tile tileSplitX:4 splitY:8];
	tile = [TILEMGR getTileForRetina:@"Blt_Railgun.png"];		[tile tileSplitX:1 splitY:1];
//	tile = [TILEMGR getTileForRetina:@"ItemTile.png"];			[tile tileSplitX:4 splitY:2];
	
	_cam = [[QobCamera alloc] init];
	[_cam setScreenWidth:_glView.surfaceSize.width Height:_glView.surfaceSize.height];
	[self addChild:_cam];
	[QOBMGR setMainCam:_cam];
	
	[self clearAllObject];
	
	return self;
}

- (void)dealloc
{
	[_cam release];

	[_tileResMgr removeAllTiles];
	[_tileResMgr release];
	[_colList release];

	[super dealloc];
}

- (void)processEnemyGen
{
	if(_gameTime > _difficultInfo.checkTime)
	{
		_difficultInfo.checkTime = _gameTime + .4f;
		_difficultInfo.diffTimeA += RANDOMF((.02f * (1.2f - _difficultInfo.difficult)));
		_difficultInfo.diffTimeB += RANDOMF((.01f * (1.2f - _difficultInfo.difficult)));
		if(_difficultInfo.diffScale < 1.f)
		{
			_difficultInfo.diffScale += RANDOMF(.002f);
			if(_difficultInfo.diffScale > 1.f) _difficultInfo.diffScale = 1.f;
		}
		_difficultInfo.difficult = (((1.f - cosf(_difficultInfo.diffTimeA)) / 2.f) + ((1.f - cosf(_difficultInfo.diffTimeB)) / 2.f)) / 2.f * _difficultInfo.diffScale;
//		_difficultInfo.difficult = _difficultInfo.difficult * .5f + .5f;
//		[GAMEUI setMaxMineral:(int)(_difficultInfo.difficult * 500.f)];
	}
	
	if(_gameTime > _enemyRegenTime)
	{
		int diffLevel = _difficultInfo.difficult * 5.f;
		if(diffLevel < 0) diffLevel = 0;
		if(diffLevel >= 5) diffLevel = 5;
		while(diffLevel > 0 && _diffSpawn[diffLevel].spawnInfoCount <= 0) diffLevel--;
		
		bool spawn = false;
		int rate = RANDOM(_diffSpawn[diffLevel].diffSum);
		
		for(int i = 0; i < _diffSpawn[diffLevel].spawnInfoCount && !spawn; i++)
		{
			if(rate < _diffSpawn[diffLevel].listSpawnInfo[i]->rate)
			{
				spawn = true;
				[self addEnemySpawner:_diffSpawn[diffLevel].listSpawnInfo[i]];
			}
		}

		float timeRate = (_difficultInfo.genTimeMax - _difficultInfo.genTimeMin) * (1.f - _difficultInfo.difficult) + _difficultInfo.genTimeMin;
		float rndRate = (_difficultInfo.rndTimeMax - _difficultInfo.rndTimeMin) * (1.f - _difficultInfo.difficult) + _difficultInfo.rndTimeMin;
		_enemyRegenTime = _gameTime + RANDOMF(rndRate) + timeRate;
	}
}

- (void)validCamPos
{
	_onCamTop = _onCamBottom = true;
	if(_camPos > _mapHalfLen - _camCenter) _camPos = _mapHalfLen - _camCenter;
	else _onCamTop = false;
	if(_camPos < -_mapHalfLen + (_camCenter - _camBottomMargin)) _camPos = -_mapHalfLen + (_camCenter - _camBottomMargin);
	else _onCamBottom = false;
	
	[GAMEUI.dlgRader setCamBottom:_camPos - _camCenter + _camBottomMargin Top:_camPos + _camCenter];
}

- (void)setUIPos:(float)pos
{
	_camBottomMargin = pos;
	if(_onCamBottom) _camPos = -_mapHalfLen + (_camCenter - _camBottomMargin);
	else if(_camPos < -_mapHalfLen + (_camCenter - _camBottomMargin)) _onCamBottom = true;

	[GAMEUI.dlgRader setCamBottom:_camPos - _camCenter + _camBottomMargin Top:_camPos + _camCenter];
}

- (void)processCamera
{
	float camY = _cam.pos.y;
	
	if(_controlCamTap == nil && _camVel != 0.f)
	{
		EASYOUTE(_camVel, 0.f, 10.f, .01f);
		_camPos += _camVel;
		[self validCamPos];
	}
	
	if(_onCamBottom)
	{
		camY = _camPos;
		_camVel = 0.f;
	}
	else
	{
		EASYOUTE(camY, _camPos, 5.f, .5f);
	}
	[_cam setPosY:camY];
}

- (void)processGameRule
{
	if(_gameTime >= _mrIncTime)
	{
		if(GVAL.mineral < GVAL.maxMineral) GVAL.mineral += GVAL.incMineral;
		_mrIncTime = _gameTime + .08f;
	}
}

- (void)tick
{
	if(!_show) return;
	
	if(!_pause)
	{
		_gameTime += TICK_INTERVAL;
		
		if(_gameState == GSTATE_PLAY)
		{
			_topPlayerPos = -800;
			[self processGameRule];
			[self processEnemyGen];
		}
	}
	
	[self processCamera];
	[super tick];			// 수퍼클래스의 틱을 나중에 호출해 주어야 한다.
}

- (void)setGameState:(short)state
{
	_gameState = state;
	_changeStateTime = g_time;
}

- (void)setStage:(int)stage
{
	RANDOM_SEED;
	
	GSLOT->stage = stage;

	GVAL.cellUpgrade = 0;
	[GINFO updateBaseUpgrade];
	GVAL.mineral = GVAL.maxMineral * .4f;
	GVAL.killEnemies = 0;
	GVAL.deadMachs = 0;
    GVAL.getDamage = 0;
    GVAL.giveDamage = 0;
	GVAL.moveLimit = _mapHalfLen - 50 * _deviceScale;
	_stageStartTime = _gameTime;
	
	float clearCnt = GSLOT->stageClearCount[stage];
	if(clearCnt > 4) clearCnt = 4;
	_difficultInfo.diffScale = .3f + clearCnt * 0.7f / 4.f;

	[self openMap:stage];
	
	GobHvM_Enemy *base = [self addEnemyMach:"E_Base" X:0 Y:_mapHalfLen - 50 * _deviceScale];
	base.layer = VLAYER_FORE;
	[base setMachType:MACHTYPE_TURRET];
	[base setDir:0.f];
	[base setIsBase:TRUE];
	[base setHp:10000 * stage];
	[base setHpMax:10000 * stage];
	
	GobHvM_Player *mach = [[GobHvM_Player alloc] init];
	mach.layer = VLAYER_FOREMOST;
	[mach setPosX:0 Y:-_mapHalfLen + 94 * _deviceScale];
	[_listPlayerMach addChild:mach];
	[mach setMachType:MACHTYPE_TURRET];
	[mach setState:MACHSTATE_STOP];
	[mach setDir:M_PI/2.f];
	[mach setIsBase:TRUE];
	[mach setParts:@"DummyParts" partsType:PARTS_BASE];
	BaseUpgradeSet *upgradeSet = [GINFO getBaseUpgradeSet:@"BaseDefense"];
	NSString *strName = [NSString stringWithFormat:@"Base%02d", upgradeSet.level + 1];
	[mach setParts:strName partsType:PARTS_BODY];
	
	upgradeSet = [GINFO getBaseUpgradeSet:@"BaseCannon"];
	strName = [NSString stringWithFormat:@"BaseWpn%02d", upgradeSet.level + 1];
	[mach setParts:strName partsType:PARTS_WPN];
	strName = [NSString stringWithFormat:@"Base%02d_Rader", upgradeSet.level + 1];
	[mach setParts:strName partsType:PARTS_PROP];
	[mach setHp:GVAL.baseDef];
	[mach setHpMax:GVAL.baseDef];
	_baseMach = mach;

	_camBottomMargin = 178.f;
	_camPos = -_mapHalfLen + (_camCenter - _camBottomMargin);
	[self validCamPos];
	[_cam setPosX:_glView.deviceType==DEVICE_IPAD ? 0:32 Y:-_mapHalfLen + (_camCenter - _camBottomMargin)];
	_onCamBottom = true;
	
	[GAMEUI onStartStage];
	[self setGameState:GSTATE_PLAY];
	
	if(GSLOT->runCount < 5)
	{
		[GWORLD setPause:true];
		GuiHelp *help = [[GuiHelp alloc] initWithLocale:GINFO.localeCode Page:-1];
		[GAMEUI addChild:help];
		[help setLayer:VLAYER_UI];
		GSLOT->runCount += 5;
	}
	
	[_appDelegate bannerTurnOff:nil];
    
    //test
    [self onClearStage];
}

- (void)onClearStage
{
	if(_gameState == GSTATE_CLEARSTAGE) return;
	[self setGameState:GSTATE_CLEARSTAGE];
	// dustin. result dialog
 NSLog(@"Dustin-onClearStage !!!!!!!!!!!!!!!");
	DlgSummary *summery = [[DlgSummary alloc] initWithClear:true];
	if(_glView.deviceType == DEVICE_IPAD) [summery setPosX:384 Y:640];
	else [summery setPosX:130 Y:350];
	[summery setLayer:VLAYER_UI];
	[g_main addChild:summery];
	
	GobHvM_Enemy *enemy;
	for(int i = 0; i < [_listEnemy childCount]; i++)
	{
		enemy = (GobHvM_Enemy *)[_listEnemy childAtIndex:i];
		if(enemy != nil && enemy.hp > 0)
		{
			[enemy onDamage:enemy.hp From:nil];
		}
	}
	
	GVAL.moveLimit = 2048;
	
	[GAMEUI turnOffButtons:-1];
}

- (void)setNextStage
{
	[self setPause:true];
	
	UInt32 sndID = [SOUNDMGR getSound:@"Title_TitleIn.wav"];
	[SOUNDMGR play:sndID];
	
	GuiMapLoading *stageClear = [[GuiMapLoading alloc] init];
	stageClear.nextStage = GSLOT->stage;
	[g_main addChild:stageClear];
}

- (void)setGameOver
{
	if(_gameState == GSTATE_GAMEOVER) return;
	[self setGameState:GSTATE_GAMEOVER];
	
	DlgSummary *summery = [[DlgSummary alloc] initWithClear:false];
	if(_glView.deviceType == DEVICE_IPAD) [summery setPosX:384 Y:640];
	else [summery setPosX:130 Y:300];
	[summery setLayer:VLAYER_UI];
	[g_main addChild:summery];
	
	GobHvM_Player *player;
	for(int i = 0; i < [_listPlayerMach childCount]; i++)
	{
		player = (GobHvM_Player *)[_listPlayerMach childAtIndex:i];
		if(player != nil && player.hp > 0)
		{
			[player onDamage:player.hp From:nil];
		}
	}
	
	GVAL.moveLimit = 2048;
	
	[GAMEUI turnOffButtons:-1];
}

- (void)setTargetPos:(CGPoint)pos
{
	QobParticle *particle = [GWORLD getFreeParticle];
	if(particle)
	{
		Tile2D *tile = [TILEMGR getTileForRetina:@"Target.png"];
		[tile tileSplitX:2 splitY:1];
		
		[particle setBlendType:BT_ADD];
		[particle setLiveTime:3.f];
		[particle setTile:tile tileNo:0];
		[particle setPosX:pos.x Y:pos.y];
		[particle setScale:15.f];
		[particle setEasyOutScale:1.5f];
		[particle setEasyOutValue:6.f];
		[particle setRotVel:.1f];
		[particle start];
	}
/*	[_imgTarget setPosX:pos.x Y:pos.y];
	[self onTarget:true];*/
}

- (void)onTap_ControlCam:(CGPoint)pt State:(int)state ID:(id)tapID
{
	if(state == TAP_START)
	{
		if(pt.y > _radarPos.y - _radarSize.height && pt.y < _radarPos.y + _radarSize.height && pt.x > _radarPos.x - _radarSize.width && pt.x < _radarPos.x + _radarSize.width)				// map & build slot
		{
			if(_mapMoveTap == nil)
			{
				_mapMoveTap = tapID;
				_camPos = (pt.y - _radarPos.y) * 8.f;
				[self validCamPos];
			}
		}
		else if(pt.x < _rightUIPos && pt.y > _camBottomMargin && _controlCamTap == nil)
		{
			_controlCamTap = tapID;
			_camTapPos = pt.y;
			_onlyTap = true;
		}
	}
	else if(state == TAP_MOVE || state == TAP_END)
	{
		if(tapID == _mapMoveTap)
		{
			_camPos = (pt.y - _radarPos.y) * 8.f;
			[self validCamPos];
			if(state == TAP_END)
			{
				_mapMoveTap = nil;
			}
		}
		else if(tapID == _controlCamTap)
		{
			if(_onlyTap)
			{
				if(fabs(pt.y - _camTapPos) > 16.f) _onlyTap = false;
			}
			else
			{
				_camVel = _camTapPos - pt.y;
				_camPos += _camVel;
				[self validCamPos];

				_camTapPos = pt.y;
			}

			if(state == TAP_END)
			{
				_controlCamTap = nil;
				if(_onlyTap)
				{
					CGPoint pos = CGPointMake(_cam.pos.x - _cam.halfScr.width + pt.x, _cam.pos.y - _cam.halfScr.height + _cam.offsetY + pt.y);
					[GAMEUI setAttackPos:pos];
				}
				else if(fabs(_camVel) < 8.f)
				{
					_camVel = 0.f;
				}
			}
		}
	}
}

- (BOOL)onTap:(CGPoint)pt State:(int)state ID:(id)tapID
{
	if(_pause) return false;

	switch(_tapState)
	{
		case TAPSTATE_NORMAL:			[self onTap_ControlCam:pt State:state ID:tapID];		break;
//		case TAPSTATE_USEITEM_TOPOS:	[self onTap_USeItemToPos:pt State:state ID:tapID];		break;
	}
	
	return true;
}

- (void)setOrder:(int)order
{
	if(order == ORDER_TAKEBACK)
	{
		GobHvM_Player *player;
		for(int i = 0; i < [_listPlayerMach childCount]; i++)
		{
			player = (GobHvM_Player *)[_listPlayerMach childAtIndex:i];
			float len = _topPlayerPos - player.pos.y;
			if(player.hp > 0 && player.machType == MACHTYPE_BIPOD && len < 120)
			{
				[player setDestPosX:player.pos.x Y:_topPlayerPos - 80 - len * .8f];
				[player setMoveToTarget:false];
				[player setIsOrder:true];
			}
		}
	}
}

- (GobHvM_Player *)addPlayerMachWithParts:(TMachBuildParts *)parts X:(float)x Y:(float)y
{
	GobHvM_Player *mach = [[GobHvM_Player alloc] init];
	mach.layer = VLAYER_MIDDLE;
	[mach setPosX:x Y:y];
	[_listPlayerMach addChild:mach];
	mach.state = MACHSTATE_STOP;
	mach.hp = mach.hpMax = parts->armor.param1;
	[mach setStepSize:parts->foot.param1 * _deviceScale];
	[mach setParts:@"DummyParts" partsType:PARTS_BASE];
	[mach setParts:parts->foot.strParam partsType:PARTS_FOOT];
	[mach setParts:parts->armor.strParam partsType:PARTS_BODY];
	[mach setParts:parts->weapon.strParam partsType:PARTS_WPN];
	[mach setDir:M_PI/2.f];
	[mach setRadius:parts->size * _deviceScale];
	return mach;
}

- (GobHvM_Player *)addPlayerMachWithName:(const char *)machName X:(float)x Y:(float)y
{
	GobHvM_Player *mach = [[GobHvM_Player alloc] init];
	mach.layer = VLAYER_MIDDLE;
	[mach setPosX:x Y:y];
	[_listPlayerMach addChild:mach];
	mach.state = MACHSTATE_STOP;
	[mach makeMachFromName:machName];
	[mach setDir:M_PI/2.f];
	
	return mach;
}


- (GobHvM_Enemy *)addEnemyMach:(const char *)machName X:(float)x Y:(float)y
{
	GobHvM_Enemy *enemy = [[GobHvM_Enemy alloc] init];
	enemy.layer = VLAYER_BACK;
	[enemy makeMachFromName:machName];
	[enemy setPosX:x Y:y];
	[enemy setDir:-M_PI / 2.f];
	enemy.state = MACHSTATE_STOP;

	[_listEnemy addChild:enemy];
	
	return enemy;
}

- (GobHvM_Bot *)addBot:(const char *)botName X:(float)x Y:(float)y
{
	GobHvM_Bot *bot = [[GobHvM_Bot alloc] init];
	bot.layer = VLAYER_FORE;
	[bot makeMachFromName:botName];
	[bot setPosX:x Y:y];
	bot.state = MACHSTATE_STOP;
	
	[_listBot addChild:bot];
	
	return bot;
}

- (GobEnemySpawner *)addEnemySpawner:(TSpawnInfo *)info
{
	GobEnemySpawner *spawner = [[GobEnemySpawner alloc] initWithSpawnInfo:info];
	[_objectBase addChild:spawner];
	
	return spawner;
}

- (void)setAirstrike:(ItemInfo *)item To:(CGPoint)pos
{
	GobAirStrike *airStrike = [[GobAirStrike alloc] initWithItem:item];
	[airStrike setAttackPosX:pos.x Y:pos.y];
	[_objectBase addChild:airStrike];
	[airStrike setLayer:VLAYER_FOREMOST];
}

- (int)setCrossfire:(ItemInfo *)item To:(CGPoint)pos
{
	WeaponInfo *weapon = [GINFO getWeaponInfo:[NSString stringWithFormat:@"%@_%02d", item.strParam, (int)item.param1]];
	if(weapon == nil) return 0;

	int attackerCnt = 0;
	GobHvM_Player *player;
	for(int i = 0; i < [_listPlayerMach childCount]; i++)
	{
		player = (GobHvM_Player *)[_listPlayerMach childAtIndex:i];
		if(player != nil && player.hp > 0 && player.machType == MACHTYPE_BIPOD && player.pos.y < pos.y)
		{
			float len = (pos.x - player.pos.x) * (pos.x - player.pos.x) + (pos.y - player.pos.y) * (pos.y - player.pos.y);
			if(len > 10000 && len <= weapon.shotRange * weapon.shotRange)
			{
				[player setSpAttack:weapon To:pos];
				attackerCnt++;
			}
		}
	}
	
	QobParticle *particle = [GWORLD getFreeParticle];
	if(particle)
	{
		Tile2D *tile = [TILEMGR getTileForRetina:@"Target.png"];
		[tile tileSplitX:2 splitY:1];
		
		[particle setBlendType:BT_ADD];
		[particle setLiveTime:attackerCnt > 0 ? 3.f : .5f];
		[particle setTile:tile tileNo:0];
		[particle setPosX:pos.x Y:pos.y];
		[particle setScale:15.f];
		[particle setEasyOutScale:1.5f];
		[particle setEasyOutValue:6.f];
		[particle setRotVel:.1f];
		[particle start];
	}
	
	if(attackerCnt > 0) [SOUNDMGR play:[GINFO sfxID:SND_AIRSTRIKE]];
	else [SOUNDMGR play:[GINFO sfxID:SND_LOWHP]];

	return attackerCnt;
}

- (void)killEnemy:(GobHvM_Enemy *)enemy
{
	if(enemy.isBase) [self onClearStage];
		
	GobHvM_Player *player;
	for(int i = 0; i < [_listPlayerMach childCount]; i++)
	{
		player = (GobHvM_Player *)[_listPlayerMach childAtIndex:i];
		if(player != nil && player.target == enemy)
		{
			[player setTarget:nil];
			[player setMoveToTarget:false];
		}
	}

	GobHvM_Bot *bot;
	for(int i = 0; i < [_listBot childCount]; i++)
	{
		bot = (GobHvM_Bot *)[_listBot childAtIndex:i];
		if(bot == nil) continue;
		
		if(bot.target == enemy)
		{
			[bot setTarget:nil];
			[bot setMoveToTarget:false];
		}
	}
	
	GVAL.killEnemies++;
    GVAL.giveDamage += enemy.hpMax;
}

- (void)killPlayer:(GobHvM_Player *)player
{
	if(player.isBase) [self setGameOver];

	GobHvM_Enemy *enemy;
	for(int i = 0; i < [_listEnemy childCount]; i++)
	{
		enemy = (GobHvM_Enemy *)[_listEnemy childAtIndex:i];
		if(enemy != nil && enemy.target == player)
		{
			[enemy setTarget:nil];
			[enemy setMoveToTarget:false];
		}
	}
	
	GobFieldItem *item;
	for(int i = 0; i < [_listItem childCount]; i++)
	{
		item = (GobFieldItem *)[_listItem childAtIndex:i];
		if(item != nil) [item pickerDead:player];
	}
	
	GVAL.deadMachs++;
    GVAL.getDamage += player.hpMax;
}

- (QobParticle *)getFreeParticle
{
	for(int i = 0; i < MAX_PARTICLE; i++)
	{
		if(!_particleBuffer[i].isShow)
		{
			[_particleBuffer[i] reset];
			return _particleBuffer[i];
		}
	}
	
	return nil;
}

- (void)clearAllObject
{
//	[_listZonePlayer removeAllObjects];
	
	if(_objectBase != nil) [_objectBase remove];
	
	_objectBase = nil;
	_listPlayerMach = nil;
	_listEnemy = nil;
	_listBot = nil;
	_listMapObject = nil;
	_imgBG = nil;
	
	for(int x = 0; x < 4; x++)
	{
		for(int y = 0; y < 16; y++)
		{
			if(_listColVector[y][x]) [_listColVector[y][x] release];
			_listColVector[y][x] = nil;
		}
	}
	
	_difficultInfo.diffTimeA = 0;
	_difficultInfo.diffTimeB = 0;
	_difficultInfo.diffScale = .3f;
	_difficultInfo.checkTime = 0;
	_difficultInfo.genTimeMin = 10;
	_difficultInfo.genTimeMax = 20;
	_difficultInfo.rndTimeMin = 15;
	_difficultInfo.rndTimeMax = 30;

	for(int i = 0; i < 5; i++)
	{
		for(int j = 0; j < _diffSpawn[i].spawnInfoCount; j++)
		{
			free(_diffSpawn[i].listSpawnInfo[j]);
			_diffSpawn[i].listSpawnInfo[i] = NULL;
		}
		_diffSpawn[i].spawnInfoCount = 0;
		_diffSpawn[i].diffSum = 0;
	}
	
	[_colList removeAllObjects];
	[_partsMgr clear];
}

- (void)refreshWorldObject
{
/*	for(int i = 0; i < 32 * 8; i++)
	{
		ZoneManager *zoneMgr = [[ZoneManager alloc] init];
		[_listZonePlayer addObject:zoneMgr];
	}*/
	
	_objectBase = [[QobBase alloc] init];
	[self addChild:_objectBase];
	
	_listMapObject = [[QobBase alloc] init];
	[_objectBase addChild:_listMapObject];
	
	_listEnemy = [[QobBase alloc] init];
	[_objectBase addChild:_listEnemy];
	
	_listPlayerMach = [[QobBase alloc] init];
	[_objectBase addChild:_listPlayerMach];

	_listBot = [[QobBase alloc] init];
	[_objectBase addChild:_listBot];
	
	_listItem = [[QobBase alloc] init];
	[_objectBase addChild:_listItem];
	
	for(int i = 0; i < MAX_PARTICLE; i++)
	{
		_particleBuffer[i] = [[QobParticle alloc] init];
		[_particleBuffer[i] setShow:false];
		[_objectBase addChild:_particleBuffer[i]];
		_particleBuffer[i].layer = VLAYER_FORE;
	}
	
	for(int x = 0; x < 4; x++)
	{
		for(int y = 0; y < 16; y++)
		{
			_listColVector[y][x] = [[QList alloc] initWithUnitSize:3];
		}
	}
}

- (QList *)getColListFromPos:(const CGPoint *)pos 
{
	int x = (pos->x + _mapHalfLen * .25f) / _colUnitSize;
	int y = (pos->y + _mapHalfLen) / _colUnitSize;
	
	if(x < 0 || x >= 4 || y < 0 || y >= 16) return nil;
	return _listColVector[y][x];
}

- (void)addColVector:(const ColVector *)col
{
	float chkSize = 32 * _deviceScale;
	CGPoint chkOffest[4] = {{chkSize, chkSize}, {chkSize*3, chkSize}, {chkSize*3, chkSize*3}, {chkSize*3, chkSize}};
	CGPoint orgPos, chkPos;

	for(int x = 0; x < 4; x++)
	{
		for(int y = 0; y < 16; y++)
		{
			bool add = false;
			
			orgPos.x = x * _colUnitSize - _mapHalfLen * .25f;
			orgPos.y = y * _colUnitSize - _mapHalfLen;
			
			CGPoint pt = {col.origin.x, col.origin.y};
			if(pt.x >= orgPos.x-_colUnitSize*.5f && pt.x <= orgPos.x+_colUnitSize*1.5f && pt.y >= orgPos.y-_colUnitSize*.5f && pt.y <= orgPos.y+_colUnitSize*1.5f) add = true;

			pt.x += col.dir.x * col.length;
			pt.y += col.dir.y * col.length;
			if(pt.x >= orgPos.x-_colUnitSize*.5f && pt.x <= orgPos.x+_colUnitSize*1.5f && pt.y >= orgPos.y-_colUnitSize*.5f && pt.y <= orgPos.y+_colUnitSize*1.5f) add = true;
			
			for(int chk = 0; !add && chk < 4; chk++)
			{
				chkPos.x = orgPos.x + chkOffest[chk].x;
				chkPos.y = orgPos.y + chkOffest[chk].y;
				
				if([col checkCollide:&chkPos ColRadius:_colUnitSize] != 0.f) add = true;
			}
			
			if(add) [_listColVector[y][x] addData:(void *)col];
		}
	}
}

- (void)readColBox:(QChunk *)chunk
{
	void *data = chunk.data;
	int size = 0;
	
	CGPoint startPt, prevPt, curPt;
	ColVector *prevCol = nil;

	short jointCnt = *(short *)(data + size);		size += sizeof(short);
	for(int i = 0; i < jointCnt; i++)
	{
        float x,y;
        memcpy(&x, (data + size), 4); size += 4;
        memcpy(&y, (data + size), 4); size += 4;
		curPt.x = x;
		curPt.y = y;
		
		[QVector vector:&curPt Mul:_deviceScale];
		
		if(i == 0)
		{
			startPt = curPt;
		}
		else
		{
			ColVector *col = [[ColVector alloc] initWithOrigin:&prevPt Second:&curPt];
			[col setPrev:prevCol];
			[_colList addObject:col];
			[col release];
			[self addColVector:col];
			if(prevCol != nil) [prevCol setNext:col];

			prevCol = col;

			if(i == jointCnt - 1)
			{
				col = [[ColVector alloc] initWithOrigin:&curPt Second:&startPt];
				[col initWithOrigin:&curPt Second:&startPt];
				[col setPrev:prevCol];
				[_colList addObject:col];
				[col release];
				[self addColVector:col];
				if(prevCol != nil) [prevCol setNext:col];
			}
		}
		
		prevPt = curPt;
	}
}

- (void)readSpawner:(QChunk *)chunk
{
	void *pData = chunk.data;
	int dataPos = sizeof(short);
	
	char *machName = pData + dataPos;						dataPos += 16;
	short x = *(short *)(pData + dataPos);					dataPos += sizeof(short);
	short y = *(short *)(pData + dataPos);					dataPos += sizeof(short);
	
	[self addEnemyMach:machName X:x * _deviceScale Y:y * _deviceScale];
	//	[_partsMgr addMach:machName];
}


- (bool)openMap:(int)stage
{
	[self refreshWorldObject];
	
	Tile2D *tile;
	NSString *mapId = [NSString stringWithFormat:@"%d", stage + 1];
	NSString *mapName = [GINFO getMapName:mapId];
	
	if(_glView.deviceType == DEVICE_IPHONE)
    {
        tile = [_tileResMgr getTile:[NSString stringWithFormat:@"iPon_%@_01.jpg", mapName]];
    }
	else
    {
        tile = [_tileResMgr getTileForRetina:[NSString stringWithFormat:@"%@_01.jpg", mapName]];
    }
	[tile tileSplitX:1 splitY:1];
	QobImage *img = [[QobImage alloc] initWithTile:tile tileNo:0];
	[img setFixedPos:true];
	[img setPosY:-512 * _deviceScale];
	[_listMapObject addChild:img];
	[img setLayer:VLAYER_BG];
	QobImage *bg = img;

	if(_glView.deviceType == DEVICE_IPHONE) tile = [_tileResMgr getTile:[NSString stringWithFormat:@"iPon_%@_02.jpg", mapName]];
	else tile = [_tileResMgr getTileForRetina:[NSString stringWithFormat:@"%@_02.jpg", mapName]];
	[tile tileSplitX:1 splitY:1];
	img = [[QobImage alloc] initWithTile:tile tileNo:0];
	[img setFixedPos:true];
	[img setPosY:1024 * _deviceScale];
	[bg addChild:img];
	[img setLayer:VLAYER_BG];

	QChunk *mapChunk = [GINFO getMapInfo:mapId];
//	strcpy(GSLOT->placeName, mapChunk.data + 24);
	for(int i = 0; i < mapChunk.subCount; i++)
	{
		QChunk *chunk = [mapChunk getSubChunk:i];
		switch(chunk.type)
		{
			case MCNK_COLBOX:		[self readColBox:chunk];		break;
			case MCNK_SPAWNER:		[self readSpawner:chunk];		break;
		}
	}

	NSMutableArray *genMachList = [[NSMutableArray alloc] init];
	NSString *fileName = [NSString stringWithFormat:@"ESpawn_%02d", stage + 1];
	QTable *table = [[QTable alloc] initWithFile:[[NSBundle mainBundle] pathForResource:fileName ofType:@"tbl"]];
	for(int i = 0; i < table.row; i++)
	{
		NSString *machName = [table getString:i Key:@"MachName"];
		if(machName != nil)
		{
			int level = [table getInt:i Key:@"Dif"];
			TSpawnInfo *spawnInfo = (TSpawnInfo *)malloc(sizeof(TSpawnInfo));
			strcpy(spawnInfo->machName, [machName UTF8String]);
			spawnInfo->regenCount = [table getInt:i Key:@"Cnt"];
			spawnInfo->regenDelay = [table getInt:i Key:@"Dly"];
			
			if(level > 0 && level <= 5)					// 난이도 테이블
			{
				level--;
				if(_diffSpawn[level].spawnInfoCount < 32)
				{
					int rate = [table getInt:i Key:@"Rte"];
					
					spawnInfo->startTime = -1;
					_diffSpawn[level].diffSum += rate;
					spawnInfo->rate = _diffSpawn[level].diffSum;
					
					_diffSpawn[level].listSpawnInfo[_diffSpawn[level].spawnInfoCount] = spawnInfo;
					_diffSpawn[level].spawnInfoCount++;
				}
			}
			else										// 강제 리젠 테이블
			{
				spawnInfo->startTime = (float)(level / 100) * 60.f + (float)(level % 100);
				[self addEnemySpawner:spawnInfo];
				free(spawnInfo);
			}
			
			if(![genMachList containsObject:machName]) [genMachList addObject:machName];

//			[_partsMgr addMach:spawnInfo->machName];
		}
	}
	NSArray *sortList = [genMachList sortedArrayUsingSelector:@selector(compare:)];
	[genMachList release];
	
	float reserveTime = 0.f, reserveTimeMin = 90.f, reserveTimeRange = 30.f;
	float reserveAdd = MAX(5.f, (60.f - stage));
	int stageValue = MIN(5000, (2000 + stage * 10));
	int sortCnt = MIN(4, (int)sortList.count), cntMin = sortList.count - sortCnt;

	for(int gen = 0; gen < 7; gen++)
	{
		int reservePower = 6000 + stage * stageValue + gen * (int)((float)stageValue * .6f), genCount;
		int tmpPower = reservePower, genPower, odd = 0;

		reserveTime += reserveTimeMin + RANDOMF(reserveTimeRange);
		reserveTimeMin += reserveAdd;
		reserveTimeRange += 10.f;

		for(int i = sortList.count - 1; i >= cntMin; i--)
		{
			NSString *machName = [sortList objectAtIndex:i];
			MachInfo *info = [GINFO getMachInfo:machName];
			genPower = MIN(tmpPower, (int)((float)reservePower / (float)sortCnt) + odd);
			if(info && info.hp <= genPower)
			{
				TSpawnInfo *spawnInfo = (TSpawnInfo *)malloc(sizeof(TSpawnInfo));
				strcpy(spawnInfo->machName, [machName UTF8String]);
				genCount = genPower / info.hp;
				spawnInfo->regenCount = genCount;
				spawnInfo->regenDelay = 2.f + RANDOMF(2.f);
				spawnInfo->startTime = reserveTime + RANDOMF(5.f);
				[self addEnemySpawner:spawnInfo];
				
				tmpPower -= info.hp * genCount;
				genPower -= info.hp * genCount;
			}
			odd = genPower;
		}
	}

//	[_partsMgr bakePartsTiles];
//	[_partsMgr loadPartsTiles];

	return true;
}

- (ResMgr_Tile *)tileResMgr
{
	return _tileResMgr;
}

- (void)clearTileResMgr
{
	[QOBMGR removeAllAtlas];
	[_tileResMgr removeAllTiles];
}

@end
