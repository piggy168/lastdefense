//
//  DlgShop.m
//  MachDefense
//
//  Created by Dustin on 1/29/15.
//
//

#import "DlgShopBase.h"
#import "GameMain.h"
#import "GobHvMach.h"
#import "GuiGame.h"
#import "GobHvM_Player.h"
#import "GobMachParts.h"
#import "BaseUpgradeSet.h"
#import "WndBuildSlot.h"

@implementation DlgShopBase

static NSString *baseUpgradeName[6] = { @"Base Weapon", @"Base Armor", @"Production Speed", @"Crystal", @"Income Rate", @"Income Storage" };
static NSString *baseUpgrade[6] = { @"BaseWeapon", @"BaseArmor", @"ProductionSpeed", @"Crystal", @"IncomeRate", @"IncomeStorage" };
static NSString *baseUpgradeDsc[6] = { @"Increase the attack power of base weapon",
                                        @"Increase the armor of the base",
                                        @"Increase unit production speed",
                                        @"Increase the rate of Crystal drops",
                                        @"Increase income generation rate",
                                        @"Increase income storage capacity and initial income"};

- (id)init
{
    [super init];
    [self setUiReceiver:true];
    
    _canClick = true;
    _isScroll = false;
    _scrollPos = 0.0f;
    _topPos = 115.0f+24;
    _buttonId = -1;
    
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
    
//    tile = [TILEMGR getTileForRetina:[NSString stringWithFormat:@"Shop_Screen_BG_right_filter.png"]];
//    QobImage *bgMid = [[QobImage alloc] initWithTile:tile tileNo:0];
//    [bgMid setScaleY:1.3f];
//    [bgMid setLayer:2];
//    [bgMid setPosX:104 Y:0];
//    [bg addChild:bgMid];
    
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
    
    _desc = nil;
    _prise = nil;
    _mach = nil;
    [self updateList];
    [self refreshDlg];
    [self refreshButton];
    
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

    for(int i=0; i<6; i++)
    {
        [_QSLOT[i].btn remove];
        _QSLOT[i].btn = nil;
    }
    
    [_cr remove];
    _cr = nil;
    
    [_desc remove];
    _desc = nil;

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
    for(int i=0; i<6; i++)
    {
        TShopBaseButton baseInfo;
        Tile2D *tile = [TILEMGR getTileForRetina:[NSString stringWithFormat:@"base_shop_ui.png"]];
        [tile tileSplitX:1 splitY:3];
        baseInfo.btn = [[QobButton alloc] initWithTile:tile TileNo:0 ID:i+10000];
        [baseInfo.btn setReleaseTileNo:1];
        [_base addChild:baseInfo.btn];
        [baseInfo.btn setPosX:20 Y:15-i*43];
        
        baseInfo.text = [[QobText alloc] initWithString:[NSString stringWithString:baseUpgradeName[i]] Size:CGSizeMake(256, 25) Align:UITextAlignmentLeft Font:@"TrebuchetMS-Bold" FontSize:20 Retina:true];
        [baseInfo.text setColorR:255 G:255 B:255];
        [baseInfo.text setPosX:-40 Y:0];
        [baseInfo.btn addChild:baseInfo.text];
        baseInfo.cr = nil;
        baseInfo.lv = nil;
        baseInfo.txt = nil;
        
        _QSLOT[i] = baseInfo;
    }
    
    Tile2D *tile = [TILEMGR getTileForRetina:[NSString stringWithFormat:@"shop_base_desc_board.png"]];
    QobImage *bgDesc = [[QobImage alloc] initWithTile:tile tileNo:0];
    [bgDesc setPosX:20 Y:-270];
    [_base addChild:bgDesc];
    
    tile = [TILEMGR getTileForRetina:@"Upgrade_Btn.png"];
    [tile tileSplitX:1 splitY:3];
    _upgradeBtn = [[QobButton alloc] initWithTile:tile TileNo:0 ID:100];
    [_upgradeBtn setReleaseTileNo:1];
    [_upgradeBtn setPosX:65 Y:0 ];
    [bgDesc addChild:_upgradeBtn];
    
    [self setSelectUpgrade:0];
}

