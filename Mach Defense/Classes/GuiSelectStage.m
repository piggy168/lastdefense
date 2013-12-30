//
//  GuiSelectStage.m
//  MachDefense
//
//  Created by HaeJun Byun on 10. 12. 6..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GuiSelectStage.h"


@implementation GuiSelectStage

- (id)init
{
	[super init];
	[self setUiReceiver:true];
    
	_tileResMgr = [[ResMgr_Tile alloc] init];
	
	Tile2D *tile = nil;
	QobImage *img = nil;
	QobButton *btn = nil;
	
	if(_glView.deviceType == DEVICE_IPAD)
	{
		_btnHeight = 100;
		_topLimit = 260;
		_btmLimit = 270;
	}
	else
	{
		_btnHeight = 50;
		_topLimit = 120;
		_btmLimit = 125;
	}
	
	[SOUNDMGR playBGM:@"UI_BGM.mp3"];
	
	/*	img = [[QobImage alloc] initWithTile:g_main.loadingImg tileNo:0];
	 [img setPosX:240 Y:160];
	 [self addChild:img];*/
	
	tile = [_tileResMgr getUniTile:@"SelSlot_BG.jpg"];
	img = [[QobImage alloc] initWithTile:tile tileNo:0];
	[img setPosX:_glView.surfaceSize.width/2 Y:_glView.surfaceSize.height/2];
	[img setLayer:VLAYER_BG];
	[self addChild:img];
	
	_buttonBase = [[QobBase alloc] init];
	[_buttonBase setLayer:VLAYER_FORE];
//	[_buttonBase setPosY:0];
	[img addChild:_buttonBase];
	
	tile = [_tileResMgr getUniTile:@"SelStage_Fore.png"];
	img = [[QobImage alloc] initWithTile:tile tileNo:0];
	[img setPosX:_glView.surfaceSize.width/2 Y:_glView.surfaceSize.height/2];
	[img setLayer:VLAYER_UI];
	[self addChild:img];
	
	for(int i = 0; i < GSLOT->lastStage + 11; i++)
	{
		if(i >= MAX_STAGE) continue;
		tile = [_tileResMgr getTileForRetina:@"selStage_btn.png"];
		[tile tileSplitX:1 splitY:3];
		btn = [[QobButton alloc] initWithTile:tile TileNo:0 ID:BTNID_SELSTAGE];
		if(i > GSLOT->lastStage)
		{
			[btn setDefaultTileNo:2];
			[btn setReleaseTileNo:2];
			[btn setDeactiveTileNo:2];
		}
		else
		{
			[btn setReleaseTileNo:1];
			[btn setDeactiveTileNo:2];
		}

       // NSString *mapId = [NSString stringWithFormat:@"%d", i + 1];
        CGPoint btnPos = [GINFO getMapPositionFromIndex:i];
		[btn setIntData:i];
//		[btn setBoundWidth:80 Height:40];
		[btn setPosX:btnPos.x Y:btnPos.y];
		[_buttonBase addChild:btn];

        /*
		QobText *text = [[QobText alloc] initWithString:[NSString stringWithFormat:@"Stage %d", i + 1] Size:CGSizeMake(256, 42) Align:UITextAlignmentLeft Font:@"TrebuchetMS-Bold" FontSize:32 Retina:true];
		if(i > GSLOT->lastStage) [text setColorR:10 G:10 B:10];
		else  [text setColorR:10 G:255 B:255];
		if(_glView.deviceType == DEVICE_IPAD) [text setPosX:-40];
		else [text setPosX:-10];
		[btn addChild:text];

		NSString *mapId = [NSString stringWithFormat:@"%d", i + 1];
		NSString *mapName = [GINFO getMapName:mapId];
		
		tile = [_tileResMgr getTileForRetina:[NSString stringWithFormat:@"t%@_01.png", mapName]];
		[tile tileSplitX:1 splitY:1];
		QobImage *img = [[QobImage alloc] initWithTile:tile tileNo:0];
		[img setFixedPos:true];
		if(_glView.deviceType == DEVICE_IPAD) [img setPosX:77];
		else [img setPosX:38];
		[btn addChild:img];
		
		tile = [_tileResMgr getTileForRetina:[NSString stringWithFormat:@"t%@_02.png", mapName]];
		[tile tileSplitX:1 splitY:1];
		img = [[QobImage alloc] initWithTile:tile tileNo:0];
		[img setFixedPos:true];
		if(_glView.deviceType == DEVICE_IPAD) [img setPosX:173];
		else [img setPosX:86];
		[btn addChild:img];

		if(i < GSLOT->lastStage)
		{
			tile = [_tileResMgr getTileForRetina:@"CompleteMark.png"];
			[tile tileSplitX:1 splitY:1];
			img = [[QobImage alloc] initWithTile:tile tileNo:0];
			[img setFixedPos:true];
			[img setPosX:160];
			[btn addChild:img];
		}
*/
		if(i == GSLOT->lastStage) _camPos = i * _btnHeight;
	}

#ifdef _LITE_VERSION_
	tile = [_tileResMgr getTileForRetina:@"BuyFullVersion.png"];
	[tile tileSplitX:1 splitY:4];
	btn = [[QobButton alloc] initWithTile:tile TileNo:0 ID:BTNID_BUYFULLVERSION];
	[btn setReleaseTileNo:1];
	[btn setDeactiveTileNo:2];
	[btn setPosX:0 Y:7.2f * -_btnHeight];
	[_buttonBase addChild:btn];
#endif

	tile = [_tileResMgr getTileForRetina:@"Common_Btn_BACK.png"];
	[tile tileSplitX:1 splitY:2];
	btn = [[QobButton alloc] initWithTile:tile TileNo:0 ID:BTNID_BACK];
	[btn setReleaseTileNo:1];
	[btn setBoundWidth:80 Height:40];
	if(_glView.deviceType == DEVICE_IPAD) [btn setPosX:224 Y:80];
	else [btn setPosX:80 Y:30];
	[btn setLayer:VLAYER_UI];
	[self addChild:btn];
	
	tile = [_tileResMgr getTileForRetina:@"Common_Btn_OK.png"];
	[tile tileSplitX:1 splitY:4];
	_btnFight = [[QobButton alloc] initWithTile:tile TileNo:0 ID:BTNID_OK];
	[_btnFight setReleaseTileNo:1];
	[_btnFight setBoundWidth:80 Height:40];
	if(_glView.deviceType == DEVICE_IPAD) [_btnFight setPosX: 544 Y:80];
	else [_btnFight setPosX: 240 Y:30];
	[_btnFight setLayer:VLAYER_UI];
	[_buttonBase addChild:_btnFight];
    _btnFight.visual = NO;
	
	_sel = 3;//GSLOT->lastStage;
    NSLog(@"lastStage %d", GSLOT->lastStage);
    CGPoint pos = [GINFO getMapPosition:[NSString stringWithFormat:@"%d", GSLOT->lastStage-1]];
    _lastPosition = pos.y;
	
	tile = [_tileResMgr getTileForRetina:@"SelStage_Btn_Stage.png"];
	[tile tileSplitX:1 splitY:4];
	_imgSel = [[QobImage alloc] initWithTile:tile tileNo:3];
	[_imgSel setPosY:-_sel * _btnHeight];
	[_buttonBase addChild:_imgSel];

	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:self selector:@selector(handleButton:) name:@"PushButton" object:nil];
	[nc addObserver:self selector:@selector(handleButton:) name:@"MoveButton" object:nil];
	[nc addObserver:self selector:@selector(handleButton:) name:@"PopButton" object:nil];
	[nc addObserver:self selector:@selector(handleButton:) name:@"CancelButton" object:nil];
	
	return self;
}

