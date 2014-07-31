//
//  GuiSelectStage.m
//  MachDefense
//
//  Created by HaeJun Byun on 10. 12. 6..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GuiSelectStage.h"
#import "DlgShop.h"
//#import "DlgShopSpecial.h"
//#import "DlgUpgradeEquip.h"

@implementation GuiSelectStage

- (id)init
{
	[super init];
	[self setUiReceiver:true];
    
	_tileResMgr = [[ResMgr_Tile alloc] init];
    _btnMNG = [[NSMutableArray alloc] init];
    
//    _dlgShop = nil;
//    _dlgShopSpecial = nil;
	
	Tile2D *tile = nil;
	QobImage *img = nil;
	QobButton *btn = nil;
    
    _mode = 0;
	
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
    _topLimit = MAX_WORLDMAP/2*1024/2+960/4+50;
    _isClick = NO;
	
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

	tile = [_tileResMgr getTileForRetina:@"worldmap_frame_menu_base.png"];
	[tile tileSplitX:1 splitY:3];
	btn = [[QobButton alloc] initWithTile:tile TileNo:0 ID:BTNID_BASE];
	[btn setReleaseTileNo:1];
//	[btn setBoundWidth:80 Height:40];
	if(_glView.deviceType == DEVICE_IPAD) [btn setPosX:224 Y:80];
	else [btn setPosX:60 Y:40];
	[btn setLayer:VLAYER_FORE_UI2];
	[self addChild:btn];
	
    tile = [_tileResMgr getTileForRetina:@"worldmap_frame_menu_unit.png"];
    [tile tileSplitX:1 splitY:3];
	btn = [[QobButton alloc] initWithTile:tile TileNo:0 ID:BTNID_UNIT];
	[btn setReleaseTileNo:1];
	//[btn setBoundWidth:80 Height:40];
	if(_glView.deviceType == DEVICE_IPAD) [btn setPosX: 544 Y:80];
	else [btn setPosX: 160 Y:40];
	[btn setLayer:VLAYER_FORE_UI2];
	[self addChild:btn];
    
    tile = [_tileResMgr getTileForRetina:@"worldmap_frame_menu_bomb.png"];
    [tile tileSplitX:1 splitY:3];
    btn = [[QobButton alloc] initWithTile:tile TileNo:0 ID:BTNID_SPECIAL_ATTACK];
	[btn setReleaseTileNo:1];
	//[btn setBoundWidth:80 Height:40];
	if(_glView.deviceType == DEVICE_IPAD) [btn setPosX: 544 Y:80];
	else [btn setPosX: 260 Y:40];
	[btn setLayer:VLAYER_FORE_UI2];
	[self addChild:btn];
    
    tile = [_tileResMgr getTileForRetina:@"worldmap_btn_base.png"];
	[tile tileSplitX:1 splitY:3];
	btn = [[QobButton alloc] initWithTile:tile TileNo:0 ID:BTNID_BASE];
	[btn setReleaseTileNo:1];
    //	[btn setBoundWidth:80 Height:40];
	if(_glView.deviceType == DEVICE_IPAD) [btn setPosX:224 Y:80];
	else [btn setPosX:60 Y:20];
	[btn setLayer:VLAYER_FORE_UI2];
	[self addChild:btn];
    
    tile = [_tileResMgr getTileForRetina:@"worldmap_btn_mechs.png"];
	[tile tileSplitX:1 splitY:3];
	btn = [[QobButton alloc] initWithTile:tile TileNo:0 ID:BTNID_UNIT];
	[btn setReleaseTileNo:1];
    //	[btn setBoundWidth:80 Height:40];
	if(_glView.deviceType == DEVICE_IPAD) [btn setPosX:224 Y:80];
	else [btn setPosX:160 Y:20];
	[btn setLayer:VLAYER_FORE_UI2];
	[self addChild:btn];
    
    tile = [_tileResMgr getTileForRetina:@"worldmap_btn_bombs.png"];
	[tile tileSplitX:1 splitY:3];
	btn = [[QobButton alloc] initWithTile:tile TileNo:0 ID:BTNID_SPECIAL_ATTACK];
	[btn setReleaseTileNo:1];
    //	[btn setBoundWidth:80 Height:40];
	if(_glView.deviceType == DEVICE_IPAD) [btn setPosX:224 Y:80];
	else [btn setPosX:260 Y:20];
	[btn setLayer:VLAYER_FORE_UI2];
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
    
//    if(_dlgShop)
//    {
//        [_dlgShop remove];
//        _dlgShop = nil;
//    }
//    
//    if(_dlgShopSpecial)
//    {
//        [_dlgShopSpecial remove];
//        _dlgShopSpecial = nil;
//    }
	
	[_tileResMgr removeAllTiles];
	[_tileResMgr release];
    
    [_btnMNG removeAllObjects];
    [_btnMNG release];
	
	[super dealloc];
}

