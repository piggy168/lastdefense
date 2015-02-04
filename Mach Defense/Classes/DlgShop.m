//
//  DlgShop.m
//  MachDefense
//
//  Created by Dustin on 4/9/14.
//
//

#import "DlgShop.h"
#import "GameMain.h"
#import "GuiGame.h"
#import "GobHvMach.h"
#import "GobHvM_Player.h"

@implementation DlgShop

- (id)init
{
    [super init];
    [self setUiReceiver:true];
    
    _canClick = true;
    _isScroll = false;
    _scrollPos = 0.0f;
    _topPos = 115.0f+24;
    
    _QSLOT = [[NSMutableArray alloc]init];
    _QLIST = [[NSMutableArray alloc]init];
    
    Tile2D *tile = [TILEMGR getTileForRetina:[NSString stringWithFormat:@"shop_bg.jpg"]];
    QobImage *bg_full = [[QobImage alloc] initWithTile:tile tileNo:0];
//    [bg_full setScaleY:1.15f];
    [bg_full setLayer:0];
    [self addChild:bg_full];
    
    tile = [TILEMGR getTileForRetina:[NSString stringWithFormat:@"Shop_Screen_BG.png"]];
    QobImage *bg = [[QobImage alloc] initWithTile:tile tileNo:0];
    [bg setScaleY:1.15f];
    [bg setLayer:0];
    [bg setPosY:24];
    [self addChild:bg];
    
    [self createMainMenu];
    
    tile = [TILEMGR getTileForRetina:[NSString stringWithFormat:@"Shop_Screen_BG_right_filter.png"]];
    QobImage *bgMid = [[QobImage alloc] initWithTile:tile tileNo:0];
    [bgMid setScaleY:1.3f];
    [bgMid setLayer:2];
    [bgMid setPosX:104 Y:0];
    [bg addChild:bgMid];
    
    _base = [[QobBase alloc] init];
    [_base setPosX:-22 Y:_topPos];
    [self addChild:_base];
    
    tile = [TILEMGR getTileForRetina:[NSString stringWithFormat:@"Shop_Screen_Border.png"]];
    QobImage *bgTop = [[QobImage alloc] initWithTile:tile tileNo:0];
    [bgTop setScaleY:1.15f];
    [bgTop setLayer:4];
    [bgTop setPosY:24];
    [self addChild:bgTop];
    
    tile = [TILEMGR getTileForRetina:@"worldmap_bottom_bar.png"];
    QobImage *img = [[QobImage alloc] initWithTile:tile tileNo:0];
    [img setPosX:0 Y:-_glView.surfaceSize.height/2+35];
    [img setLayer:VLAYER_MIDDLE+1];
    [self addChild:img];
    
    tile = [TILEMGR getTileForRetina:@"worldmap_top_bar.png"];
    img = [[QobImage alloc] initWithTile:tile tileNo:0];
    [img setPosX:5 Y:_glView.surfaceSize.height/2-5];
    [img setLayer:3];
    [self addChild:img];
    
    tile = [TILEMGR getTileForRetina:@"Done_btn.png"];
    [tile tileSplitX:1 splitY:3];
	QobButton *btn = [[QobButton alloc] initWithTile:tile TileNo:0 ID:9999];
	[btn setReleaseTileNo:1];
	[btn setPosX: _glView.surfaceSize.width/2 - 70 Y:185];
	[btn setLayer:VLAYER_FORE_UI2];
	[bgTop addChild:btn];
    
    _cr = [[QobText alloc] initWithString:[NSString stringWithFormat:@"%d",GSLOT->cr] Size:CGSizeMake(128, 32) Align:UITextAlignmentRight Font:@"TrebuchetMS-Bold" FontSize:24 Retina:true];
    [_cr setPosX:-102 Y:185];
    [bgTop addChild:_cr];
    [_cr setColorR:55 G:125 B:126];
    
    for(int i=0; i<7; i++)
    {
        tile = [TILEMGR getTileForRetina:[NSString stringWithFormat:@"Side_bar_mech_box.png"]];
        QobImage *slot = [[QobImage alloc] initWithTile:tile tileNo:0];
        [bgTop addChild:slot];
        [slot setPosX:106 Y:142-i*50];
    }
    
    [self updateList];
    
 	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:self selector:@selector(handleButton:) name:@"PushButton" object:nil];
	[nc addObserver:self selector:@selector(handleButton:) name:@"ReleaseButton" object:nil];
	[nc addObserver:self selector:@selector(handleButton:) name:@"PopButton" object:nil];
    [nc addObserver:self selector:@selector(handleButton:) name:@"CancelButton" object:nil];
	
	return self;
}

