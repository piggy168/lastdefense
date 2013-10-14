//
//  ObjectHvMach.h
//  HeavyMachinery
//
//  Created by 엔비 on 08. 10. 21.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

enum EMachState
{
	MACHSTATE_STOP, MACHSTATE_MOVE, MACHSTATE_CRASH, MACHSTATE_DESTROYED, MACHSTATE_CLEARSTAGE, MACHSTATE_MODEL
};

enum EWalkStep
{
	EWALK_STOP, EWALK_CALCPOS, EWALK_FOOTCHANGE, EWALK_MOVESTEP, EWALK_TURN
};

#define SPSTATUS_PLASMA		1
#define SPSTATUS_STUN		2

@class QVisualLayer;
@class GobWorld;
@class GobMachParts;
@class GobBullet;
@class ColVector;
@class SpDamageInfo;

struct TMoveInfo
{
	bool blocked;					// 진행방향이 막혀있는가?
	CGPoint destPos;				// 움직일 목표점
	char walkStep;					// 걷기모드 단계
	char walkFoot;					// 현재 움직이고 있는 발
	float stepLen;					// 움직인 스탭 크기
	float moveLen;					// 실제 몸통 좌표 이동시킨 크기
	float stepSize;					// 스탭 사이즈
	GobMachParts *curStep;			// 현재 걷는 발 파츠
	GobMachParts *elseStep;			// 반대쪽 발 파츠
};
typedef struct TMoveInfo TMoveInfo;

@interface GobHvMach : QobBase
{
	MachInfo *_info;
	bool _uiModel;
	BOOL _isBase;
	
//	QVisualLayer *_layer;
	QList *_partsList;
	short _machState;
	unsigned char _machType;
	NSString *_machName;
	bool _enemy;

	NSMutableDictionary *_listSpStatus;
	unsigned int _spStatusFlag;
	
	GobMachParts *_partsBase;
	GobMachParts *_partsBtm;
	GobMachParts *_partsFootL;
	GobMachParts *_partsFootR;
	GobMachParts *_partsBody;
	GobMachParts *_partsWpnL;
	GobMachParts *_partsWpnR;
	GobMachParts *_partsProp;
	
	int _hp, _hpMax, _atkPoint, _spdPoint;
	unsigned int _spAttackFlag;

	float _scale, _speed, _moveSpeed, _rotSpeed;
	float _targetRange, _radius;
	CGPoint _dashVel, _dashPos;
	CGPoint _dir;
	
	ColVector *_currentCol;
	ColVector *_prevCol;
	bool _weaponReady;

	TMoveInfo _moveInfo;
	
	bool _moveToTarget;
	GobHvMach *_target;
	float _targetCheckTime;
	float _attackCheckTime;
	float _collideCheckTime;
	float _spDmgCheckTime;
	float _crashTime;
}

@property(readonly) MachInfo *info;
@property(readonly) NSString *name;
@property(readonly) unsigned int spStatusFlag;
@property(readwrite) float scale, rotSpeed;
@property(readwrite) int hp, hpMax, atkPoint, spdPoint;
@property(readwrite) unsigned char machType;
@property(readwrite) float speed, radius, targetRange;
@property(readwrite) short state;
@property(readonly) TMoveInfo moveInfo;
@property(readwrite) bool enemy, moveToTarget, weaponReady, uiModel;
@property(readwrite) BOOL isBase;
@property(readonly) GobHvMach *target;

- (bool)isPlayer;

- (void)processMove;
- (void)processMove_Bipod;
- (void)processMove_Vehicle;
- (void)processMove_AirCraft;
- (void)processMove_Train;

- (void)processCrash;

- (void)bipodFootChange;

- (void)checkObjectCollide;
- (void)onCollideObject:(GobHvMach *)mach;

- (void)addSpDamage:(SpDamageInfo *)spDmg;

- (void)setTarget:(GobHvMach *)target;
- (void)setDestPosX:(float)x Y:(float)y;
- (void)setDir:(float)dir;
- (void)setDashVel:(CGPoint *)vel;
- (void)setStepSize:(float)len;

- (void)insertPartsToLayer:(GobMachParts *)parts;

- (GobMachParts *)addParts:(PartsInfo *)partsInfo;
- (GobMachParts *)addParts:(PartsInfo *)partsInfo BaseParts:(GobMachParts *)parts BaseSocket:(unsigned char)socket;
- (int)decodeChunk:(GobMachParts *)baseParts Data:(char *)data Pos:(int)pos;
- (bool)makeMachFromName:(const char *)machName;

//- (void)setLockon:(GobBullet *)missile;

- (void)useRepairItem:(ItemInfo *)item;
- (void)onDamage:(int)dmg From:(GobHvMach *)from;
- (void)onCrash;
- (void)onDestroy;
- (void)setMoveVel:(float)vel;

- (void)setCurrentCol:(ColVector *)col;

//- (float)getAheadAngle;


@end