- (void) refreshDlg
{
    if(_mach) {
        [_mach remove];
        _mach = nil;
    }
    _mach = [[GobHvM_Player alloc] init];
    [_mach setPosX:-26 Y:-275];
    [_mach setUiModel:true];
    [_base addChild:_mach];
    [_mach setMachType:MACHTYPE_TURRET];
    [_mach setState:MACHSTATE_STOP];
    [_mach setDir:M_PI/2.f];
    [_mach setParts:@"DummyParts" partsType:PARTS_BASE];
    
    BaseUpgradeSet *upgradeSet = [GINFO getBaseUpgradeSet:@"BaseArmor"];
    NSString *strName = [NSString stringWithFormat:@"Base%02d", upgradeSet.level + 1];
    [_mach setParts:strName partsType:PARTS_BODY];
    
    upgradeSet = [GINFO getBaseUpgradeSet:@"BaseWeapon"];
    strName = [NSString stringWithFormat:@"BaseWpn%02d", upgradeSet.level + 1];
    GobMachParts *parts = [_mach setParts:strName partsType:PARTS_WPN];
    [parts refreshRotationPos];
}

- (void) refreshButton
{
    for (int i=0; i<6; i++) {
        TShopBaseButton info = _QSLOT[i];
        BaseUpgradeSet *upgradeSet = [GINFO getBaseUpgradeSet:baseUpgrade[i]];
        TBaseUpgradeSet *upgradeInfo = [upgradeSet upgradeSet];
        TBaseUpgradeSet *nextUpgradeInfo = [upgradeSet nextUpgradeSet];
        
        if (info.cr) {
            [info.cr remove];
            info.cr = nil;
            [info.lv remove];
            info.lv = nil;
        }
        
        if (info.txt) {
            [info.txt remove];
            info.txt = nil;
        }
        
        info.cr = [[QobText alloc] initWithString:[NSString stringWithFormat:@"%d cr", upgradeInfo->upgradeCost] Size:CGSizeMake(128, 16) Align:UITextAlignmentRight Font:@"TrebuchetMS-Bold" FontSize:16 Retina:true];
        [info.cr setColorR:240 G:255 B:255];
        [info.cr setPosX:-10 Y:0];
        [info.btn addChild:info.cr];
        
        int nLvFont = 16;
        float fLvPosY = 0;
        
        if(i==0)
        {
            NSString *wpnName = [NSString stringWithFormat:@"BaseWpn%02d", upgradeSet.level + 1];
            WeaponInfo *wpnInfo = [GINFO getWeaponInfo:wpnName];
            if(wpnInfo)
            {
                wpnName = [NSString stringWithFormat:@"BaseWpn%02d", upgradeSet.level + 2];
                WeaponInfo *nextWpnInfo = [GINFO getWeaponInfo:wpnName];
                NSString *str = nil;
                if (nextWpnInfo)
                    str = [NSString stringWithFormat:@"Attack : %d(%+d)", wpnInfo.atkPoint, nextWpnInfo.atkPoint - wpnInfo.atkPoint];
                else
                    str = [NSString stringWithFormat:@"Attack : %d(Max)", wpnInfo.atkPoint];
                
                info.txt = [[QobText alloc] initWithString:str Size:CGSizeMake(128, 16) Align:UITextAlignmentLeft Font:@"TrebuchetMS-Bold" FontSize:14 Retina:true];
                [info.txt setColorR:240 G:255 B:255];
                [info.txt setPosX:60 Y:-5];
                [info.btn addChild:info.txt];
                fLvPosY = 5;
                nLvFont = 14;
            }
        }
        else if(i==1)
        {
            NSString *strInfo;
            if(nextUpgradeInfo)
                strInfo = [NSString stringWithFormat:@"Armor : %d(%+d)", (int)(upgradeInfo->param / 100), (int)(nextUpgradeInfo->param - upgradeInfo->param) / 100];
            else
                strInfo = [NSString stringWithFormat:@"Armor : %d(Max)", (int)(upgradeInfo->param / 100)];
            
            info.txt = [[QobText alloc] initWithString:strInfo Size:CGSizeMake(128, 16) Align:UITextAlignmentLeft Font:@"TrebuchetMS-Bold" FontSize:14 Retina:true];
            [info.txt setColorR:240 G:255 B:255];
            [info.txt setPosX:60 Y:-5];
            [info.btn addChild:info.txt];
            fLvPosY = 5;
            nLvFont = 14;
        }
        else if(i==5)
        {
            NSString *strInfo;
            if(nextUpgradeInfo)
                strInfo = [NSString stringWithFormat:@"Size : %d(%+d)", (int)upgradeInfo->param, (int)(nextUpgradeInfo->param - upgradeInfo->param)];
            else
                strInfo = [NSString stringWithFormat:@"Size : %d(Max)", (int)upgradeInfo->param];
            
            info.txt = [[QobText alloc] initWithString:strInfo Size:CGSizeMake(128, 16) Align:UITextAlignmentLeft Font:@"TrebuchetMS-Bold" FontSize:14 Retina:true];
            [info.txt setColorR:240 G:255 B:255];
            [info.txt setPosX:60 Y:-5];
            [info.btn addChild:info.txt];
            fLvPosY = 5;
            nLvFont = 14;
        }
        
        NSString *strNextLv = @"Max";
        if ( upgradeSet.maxLevel > upgradeSet.level+2 ) strNextLv = [NSString stringWithFormat:@"%d", upgradeSet.level+2];
        
        info.lv = [[QobText alloc] initWithString:[NSString stringWithFormat:@"Lv. %d -> %@", upgradeSet.level+1, strNextLv] Size:CGSizeMake(128, 16) Align:UITextAlignmentLeft Font:@"TrebuchetMS-Bold" FontSize:nLvFont Retina:true];
        [info.lv setColorR:200 G:255 B:200];
        [info.lv setPosX:60 Y:fLvPosY];
        [info.lv setLayer:VLAYER_FORE_UI];
        [info.btn addChild:info.lv];
        
        _QSLOT[i] = info;
    }
}