- (void)createMainMenu
{
    Tile2D *tile = [TILEMGR getTileForRetina:@"worldmap_frame_menu_base.png"];
	[tile tileSplitX:1 splitY:3];
	QobButton *btn = [[QobButton alloc] initWithTile:tile TileNo:0 ID:BTNID_BASE];
	[btn setReleaseTileNo:1];
    //	[btn setBoundWidth:80 Height:40];
	if(_glView.deviceType == DEVICE_IPAD) [btn setPosX:224 Y:80];
	else [btn setPosX:60-_glView.surfaceSize.width/2 Y:40-_glView.surfaceSize.height/2];
	[btn setLayer:VLAYER_FORE_UI2];
	[self addChild:btn];
	
    tile = [TILEMGR getTileForRetina:@"worldmap_frame_menu_unit.png"];
    [tile tileSplitX:1 splitY:3];
	btn = [[QobButton alloc] initWithTile:tile TileNo:0 ID:BTNID_UNIT];
	[btn setReleaseTileNo:1];
	//[btn setBoundWidth:80 Height:40];
	if(_glView.deviceType == DEVICE_IPAD) [btn setPosX: 544 Y:80];
	else [btn setPosX: 160-_glView.surfaceSize.width/2 Y:40-_glView.surfaceSize.height/2];
	[btn setLayer:VLAYER_FORE_UI2];
	[self addChild:btn];
    
    tile = [TILEMGR getTileForRetina:@"worldmap_frame_menu_bomb.png"];
    [tile tileSplitX:1 splitY:3];
    btn = [[QobButton alloc] initWithTile:tile TileNo:0 ID:BTNID_BOMB];
	[btn setReleaseTileNo:1];
	//[btn setBoundWidth:80 Height:40];
	if(_glView.deviceType == DEVICE_IPAD) [btn setPosX: 544 Y:80];
	else [btn setPosX: 260-_glView.surfaceSize.width/2 Y:40-_glView.surfaceSize.height/2];
	[btn setLayer:VLAYER_FORE_UI2];
	[self addChild:btn];
    
    tile = [TILEMGR getTileForRetina:@"worldmap_btn_base.png"];
	[tile tileSplitX:1 splitY:3];
	btn = [[QobButton alloc] initWithTile:tile TileNo:0 ID:BTNID_BASE];
	[btn setReleaseTileNo:1];
    //	[btn setBoundWidth:80 Height:40];
	if(_glView.deviceType == DEVICE_IPAD) [btn setPosX:224 Y:80];
	else [btn setPosX:60-_glView.surfaceSize.width/2 Y:20-_glView.surfaceSize.height/2];
	[btn setLayer:VLAYER_FORE_UI2];
	[self addChild:btn];
    
    tile = [TILEMGR getTileForRetina:@"worldmap_btn_mechs.png"];
	[tile tileSplitX:1 splitY:3];
	btn = [[QobButton alloc] initWithTile:tile TileNo:0 ID:BTNID_UNIT];
	[btn setReleaseTileNo:1];
    //	[btn setBoundWidth:80 Height:40];
	if(_glView.deviceType == DEVICE_IPAD) [btn setPosX:224 Y:80];
	else [btn setPosX:160-_glView.surfaceSize.width/2 Y:20-_glView.surfaceSize.height/2];
	[btn setLayer:VLAYER_FORE_UI2];
	[self addChild:btn];
    
    tile = [TILEMGR getTileForRetina:@"worldmap_btn_bombs.png"];
	[tile tileSplitX:1 splitY:3];
	btn = [[QobButton alloc] initWithTile:tile TileNo:0 ID:BTNID_BOMB];
	[btn setReleaseTileNo:1];
    //	[btn setBoundWidth:80 Height:40];
	if(_glView.deviceType == DEVICE_IPAD) [btn setPosX:224 Y:80];
	else [btn setPosX:260-_glView.surfaceSize.width/2 Y:20-_glView.surfaceSize.height/2];
	[btn setLayer:VLAYER_FORE_UI2];
	[self addChild:btn];
}

- (void)dealloc
{
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc removeObserver:self];

    [_QSLOT removeAllObjects];
    [_QSLOT release];
    _QSLOT = nil;
    [_QLIST removeAllObjects];
    [_QLIST release];
    _QLIST = nil;
	[_base remove];
    _base = nil;
	[super dealloc];
}

- (void)tick
{
	if(_scrollPos != 0.0f)
	{
        float y = _base.pos.y +_scrollPos;
        if(y <= _topPos ) y = _topPos;
        else if(y>=_bottomPos) y = _bottomPos;
        [_base setPosY:y];
        _scrollPos = 0.0f;
        NSLog(@"tick %0.2f",_base.pos.y);
	}
	
	[super tick];
}