- (void)dealloc
{
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc removeObserver:self];
	
	[_tileResMgr removeAllTiles];
	[_tileResMgr release];
	
	[super dealloc];
}

- (void)tick
{
	float y = _buttonBase.pos.y;
	float lowerLimit = fabs(_btmLimit + _lastPosition);
//    if(GSLOT->lastStage < 5) lowerLimit -= [GINFO getMapPositionFromIndex:GSLOT->lastStage-1].y;
//	else lowerLimit = _lastPosition;
	if(_dragPos == 0.f && _dragVel != 0.f)
	{
		EASYOUTE(_dragVel, 0.0f, 10.f, .1f);
		_camPos += _dragVel;
	}
	if(_camPos < _topLimit) EASYOUTE(_camPos, _topLimit, 5.f, .1f);
	if(_camPos > lowerLimit) EASYOUTE(_camPos, lowerLimit, 5.f, .1f);
	EASYOUTE(y, _camPos, 5.f, .1f);
	[_buttonBase setPosY:y];
	
	[super tick];
}

- (void)handleButton:(NSNotification *)note
{
	QobButton *button = [note object];
	if(button == nil) return;
	
	if([[note name]isEqualToString:@"PushButton"])
	{
		if(button.buttonId == BTNID_SELSTAGE)
		{
			_dragPos = button.tapPos.y;
//			[SOUNDMGR play:[GINFO sfxID:SND_MENU_CLICK]];
		}
	}
	else if([[note name]isEqualToString:@"MoveButton"])
	{
		if(button.buttonId == BTNID_SELSTAGE)
		{
			_dragVel = button.tapPos.y - _dragPos;
			_dragPos = button.tapPos.y;
			
			_camPos += _dragVel;
		}
	}
	else if([[note name]isEqualToString:@"CancelButton"])
	{
		if(button.buttonId == BTNID_SELSTAGE)
		{
			_dragVel = button.tapPos.y - _dragPos;
			_dragPos = 0;
		}
	}
	else if([[note name]isEqualToString:@"PopButton"])
	{
		if(button.buttonId == BTNID_OK)
		{
			GSLOT->stage = _sel;
			[g_main changeScreen:GSCR_GAME];
			[SOUNDMGR play:[GINFO sfxID:SND_BTN_OK]];
		}
		else if(button.buttonId == BTNID_BACK)
		{
			[g_main changeScreen:GSCR_SELECTSLOT];
			[SOUNDMGR play:[GINFO sfxID:SND_BTN_OK]];
		}
		else if(button.buttonId == BTNID_SELSTAGE)
		{
			if(button.intData <= GSLOT->lastStage)
			{
				_sel = button.intData;
				//[_imgSel setPosY:-_sel * _btnHeight];
                _btnFight.visual = YES;
                CGPoint pos = [GINFO getMapPositionFromIndex:_sel];
                [_btnFight setPosX:pos.x Y:pos.y+_btnHeight];
				[SOUNDMGR play:[GINFO sfxID:SND_BTN_OK]];
			}
		}
		else if(button.buttonId == BTNID_BUYFULLVERSION)
		{
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://itunes.apple.com/us/app/mach-defense/id409754707?mt=8"]];
			[SOUNDMGR play:[GINFO sfxID:SND_BTN_OK]];
		}
	}
}

- (BOOL)onTap:(CGPoint)pt State:(int)state ID:(id)tapID
{
    if(state == TAP_START)
    {
        _dragPos = pt.y;
        _btnFight.visual = NO;
    }
    else if(state == TAP_MOVE)
    {
        _dragVel = pt.y - _dragPos;
        _dragPos = pt.y;
        
        _camPos += _dragVel;
    }
    else if(state == TAP_END)
    {
        _dragVel = pt.y - _dragPos;
        _dragPos = 0;
    }
    
    return true;
}


@end
