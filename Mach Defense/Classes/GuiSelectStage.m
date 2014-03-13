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
		_lowerLimit = 260;
		_btmLimit = 270;
	}
	else
	{
		_btnHeight = 50;
		_lowerLimit = _glView.surfaceSize.height/2+110/2;
		_btmLimit = 125;
	}
    
    _camPos = _lowerLimit;
	
	[SOUNDMGR playBGM:@"UI_BGM.mp3"];
    
    [self createWorldMap];

#ifdef _LITE_VERSION_
	tile = [_tileResMgr getTileForRetina:@"BuyFullVersion.png"];
	[tile tileSplitX:1 splitY:4];
	btn = [[QobButton alloc] initWithTile:tile TileNo:0 ID:BTNID_BUYFULLVERSION];
	[btn setReleaseTileNo:1];
	[btn setDeactiveTileNo:2];
	[btn setPosX:0 Y:7.2f * -_btnHeight];
	[_buttonBase addChild:btn];
#endif

	tile = [_tileResMgr getTileForRetina:@"worldmap_frame_menu.png"];
	[tile tileSplitX:1 splitY:1];
	btn = [[QobButton alloc] initWithTile:tile TileNo:0 ID:BTNID_BASE];
	[btn setReleaseTileNo:1];
//	[btn setBoundWidth:80 Height:40];
	if(_glView.deviceType == DEVICE_IPAD) [btn setPosX:224 Y:80];
	else [btn setPosX:60 Y:40];
	[btn setLayer:VLAYER_UI];
	[self addChild:btn];
	
	btn = [[QobButton alloc] initWithTile:tile TileNo:0 ID:BTNID_UNIT];
	[btn setReleaseTileNo:1];
	//[btn setBoundWidth:80 Height:40];
	if(_glView.deviceType == DEVICE_IPAD) [btn setPosX: 544 Y:80];
	else [btn setPosX: 160 Y:40];
	[btn setLayer:VLAYER_UI];
	[self addChild:btn];
    
    btn = [[QobButton alloc] initWithTile:tile TileNo:0 ID:BTNID_UNIT];
	[btn setReleaseTileNo:1];
	//[btn setBoundWidth:80 Height:40];
	if(_glView.deviceType == DEVICE_IPAD) [btn setPosX: 544 Y:80];
	else [btn setPosX: 260 Y:40];
	[btn setLayer:VLAYER_UI];
	[self addChild:btn];
    
    tile = [_tileResMgr getTileForRetina:@"worldmap_btn_base.png"];
	[tile tileSplitX:1 splitY:3];
	btn = [[QobButton alloc] initWithTile:tile TileNo:0 ID:BTNID_BASE];
	[btn setReleaseTileNo:1];
    //	[btn setBoundWidth:80 Height:40];
	if(_glView.deviceType == DEVICE_IPAD) [btn setPosX:224 Y:80];
	else [btn setPosX:60 Y:20];
	[btn setLayer:VLAYER_UI+1];
	[self addChild:btn];
    
    tile = [_tileResMgr getTileForRetina:@"worldmap_btn_mechs.png"];
	[tile tileSplitX:1 splitY:3];
	btn = [[QobButton alloc] initWithTile:tile TileNo:0 ID:BTNID_UNIT];
	[btn setReleaseTileNo:1];
    //	[btn setBoundWidth:80 Height:40];
	if(_glView.deviceType == DEVICE_IPAD) [btn setPosX:224 Y:80];
	else [btn setPosX:160 Y:20];
	[btn setLayer:VLAYER_UI+1];
	[self addChild:btn];
    
    tile = [_tileResMgr getTileForRetina:@"worldmap_btn_bombs.png"];
	[tile tileSplitX:1 splitY:3];
	btn = [[QobButton alloc] initWithTile:tile TileNo:0 ID:BTNID_BOMB];
	[btn setReleaseTileNo:1];
    //	[btn setBoundWidth:80 Height:40];
	if(_glView.deviceType == DEVICE_IPAD) [btn setPosX:224 Y:80];
	else [btn setPosX:260 Y:20];
	[btn setLayer:VLAYER_UI+1];
	[self addChild:btn];
	
	_sel = GSLOT->lastStage;
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