- (void) updateList
{
    NSArray *listBuildSet = [GINFO listBuyBuildSet];
    NSLog(@"updateList %d",listBuildSet.count);
    _bottomPos = 88*listBuildSet.count;// + _topPos;
//    int nSlot = 0;
    for(int i = 0; i < listBuildSet.count; i++)
    {
        NSString *strInfo;
        GobHvM_Player *mach, *nextMach;
        int atk1, atk2, rng1, rng2, def1, def2, spd1, spd2;
        float x = 0.0f;
        float y = -i*80;
        
        MachBuildSet *buildSet = [listBuildSet objectAtIndex:i];
        if(buildSet == nil) continue;
        
        NSLog(@"updatelist load [%@] [%d]", buildSet.machName, i);
        if(![GINFO existBuyBuildSet:buildSet.machName])
        {
            NSLog(@"updatelist skip [%@]", buildSet.machName);
            continue;
        }

        TMachBuildSet *set = [buildSet buildSet];
        
//        bool bActive = buildSet.onSlot;
        //if(bActive) continue;
        
        Tile2D *tile = [TILEMGR getTileForRetina:[NSString stringWithFormat:@"Upgrade_Mach_BG.png"]];
        QobImage *bg = [[QobImage alloc] initWithTile:tile tileNo:0];
        [bg setPosX:x Y:y];
        [bg setLayer:1];
        [_base addChild:bg];

        NSString *machName = [GINFO getDescription:[NSString stringWithFormat:@"MN_%@", buildSet.machName]];
        if(machName == nil) machName = buildSet.machName;
        QobText *text = [[QobText alloc] initWithString:[NSString stringWithFormat:@"%@  Lv. %d", machName, buildSet.level+1] Size:CGSizeMake(128, 16) Align:UITextAlignmentCenter Font:@"TrebuchetMS-Bold" FontSize:14 Retina:true];
        [text setColorR:255 G:255 B:255];
        [text setPosX:-36 Y:31];
        [text setLayer:2];
        [bg addChild:text];

        tile = [TILEMGR getTileForRetina:@"Uninstall_Btn.png"];
        [tile tileSplitX:1 splitY:3];
        QobButton *btn = [[QobButton alloc] initWithTile:tile TileNo:0 ID:100+i];
        [btn setReleaseTileNo:1];
        if(_glView.deviceType == DEVICE_IPAD) [btn setPosX:224 Y:80];
        else [btn setPosX:60 Y:-12 ];
        [btn setLayer:2];
        [bg addChild:btn];
        [btn setVisual:buildSet.onSlot];
        
        tile = [TILEMGR getTileForRetina:@"Install_Btn.png"];
        [tile tileSplitX:1 splitY:3];
        btn = [[QobButton alloc] initWithTile:tile TileNo:0 ID:100+i];
        [btn setReleaseTileNo:1];
        if(_glView.deviceType == DEVICE_IPAD) [btn setPosX:224 Y:80];
        else [btn setPosX:60 Y:-12 ];
        [btn setLayer:2];
        [bg addChild:btn];
        [btn setVisual:(!buildSet.onSlot)];
        
        tile = [TILEMGR getTileForRetina:@"Upgrade_Btn.png"];
        [tile tileSplitX:1 splitY:3];
        btn = [[QobButton alloc] initWithTile:tile TileNo:0 ID:1000+i];
        [btn setReleaseTileNo:1];
        if(_glView.deviceType == DEVICE_IPAD) [btn setPosX:224 Y:80];
        else [btn setPosX:60 Y:19 ];
        [btn setLayer:2];
        [bg addChild:btn];
        
        text = [[QobText alloc] initWithString:[NSString stringWithFormat:@"%d cr", set->upgradeCost] Size:CGSizeMake(64, 16) Align:UITextAlignmentCenter Font:@"TrebuchetMS-Bold" FontSize:14 Retina:true];
        [text setColorR:240 G:255 B:255];
        [text setPosX:7 Y:7];
        [text setLayer:2];
        [btn addChild:text];
        
        mach = [[GobHvM_Player alloc] init];
        [mach setPosX:-138 * GWORLD.deviceScale Y:8 * GWORLD.deviceScale];
        [bg addChild:mach];
        [mach setDir:M_PI / 2.f];
        [mach setState:MACHSTATE_STOP];
        [mach setUiModel:true];
        [mach setLayer:2];
        [mach setParts:@"DummyParts" partsType:PARTS_BASE];
        
        if(buildSet.setType == BST_PARTS)
        {
            mach.hp = mach.hpMax = set->parts->armor.param1;
            [mach setStepSize:set->parts->foot.param1];
            
            [mach setParts:set->parts->foot.strParam partsType:PARTS_FOOT];
            [mach setParts:set->parts->armor.strParam partsType:PARTS_BODY];
            [mach setParts:set->parts->weapon.strParam partsType:PARTS_WPN];
        }
        else if(buildSet.setType == BST_NAME)
        {
            [mach makeMachFromName:set->name->szMachName];
        }
        
        atk1 = mach.atkPoint;
        rng1 = mach.targetRange;
        def1 = mach.hpMax;
        spd1 = mach.spdPoint;
                
        TMachBuildSet *nextSet = [buildSet nextBuildSet];
        if(nextSet)
        {
            nextMach = [[GobHvM_Player alloc] init];
            [nextMach setPosX:-16 * GWORLD.deviceScale Y:8 * GWORLD.deviceScale];
            [bg addChild:nextMach];
            [nextMach setDir:M_PI / 2.f];
            [nextMach setState:MACHSTATE_STOP];
            [nextMach setUiModel:true];
            [nextMach setLayer:2];
            [nextMach setParts:@"DummyParts" partsType:PARTS_BASE];
            
            if(buildSet.setType == BST_PARTS)
            {
                nextMach.hp = nextMach.hpMax = nextSet->parts->armor.param1;
                [nextMach setStepSize:nextSet->parts->foot.param1];
                
                [nextMach setParts:nextSet->parts->foot.strParam partsType:PARTS_FOOT];
                [nextMach setParts:nextSet->parts->armor.strParam partsType:PARTS_BODY];
                [nextMach setParts:nextSet->parts->weapon.strParam partsType:PARTS_WPN];
            }
            else if(buildSet.setType == BST_NAME)
            {
                [nextMach makeMachFromName:nextSet->name->szMachName];
            }
            
            atk2 = nextMach.atkPoint;
            rng2 = nextMach.targetRange;
            def2 = nextMach.hpMax;
            spd2 = nextMach.spdPoint;
        }
        
        if(nextSet)
        {
            strInfo = [NSString stringWithFormat:@"%d(%+d)", atk1, atk2-atk1];
            text = [[QobText alloc] initWithString:strInfo Size:CGSizeMake(128, 16) Align:UITextAlignmentLeft Font:@"TrebuchetMS-Bold" FontSize:12 Retina:true];
            [text setColorR:240 G:255 B:255];
            [text setPosX:-70 * GWORLD.deviceScale Y:-31 * GWORLD.deviceScale];
            [bg addChild:text];
            
            strInfo = [NSString stringWithFormat:@"%d(%+d)", rng1, rng2-rng1];
            text = [[QobText alloc] initWithString:strInfo Size:CGSizeMake(128, 16) Align:UITextAlignmentLeft Font:@"TrebuchetMS-Bold" FontSize:12 Retina:true];
            [text setColorR:240 G:255 B:255];
            [text setPosX:70 * GWORLD.deviceScale Y:-31 * GWORLD.deviceScale];
            [bg addChild:text];
            
            strInfo = [NSString stringWithFormat:@"%d(%+d)", def1, def2-def1];
            text = [[QobText alloc] initWithString:strInfo Size:CGSizeMake(128, 16) Align:UITextAlignmentLeft Font:@"TrebuchetMS-Bold" FontSize:12 Retina:true];
            [text setColorR:240 G:255 B:255];
            [text setPosX:-69 * GWORLD.deviceScale Y:-46 * GWORLD.deviceScale];
            [bg addChild:text];
            
            strInfo = [NSString stringWithFormat:@"%d(%+d)", spd1, spd2-spd1];
            text = [[QobText alloc] initWithString:strInfo Size:CGSizeMake(128, 16) Align:UITextAlignmentLeft Font:@"TrebuchetMS-Bold" FontSize:12 Retina:true];
            [text setColorR:240 G:255 B:255];
            [text setPosX:50 * GWORLD.deviceScale Y:-46 * GWORLD.deviceScale];
            [bg addChild:text];
        }
        else
        {
            strInfo = [NSString stringWithFormat:@"%@ : %d", [GINFO getDescription:@"Stat_Atk"], atk1];
            text = [[QobText alloc] initWithString:strInfo Size:CGSizeMake(128, 16) Align:UITextAlignmentLeft Font:@"TrebuchetMS-Bold" FontSize:12 Retina:true];
            [text setColorR:240 G:255 B:255];
            [text setPosX:-120 * GWORLD.deviceScale Y:-44 * GWORLD.deviceScale];
            [bg addChild:text];
            
            strInfo = [NSString stringWithFormat:@"%@ : %d", [GINFO getDescription:@"Stat_Rng"], rng1];
            text = [[QobText alloc] initWithString:strInfo Size:CGSizeMake(128, 16) Align:UITextAlignmentLeft Font:@"TrebuchetMS-Bold" FontSize:12 Retina:true];
            [text setColorR:240 G:255 B:255];
            [text setPosX:20 * GWORLD.deviceScale Y:-44 * GWORLD.deviceScale];
            [bg addChild:text];
            
            strInfo = [NSString stringWithFormat:@"%@ : %d", [GINFO getDescription:@"Stat_Def"], def1];
            text = [[QobText alloc] initWithString:strInfo Size:CGSizeMake(128, 16) Align:UITextAlignmentLeft Font:@"TrebuchetMS-Bold" FontSize:12 Retina:true];
            [text setColorR:240 G:255 B:255];
            [text setPosX:-120 * GWORLD.deviceScale Y:-60 * GWORLD.deviceScale];
            [bg addChild:text];
            
            strInfo = [NSString stringWithFormat:@"%@ : %d", [GINFO getDescription:@"Stat_Spd"], spd1];
            text = [[QobText alloc] initWithString:strInfo Size:CGSizeMake(128, 16) Align:UITextAlignmentLeft Font:@"TrebuchetMS-Bold" FontSize:12 Retina:true];
            [text setColorR:240 G:255 B:255];
            [text setPosX:20 * GWORLD.deviceScale Y:-60 * GWORLD.deviceScale];
            [bg addChild:text];
        }
        
//        [_QLIST addObject:bg];
        [_QLIST insertObject:bg atIndex:i];
    }
    
    [self updateSlot];
}

