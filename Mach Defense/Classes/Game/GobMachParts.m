//
//  GobMachParts.m
//  HeavyMach
//
//  Created by 엔비 on 08. 12. 07.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "GobMachParts.h"
#import "GobHvMach.h"
#import "PartsManager.h"

@implementation GobMachParts

@synthesize scale=_scale, useBaseRot=_useBaseRot, baseSocket=_baseSocket, rotPos=_rotPos, addPos=_addPos, baseParts=_baseParts;

- (id)init
{
	[super init];
	
	_visual = true;
	_hvMach = nil;
	_partsInfo = nil;
	_baseParts = nil;
	_baseSocket = 0;
	_rotate = 0.f;
	_tileNo = 0;
	_scale = 1.f;
	_drawScale = 1.f;
	_useBaseRot = true;
	_reverse = 0;
	_prevRot = -1.f;
	_shadowLen = 4.f;
	_curMuzzle = 1;
	
	return self;
}

- (void)setHvMach:(GobHvMach *)mach
{
	_hvMach = mach;
	if(_hvMach.machType == MACHTYPE_AIRCRAFT || _hvMach.machType == MACHTYPE_BOT) _shadowLen = 10.f;
	
//	if(_hvMach.machType != MACHTYPE_BIPOD) 	
	if(!_hvMach.isBase && !_hvMach.uiModel) [self setUseAtlas:true];
	else [self setUseAtlas:false];
}

- (void)setPartsInfo:(PartsInfo *)partsInfo
{
	_partsInfo = partsInfo;
	NSString *partsTileName = [partsInfo getTileName];
	
	if(partsInfo.partsType == PARTS_FOOT) _shadowLen = 2.f;
	if(partsInfo.partsType == PARTS_PROP) _useBaseRot = false;

	if(partsInfo.tileCnt == 0)
	{
		_tile = [[GWORLD tileResMgr] getTile:@"PartsDummy.png"];
		[_tile tileSplitX:1 splitY:1];
	}
	else
	{
		PartsTile *partsTile = [[GWORLD partsMgr] getPartsTile:partsTileName];
		Tile2D *shadowTile;
		if(partsTile != nil)
		{
			_tile = partsTile.tile;
			_tileNo = partsTile.tileNo;
			shadowTile = partsTile.shadowTile;
		}
		else
		{
			_tile = [[GWORLD tileResMgr] getTile:partsTileName];
			if(_glView.deviceType != DEVICE_IPAD) [_tile setForRetina:YES];
			_tileNo = _partsInfo.tileNo;
			if(_partsInfo.useCommonTile)
			{
				if(_tile.splitX == 0 || _tile.splitY == 0)
				{
					for(int i = 0; i < GINFO.tileList.row; i++)
					{
						NSString *tileName = [GINFO.tileList getString:i Key:@"TileName"];
						if([tileName compare:partsTileName] == NSOrderedSame)
						{
							[_tile tileSplitX:[GINFO.tileList getInt:i Key:@"X"] splitY:[GINFO.tileList getInt:i Key:@"Y"]];
						}
					}
				}
			}
			else
			{
				[_tile tileSplitX:partsInfo.tileCnt splitY:1];
			}
			shadowTile = [[GWORLD tileResMgr] getAlphaTile:partsTileName];
			if(_glView.deviceType != DEVICE_IPAD) [shadowTile setForRetina:YES];
			[shadowTile tileSplitX:_tile.splitX splitY:_tile.splitY];
//			[shadowTile tileSplitX:partsInfo.tileCnt splitY:1];
		}
		
		[shadowTile setColorR:0 G:0 B:0];
		
		_imgShadow = [[QobImage alloc] initWithTile:shadowTile tileNo:_tileNo];
		[_imgShadow setPosX:_shadowLen * GWORLD.deviceScale Y:-_shadowLen * GWORLD.deviceScale];
		[_imgShadow setUseAtlas:true];
		[self addChild:_imgShadow];
		[_imgShadow setLayer:VLAYER_BG];
	}

	_boundRect.origin.x = -_tile.tileWidth / 2.f - [partsInfo getSocket:0]->x;
	_boundRect.origin.y = -_tile.tileHeight / 2.f - [partsInfo getSocket:0]->y;
	_boundRect.size.width = _tile.tileWidth / 2.f - [partsInfo getSocket:0]->x;
	_boundRect.size.height = _tile.tileHeight / 2.f - [partsInfo getSocket:0]->y;
	
//	[self refreshRotationPos];
}

- (PartsInfo *)getPartsInfo
{
	return _partsInfo;
}

- (float)getScale
{
	float scale = _scale;
	
	if(_baseParts != nil) scale *= [_baseParts getScale];
	
	return scale;
}

- (void)setChildParts:(GobMachParts *)child Socket:(unsigned char)socket
{
	[child setBaseParts:self Socket:socket];
	CGPoint pos = [self getSocketPos:0];
	pos.x *= _hvMach.scale;
	pos.y *= _hvMach.scale;
	_rotPos = pos;
}