- (void) setSelectUpgrade:(int)sel
{
    if(sel < 0) return;
    _buttonId = sel;
    
    for(int i=0; i<6; i++)
    {
        [_QSLOT[i].btn setDefaultTileNo:(sel == i) ? 1 : 0];
    }
    
    if (_desc) {
        [_desc remove];
        _desc = nil;
    }
    
    _desc = [[QobText alloc] initWithString:[NSString stringWithString:baseUpgradeDsc[sel]] Size:CGSizeMake(512, 32) Align:UITextAlignmentCenter Font:@"TrebuchetMS-Bold" FontSize:16 Retina:true];
    [_desc setPosX:15 Y:-245];
    [_base addChild:_desc];
    [_desc setColorR:255 G:255 B:255];
    
    BaseUpgradeSet *upgradeSet = [GINFO getBaseUpgradeSet:baseUpgrade[sel]];
    TBaseUpgradeSet *upgradeInfo = [upgradeSet upgradeSet];
    TBaseUpgradeSet *nextUpgradeInfo = [upgradeSet nextUpgradeSet];
    
    if (_prise) {
        [_prise remove];
        _prise = nil;
    }
    
    _prise = [[QobText alloc] initWithString:[NSString stringWithFormat:@"%d",upgradeInfo->upgradeCost] Size:CGSizeMake(256, 32) Align:UITextAlignmentCenter Font:@"TrebuchetMS-Bold" FontSize:16 Retina:true];
    [_prise setPosX:5 Y:4];
    [_upgradeBtn addChild:_prise];
    [_prise setColorR:255 G:255 B:255];
    
    [_upgradeBtn setActive:GSLOT->cr >= upgradeInfo->upgradeCost && nextUpgradeInfo != NULL];
}

- (void) setUpgrade
{
    if(_buttonId == -1) return;
    
    BaseUpgradeSet *upgradeSet = [GINFO getBaseUpgradeSet:baseUpgrade[_buttonId]];
    if(upgradeSet == nil || upgradeSet.level >= upgradeSet.maxLevel) return;
    TBaseUpgradeSet *upgrade = [upgradeSet upgradeSet];
    if(upgrade == NULL || GSLOT->cr < upgrade->upgradeCost) return;
    
    upgradeSet.level++;
    GSLOT->cr -= upgrade->upgradeCost;
    
    [GINFO updateBaseUpgrade];
    [GAMEUI refreshMaxMineral];
    
    if(_buttonId == 0)
    {
        NSString *strName = [NSString stringWithFormat:@"BaseWpn%02d", upgradeSet.level + 1];
        [GWORLD.baseMach setParts:strName partsType:PARTS_WPN];
    }
    else if(_buttonId == 1)
    {
        //		NSString *strName = [NSString stringWithFormat:@"Base%02d", upgradeSet.level + 1];
        //		GobMachParts *parts = [GWORLD.baseMach setParts:strName partsType:PARTS_BODY];
        [GWORLD.baseMach setHp:GVAL.baseDef];
        [GWORLD.baseMach setHpMax:GVAL.baseDef];
        [GAMEUI refreshMyGauge:1.f];
    }
    
    [SOUNDMGR play:[GINFO sfxID:SND_UPGRADE_BASE]];
    
    [self refreshDlg];
    [self refreshButton];
    [self refreshCR];
}