- (void) updateSlot
{
    for(GobHvM_Player *slot in _QSLOT)
    {
        [slot remove];
//        [slot release];
        slot = nil;
    }
    [_QSLOT removeAllObjects];
    
    int nSlot = 0;
    NSArray *listBuildSet = [GINFO listBuyBuildSet];
    for(MachBuildSet *buildSet in listBuildSet)
    {
        bool bActive = buildSet.onSlot;
        if(bActive)
        {
            TMachBuildSet *set = [buildSet buildSet];
            GobHvM_Player *pSlotPlayer = [[GobHvM_Player alloc] init];
            [pSlotPlayer setPosX:106 Y:166-nSlot*50];
            [self addChild:pSlotPlayer];
            [pSlotPlayer setDir:M_PI / 2.f];
            [pSlotPlayer setState:MACHSTATE_STOP];
            [pSlotPlayer setUiModel:true];
            [pSlotPlayer setLayer:5];
            [pSlotPlayer setParts:@"DummyParts" partsType:PARTS_BASE];
            [_QSLOT addObject:pSlotPlayer];
            
            if(buildSet.setType == BST_PARTS)
            {
                [pSlotPlayer setStepSize:set->parts->foot.param1];
                
                [pSlotPlayer setParts:set->parts->foot.strParam partsType:PARTS_FOOT];
                [pSlotPlayer setParts:set->parts->armor.strParam partsType:PARTS_BODY];
                [pSlotPlayer setParts:set->parts->weapon.strParam partsType:PARTS_WPN];
            }
            else if(buildSet.setType == BST_NAME)
            {
                [pSlotPlayer makeMachFromName:set->name->szMachName];
            }
            nSlot++;
        }
    }
}