- (void)createWorldMap
{
    Tile2D *tile = [_tileResMgr getTileForRetina:@"worldmap_bottom_bar.png"];
    QobImage *img = [[QobImage alloc] initWithTile:tile tileNo:0];
    [img setPosX:_glView.surfaceSize.width/2 Y:165/4];
    [img setLayer:VLAYER_MIDDLE];
    [self addChild:img];
    
    tile = [_tileResMgr getTileForRetina:@"worldmap_top_bar.png"];
    img = [[QobImage alloc] initWithTile:tile tileNo:0];
    [img setPosX:_glView.surfaceSize.width/2+5 Y:_glView.surfaceSize.height-30];
    [img setLayer:VLAYER_MIDDLE+1];
    [self addChild:img];
    
    tile = [_tileResMgr getTileForRetina:@"worldmap_bar_left.png"];
    img = [[QobImage alloc] initWithTile:tile tileNo:0];
    [img setPosX:10 Y:_glView.surfaceSize.height/2];
    [img setLayer:VLAYER_MIDDLE];
    [self addChild:img];
    
    tile = [_tileResMgr getTileForRetina:@"worldmap_bar_right.png"];
    img = [[QobImage alloc] initWithTile:tile tileNo:0];
    [img setPosX:_glView.surfaceSize.width-10 Y:_glView.surfaceSize.height/2];
    [img setLayer:VLAYER_MIDDLE];
    [self addChild:img];
    
    tile = [_tileResMgr getTileForRetina:@"worldmap_map_01.jpg"];
    _imgWorldMap = [[QobImage alloc] initWithTile:tile tileNo:0];
    [_imgWorldMap setPosX:_glView.surfaceSize.width/2 Y:_glView.surfaceSize.height/2+110/2];
    [_imgWorldMap setLayer:VLAYER_BG];
    [self addChild:_imgWorldMap];
    
    float fY = 0;
    for(int i=1; i<MAX_WORLDMAP; i++)
    {
        NSString *strName = [NSString stringWithFormat:@"worldmap_map_%02d.jpg",i+1];
        tile = [_tileResMgr getTileForRetina:strName];
        fY += 1024/2;
        QobImage *imgMap = [[QobImage alloc] initWithTile:tile tileNo:0];
        [imgMap setPosX:0 Y:fY];
        [imgMap setLayer:VLAYER_BG];
        [_imgWorldMap addChild:imgMap];
    }
    
    for(int i = 0; i < MAX_STAGE; i++)
    {
        CGPoint btnPos = [GINFO getMapPositionFromIndex:i];
        tile = [_tileResMgr getTileForRetina:@"worldmap_btn_dots.png"];
        [tile tileSplitX:3 splitY:1];
        QobButton *btn = [[QobButton alloc] initWithTile:tile TileNo:0 ID:BTNID_SELSTAGE];
        [btn setPosX:btnPos.x-_glView.surfaceSize.width/2 Y:btnPos.y-_glView.surfaceSize.height/2];
        [btn setIntData:i];
        [_imgWorldMap addChild:btn];
        
        QobText *text = [[QobText alloc] initWithString:[NSString stringWithFormat:@"%d",i+1] Size:CGSizeMake(64, 32) Align:UITextAlignmentCenter Font:@"TrebuchetMS-Bold" FontSize:24 Retina:true];
		[text setPosX:0 Y:0];
		[btn addChild:text];
        
        NSString *strMapID = [NSString stringWithFormat:@"%d",i+1];
        NSString *strUnlock = [GINFO getUnlockName:strMapID];
        if([strUnlock compare:@"-"] != NSOrderedSame)
        {
            NSLog(@"%@ !!!!!",strUnlock);
            MachBuildSet *mach = [GINFO buyBuildSet:strUnlock];
            
            QobImage *img = [[QobImage alloc] initWithTile:[mach machTile] tileNo:0];
            [img setUseAtlas:true];
            [img setPosX:26 Y:0];
            [btn addChild:img];
        }
        
        if(i > GSLOT->lastStage)
        {
            [text setColorR:246 G:75 B:75];
   			[btn setDefaultTileNo:2];
   			[btn setReleaseTileNo:2];
   			[btn setDeactiveTileNo:2];
        }
        else
        {
       		[text setColorR:75 G:255 B:246];
            [btn setReleaseTileNo:1];
            [btn setDeactiveTileNo:2];
        }
        //		if(i >= MAX_STAGE) continue;
        //		tile = [_tileResMgr getTileForRetina:@"selStage_btn.png"];
        //		[tile tileSplitX:1 splitY:3];
        //		btn = [[QobButton alloc] initWithTile:tile TileNo:0 ID:BTNID_SELSTAGE];
        //		if(i > GSLOT->lastStage)
        //		{
        //			[btn setDefaultTileNo:2];
        //			[btn setReleaseTileNo:2];
        //			[btn setDeactiveTileNo:2];
        //		}
        //		else
        //		{
        //			[btn setReleaseTileNo:1];
        //			[btn setDeactiveTileNo:2];
        //		}
        //
        //       // NSString *mapId = [NSString stringWithFormat:@"%d", i + 1];
        //        CGPoint btnPos = [GINFO getMapPositionFromIndex:i];
        //		[btn setIntData:i];
        ////		[btn setBoundWidth:80 Height:40];
        //		[btn setPosX:btnPos.x Y:btnPos.y];
        //		[_buttonBase addChild:btn];
    }
}

- (void)tick
{
	float y = _imgWorldMap.pos.y;
	//float lowerLimit = fabs(_btmLimit + _lastPosition);
//    if(GSLOT->lastStage < 5) lowerLimit -= [GINFO getMapPositionFromIndex:GSLOT->lastStage-1].y;
//	else lowerLimit = _lastPosition;
	if(_dragPos == 0.f && _dragVel != 0.f)
	{
		EASYOUTE(_dragVel, 0.0f, 10.f, .1f);
		_camPos += _dragVel;
	}
//	if(_camPos < _topLimit) EASYOUTE(_camPos, _topLimit, 5.f, .1f);
	if(_camPos > _lowerLimit) EASYOUTE(_camPos, _lowerLimit, 5.f, .1f);
	EASYOUTE(y, _camPos, 5.f, .1f);
	[_imgWorldMap setPosY:y];
	
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
                //CGPoint pos = [GINFO getMapPositionFromIndex:_sel];
                //[_btnFight setPosX:pos.x Y:pos.y+_btnHeight];
                GSLOT->stage = _sel;
                [g_main changeScreen:GSCR_GAME];
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
