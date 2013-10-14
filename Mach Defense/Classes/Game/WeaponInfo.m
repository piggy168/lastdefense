//
//  WeaponInfo.m
//  HeavyMach
//
//  Created by 엔비 on 08. 12. 13.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "WeaponInfo.h"


@implementation WeaponInfo

@synthesize wpnType=_wpnType, dmg=_dmg, dmgRange=_dmgRange, shotRange=_shotRange, shotCnt=_shotCnt, shotDly=_shotDly, reloadDly=_reloadDly, spd=_spd, aimRate=_aimRate, spParam1=_spParam1, spParam2=_spParam2, uiTile=_uiTile, bulletTile=_bulletTile, bulletTileNo=_bulletTileNo, effectType=_effectType, effectTile=_effectTile, explodeTile=_explodeTile, explodeScale=_explodeSclae, shell=_shell, fireSFX=_fireSFX, atkPoint=_atkPoint;

- (void)setBulletTile:(Tile2D *)tile TileNo:(int)n
{
//	[tile tileSplitX:1 splitY:1];
	_bulletTile = tile;
	_bulletTileNo = n;
}

- (void)setEffectType:(short)type Tile:(Tile2D *)tile;
{
	[tile tileSplitX:1 splitY:1];
	_effectType = type;
	_effectTile = tile;
}

- (void)setExplodeTile:(Tile2D *)tile
{
	_explodeTile = tile;
}

- (void)calcAtkPoint
{
	float cycleDmg = _shotCnt * _dmg;
	float cycleTime = _shotCnt * _shotDly + _reloadDly;
	_atkPoint = 1.f / cycleTime * cycleDmg + .5f;
}

@end