- (void) refreshList:(int)unit_id
{
    QobImage *bg = [_QLIST objectAtIndex:unit_id];
    if(bg)
    {
        [_QLIST removeObject:bg];
        [bg remove];
        //bg = nil;
    }
    
    NSArray *listBuildSet = [GINFO listBuyBuildSet];
    NSLog(@"updateList %d",listBuildSet.count);
    _bottomPos = 88*listBuildSet.count;// + _topPos;
    //    int nSlot = 0;
//    for(int i = 0; i < listBuildSet.count; i++)
    {
        int i = unit_id;
        NSString *strInfo;
        GobHvM_Player *mach, *nextMach;
        int atk1, atk2, rng1, rng2, def1, def2, spd1, spd2;
        float x = 0.0f;
        float y = -i*80;
        
        MachBuildSet *buildSet = [listBuildSet objectAtIndex:unit_id];
        if(buildSet == nil) return;
        
        TMachBuildSet *set = [buildSet buildSet];
        
        //        bool bActive = buildSet.onSlot;
        //if(bActive) continue;
        
        Tile2D *tile = [TILEMGR getTileForRetina:[NSString stringWithFormat:@"Upgrade_Mach_BG.png"]];
        QobImage *bg = [[QobImage alloc] initWithTile:tile tileNo:0];
        [bg setPosX:x Y:y];
        [bg setLayer:1];
        [_base addChild:bg];
        
        NSString *machName = [GINFO getDescription:[NSString stringWithFormat:@"MN_%@", buildSet.machName]];
        if(machName == nil) machName = buildSet.machName;
        QobText *text = [[QobText alloc] initWithString:[NSString stringWithFormat:@"%@  Lv. %d", machName, buildSet.level+1] Size:CGSizeMake(128, 16) Align:UITextAlignmentCenter Font:@"TrebuchetMS-Bold" FontSize:14 Retina:true];
        [text setColorR:255 G:255 B:255];
        [text setPosX:-36 Y:31];
        [text setLayer:2];
        [bg addChild:text];
        
        tile = [TILEMGR getTileForRetina:@"Uninstall_Btn.png"];
        [tile tileSplitX:1 splitY:3];
        QobButton *btn = [[QobButton alloc] initWithTile:tile TileNo:0 ID:100+i];
        [btn setReleaseTileNo:1];
        if(_glView.deviceType == DEVICE_IPAD) [btn setPosX:224 Y:80];
        else [btn setPosX:60 Y:-12 ];
        [btn setLayer:2];
        [bg addChild:btn];
        [btn setVisual:buildSet.onSlot];
        
        tile = [TILEMGR getTileForRetina:@"Install_Btn.png"];
        [tile tileSplitX:1 splitY:3];
        btn = [[QobButton alloc] initWithTile:tile TileNo:0 ID:100+i];
        [btn setReleaseTileNo:1];
        if(_glView.deviceType == DEVICE_IPAD) [btn setPosX:224 Y:80];
        else [btn setPosX:60 Y:-12 ];
        [btn setLayer:2];
        [bg addChild:btn];
        [btn setVisual:(!buildSet.onSlot)];
        
        tile = [TILEMGR getTileForRetina:@"Upgrade_Btn.png"];
        [tile tileSplitX:1 splitY:3];
        btn = [[QobButton alloc] initWithTile:tile TileNo:0 ID:1000+i];
        [btn setReleaseTileNo:1];
        if(_glView.deviceType == DEVICE_IPAD) [btn setPosX:224 Y:80];
        else [btn setPosX:60 Y:19 ];
        [btn setLayer:2];
        [bg addChild:btn];
        
        text = [[QobText alloc] initWithString:[NSString stringWithFormat:@"%d cr", set->upgradeCost] Size:CGSizeMake(64, 16) Align:UITextAlignmentCenter Font:@"TrebuchetMS-Bold" FontSize:14 Retina:true];
        [text setColorR:240 G:255 B:255];
        [text setPosX:7 Y:7];
        [text setLayer:2];
        [btn addChild:text];
        
        mach = [[GobHvM_Player alloc] init];
        [mach setPosX:-138 * GWORLD.deviceScale Y:8 * GWORLD.deviceScale];
        [bg addChild:mach];
        [mach setDir:M_PI / 2.f];
        [mach setState:MACHSTATE_STOP];
        [mach setUiModel:true];
        [mach setLayer:2];
        [mach setParts:@"DummyParts" partsType:PARTS_BASE];
        
        if(buildSet.setType == BST_PARTS)
        {
            mach.hp = mach.hpMax = set->parts->armor.param1;
            [mach setStepSize:set->parts->foot.param1];
            
            [mach setParts:set->parts->foot.strParam partsType:PARTS_FOOT];
            [mach setParts:set->parts->armor.strParam partsType:PARTS_BODY];
            [mach setParts:set->parts->weapon.strParam partsType:PARTS_WPN];
        }
        else if(buildSet.setType == BST_NAME)
        {
            [mach makeMachFromName:set->name->szMachName];
        }
        
        atk1 = mach.atkPoint;
        rng1 = mach.targetRange;
        def1 = mach.hpMax;
        spd1 = mach.spdPoint;
        
        TMachBuildSet *nextSet = [buildSet nextBuildSet];
        if(nextSet)
        {
            nextMach = [[GobHvM_Player alloc] init];
            [nextMach setPosX:-16 * GWORLD.deviceScale Y:8 * GWORLD.deviceScale];
            [bg addChild:nextMach];
            [nextMach setDir:M_PI / 2.f];
            [nextMach setState:MACHSTATE_STOP];
            [nextMach setUiModel:true];
            [nextMach setLayer:2];
            [nextMach setParts:@"DummyParts" partsType:PARTS_BASE];
            
            if(buildSet.setType == BST_PARTS)
            {
                nextMach.hp = nextMach.hpMax = nextSet->parts->armor.param1;
                [nextMach setStepSize:nextSet->parts->foot.param1];
                
                [nextMach setParts:nextSet->parts->foot.strParam partsType:PARTS_FOOT];
                [nextMach setParts:nextSet->parts->armor.strParam partsType:PARTS_BODY];
                [nextMach setParts:nextSet->parts->weapon.strParam partsType:PARTS_WPN];
            }
            else if(buildSet.setType == BST_NAME)
            {
                [nextMach makeMachFromName:nextSet->name->szMachName];
            }
            
            atk2 = nextMach.atkPoint;
            rng2 = nextMach.targetRange;
            def2 = nextMach.hpMax;
            spd2 = nextMach.spdPoint;
        }
        
        if(nextSet)
        {
            strInfo = [NSString stringWithFormat:@"%d(%+d)", atk1, atk2-atk1];
            text = [[QobText alloc] initWithString:strInfo Size:CGSizeMake(128, 16) Align:UITextAlignmentLeft Font:@"TrebuchetMS-Bold" FontSize:12 Retina:true];
            [text setColorR:240 G:255 B:255];
            [text setPosX:-70 * GWORLD.deviceScale Y:-31 * GWORLD.deviceScale];
            [bg addChild:text];
            
            strInfo = [NSString stringWithFormat:@"%d(%+d)", rng1, rng2-rng1];
            text = [[QobText alloc] initWithString:strInfo Size:CGSizeMake(128, 16) Align:UITextAlignmentLeft Font:@"TrebuchetMS-Bold" FontSize:12 Retina:true];
            [text setColorR:240 G:255 B:255];
            [text setPosX:70 * GWORLD.deviceScale Y:-31 * GWORLD.deviceScale];
            [bg addChild:text];
            
            strInfo = [NSString stringWithFormat:@"%d(%+d)", def1, def2-def1];
            text = [[QobText alloc] initWithString:strInfo Size:CGSizeMake(128, 16) Align:UITextAlignmentLeft Font:@"TrebuchetMS-Bold" FontSize:12 Retina:true];
            [text setColorR:240 G:255 B:255];
            [text setPosX:-69 * GWORLD.deviceScale Y:-46 * GWORLD.deviceScale];
            [bg addChild:text];
            
            strInfo = [NSString stringWithFormat:@"%d(%+d)", spd1, spd2-spd1];
            text = [[QobText alloc] initWithString:strInfo Size:CGSizeMake(128, 16) Align:UITextAlignmentLeft Font:@"TrebuchetMS-Bold" FontSize:12 Retina:true];
            [text setColorR:240 G:255 B:255];
            [text setPosX:50 * GWORLD.deviceScale Y:-46 * GWORLD.deviceScale];
            [bg addChild:text];
        }
        else
        {
            strInfo = [NSString stringWithFormat:@"%@ : %d", [GINFO getDescription:@"Stat_Atk"], atk1];
            text = [[QobText alloc] initWithString:strInfo Size:CGSizeMake(128, 16) Align:UITextAlignmentLeft Font:@"TrebuchetMS-Bold" FontSize:12 Retina:true];
            [text setColorR:240 G:255 B:255];
            [text setPosX:-120 * GWORLD.deviceScale Y:-44 * GWORLD.deviceScale];
            [bg addChild:text];
            
            strInfo = [NSString stringWithFormat:@"%@ : %d", [GINFO getDescription:@"Stat_Rng"], rng1];
            text = [[QobText alloc] initWithString:strInfo Size:CGSizeMake(128, 16) Align:UITextAlignmentLeft Font:@"TrebuchetMS-Bold" FontSize:12 Retina:true];
            [text setColorR:240 G:255 B:255];
            [text setPosX:20 * GWORLD.deviceScale Y:-44 * GWORLD.deviceScale];
            [bg addChild:text];
            
            strInfo = [NSString stringWithFormat:@"%@ : %d", [GINFO getDescription:@"Stat_Def"], def1];
            text = [[QobText alloc] initWithString:strInfo Size:CGSizeMake(128, 16) Align:UITextAlignmentLeft Font:@"TrebuchetMS-Bold" FontSize:12 Retina:true];
            [text setColorR:240 G:255 B:255];
            [text setPosX:-120 * GWORLD.deviceScale Y:-60 * GWORLD.deviceScale];
            [bg addChild:text];
            
            strInfo = [NSString stringWithFormat:@"%@ : %d", [GINFO getDescription:@"Stat_Spd"], spd1];
            text = [[QobText alloc] initWithString:strInfo Size:CGSizeMake(128, 16) Align:UITextAlignmentLeft Font:@"TrebuchetMS-Bold" FontSize:12 Retina:true];
            [text setColorR:240 G:255 B:255];
            [text setPosX:20 * GWORLD.deviceScale Y:-60 * GWORLD.deviceScale];
            [bg addChild:text];
        }
    }
    [_QLIST addObject:bg];
    
    [self updateSlot];
}

