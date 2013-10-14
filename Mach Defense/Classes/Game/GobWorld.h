//
//  GobMap.h
//  HeavyMach
//
//  Created by 엔비 on 08. 11. 08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "GobEnemySpawner.h"

@class ColVector;
@class QobLine;
@class GobHvM_Player;
@class GobHvM_Enemy;
@class GobHvM_Bot;
@class GobBullet;
@class GobTrailEffect;
@class PartsManager;

enum EnumMapChunkType
{
	MCT_MAP, MCT_DUMMY1,
	MCT_MAPSIZE,
	MCT_COLLIST, MCT_DUMMY2,
	MCT_JOINTLIST, MCT_JOINT,
	MCT_OBJECTLIST, MCT_OBJECT,
	MCT_BGNAME,
	MCT_ENEMYLIST, MCT_ENEMY,
};

enum EnumLoadingStep
{
	LOADSTEP_STAGECLEAR, LOADSTEP_GAMEOVER, LOADSTEP_LOADBG, LOADSTEP_CLEAROBJECTS, LOADSTEP_CLEARTILEMGR, LOADSTEP_LOADMAP, LOADSTEP_FADEIN, LOADSTEP_COMPLETE
};

enum EnumGameState
{
	GSTATE_PLAY, GSTATE_CLEARSTAGE, GSTATE_GAMEOVER
};

enum EnumTapState
{
	TAPSTATE_NORMAL, TAPSTATE_USEITEM_TOMACH, TAPSTATE_USEITEM_TOPOS
};

enum EnumOrderType
{
	ORDER_TAKEBACK
};

struct TDifficultInfo
{
	float diffTimeA, diffTimeB;
	float diffScale, difficult;
	float checkTime;
	float genTimeMin, genTimeMax, rndTimeMin, rndTimeMax;
};
typedef struct TDifficultInfo TDifficultInfo;

struct TDifficultSpawn
{
	TSpawnInfo *listSpawnInfo[32];
	int spawnInfoCount;
	int diffSum;
};
typedef struct TDifficultSpawn TDifficultSpawn;

@interface GobWorld : QobBase <UIAccelerometerDelegate>
{
	ResMgr_Tile *_tileResMgr;
	PartsManager *_partsMgr;
	
	double _gameTime;
	float _deviceScale, _mapLen, _mapHalfLen, _colUnitSize;
	float _leftUIPos, _rightUIPos;
	bool _isSave;
	int _gameState;
	float _changeStateTime, _stageStartTime;
	bool _pause;
	short _tapState;
//	ItemInfo *_useItem;

	QobBase *_objectBase;
	QobBase *_listPlayerMach;
	QobBase *_listEnemy;
	QobBase *_listBot;
	QobBase *_listItem;
	QobBase *_listMapObject;
	
	GobHvM_Player *_baseMach;
	
//	NSMutableArray *_listZonePlayer;
	
	id _controlCamTap, _mapMoveTap;
	float _camPos, _camTapPos, _camCenter, _camBottomMargin, _camVel;
	bool _onlyTap, _onCamTop, _onCamBottom;
	QobImage *_imgBG;
	
	CGPoint _radarPos;
	CGSize _radarSize;
	
	QobParticle *_particleBuffer[MAX_PARTICLE];
	NSMutableArray *_colList;
	QList *_listColVector[16][4];
	
	TDifficultInfo _difficultInfo;
	TDifficultSpawn _diffSpawn[5];
	float _enemyRegenTime;
	float _mrIncTime;
	
	int _killCount;
	float _topPlayerPos;
}

@property(readonly) int state;
@property(readonly) double time;
@property(readonly) float stageStartTime, deviceScale, mapHalfLen;
@property(readwrite) bool pause, isSave;
@property(readwrite) int killCount;
@property(readwrite) float topPlayerPos;
@property(readonly) QobBase *objectBase;
@property(readonly) QobBase *listEnemy, *listPlayer, *listBot;
@property(readonly) QobBase *listItem;
@property(readonly) GobHvM_Player *baseMach;
@property(readonly) NSMutableArray *colList;
@property(readonly) PartsManager *partsMgr;

- (void)setGameState:(short)state;
- (void)setUIPos:(float)pos;

- (void)setStage:(int)stage;
- (void)setGameOver;
- (void)setNextStage;
- (void)onClearStage;

- (void)setOrder:(int)order;

- (GobHvM_Player *)addPlayerMachWithParts:(TMachBuildParts *)parts X:(float)x Y:(float)y;
- (GobHvM_Player *)addPlayerMachWithName:(const char *)machName X:(float)x Y:(float)y;
- (GobHvM_Enemy *)addEnemyMach:(const char *)machName X:(float)x Y:(float)y;
- (GobHvM_Bot *)addBot:(const char *)botName X:(float)x Y:(float)y;

- (GobEnemySpawner *)addEnemySpawner:(TSpawnInfo *)info;
- (void)setAirstrike:(ItemInfo *)item To:(CGPoint)pos;
- (int)setCrossfire:(ItemInfo *)item To:(CGPoint)pos;

- (void)setTargetPos:(CGPoint)pos;

//- (void)useItem:(ItemInfo *)item;
- (void)killEnemy:(GobHvM_Enemy *)enemy;
- (void)killPlayer:(GobHvM_Player *)player;

- (QobParticle *)getFreeParticle;

- (QList *)getColListFromPos:(const CGPoint *)pos;
- (void)addColVector:(const ColVector *)col;

- (void)clearAllObject;
- (void)refreshWorldObject;

- (bool)openMap:(int)stage;

- (ResMgr_Tile *)tileResMgr;
- (void)clearTileResMgr;

//- (void)handleButton:(NSNotification *)note;

@end
