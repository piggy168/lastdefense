//
//  QobImage.m
//  BPop
//
//  Created by 엔비 on 08. 10. 26.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "QobImage.h"

@implementation QobImage

@synthesize tile=_tile, blendType=_blendType, reverse=_reverse, tileNo=_tileNo;

- (id)initWithTile:(Tile2D *)tile tileNo:(unsigned int)tileNo
{
	[super init];
	
	_blendType = BT_NORMAL;
	
	_visual = true;
	_tile = tile;
	_tileNo = tileNo;
	_reverse = false;
	
	_boundRect.origin.x = -tile.tileWidth / 2.f;
	_boundRect.origin.y = -tile.tileHeight / 2.f;
	_boundRect.size.width = tile.tileWidth / 2.f;
	_boundRect.size.height = tile.tileHeight / 2.f;
	
	return self;
}

- (void)tick
{
	if(_useAtlas && _show && _isInScreen && _tile)
	{
		TQuadInfo *quad = [QOBMGR getMyAtlasQuad:self];
		if(quad != NULL)
		{
			float x = SCRPOS_X, y = SCRPOS_Y;
			float sx = _scaleX, sy = _scaleY;
			if(_tile.forRetina)
			{
				sx *= .5f;
				sy *= .5f;
			}
			float ww = _tile.w * sx, hh = _tile.h * sy;
			
			if(_reverse & REVERSE_H) ww = -ww;
			if(_reverse & REVERSE_V) hh = -hh;
			
			if(_tileNo >= _tile.tileCnt) _tileNo = _tile.tileCnt - 1;
			
			int tx = _tileNo % _tile.splitX;
			int ty = _tileNo / _tile.splitX;
			float u = _tile.u, v = _tile.v;
			
			if(_rotate != 0.f)
			{
				float x1 = -ww + _tile.originX * sx, y1 = -hh + _tile.originY * sy;
				float x2 = ww + _tile.originX * sx, y2 = hh + _tile.originY * sy;
				float cr = cosf(_rotate), sr = sinf(_rotate);
				float ax = x1 * cr - y1 * sr + x;
				float ay = x1 * sr + y1 * cr + y;
				float bx = x2 * cr - y1 * sr + x;
				float by = x2 * sr + y1 * cr + y;
				float cx = x2 * cr - y2 * sr + x;
				float cy = x2 * sr + y2 * cr + y;
				float dx = x1 * cr - y2 * sr + x;
				float dy = x1 * sr + y2 * cr + y;
				
				quad->bl.vertices.x = ax;				quad->bl.vertices.y = ay;
				quad->br.vertices.x = bx;				quad->br.vertices.y = by;
				quad->tl.vertices.x = dx;				quad->tl.vertices.y = dy;
				quad->tr.vertices.x = cx;				quad->tr.vertices.y = cy;
			}
			else
			{
				quad->bl.vertices.x = x - ww;			quad->bl.vertices.y = y - hh;
				quad->br.vertices.x = x + ww;			quad->br.vertices.y = y - hh;
				quad->tl.vertices.x = x - ww;			quad->tl.vertices.y = y + hh;
				quad->tr.vertices.x = x + ww;			quad->tr.vertices.y = y + hh;
			}
			
			quad->bl.coords.u = tx * u;
			quad->bl.coords.v = ty * v + v;
			
			quad->br.coords.u = tx * u + u;
			quad->br.coords.v = ty * v + v;
			
			quad->tl.coords.u = tx * u;
			quad->tl.coords.v = ty * v;
			
			quad->tr.coords.u = tx * u + u;
			quad->tr.coords.v = ty * v;
			
			unsigned char colorR = _tile.colorR * 255, colorG = _tile.colorG * 255, colorB = _tile.colorB * 255;
			quad->bl.colors.r = colorR;
			quad->bl.colors.g = colorG;
			quad->bl.colors.b = colorB;
			quad->bl.colors.a = _alpha * 255;
			quad->br.colors.r = colorR;
			quad->br.colors.g = colorG;
			quad->br.colors.b = colorB;
			quad->br.colors.a = _alpha * 255;
			quad->tl.colors.r = colorR;
			quad->tl.colors.g = colorG;
			quad->tl.colors.b = colorB;
			quad->tl.colors.a = _alpha * 255;
			quad->tr.colors.r = colorR;
			quad->tr.colors.g = colorG;
			quad->tr.colors.b = colorB;
			quad->tr.colors.a = _alpha * 255;
		}
	}
	
	[super tick];
}

- (float)tileWidth
{
	if(_tile == nil) return 0;
	return _tile.tileWidth;
}

- (void)setTile:(Tile2D *)tile tileNo:(unsigned int)tileNo
{
	_tile = tile;
	_tileNo = tileNo;
	
	_boundRect.origin.x = -tile.tileWidth / 2.f;
	_boundRect.origin.y = -tile.tileHeight / 2.f;
	_boundRect.size.width = tile.tileWidth / 2.f;
	_boundRect.size.height = tile.tileHeight / 2.f;
}

- (void)setTileNo:(unsigned int)tileNo
{
	_tileNo = tileNo;
}

- (void)setUseAtlas:(BOOL)use
{
	_useAtlas = use;
}

- (void)draw
{
	if(_tile != nil || !_remove) [_tile drawTile:_tileNo x:SCRPOS_X y:SCRPOS_Y blendType:_blendType alpha:_alpha scaleX:_scaleX scaleY:_scaleY rotate:_rotate reverse:_reverse];
}

@end