- (void)uninstallMach:(int)unit_id
{
    NSArray *listBuildSet = [GINFO listBuyBuildSet];
    MachBuildSet *buildSet = [listBuildSet objectAtIndex:unit_id];
    NSLog(@"uninstallMach [%@] [%d]", buildSet.machName, unit_id);
	if(buildSet == nil) return;
    
    int nCount = 0;
    for(MachBuildSet *buildSet in listBuildSet)
    {
        bool bActive = buildSet.onSlot;
        if(bActive) nCount++;
    }
	
    NSLog(@"BuildSet count %d [%s]",nCount, buildSet.onSlot ? "true" : "false");
    if(buildSet.onSlot) buildSet.onSlot = false;
    else if(nCount < 7) buildSet.onSlot = true;
//	[self refreshButtonsWithType:BMT_UPGRADEMACH];
//	[GAMEUI.dlgUpgrade refreshMachButtons];
//	[GAMEUI.dlgUpgrade setUpgradeMachItem:buildSet];
    [self updateSlot];
    
    QobImage *bg = [_QLIST objectAtIndex:unit_id];
    if(bg)
    {
        [[bg childAtIndex:1] setVisual:buildSet.onSlot];
        [[bg childAtIndex:2] setVisual:(!buildSet.onSlot)];
    }
	
	[SOUNDMGR play:[GINFO sfxID:SND_UNINSTALL]];
}