//- (void) updateList
//{
//    NSArray *array = [GINFO listBuyAttackSet];
//    _bottomPos = 88*array.count;// + _topPos;   
//    NSLog(@"count %d",array.count);
//    int i=0;
//	for(SpAttackSet *set in array)
//    {
//        NSString *strInfo;
//        float x = 0.0f;
//        float y = -i*80;
//
//        TSpAttackSet *attack = [set attackSet];
//        
//        Tile2D *tile = [TILEMGR getTileForRetina:[NSString stringWithFormat:@"Upgrade_Special_BG.png"]];
//        QobImage *bg = [[QobImage alloc] initWithTile:tile tileNo:0];
//        [bg setPosX:x Y:y];
//        [bg setLayer:1];
//        [_base addChild:bg];
//        
//        tile = [TILEMGR getTileForRetina:[NSString stringWithFormat:@"Icon%05d.png", attack->itemId]];
//		[tile tileSplitX:1 splitY:1];
//        QobImage *image = [[QobImage alloc] initWithTile:tile tileNo:0];
//        [image setPosX:-138 * GWORLD.deviceScale Y:11 * GWORLD.deviceScale];
//        [image setScale:0.9f];
//		[bg addChild:image];
//        
//        QobText *text = [[QobText alloc] initWithString:[NSString stringWithFormat:@"%@", set.attackName] Size:CGSizeMake(128, 16) Align:UITextAlignmentCenter Font:@"TrebuchetMS-Bold" FontSize:14 Retina:true];
//        [text setColorR:255 G:255 B:255];
//        [text setPosX:-36 Y:31];
//        [text setLayer:2];
//        [bg addChild:text];
//
//        tile = [TILEMGR getTileForRetina:@"Buy_Btn.png"];
//        [tile tileSplitX:1 splitY:3];
//        QobButton *btn = [[QobButton alloc] initWithTile:tile TileNo:0 ID:-100*attack->itemId-i];
//        [btn setReleaseTileNo:1];
//        if(_glView.deviceType == DEVICE_IPAD) [btn setPosX:224 Y:80];
//        else [btn setPosX:60 Y:-12 ];
//        [btn setLayer:2];
//        [bg addChild:btn];
//        
//        NSLog(@"item id [%d]",attack->itemId);
//        tile = [TILEMGR getTileForRetina:@"Upgrade_Btn.png"];
//        [tile tileSplitX:1 splitY:3];
//        btn = [[QobButton alloc] initWithTile:tile TileNo:0 ID:1000*attack->itemId+i];
//        [btn setReleaseTileNo:1];
//        if(_glView.deviceType == DEVICE_IPAD) [btn setPosX:224 Y:80];
//        else [btn setPosX:60 Y:19 ];
//        [btn setLayer:2];
//        [bg addChild:btn];
//        
//        TSpAttackSet *nextAttack = [set nextAttackSet];
//        if(set.level+1 >= set.maxLevel)
//        {
//            [btn setActive:false];
//            tile = [TILEMGR getTileForRetina:[NSString stringWithFormat:@"Icon%05d.png", attack->itemId]];
//        }
//        else tile = [TILEMGR getTileForRetina:[NSString stringWithFormat:@"Icon%05d.png", nextAttack->itemId]];
//
//        [tile tileSplitX:1 splitY:1];
//        QobImage *image2 = [[QobImage alloc] initWithTile:tile tileNo:0];
//        [image2 setPosX:-16 * GWORLD.deviceScale Y:11 * GWORLD.deviceScale];
//        [image2 setScale:0.9f];
//        [bg addChild:image2];
//        
//        int upgradeCost = nextAttack ? attack->upgradeCost + (nextAttack->cost - attack->cost) * set.count : 0;
//        
//        text = [[QobText alloc] initWithString:[NSString stringWithFormat:@"%d cr", upgradeCost] Size:CGSizeMake(64, 16) Align:UITextAlignmentCenter Font:@"TrebuchetMS-Bold" FontSize:14 Retina:true];
//        [text setColorR:240 G:255 B:255];
//        [text setPosX:7 Y:7];
//        [text setLayer:2];
//        [btn addChild:text];
//        
//        strInfo = [NSString stringWithFormat:@"Count : %d", set.count];
//        text = [[QobText alloc] initWithString:strInfo Size:CGSizeMake(64, 16) Align:UITextAlignmentCenter Font:@"TrebuchetMS-Bold" FontSize:14 Retina:true];
//        [text setColorR:240 G:255 B:255];
//        [text setPosX:-120 Y:-40];
//        [text setLayer:2];
//        [btn addChild:text];
//                
//        [_QLIST addObject:bg];
//        i++;
//    }
//    
//    [self updateSlot];
//}


