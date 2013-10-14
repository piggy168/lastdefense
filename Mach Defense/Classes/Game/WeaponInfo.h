//
//  WeaponInfo.h
//  HeavyMach
//
//  Created by 엔비 on 08. 12. 13.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

enum EWeaponType
{
	WPN_NORMAL, WPN_SHOTGUN, WPN_LASER, WPN_RAILGUN, WPN_EMP, WPN_BOMB, WPN_MISSILE, WPN_SNIPER, WPN_NUCLEAR, WPN_BULLET, WPN_BACKUP, WPN_ASM, WPN_MORTAL
};

enum EBulletEffectType
{
	BULLETEFF_NONE, BULLETEFF_NORMAL, BULLETEFF_FLAME, BULLETEFF_ION, BULLETEFF_SMOKE, BULLETEFF_SMOKETRAIL, BULLETEFF_LASER, BULLETEFF_RAILGUN, BULLETEFF_SHOTGUN
};

@interface WeaponInfo : NSObject
{
	short _wpnType;						// 무기타입
	short _dmg;							// 대미지
	short _dmgRange;					// 범위공격의 경우 대미지 범위
	short _shotRange;					// 사정거리
	unsigned char _shotCnt;				// 탄수
	float _shotDly;						// 연발 딜레이
	float _reloadDly;					// 재장전 딜레이
	float _spd;							// 탄속
	float _aimRate;						// 조준력
	float _spParam1, _spParam2;
	Tile2D *_bulletTile;				// 총알 이미지 타일
	int _bulletTileNo;					// 총알 이미지 타일번호
	short _effectType;					// 이펙트 타입 (normal, smoke, etc...)
	Tile2D *_effectTile;				// 이펙트 이미지 타일
	Tile2D *_explodeTile;				// 폭파 애니메이션 타일
	float _explodeSclae;				// 폭파애니메이션 스케일
	short _shell;						// 탄피 종류
	UInt32 _fireSFX;					// 발사 효과음
	unsigned char _uiTile;				// UI에 표시되는 타일
	
	int _atkPoint;						// 공격력
}

@property(readwrite) short wpnType, dmg, dmgRange, shotRange;
@property(readwrite) unsigned char shotCnt;
@property(readwrite) float shotDly, reloadDly;
@property(readwrite) float spd, aimRate, explodeScale, spParam1, spParam2;
@property(readonly) Tile2D *bulletTile;
@property(readonly) int bulletTileNo;
@property(readwrite) short effectType;
@property(readonly) Tile2D *effectTile, *explodeTile;
@property(readwrite) short shell;
@property(readwrite) UInt32 fireSFX;
@property(readwrite) unsigned char uiTile;
@property(readonly) int atkPoint;

- (void)setBulletTile:(Tile2D *)tile TileNo:(int)n;
- (void)setEffectType:(short)type Tile:(Tile2D *)tile;
- (void)setExplodeTile:(Tile2D *)tile;
- (void)calcAtkPoint;

@end
