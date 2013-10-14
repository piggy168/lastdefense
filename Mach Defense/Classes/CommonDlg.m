//
//  CommonDlg.m
//  MachDefense
//
//  Created by HaeJun Byun on 10. 11. 22..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CommonDlg.h"


@implementation CommonDlg

- (id)initWithCommonImg:(NSString *)commonImg TopImg:(NSString *)topImg Height:(float)height
{
	[super init];
	
	_height = height;
	
	Tile2D *tile = [TILEMGR getTileForRetina:[NSString stringWithFormat:@"%@_Mid.png", commonImg]];
	_bgMid = [[QobImage alloc] initWithTile:tile tileNo:0];
	[_bgMid setScaleY:height / (64.f * GWORLD.deviceScale)];
	[self addChild:_bgMid];
	
	if(topImg != nil) tile = [TILEMGR getTileForRetina:[NSString stringWithFormat:@"%@_%@.png", commonImg, topImg]];
	if(tile == nil) tile = [TILEMGR getTileForRetina:[NSString stringWithFormat:@"%@_Top.png", commonImg]];
	_bgTop = [[QobImage alloc] initWithTile:tile tileNo:0];
	[_bgTop setPosY:32 * GWORLD.deviceScale + (height / 2.f)];
	[self addChild:_bgTop];
	
	tile = [TILEMGR getTileForRetina:[NSString stringWithFormat:@"%@_Btm.png", commonImg]];
	_bgBtm = [[QobImage alloc] initWithTile:tile tileNo:0];
	[_bgBtm setPosY:-32 * GWORLD.deviceScale - (height / 2.f)];
	[self addChild:_bgBtm];
	
	return self;
}

- (void)setHeight:(float)height
{
	_height = height;
	
	[_bgTop setPosY:32 * GWORLD.deviceScale + (height / 2.f)];
	[_bgMid setScaleY:height / (64.f * GWORLD.deviceScale)];
	[_bgBtm setPosY:-32 * GWORLD.deviceScale - (height / 2.f)];
}

- (void)setScale:(float)scale
{
	[super setScale:scale];
	float height = _height * scale;

	[_bgTop setScale:scale];
	[_bgTop setPosY:(32 * scale) + (height / 2.f)];
	[_bgMid setScaleX:scale];
	[_bgMid setScaleY:height / 64.f];
	[_bgBtm setScale:scale];
	[_bgBtm setPosY:(-32 * scale) - (height / 2.f)];
}

- (QobButton *)addButton:(Tile2D *)tile ID:(unsigned int)buttonID
{
	QobButton *btn = [[QobButton alloc] initWithTile:tile TileNo:0 ID:buttonID];
	[btn setReleaseTileNo:1];
	[btn setPosX:(136-_buttonCount*128) * GWORLD.deviceScale Y:16 * GWORLD.deviceScale];
	[_bgBtm addChild:btn];
	
	_buttonCount++;
	
	return btn;
}

@end