- (void)upgradeMach:(int)unit_id
{
    NSArray *listBuildSet = [GINFO listBuyBuildSet];
    MachBuildSet *buildSet = [listBuildSet objectAtIndex:unit_id];
	if(buildSet == nil) return;
    TMachBuildSet *set = [buildSet buildSet];
    
    if(buildSet.level < buildSet.maxLevel)
	{
        if (GSLOT->cr < set->upgradeCost) return;

		buildSet.level++;
		GSLOT->cr -= set->upgradeCost;
        [self refreshCR];
	}
	
    [self refreshList:unit_id];
    
//	[self refreshButtonsWithType:BMT_UPGRADEMACH];
}

- (void)refreshCR
{
    QobBase *pTop = nil;
    if(_cr)
    {
        pTop = [_cr getParent];
        if (pTop)
        {
            [_cr remove];
//            [_cr release];
        }
        else return;
    }
    
    _cr = [[QobText alloc] initWithString:[NSString stringWithFormat:@"%d",GSLOT->cr] Size:CGSizeMake(128, 32) Align:UITextAlignmentRight Font:@"TrebuchetMS-Bold" FontSize:24 Retina:true];
    [_cr setPosX:-102 Y:185];
    [pTop addChild:_cr];
    [_cr setColorR:55 G:125 B:126];
}

