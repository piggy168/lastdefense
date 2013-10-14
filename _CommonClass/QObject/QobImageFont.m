//
//  QobImageFont.m
//  BPop
//
//  Created by 엔비 on 08. 10. 26.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "QobImageFont.h"


@implementation QobImageFont

@synthesize num=_num, pitch=_pitch, blendType=_blendType;

- (id)initWithTile:(Tile2D *)tile
{
	[super init];
	
	_visual = true;
	_tile = tile;
	_num = 0;
	_numCnt = 0;
	_alignRate = 0.f;
	
	_boundCheck = false;
	_pitch = _tile.tileWidth;
	if(_tile.forRetina) _pitch *= .5f;
	
	_blendType = BT_NORMAL;
	
	_boundRect.origin.x = -_tile.tileWidth / 2.f;
	_boundRect.origin.y = -_tile.tileHeight / 2.f;
	_boundRect.size.width = _tile.tileWidth / 2.f;
	_boundRect.size.height = _tile.tileHeight / 2.f;
	
	return self;
}

- (void)setPitch:(float)pitch
{
	_pitch = pitch;
	if(_tile.forRetina) _pitch *= .5f;	
}

- (void)setAlignRate:(float)rate
{
	_alignRate = rate;
}

- (void)setNumber:(int)num
{
	QobImage *img;
	
	if(_listNum)
	{
		[_listNum remove];
		_listNum = nil;
	}
	
	_listNum = [[QobBase alloc] init];
	[self addChild:_listNum];

	_num = num;
	_numCnt = 0;
	
	num = abs(num);
	
	do
	{
		img = [[QobImage alloc] initWithTile:_tile tileNo:num % 10];
		[img setUseAtlas:true];
		[img setBlendType:_blendType];
		[img setPosX:-_numCnt*_pitch*_scaleX];
		[_listNum addChild:img];
//		_tileList[_numCnt++] = num % 10;
		num /= 10;
		_numCnt++;
	} while(num > 0);
	
	if(_numCnt == 0)
	{
		_numCnt = 1;
		_tileList[0] = 0;
	}

	[_listNum setPosX:_pitch * _scaleX * (_numCnt - 1) * (1.f - _alignRate)];
}

- (void)setBlendType:(int)type
{
	QobImage *img;
	_blendType = type;
	
	int numCnt = [_listNum childCount];
	for(int i = 0; i < numCnt; i++)
	{
		img = (QobImage *)[_listNum childAtIndex:i];
		if(img) [img setBlendType:type];
	}
}

- (void)setText:(char *)text
{
	QobImage *img;

	if(_listNum)
	{
		[_listNum remove];
		_listNum = nil;
	}
	
	_listNum = [[QobBase alloc] init];
	[self addChild:_listNum];

	_numCnt = strlen(text);
	for(int i = _numCnt-1; i >= 0; i--)
	{
		img = [[QobImage alloc] initWithTile:_tile tileNo:0];
		[img setUseAtlas:true];
		[img setBlendType:_blendType];
		[img setPosX:i*_pitch*_scaleX];
		[_listNum addChild:img];
		
		if(text[i] >= '0' && text[i] <= '9') [img setTileNo:text[i] - '0'];
		else if(text[i] == '.') [img setTileNo:10];
		else if(text[i] == '/') [img setTileNo:11];
		else if(text[i] == ':') [img setTileNo:12];
		else if(text[i] == '-') [img setTileNo:13];
		else if(text[i] == '%') [img setTileNo:14];
		else if(text[i] == '*') [img setTileNo:15];
		else [img setShow:false];
/*		if(text[i] >= '0' && text[i] <= '9') _tileList[_numCnt - i - 1] = text[i] - '0';
		else if(text[i] == '.') _tileList[_numCnt - i - 1] = 10;
		else if(text[i] == '/') _tileList[_numCnt - i - 1] = 11;
		else if(text[i] == ':') _tileList[_numCnt - i - 1] = 12;
		else if(text[i] == '-') _tileList[_numCnt - i - 1] = 13;
		else if(text[i] == '%') _tileList[_numCnt - i - 1] = 14;
		else if(text[i] == '*') _tileList[_numCnt - i - 1] = 15;
		else _tileList[_numCnt - i - 1] = -1;*/
	}
	
	[_listNum setPosX:_pitch * _scaleX * (_numCnt - 1) * (1.f - _alignRate)];
}

- (float)getNumWidth
{
	return _numCnt * _pitch;
}

- (void)setBoundCheck:(bool)bCheck
{
	_boundCheck = bCheck;
}

- (void)tick
{
	if(_calcScaleX != _scaleX || _calcScaleY != _scaleY)
	{
		QobBase *img;
		
		[_listNum setPosX:_pitch * _scaleX * (_numCnt - 1) * (1.f - _alignRate)];
		int numCnt = [_listNum childCount];
		for(int i = 0; i < numCnt; i++)
		{
			img = [_listNum childAtIndex:i];
			if(img)
			{
				[img setScaleX:_scaleX];
				[img setScaleY:_scaleY];
				[img setPosX:-i*_pitch*_scaleX];
			}
		}
		
		_calcScaleX = _scaleX;
		_calcScaleY = _scaleY;
	}
	
	[super tick];
}

/*- (void)draw
{
	if(_numCnt <= 0) return;
	
	float start = -(_pitch * _scaleX * (_numCnt - 1) * _alignRate) + SCRPOS_X;
	if(_boundCheck)
	{
		if(start < _pitch * _scaleX / 2.f) start = _pitch * _scaleX / 2.f;
		if(start + _pitch * _scaleX * (_numCnt - 1) > 320.f) start = 320.f - _pitch * _scaleX * (_numCnt - 1);
	}
	
	for(int i = 0; i < _numCnt; i++)
	{
		if(_tileList[_numCnt-1-i] != -1) [_tile drawTile:_tileList[_numCnt-1-i] x:start+i*_pitch*_scaleX y:SCRPOS_Y blendType:_blendType alpha:_alpha scaleX:_scaleX scaleY:_scaleY rotate:0.f];
	}
}*/

@end
