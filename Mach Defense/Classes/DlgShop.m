//
//  DlgShop.m
//  MachDefense
//
//  Created by Dustin on 4/9/14.
//
//

#import "DlgShop.h"
#import "GobHvMach.h"
#import "GobHvM_Player.h"

@implementation DlgShop

- (id)init
{
    [super init];
    
    _isClick = false;
    _scrollPos = 0.0f;
    _topPos = 115.0f;
    
    _QSLOT = [[NSMutableArray alloc]init];
    
    Tile2D *tile = [TILEMGR getTileForRetina:[NSString stringWithFormat:@"Shop_Screen_BG.png"]];
    QobImage *bg = [[QobImage alloc] initWithTile:tile tileNo:0];
    [bg setScaleY:1.15f];
    [bg setLayer:0];
    [self addChild:bg];
    
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
    [self addChild:bgTop];
    
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
	
	return self;
}

- (void)dealloc
{
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc removeObserver:self];

    [_QSLOT removeAllObjects];
    [_QSLOT release];
    _QSLOT = nil;
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
    _bottomPos = 41*listBuildSet.count + _topPos;
    int nSlot = 0;
    for(int i = 0; i < listBuildSet.count; i++)
    {
        NSString *strInfo;
        GobHvM_Player *mach, *nextMach;
        int atk1, atk2, rng1, rng2, def1, def2, spd1, spd2;
        float x = 0.0f;
        float y = -i*80;
        
        MachBuildSet *buildSet = [listBuildSet objectAtIndex:i];
        if(buildSet == nil) continue;

        TMachBuildSet *set = [buildSet buildSet];
        
        bool bActive = buildSet.onSlot;
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
        
        tile = [TILEMGR getTileForRetina:@"Upgrade_Btn.png"];
        [tile tileSplitX:1 splitY:3];
        QobButton *btn = [[QobButton alloc] initWithTile:tile TileNo:0 ID:100+i];
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
        
        if(bActive)
        {
            GobHvM_Player *pSlotPlayer = [[GobHvM_Player alloc] init];
            [pSlotPlayer setPosX:106 Y:142-nSlot*50];
            [self addChild:pSlotPlayer];
            [pSlotPlayer setDir:M_PI / 2.f];
            [pSlotPlayer setState:MACHSTATE_STOP];
            [pSlotPlayer setUiModel:true];
            [pSlotPlayer setLayer:5];
            [pSlotPlayer setParts:@"DummyParts" partsType:PARTS_BASE];
            
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
}


- (void)handleButton:(NSNotification *)note
{
	if(![self isShow]) return;
	
	QobButton *button = [note object];
	if(button == nil) return;
	
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
		if(button.buttonId == BTNID_UPGRADE_MACH)
		{
        }
	}
}

- (BOOL)onTap:(CGPoint)pt State:(int)state ID:(id)tapID
{
        NSLog(@"DlgShop %d", state);
    if(state == TAP_START)
    {
        if(!_isClick)
        {
            _startPos = pt.y;
        }
    }
    else if(state == TAP_MOVE)
    {
        if(!_isClick)
        {
            _scrollPos = pt.y - _startPos;
            _startPos = pt.y;
        }
    }
    else if(state == TAP_END)
    {
        if(!_isClick)
        {
            _scrollPos = 0.0f;
        }
        
        _isClick = NO;
    }
    
    return true;
}



@end
