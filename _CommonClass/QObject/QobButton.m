//
//  QUiButton.m
//  Jumping!
//
//  Created by 엔비 on 08. 09. 26.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "Tile2D.h"
#import "QobButton.h"

@implementation QobButton

@synthesize tile=_tile, buttonId=_id, pushDepth=_pushDepth, pushDelay=_pushDelay, releaseHeight=_releaseHeight, releaseDelay=_releaseDelay, dataObject=_dataObject, intData=_intData, tapPos=_tapPos;


- (id)initWithTile:(Tile2D *)tile TileNo:(unsigned int)n
{
	[super init];
	[self setUiReceiver:true];
	
	_visual = true;
	_tile = tile;
	_tileNo = n;
	_releaseTileNo = [tile tileCnt] > n + 1 ? n + 1 : n;
	_deactiveTileNo = n;
	_id = 0xffffffff;
	_tapID = nil;
	
	_pushDepth = 0.f;
	_pushDelay = 0.f;
	
	_releaseHeight = 0.f;
	_releaseDelay = 0.f;
	
	if(_tile != nil)
	{
		_boundRect.origin.x = -_tile.tileWidth / 2.f;
		_boundRect.origin.y = -_tile.tileHeight / 2.f;
		_boundRect.size.width = _tile.tileWidth / 2.f;
		_boundRect.size.height = _tile.tileHeight / 2.f;
		
		if(_tile.forRetina)
		{
			_boundRect.origin.x *= .5f;
			_boundRect.origin.y *= .5f;
			_boundRect.size.width *= .5f;
			_boundRect.size.height *= .5f;
		}
	}
	
	return self;
}

- (id)initWithTile:(Tile2D *)tile TileNo:(unsigned int)n ID:(unsigned int)buttonId
{
	[self initWithTile:tile TileNo:n];

	_id = buttonId;
	
	return self;
}

- (void)setTile:(Tile2D *)tile
{
	_tile = tile;
	if(_tile != nil)
	{
		_boundRect.origin.x = -_tile.tileWidth / 2.f;
		_boundRect.origin.y = -_tile.tileHeight / 2.f;
		_boundRect.size.width = _tile.tileWidth / 2.f;
		_boundRect.size.height = _tile.tileHeight / 2.f;
		
		if(_tile.forRetina)
		{
			_boundRect.origin.x *= .5f;
			_boundRect.origin.y *= .5f;
			_boundRect.size.width *= .5f;
			_boundRect.size.height *= .5f;
		}
	}
}

- (void)dealloc
{
	[super dealloc];
}

- (void)setBoundWidth:(float)width Height:(float)height
{
	_boundRect.origin.x = -width / 2.f * _scaleX;
	_boundRect.origin.y = -height / 2.f * _scaleX;
	_boundRect.size.width = width / 2.f * _scaleY;
	_boundRect.size.height = height / 2.f * _scaleY;
}

- (void)setDefaultTileNo:(unsigned int)n
{
	_tileNo = n;
}

- (void)setReleaseTileNo:(unsigned int)n
{
	_releaseTileNo = n;
}

- (void)setDeactiveTileNo:(unsigned int)n
{
	_deactiveTileNo = n;
}

- (void)setReleaseAction
{
	if(_uiState == UISTATE_NONE && _btnReleaseTime == 0) _btnReleaseTime = g_time;
}

- (void)tick
{
	if(!_show) return;
	[super tick];			// 수퍼클래스의 틱을 나중에 호출해 주어야 한다.
}

- (void)draw
{
	float offset = 0.f;
	double dt = 0;
	
	if(_btnClickTime != 0)
	{
		dt = g_time - _btnClickTime;
		if(dt < _pushDelay) offset = sinf(dt / _pushDelay * (M_PI / 2.f)) * _pushDepth;
		else offset = _pushDepth;
	}
	else if(_btnReleaseTime != 0)
	{
		dt = g_time - _btnReleaseTime;
		if(dt < _releaseDelay) offset = sinf(dt / _releaseDelay * M_PI * 2.f) * (_releaseHeight * (_releaseDelay - dt));
		else _btnReleaseTime = 0;
	}

	if(!_active)
	{
		[_tile drawTile:_deactiveTileNo x:SCRPOS_X y:SCRPOS_Y - offset blendType:BT_NORMAL alpha:_alpha scaleX:_scaleX scaleY:_scaleY rotate:_rotate];
	}
	else if(_uiState == UISTATE_CLICK)
	{
		[_tile drawTile:_releaseTileNo x:SCRPOS_X y:SCRPOS_Y - offset blendType:BT_NORMAL alpha:_alpha scaleX:_scaleX scaleY:_scaleY rotate:_rotate];
	}
	else
	{
		[_tile drawTile:_tileNo x:SCRPOS_X y:SCRPOS_Y + offset blendType:BT_NORMAL alpha:_alpha scaleX:_scaleX scaleY:_scaleY rotate:_rotate];
	}
}

- (BOOL)onTap:(CGPoint)pt State:(int)state ID:(id)tapID
{
	if(!_show || !_active) return false;
	
	bool bOn = false;
	float x = SCRPOS_X;
	float y = SCRPOS_Y;

	bOn = pt.x > x + _boundRect.origin.x && pt.x <= x + _boundRect.size.width && pt.y > y + _boundRect.origin.y && pt.y <= y + _boundRect.size.height;
	if(state == TAP_END && tapID == _tapID)
	{
		_uiState = UISTATE_NONE;
		
		_btnClickTime = 0;
		_tapID = nil;
		_tapPos = pt;

		if(bOn)
		{
			_btnReleaseTime = g_time;
			[[NSNotificationCenter defaultCenter] postNotificationName:@"PopButton" object:self];
		}
		else
		{
			[[NSNotificationCenter defaultCenter] postNotificationName:@"CancelButton" object:self];
		}
	}

	if(bOn)
	{
		if(state == TAP_START || _uiState != UISTATE_CLICK && state == TAP_MOVE && tapID == _tapID)
		{
			_btnClickTime = g_time;
			_btnReleaseTime = 0;
			_tapID = tapID;
			_uiState = UISTATE_CLICK;
			_tapPos = pt;

			[[NSNotificationCenter defaultCenter] postNotificationName:@"PushButton" object:self];
		}
		else
		{
			bOn = false;
		}
	}
	else if(tapID == _tapID)
	{
		_tapPos = pt;
		if(_uiState == UISTATE_CLICK)
		{
			_btnClickTime = 0;
			_btnReleaseTime = g_time;
			[[NSNotificationCenter defaultCenter] postNotificationName:@"ReleaseButton" object:self];
			
			_uiState = UISTATE_NONE;
		}
	}
	
	if(tapID == _tapID && state == TAP_MOVE)
	{
		_tapPos = pt;
		[[NSNotificationCenter defaultCenter] postNotificationName:@"MoveButton" object:self];
	}

	return bOn;
}


@end
