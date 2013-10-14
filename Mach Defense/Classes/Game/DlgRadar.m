//
//  DlgRader.m
//  HeavyMach2
//
//  Created by 엔비 on 09. 12. 07.
//  Copyright 2009 (주)인디앱스. All rights reserved.
//

#import "DlgRadar.h"
#import "GobHvMach.h"
#import "TextureAtlas.h"
#import "QobLine.h"

@implementation DlgRadar

- (id)init
{
	[super init];

	_visual = true;
	_mapScale = 64.f / 512.f;
	
	if(_glView.deviceType != DEVICE_IPAD)
	{
		Tile2D *tile = [TILEMGR getTileForRetina:@"RaderBG.png"];
		QobImage *img = [[QobImage alloc] initWithTile:tile tileNo:0];
		[img setPosY:.5f];
		[self addChild:img];
	}

	_tileMark = [TILEMGR getTileForRetina:@"RaderMark.png"];
	[_tileMark tileSplitX:8 splitY:1];
	_imgMark = [[QobImage alloc] initWithTile:_tileMark tileNo:0];
	[_imgMark setLayer:VLAYER_UI];
	
	Tile2D *tile = [TILEMGR getTile:@"MovePath.png"];
	for(int i = 0; i < 4; i++)
	{
		_camLine[i] = [[QobLine alloc] initWithTile:tile tileNo:0];
		[_camLine[i] initTexWidth:2 Len:16 MaxBlocks:8];
		[_camLine[i] setBlendType:BT_ADD];
		[_camLine[i] setShow:true];
		[self addChild:_camLine[i]];
	}
	
	return self;
}

- (void)dealloc
{
	[_imgMark release];
	[super dealloc];
}

- (void)tick
{
	[super tick];
}

- (void)setCamBottom:(float)bottom Top:(float)top
{
	float width = 32.f * GWORLD.deviceScale;
	bottom *= _mapScale;
	top *= _mapScale;
	bottom = (int)(bottom + 1.f);
	top = (int)(top + 1.f);
	
	[_camLine[0] setLineX1:-width Y1:bottom X2:width Y2:bottom];
	[_camLine[1] setLineX1:-width Y1:top X2:width Y2:top];
	[_camLine[2] setLineX1:-width Y1:top X2:-width Y2:bottom];
	[_camLine[3] setLineX1:width Y1:top X2:width Y2:bottom];
}

- (void)drawMapMark:(int)tileNo X:(float)x Y:(float)y
{
	TQuadInfo *quad = [QOBMGR getMyAtlasQuad:_imgMark];
	if(quad != NULL)
	{
		float ww = _tileMark.w, hh = _tileMark.h;
		if(_tileMark.forRetina)
		{
			ww *= .5f;
			hh *= .5f;
		}
		
		if(tileNo >= _tileMark.tileCnt) tileNo = _tileMark.tileCnt - 1;
		
		int tx = tileNo % _tileMark.splitX;
		int ty = tileNo / _tileMark.splitX;
		float u = _tileMark.u, v = _tileMark.v;
		
		quad->bl.vertices.x = x - ww;			quad->bl.vertices.y = y - hh;
		quad->br.vertices.x = x + ww;			quad->br.vertices.y = y - hh;
		quad->tl.vertices.x = x - ww;			quad->tl.vertices.y = y + hh;
		quad->tr.vertices.x = x + ww;			quad->tr.vertices.y = y + hh;
		
		quad->bl.coords.u = tx * u;
		quad->bl.coords.v = ty * v + v;
		
		quad->br.coords.u = tx * u + u;
		quad->br.coords.v = ty * v + v;
		
		quad->tl.coords.u = tx * u;
		quad->tl.coords.v = ty * v;
		
		quad->tr.coords.u = tx * u + u;
		quad->tr.coords.v = ty * v;
		
		quad->bl.colors.r = 255;
		quad->bl.colors.g = 255;
		quad->bl.colors.b = 255;
		quad->bl.colors.a = 255;
		quad->br.colors.r = 255;
		quad->br.colors.g = 255;
		quad->br.colors.b = 255;
		quad->br.colors.a = 255;
		quad->tl.colors.r = 255;
		quad->tl.colors.g = 255;
		quad->tl.colors.b = 255;
		quad->tl.colors.a = 255;
		quad->tr.colors.r = 255;
		quad->tr.colors.g = 255;
		quad->tr.colors.b = 255;
		quad->tr.colors.a = 255;
	}
}

- (void)draw
{
	float x = SCRPOS_X, y = SCRPOS_Y, xx, yy;
	
	GobHvMach *mach;
	for(int i = 0; i < [GWORLD.listPlayer childCount]; i++)
	{
		mach = (GobHvMach *)[GWORLD.listPlayer childAtIndex:i];
		if(mach != nil)
		{
			xx = mach.pos.x * _mapScale;
			yy = mach.pos.y * _mapScale;
			if(yy >= -128.f && yy <= 128.f) [self drawMapMark:mach.isBase ? 2 : 0 X:x + xx Y:y + yy]; //[_tileMark drawTile:mach.isBase ? 2 : 0 x:x + xx y:y + yy];
		}
	}

	for(int i = 0; i < [GWORLD.listEnemy childCount]; i++)
	{
		mach = (GobHvMach *)[GWORLD.listEnemy childAtIndex:i];
		if(mach != nil)
		{
			xx = mach.pos.x * _mapScale;
			yy = mach.pos.y * _mapScale;
			if(yy >= -128.f && yy <= 128.f) [self drawMapMark:mach.isBase ? 3 : 1 X:x + xx Y:y + yy];
		}
	}
}

@end
