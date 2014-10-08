//
//  DlgSystemMenu.m
//  HeavyMach2
//
//  Created by 엔비 on 09. 11. 12.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "DlgSystemMenu.h"


@implementation DlgSystemMenu

#define THUMB_POS	-76
#define THUMB_SIZE	260.f

- (id)init
{
	[super initWithCommonImg:@"SysMenu" TopImg:@"half" Height:384 * GWORLD.deviceScale];
	
	_thumbPos = THUMB_POS * GWORLD.deviceScale;
	_thumbSize = THUMB_SIZE * GWORLD.deviceScale;
    
    QobText *title_text = [[QobText alloc] initWithString:@"OPTION" Size:CGSizeMake(360, 26) Align:UITextAlignmentCenter Font:@"TrebuchetMS-Bold" FontSize:26 Retina:true];
    [title_text setColorR:255 G:255 B:255];
    [title_text setPosX:20 Y:58];
    [_bgMid addChild:title_text];
	
	float vol = 0.8f;
	QobButton *btn;
	int btnID[5] = { BTNID_RESUME_GAME, BTNID_SAVE_EXIT, BTNID_VISIT_INDIEAPPS, BTNID_HELP, BTNID_LEADERBOARD};
	NSString *btnName[2] = {@"Resume Game", @"Exit Game"};

	Tile2D *tile = [TILEMGR getTileForRetina:@"SysMenu_Btn.png"];
	[tile tileSplitX:1 splitY:2];
	for(int i = 0; i < 2; i++)
	{
		btn = [[QobButton alloc] initWithTile:tile TileNo:0 ID:btnID[i]];
		[btn setReleaseTileNo:1];
		[btn setPosY:(50 - i * 60.f) * GWORLD.deviceScale];
		[btn setBoundWidth:480 * GWORLD.deviceScale Height:48 * GWORLD.deviceScale];
		[_bgMid addChild:btn];
		
		QobText *text = [[QobText alloc] initWithString:btnName[i] Size:CGSizeMake(360, 24) Align:UITextAlignmentCenter Font:@"TrebuchetMS-Bold" FontSize:20 Retina:true];
		[text setColorR:140 G:240 B:255];
		[btn addChild:text];
	}
	
	tile = [TILEMGR getTileForRetina:@"VolOption.png"];
	[tile tileSplitX:1 splitY:2];
	QobImage *img = [[QobImage alloc] initWithTile:tile tileNo:0];
	[img setPosX:-4 * GWORLD.deviceScale Y:-66 * GWORLD.deviceScale];
	[_bgMid addChild:img];
	
	img = [[QobImage alloc] initWithTile:tile tileNo:1];
	[img setPosX:-4 * GWORLD.deviceScale Y:-112 * GWORLD.deviceScale];
	[_bgMid addChild:img];
	
	if(GSLOT != NULL) vol = GSLOT->bgmVol;
	tile = [TILEMGR getTileForRetina:@"VolOption_Thumb.png"];
	[tile tileSplitX:1 splitY:1];
	btn = [[QobButton alloc] initWithTile:tile TileNo:0 ID:BTNID_THUMB_BGM];
	[btn setPosX:(_thumbPos + vol * _thumbSize ) * GWORLD.deviceScale Y:-66 * GWORLD.deviceScale];
	[btn setBoundWidth:64 * GWORLD.deviceScale Height:46 * GWORLD.deviceScale];
	[_bgMid addChild:btn];
	[btn setLayer:VLAYER_UI];
	_btnBgmVol = btn;
	
	if(GSLOT != NULL) vol = GSLOT->sfxVol;
	btn = [[QobButton alloc] initWithTile:tile TileNo:0 ID:BTNID_THUMB_SFX];
	[btn setPosX:(_thumbPos + vol * _thumbSize ) * GWORLD.deviceScale Y:-112 * GWORLD.deviceScale];
	[btn setBoundWidth:64 * GWORLD.deviceScale Height:46 * GWORLD.deviceScale];
	[_bgMid addChild:btn];
	[btn setLayer:VLAYER_UI];
	_btnSfxVol = btn;

	tile = [TILEMGR getTileForRetina:@"Common_Btn_CLOSE.png"];
	[tile tileSplitX:1 splitY:2];
	[self addButton:tile ID:BTNID_RESUME_GAME];

	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:self selector:@selector(handleButton:) name:@"PushButton" object:nil];
	[nc addObserver:self selector:@selector(handleButton:) name:@"MoveButton" object:nil];
	[nc addObserver:self selector:@selector(handleButton:) name:@"PopButton" object:nil];
	
	return self;
}

- (void)dealloc
{
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc removeObserver:self];
	
	[super dealloc];
}

- (void)setShow:(bool)show
{
	[super setShow:show];
	
	if(show)
	{
		[_btnBgmVol setPosX:_thumbPos + GSLOT->bgmVol * _thumbSize];
		[_btnSfxVol setPosX:_thumbPos + GSLOT->sfxVol * _thumbSize];
	}
}

- (void)handleButton:(NSNotification *)note
{
	if(![self isShow]) return;
	
	QobButton *button = [note object];
	if(button == nil) return;
	
	if([[note name]isEqualToString:@"PopButton"])
	{
	}
	else if([[note name]isEqualToString:@"MoveButton"])
	{
		float x = button.tapPos.x - (_glView.surfaceSize.width / 2 + _pos.x);
		if(x < _thumbPos) x = _thumbPos;
		if(x > _thumbPos+_thumbSize) x = _thumbPos+_thumbSize;
		
		if(button.buttonId == BTNID_THUMB_BGM)
		{
			GSLOT->bgmVol = (x-_thumbPos)/_thumbSize;
			[button setPosX:x];
			[SOUNDMGR setBGMVolume:GSLOT->bgmVol];
		}
		else if(button.buttonId == BTNID_THUMB_SFX)
		{
			GSLOT->sfxVol = (x-_thumbPos)/_thumbSize;
			[button setPosX:x];
			[SOUNDMGR setSFXVolume:GSLOT->sfxVol];
		}
	}
}

@end