//- (void) refreshList:(int)unit_id
//{
//    int uid = unit_id/1000;
//    int index = unit_id%1000;
//    QobImage *bg = [_QLIST objectAtIndex:index];
//    if(bg == nil)
//    {
//        return;
////        [_QLIST removeObject:bg];
////        [bg remove];
//        //bg = nil;
//    }
//    
////    NSArray *listBuildSet = [GINFO listBuyAttackSet];
////    NSLog(@"updateList %d",listBuildSet.count);
////    _bottomPos = 88*listBuildSet.count;// + _topPos;
//    //    int nSlot = 0;
////    for(int i = 0; i < listBuildSet.count; i++)
//    {
//        int i = index;
//        NSString *strInfo;
//        float x = 0.0f;
//        float y = -i*80;
//        
//        SpAttackSet *set = [self getAttackSet:uid];
//        if(set == nil) return;
//        
//        [bg removeAllChild];
//        
//        TSpAttackSet *attack = [set attackSet];
//        
//        Tile2D *tile = [TILEMGR getTileForRetina:[NSString stringWithFormat:@"Icon%05d.png", attack->itemId]];
//		[tile tileSplitX:1 splitY:1];
//        QobImage *image = [[QobImage alloc] initWithTile:tile tileNo:0];
//        [image setPosX:-138 * GWORLD.deviceScale Y:11 * GWORLD.deviceScale];
//        [image setScale:0.9f];
//		[bg addChild:image];
//        
//        QobText *text = [[QobText alloc] initWithString:[NSString stringWithFormat:@"%@", set.attackName] Size:CGSizeMake(128, 16) Align:UITextAlignmentCenter Font:@"TrebuchetMS-Bold" FontSize:14 Retina:true];
//        [text setColorR:255 G:255 B:255];
//        [text setPosX:-36 Y:31];
//        [text setLayer:2];
//        [bg addChild:text];
//        
//        tile = [TILEMGR getTileForRetina:@"Buy_Btn.png"];
//        [tile tileSplitX:1 splitY:3];
//        QobButton *btn = [[QobButton alloc] initWithTile:tile TileNo:0 ID:-100*attack->itemId-i];
//        [btn setReleaseTileNo:1];
//        if(_glView.deviceType == DEVICE_IPAD) [btn setPosX:224 Y:80];
//        else [btn setPosX:60 Y:-12 ];
//        [btn setLayer:2];
//        [bg addChild:btn];
//        
//        tile = [TILEMGR getTileForRetina:@"Upgrade_Btn.png"];
//        [tile tileSplitX:1 splitY:3];
//        btn = [[QobButton alloc] initWithTile:tile TileNo:0 ID:unit_id];
//        [btn setReleaseTileNo:1];
//        if(_glView.deviceType == DEVICE_IPAD) [btn setPosX:224 Y:80];
//        else [btn setPosX:60 Y:19 ];
//        [btn setLayer:2];
//        [bg addChild:btn];
//        
//        TSpAttackSet *nextAttack = [set nextAttackSet];
//        if(set.level+1 >= set.maxLevel)
//        {
//            [btn setActive:false];
//            tile = [TILEMGR getTileForRetina:[NSString stringWithFormat:@"Icon%05d.png", attack->itemId]];
//        }
//        else tile = [TILEMGR getTileForRetina:[NSString stringWithFormat:@"Icon%05d.png", nextAttack->itemId]];
//        
//        [tile tileSplitX:1 splitY:1];
//        QobImage *image2 = [[QobImage alloc] initWithTile:tile tileNo:0];
//        [image2 setPosX:-16 * GWORLD.deviceScale Y:11 * GWORLD.deviceScale];
//        [image2 setScale:0.9f];
//        [bg addChild:image2];
//        
//        int upgradeCost = nextAttack ? attack->upgradeCost + (nextAttack->cost - attack->cost) * set.count : 0;
//        
//        text = [[QobText alloc] initWithString:[NSString stringWithFormat:@"%d cr", upgradeCost] Size:CGSizeMake(64, 16) Align:UITextAlignmentCenter Font:@"TrebuchetMS-Bold" FontSize:14 Retina:true];
//        [text setColorR:240 G:255 B:255];
//        [text setPosX:7 Y:7];
//        [text setLayer:2];
//        [btn addChild:text];
//        
//        strInfo = [NSString stringWithFormat:@"Count : %d", set.count];
//        text = [[QobText alloc] initWithString:strInfo Size:CGSizeMake(64, 16) Align:UITextAlignmentCenter Font:@"TrebuchetMS-Bold" FontSize:14 Retina:true];
//        [text setColorR:240 G:255 B:255];
//        [text setPosX:-120 Y:-40];
//        [text setLayer:2];
//        [btn addChild:text];
//    }            
//    
//    [self updateSlot];
//}