- (void)handleButton:(NSNotification *)note
{
    if(_canClick) NSLog(@"canclick");
    
	if(![self isShow]) return;
//    if(!_canClick) return;
	
	QobButton *button = [note object];
	if(button == nil) return;
    
    NSLog(@"handleButton %d", button.buttonId);
	
	if([[note name]isEqualToString:@"PushButton"])
	{
		if(button.buttonId == BTNID_UPGRADE_MACH || button.buttonId == BTNID_UPGRADE_ATTACK)
		{
		}
	}
	if([[note name]isEqualToString:@"ReleaseButton"])
	{
		if(button.buttonId == BTNID_UPGRADE_MACH || button.buttonId == BTNID_UPGRADE_ATTACK)
		{
		}
	}
	else if([[note name]isEqualToString:@"PopButton"])
	{
        if(button.buttonId == 9999)
        {
            [GINFO saveDataFile];
            [g_main makeScreen:GSCR_SELECTSTAGE];
        }
        else if( button.buttonId == BTNID_UNIT || button.buttonId == BTNID_UNIT1 )
        {
            [GINFO saveDataFile];
            [g_main makeScreen:GSCR_SELECTSTAGE];
        }
        else if( button.buttonId == BTNID_BOMB )
        {
            [GINFO saveDataFile];
            [g_main makeScreen:GSCR_SHOPSPECIAL];
        }
        else if ( button.buttonId == BTNID_BASE )
        {
            [GINFO saveDataFile];
            [g_main makeScreen:GSCR_SHOPBASE];
        }
		else if(button.buttonId == BTNID_UPGRADE_MACH)
		{
        }
        else if(_canClick)
        {
            NSLog(@"click unit %d", button.buttonId);
            if(button.buttonId >= 1000)
            {
                [self upgradeMach:button.buttonId-1000];
            }
            else if(button.buttonId >= 100)
            {
                [self uninstallMach:button.buttonId-100];
            }
        }
	}
}

- (BOOL)onTap:(CGPoint)pt State:(int)state ID:(id)tapID
{
    NSLog(@"DlgShop %.02f", pt.y);
    if(state == TAP_START)
    {
        NSLog(@"DlgShop TAP_START %.02f", pt.y);
        
        if(pt.y < 60.0f )
        {
            _isScroll = false;
            _canClick = false;
            NSLog(@"can not click!");
        }
        else
        {
            _isScroll = true;
            _canClick = true;
            _startPos = pt.y;
        }
    }
    else if(state == TAP_MOVE)
    {
        if(_isScroll)
        {
            _scrollPos = pt.y - _startPos;
            _startPos = pt.y;
        }
    }
    else if(state == TAP_END)
    {
        NSLog(@"DlgShop TAP_END %.02f", pt.y);
        if(_isScroll)
        {
            _scrollPos = 0.0f;
        }
        
        _canClick = true;
    }
    
    return true;
}



@end
