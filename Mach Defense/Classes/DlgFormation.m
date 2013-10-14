//
//  DlgFormation.m
//  MachDefense
//
//  Created by HaeJun Byun on 11. 1. 17..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DlgFormation.h"


@implementation DlgFormation

- (id)init
{
	[super init];
	
	Tile2D *tile;
	QobImage *img;
	
	tile = [TILEMGR getTileForRetina:@"GameUI_MachSlot.png"];
	[tile tileSplitX:1 splitY:1];
	img = [[QobImage alloc] initWithTile:tile tileNo:0];
	[img setPosX:-71 Y:-352];
	[self addChild:img];
	
	tile = [TILEMGR getTileForRetina:@"SelMach.png"];
	[tile tileSplitX:1 splitY:1];
	img = [[QobImage alloc] initWithTile:tile tileNo:0];
	[img setShow:false];
	[img setBlendType:BT_ADD];
	[img setLayer:VLAYER_UI];
	[self addChild:img];
	_imgSelFormation = img;
	
//	[self setSelAttack:nil];
	
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:self selector:@selector(handleButton:) name:@"PushButton" object:nil];
	[nc addObserver:self selector:@selector(handleButton:) name:@"ReleaseButton" object:nil];
	[nc addObserver:self selector:@selector(handleButton:) name:@"PopButton" object:nil];
	
	return self;
}

- (void)dealloc
{
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc removeObserver:self];
	
	[super dealloc];
}

- (void)refreshButtons
{
	Tile2D *tile;
	QobButton *btn;
//	QobImage *img;
//	QobText *text;
	float basePos = _glView.deviceType == DEVICE_IPAD ? 0 : -176;
	
	[_imgSelFormation setShow:false];
	
	if(_buttons) [_buttons remove];
	_buttons = [[QobBase alloc] init];
	[self addChild:_buttons];
	
	_btnCnt = 0;
	for(int i = 0; i < 5; i++)
	{
		tile = [TILEMGR getTileForRetina:[NSString stringWithFormat:@"FormationIcon_%02d.png", i + 1]];
		[tile tileSplitX:1 splitY:1];
		btn = [[QobButton alloc] initWithTile:tile TileNo:0 ID:BTNID_SPATTACK_SELATTACK];
		[btn setReleaseTileNo:0];
		[btn setIntData:i];
		[btn setPosX:_glView.deviceType == DEVICE_IPAD ? 1 : -35 Y:basePos];
		[_buttons addChild:btn];
		
		tile = [TILEMGR getTileForRetina:@"Btn_BuildMach.png"];
		[tile tileSplitX:1 splitY:1];
		QobImage *body = [[QobImage alloc] initWithTile:tile tileNo:1];
		[body setUseAtlas:TRUE];
		[body setPosX:-19 * GWORLD.deviceScale Y:-17 * GWORLD.deviceScale];
		[btn addChild:body];
		
/*		text = [[QobText alloc] initWithString:[NSString stringWithFormat:@"%d", set.count] Size:CGSizeMake(64, 16) Align:UITextAlignmentCenter Font:@"TrebuchetMS-Bold" FontSize:13 Retina:true];
		[text setLayer:VLAYER_FOREMOST];
		[text setColorR:240 G:255 B:255];
		[text setPosX:0 Y:-42 * GWORLD.deviceScale];
		[btn addChild:text];
*/		
		basePos -= 102.f * GWORLD.deviceScale;
		_btnCnt++;
	}
}

- (void)handleButton:(NSNotification *)note
{
	if(![self isShow]) return;
	
	QobButton *button = [note object];
	if(button == nil) return;
	
	if([[note name]isEqualToString:@"PushButton"])
	{
	}
	else if([[note name]isEqualToString:@"PopButton"])
	{
	}
}

@end