//- (void)upgradeMach:(int)unit_id
//{
////    NSArray *listBuildSet = [GINFO listBuyBuildSet];
////    MachBuildSet *buildSet = [listBuildSet objectAtIndex:unit_id];
////	if(buildSet == nil) return;
////    TMachBuildSet *set = [buildSet buildSet];
//    int uid = unit_id/1000;
//    int index = unit_id%1000;
//    
//    SpAttackSet *buildSet = [self getAttackSet:uid];
//    if(buildSet == nil) return;
//    
//    TSpAttackSet *attack = [buildSet attackSet];
//    TSpAttackSet *nextAttack = [buildSet nextAttackSet];
//    
//    if(buildSet.level < buildSet.maxLevel)
//	{
//        if (GSLOT->cr < attack->upgradeCost) return;
//        
//		buildSet.level++;
//		GSLOT->cr -= attack->upgradeCost;
//        [self refreshCR];
//	}
//    
//    if (nextAttack) unit_id = nextAttack->itemId*1000+index;
//
//    [self refreshList:unit_id];
////	[self refreshButtonsWithType:BMT_UPGRADEMACH];
//}

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
        if (button.buttonId == 100) {
            [self setUpgrade];
            [GINFO saveDataFile];
        }
        if ( button.buttonId == BTNID_BASE || button.buttonId == 9999 )
        {
            [GINFO saveDataFile];
            [g_main makeScreen:GSCR_SELECTSTAGE];
        }
        else if (button.buttonId >= 10000)
        {
            [self setSelectUpgrade:button.buttonId-10000];
        }
        else if( button.buttonId == BTNID_UNIT )
        {
            [GINFO saveDataFile];
            [g_main makeScreen:GSCR_SHOPMACH];
        }
        else if( button.buttonId == BTNID_BOMB)
        {
            [GINFO saveDataFile];
            [g_main makeScreen:GSCR_SHOPSPECIAL];
        }
		else if(button.buttonId == BTNID_UPGRADE_MACH)
		{
        }
	}
}

- (BOOL)onTap:(CGPoint)pt State:(int)state ID:(id)tapID
{
//    NSLog(@"DlgShop %.02f", pt.y);
//    if(state == TAP_START)
//    {
//        NSLog(@"DlgShop TAP_START %.02f", pt.y);
//        
//        if(pt.y < 60.0f )
//        {
//            _isScroll = false;
//            _canClick = false;
//            NSLog(@"can not click!");
//        }
//        else
//        {
//            _isScroll = true;
//            _canClick = true;
//            _startPos = pt.y;
//        }
//    }
//    else if(state == TAP_MOVE)
//    {
//        if(_isScroll)
//        {
//            _scrollPos = pt.y - _startPos;
//            _startPos = pt.y;
//        }
//    }
//    else if(state == TAP_END)
//    {
//        NSLog(@"DlgShop TAP_END %.02f", pt.y);
//        if(_isScroll)
//        {
//            _scrollPos = 0.0f;
//        }
//        
//        _canClick = true;
//    }
    
    return true;
}



@end