- (void)createWorldMap
{
    Tile2D *tile = [_tileResMgr getTileForRetina:@"worldmap_bottom_bar.png"];
    QobImage *img = [[QobImage alloc] initWithTile:tile tileNo:0];
    [img setPosX:_glView.surfaceSize.width/2 Y:165/4];
    [img setLayer:VLAYER_FORE_UI2];
    [self addChild:img];
    
    tile = [_tileResMgr getTileForRetina:@"worldmap_top_bar.png"];
    img = [[QobImage alloc] initWithTile:tile tileNo:0];
    [img setPosX:_glView.surfaceSize.width/2+5 Y:_glView.surfaceSize.height-5];
    [img setLayer:VLAYER_MIDDLE+1];
    [self addChild:img];
    
//    _cr = [[QobText alloc] initWithString:[NSString stringWithFormat:@"%d",GSLOT->cr] Size:CGSizeMake(128, 32) Align:UITextAlignmentRight Font:@"TrebuchetMS-Bold" FontSize:24 Retina:true];
//    [_cr setPosX:-128 Y:-8];
//    [img addChild:_cr];
//    [_cr setColorR:55 G:125 B:126];
    
    NSLog(@"crcrcr %d",GSLOT->cr);
    
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
    
    for(int i=1; i<MAX_WORLDMAP; i++)
    {
        NSString *strName = [NSString stringWithFormat:@"worldmap_map_%02d.jpg",i+1];
        tile = [_tileResMgr getTileForRetina:strName];
        QobImage *imgMap = [[QobImage alloc] initWithTile:tile tileNo:0];
        [imgMap setPosX:0 Y:1024/2+((i-1)*1024/2)];
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
        
        [_btnMNG addObject:btn];
        
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
            [text setVisual:NO];
            [text setColorR:50 G:40 B:50];
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
    
    if( GSLOT->lastStage > 10)
    {
        CGPoint btnPos = [GINFO getMapPositionFromIndex:GSLOT->lastStage];
        _camPos = -(btnPos.y-_glView.surfaceSize.height/2)/2+110/2;
    
        NSLog(@"[%.02f]",btnPos.y);
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
        NSLog(@"campos [%.02f]",_camPos);
	}

	if(_camPos < -_topLimit) EASYOUTE(_camPos, -_topLimit, 5.f, .1f);
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
        if( button.buttonId == BTNID_UNIT || button.buttonId == BTNID_SPECIAL_ATTACK)
        {
            _isClick = YES;
            _mode = 1;
//            DlgUpgradeEquip *upgrade = [[DlgUpgradeEquip alloc] init];
//            [upgrade setLayer:VLAYER_MIDDLE];
//            [upgrade setPosX:_glView.surfaceSize.width/2 Y:_glView.surfaceSize.height/2-7];
//            [upgrade refreshMachButtons];
//            [self addChild:upgrade];
//            _dlgUpgrade = upgrade;
            
            //[_dlgBuildMach refreshButtonsWithType:BMT_UPGRADEMACH];
            //[_dlgBuildSpAttack refreshButtonsWithType:BSAT_UPGRADEATTACK];
        }
		else if(button.buttonId == BTNID_SELSTAGE)
		{
            _isClick = YES;
            NSLog(@"yes");
			_dragPos = button.tapPos.y;
//			[SOUNDMGR play:[GINFO sfxID:SND_MENU_CLICK]];
		}
        else
            NSLog(@"NO");
	}
	else if([[note name]isEqualToString:@"MoveButton"])
	{
//		if(button.buttonId != BTNID_SELSTAGE)
//		{
//			_dragVel = button.tapPos.y - _dragPos;
//			_dragPos = button.tapPos.y;
//			
//			_camPos += _dragVel;
//		}
	}
	else if([[note name]isEqualToString:@"CancelButton"])
	{
//		if(button.buttonId != BTNID_SELSTAGE)
//		{
//			_dragVel = button.tapPos.y - _dragPos;
//			_dragPos = 0;
//		}
	}
	else if([[note name]isEqualToString:@"PopButton"])
    {
        if(_isClick)
        {
            if( button.buttonId == BTNID_UNIT )
            {
//                if(_dlgShop)
//                {
//                    [_dlgShop remove];
//                    _dlgShop = nil;
//                }
//                else
                {
                    [g_main makeScreen:GSCR_SHOPMACH];
//                    DlgShop *dlgShop = [[DlgShop alloc] init];
//                    [dlgShop setLayer:VLAYER_MIDDLE-2];
//                    [dlgShop setPosX:_glView.surfaceSize.width/2 Y:_glView.surfaceSize.height/2+24];
//                    [self addChild:dlgShop];
//                    _dlgShop = dlgShop;
                }
            }
            else if( button.buttonId == BTNID_SPECIAL_ATTACK )
            {
//                if(_dlgShopSpecial)
//                {
//                    [_dlgShopSpecial remove];
//                    _dlgShopSpecial = nil;
//                }
//                else
                {
                    [g_main makeScreen:GSCR_SHOPSPECIAL];
                }
            }
            else if(button.buttonId == BTNID_OK)
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
        
        _isClick = NO;
	}
}

- (BOOL)onTap:(CGPoint)pt State:(int)state ID:(id)tapID
{
    NSLog(@"GuiSelectStage %d", state);
    
    if(_mode == 1)
    {
        NSLog(@"GuiSelectStage mode 1 %d [%.02f %.02f]", state, pt.x, pt.y);
//        [_dlgShop onTap:pt State:state ID:tapID];
        return true;
    }
    
    if(state == TAP_START)
    {
        if(_mode == 0 && !_isClick)
        {
            _dragPos = pt.y;
            _btnFight.visual = NO;
        }
    }
    else if(state == TAP_MOVE)
    {
        if(_mode == 0 && !_isClick)
        {
            _dragVel = pt.y - _dragPos;
            _dragPos = pt.y;
        
            _camPos += _dragVel;
        }
    }
    else if(state == TAP_END)
    {
        if(_mode == 0 && !_isClick)
        {
            _dragVel = pt.y - _dragPos;
            _dragPos = 0;
        }
        
        _isClick = NO;
    }
    
    return true;
}


@end