- (void)setBaseParts:(GobMachParts *)base Socket:(unsigned char)socket
{
	_baseParts = base;
	_baseSocket = socket;
//	CGPoint pos = [self getSocketPos:0];
//	pos.x *= _hvMach.scale;
//	pos.y *= _hvMach.scale;
	_rotPos = [self getSocketPos:0];
	_basePos = [base getSocketPos:socket];
}

- (CGPoint)getSocketPos:(unsigned char)n
{
	CGPoint pos = {0, 0};

	if(_baseParts != nil)
	{
//		float scale = [_baseParts getScale] * _hvMach.scale;
		pos = [_baseParts getSocketPos:_baseSocket];
//		pos.x *= scale;
//		pos.y *= scale;
	}

	if(_partsInfo != nil)
	{
//		_drawScale = [self getScale] * _hvMach.scale;
		if([_partsInfo getSocket:0] != NULL)
		{
			CGPoint *base = [_partsInfo getSocket:0];
//			base.x *= _drawScale;
//			base.y *= _drawScale;
			if(n == 0)
			{
				pos.x -= base->x;
				if(_reverse) pos.y += base->y;
				else pos.y -= base->y;
			}
			else
			{
				CGPoint *pt = [_partsInfo getSocket:n];
				if(pt != NULL)
				{
					pos.x += pt->x - base->x;
					if(_reverse) pos.y -= pt->y - base->y;
					else pos.y += pt->y - base->y;
				}
			}
		}
	}
	
	return pos;
}

- (void)setNextMuzzle
{
	_curMuzzle++;
	if(_curMuzzle >= _partsInfo.socketCnt) _curMuzzle = 1;
}

- (CGPoint)getMuzzlePos
{
	CGPoint pos;
	if(_partsInfo.socketCnt < 2) return pos;
	
	CGPoint *pt = [_partsInfo getSocket:0];
	CGPoint *socketPos = [_partsInfo getSocket:_curMuzzle];
	if(_reverse)
	{
		pos.x = socketPos->x - pt->x;
		pos.y = -socketPos->y + pt->y;
	}
	else
	{
		pos.x = socketPos->x - pt->x;
		pos.y = socketPos->y - pt->y;
	}

	CGPoint retPos;
	CGPoint rotVec = { cosf(-_rotate), sinf(-_rotate) };
	retPos.x = _rotPos.x + [QVector vector:&rotVec Dot:&pos];
	retPos.y = _rotPos.y + [QVector vector:&rotVec Cross:&pos];
/*	float dir = atan2(pos.y, pos.x) + _rotate;
	float len = sqrt(pos.x * pos.x + pos.y * pos.y);
	pos.x = _rotPos.x + cosf(dir) * len;
	pos.y = _rotPos.y + sinf(dir) * len;
*/	
	return retPos;
}

- (void)setAddPosX:(float)x
{
	_addPos.x = x;
}

- (void)setAddPosY:(float)y
{
	_addPos.y = y;
}


- (void)refreshRotationPos
{
	float rot = _baseParts == nil ? _hvMach.rotate : _baseParts.rotate;
	if(_useBaseRot) _rotate = rot;
		
	CGPoint rotVec = { cosf(-rot), sinf(-rot) };
	CGPoint pos = { _basePos.x, _basePos.y };

	_rotPos.x = [QVector vector:&rotVec Dot:&pos];
	_rotPos.y = [QVector vector:&rotVec Cross:&pos];
	if(_addPos.x != 0 || _addPos.y != 0)
	{
//		CGPoint baseVec = { cosf(-_hvMach.rotate), sinf(-_hvMach.rotate) };
		CGPoint baseVec = { cosf(-_rotate), sinf(-_rotate) };
		_rotPos.x += [QVector vector:&baseVec Dot:&_addPos];
		_rotPos.y += [QVector vector:&baseVec Cross:&_addPos];
	}

	rotVec = CGPointMake(cosf(-_rotate), sinf(-_rotate));
	pos = *[_partsInfo getSocket:0];
	if(_reverse) pos.y = -pos.y;
	_rotPos.x -= [QVector vector:&rotVec Dot:&pos];
	_rotPos.y -= [QVector vector:&rotVec Cross:&pos];
//	float dir = atan2(pos.y, pos.x) + _rotate;
//	float len = sqrt(pos.x * pos.x + pos.y * pos.y);
//	_rotPos.x -= cos(dir) * len;
//	_rotPos.y -= sin(dir) * len;
		
	_prevRot = rot;
}

- (void)tick
{
	[self refreshRotationPos];
	[self setPosX:_rotPos.x Y:_rotPos.y];
	if(_partsInfo.partsType == PARTS_PROP)
	{
		_rotate += 0.2f;//fmod(g_time * .5f, M_PI * 2.f);
		if(_rotate > M_PI * 2.f) _rotate -= M_PI * 2.f;
	}
	
	_imgShadow.rotate = _rotate;
	_imgShadow.reverse = _reverse;
	
	[super tick];
}

@end
