//
//  DlgUpgradeEquip.m
//  MachDefense
//
//  Created by HaeJun Byun on 10. 11. 22..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "DlgUpgradeEquip.h"
#import "GobHvM_Player.h"
#import "GuiGame.h"
#import "DlgBuildMach.h"
#import "DlgUpgradeItem.h"
#import "DlgSpecialAttack.h"
#import "SpAttackSet.h"

@implementation DlgUpgradeEquip

- (id)init
{
	[super initWithCommonImg:@"CommonUI" TopImg:@"Upgrade" Height:615 * GWORLD.deviceScale];
	
	Tile2D *tile = [TILEMGR getTileForRetina:@"Common_Btn_CLOSE.png"];
	[tile tileSplitX:1 splitY:2];
	[self addButton:tile ID:BTNID_UPGRADE_EQUIP_CLOSE];
	
//	[self refreshButtons];
	
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

- (void)tick
{
	if(_upgradeInd != nil)
	{
		[_upgradeInd setShow:((int)(g_time * 2.f) % 2) == 0];
	}

	[super tick];
}

- (void)refreshMachButtons
{
	Tile2D *tile;
	QobButton *btn;
	QobImage *img;
	NSArray *listBuildSet = [GINFO listBuyBuildSet];
	
	if(_buttonsBase != nil) [_buttonsBase remove];
	_buttonsBase = [[QobBase alloc] init];
	[_buttonsBase setPosY:-96 * GWORLD.deviceScale];
	[_bgTop addChild:_buttonsBase];
	
	_upgradeInd = [[QobBase alloc] init];
	[_buttonsBase addChild:_upgradeInd];
	
	_dlgUpgradeItem = nil;

	tile = [TILEMGR getTileForRetina:@"UpgradeEquip_MachInfo.png"];
	[tile tileSplitX:1 splitY:1];
	img = [[QobImage alloc] initWithTile:tile tileNo:0];
	[img setPosY:-415 * GWORLD.deviceScale];
	[_buttonsBase addChild:img];
	
	tile = [TILEMGR getTileForRetina:@"UpgradeEquip_SelMach.png"];
	[tile tileSplitX:1 splitY:1];
	img = [[QobImage alloc] initWithTile:tile tileNo:0];
	[img setBlendType:BT_ADD];
	[img setShow:false];
	[img setLayer:VLAYER_FORE_UI];
	[_buttonsBase addChild:img];
	_imgSelWeapon = img;
	
	_buildBtnCnt = 0;
	for(int i = 0; i < listBuildSet.count; i++)
	{
		float x = ((_buildBtnCnt % 5) * 92.f - 184) * GWORLD.deviceScale;
		float y = -(_buildBtnCnt / 5) * 124.f * GWORLD.deviceScale;
		MachBuildSet *buildSet = [listBuildSet objectAtIndex:i];
		if(buildSet == nil) continue;
		
		TMachBuildSet *set = [buildSet buildSet];
		
		bool bActive = !buildSet.onSlot;
		
		tile = [TILEMGR getTileForRetina:@"Btn_MachBuild.png"];
		[tile tileSplitX:2 splitY:1];
		btn = [[QobButton alloc] initWithTile:tile TileNo:0 ID:BTNID_UPGRADE_MACH];
		[btn setReleaseTileNo:0];
		[btn setDataObject:buildSet];
		[btn setIntData:_buildBtnCnt];
		[btn setPosX:x Y:y];
		[_buttonsBase addChild:btn];
		
		img = [[QobImage alloc] initWithTile:[buildSet machTile] tileNo:0];
		[img setPosY:20 * GWORLD.deviceScale];
		[img setLayer:VLAYER_FORE_UI];
		[btn addChild:img];
		
		NSString *machName = [GINFO getDescription:[NSString stringWithFormat:@"MN_%@", buildSet.machName]];
		if(machName == nil) machName = buildSet.machName;
		QobText *text = [[QobText alloc] initWithString:machName Size:CGSizeMake(128, 16) Align:UITextAlignmentCenter Font:@"TrebuchetMS-Bold" FontSize:13 Retina:true];
		[text setColorR:0 G:0 B:0];
		[text setPosY:-9 * GWORLD.deviceScale];
		[text setLayer:VLAYER_FORE_UI];
		[btn addChild:text];
		
		text = [[QobText alloc] initWithString:machName Size:CGSizeMake(128, 16) Align:UITextAlignmentCenter Font:@"TrebuchetMS-Bold" FontSize:13 Retina:true];
		[text setColorR:240 G:255 B:255];
		[text setPosY:-10 * GWORLD.deviceScale];
		[text setLayer:VLAYER_FORE_UI];
		[btn addChild:text];
		
		text = [[QobText alloc] initWithString:[NSString stringWithFormat:@"Lv. %d/%d", buildSet.level+1, buildSet.maxLevel] Size:CGSizeMake(64, 16) Align:UITextAlignmentLeft Font:@"TrebuchetMS-Bold" FontSize:12 Retina:true];
		[text setColorR:240 G:255 B:255];
		[text setPosX:-4 * GWORLD.deviceScale Y:46 * GWORLD.deviceScale];
		[text setLayer:VLAYER_FORE_UI];
		[btn addChild:text];
		
		text = [[QobText alloc] initWithString:[NSString stringWithFormat:@"%d cr", set->upgradeCost] Size:CGSizeMake(64, 16) Align:UITextAlignmentCenter Font:@"TrebuchetMS-Bold" FontSize:14 Retina:true];
		[text setColorR:240 G:255 B:255];
		[text setPosY:-40 * GWORLD.deviceScale];
		[text setLayer:VLAYER_FORE_UI];
		[btn addChild:text];
		
		tile = [TILEMGR getTileForRetina:@"Btn_MachBuild.png"];
		[tile tileSplitX:2 splitY:1];
		img = [[QobImage alloc] initWithTile:tile tileNo:1];
		[img setUseAtlas:TRUE];
		[img setLayer:VLAYER_FORE_UI];
		[img setShow:!bActive || set->upgradeCost == 0];
		[btn addChild:img];
		
		if([buildSet nextBuildSet] && GSLOT->cr >= set->upgradeCost)
		{
			tile = [TILEMGR getTileForRetina:@"UpgradeEquip_UpgradeOn.png"];
			[tile tileSplitX:1 splitY:1];
			img = [[QobImage alloc] initWithTile:tile tileNo:1];
			[img setUseAtlas:TRUE];
			[img setPosX:x Y:y - 41 * GWORLD.deviceScale];
			[img setLayer:VLAYER_FORE_UI];
			[_upgradeInd addChild:img];
		}
		
		_buildBtnCnt++;
	}
}

- (void)refreshAttackButtons
{
	Tile2D *tile;
	QobButton *btn;
	QobImage *img;
	QobText *text;
	NSArray *listAttackSet = [GINFO listBuyAttackSet];
	
	if(_buttonsBase != nil) [_buttonsBase remove];
	_buttonsBase = [[QobBase alloc] init];
	[_buttonsBase setPosY:-96 * GWORLD.deviceScale];
	[_bgTop addChild:_buttonsBase];
	
	_upgradeInd = [[QobBase alloc] init];
	[_buttonsBase addChild:_upgradeInd];
	
	_dlgUpgradeItem = nil;
	
	tile = [TILEMGR getTileForRetina:@"UpgradeEquip_MachInfo.png"];
	[tile tileSplitX:1 splitY:1];
	img = [[QobImage alloc] initWithTile:tile tileNo:0];
	[img setPosY:-415 * GWORLD.deviceScale];
	[_buttonsBase addChild:img];

	tile = [TILEMGR getTileForRetina:@"UpgradeEquip_SelMach.png"];
	[tile tileSplitX:1 splitY:1];
	img = [[QobImage alloc] initWithTile:tile tileNo:0];
	[img setBlendType:BT_ADD];
	[img setShow:false];
	[img setLayer:VLAYER_FORE_UI];
	[_buttonsBase addChild:img];
	_imgSelWeapon = img;
	
	_buildBtnCnt = 0;
	for(int i = 0; i < listAttackSet.count; i++)
	{
		float x = ((_buildBtnCnt % 5) * 92.f - 184) * GWORLD.deviceScale;
		float y = -(_buildBtnCnt / 5) * 124.f * GWORLD.deviceScale;
		SpAttackSet *attackSet = [listAttackSet objectAtIndex:i];
		if(attackSet == nil) continue;
		
		TSpAttackSet *set = [attackSet attackSet];
		TSpAttackSet *nextSet = [attackSet nextAttackSet];
		
		int upgradeCost = set->upgradeCost;
		bool bActive = !attackSet.onSlot;
		
		if(nextSet) upgradeCost += (nextSet->cost - set->cost) * attackSet.count;
		
		tile = [TILEMGR getTileForRetina:@"Btn_MachBuild.png"];
		[tile tileSplitX:2 splitY:1];
		btn = [[QobButton alloc] initWithTile:tile TileNo:0 ID:BTNID_UPGRADE_ATTACK];
		[btn setReleaseTileNo:0];
		[btn setDataObject:attackSet];
		[btn setIntData:_buildBtnCnt];
		[btn setPosX:x Y:y];
		[_buttonsBase addChild:btn];
		
		tile = [TILEMGR getTileForRetina:[NSString stringWithFormat:@"Icon%05d.png", set->itemId]];
		[tile tileSplitX:1 splitY:1];
		img = [[QobImage alloc] initWithTile:tile tileNo:0];
		[img setPosY:11 * GWORLD.deviceScale];
		[btn addChild:img];
		
		text = [[QobText alloc] initWithString:[NSString stringWithFormat:@"Lv. %d/%d", attackSet.level+1, attackSet.maxLevel] Size:CGSizeMake(64, 16) Align:UITextAlignmentLeft Font:@"TrebuchetMS-Bold" FontSize:12 Retina:true];
		[text setColorR:240 G:255 B:255];
		[text setPosX:-4 * GWORLD.deviceScale Y:49 * GWORLD.deviceScale];
		[text setLayer:VLAYER_FORE_UI];
		[btn addChild:text];
		
		text = [[QobText alloc] initWithString:[NSString stringWithFormat:@"%d cr", upgradeCost] Size:CGSizeMake(64, 16) Align:UITextAlignmentCenter Font:@"TrebuchetMS-Bold" FontSize:14 Retina:true];
		[text setColorR:240 G:255 B:255];
		[text setPosY:-40 * GWORLD.deviceScale];
		[text setLayer:VLAYER_FORE_UI];
		[btn addChild:text];
		
		tile = [TILEMGR getTile:@"Btn_MachBuild.png"];
		[tile tileSplitX:2 splitY:1];
		img = [[QobImage alloc] initWithTile:tile tileNo:1];
		[img setUseAtlas:TRUE];
		[img setLayer:VLAYER_FORE_UI];
		[img setShow:!bActive || set->upgradeCost == 0];
		[btn addChild:img];
		
		if(nextSet && GSLOT->cr >= upgradeCost)
		{
			tile = [TILEMGR getTileForRetina:@"UpgradeEquip_UpgradeOn.png"];
			[tile tileSplitX:1 splitY:1];
			img = [[QobImage alloc] initWithTile:tile tileNo:1];
			[img setUseAtlas:TRUE];
			[img setPosX:x Y:y - 41 * GWORLD.deviceScale];
			[img setLayer:VLAYER_FORE_UI];
			[_upgradeInd addChild:img];
		}

		_buildBtnCnt++;
	}
}

- (void)setUpgradeMachItem:(MachBuildSet *)buildSet
{
	if(_dlgUpgradeItem != nil)
	{
		[_dlgUpgradeItem remove];
		_dlgUpgradeItem = nil;
	}

	if(buildSet != nil)
	{
		DlgUpgradeItem *upgrade = [[DlgUpgradeItem alloc] initWithBuildSet:buildSet];
		[upgrade setPosX:0 Y:-415 * GWORLD.deviceScale];
		[upgrade setLayer:VLAYER_FORE_UI];
		[_buttonsBase addChild:upgrade];
		_dlgUpgradeItem = upgrade;
	}
}

- (void)setUpgradeAttackItem:(SpAttackSet *)attackSet
{
	if(_dlgUpgradeItem != nil)
	{
		[_dlgUpgradeItem remove];
		_dlgUpgradeItem = nil;
	}
	
	if(attackSet != nil)
	{
		DlgUpgradeItem *upgrade = [[DlgUpgradeItem alloc] initWithAttackSet:attackSet];
		[upgrade setPosX:0 Y:-415 * GWORLD.deviceScale];
		[upgrade setLayer:VLAYER_FORE_UI];
		[_buttonsBase addChild:upgrade];
		_dlgUpgradeItem = upgrade;
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
			[_imgSelWeapon setPosX:button.pos.x Y:button.pos.y];
			[_imgSelWeapon setShow:true];
		}
	}
	if([[note name]isEqualToString:@"ReleaseButton"])
	{
		if(button.buttonId == BTNID_UPGRADE_MACH || button.buttonId == BTNID_UPGRADE_ATTACK)
		{
			[_imgSelWeapon setShow:false];
		}
	}
	else if([[note name]isEqualToString:@"PopButton"])
	{
		if(button.buttonId == BTNID_UPGRADE_MACH)
		{
			[_imgSelWeapon setPosX:button.pos.x Y:button.pos.y];
			[self setUpgradeMachItem:button.dataObject];

			[SOUNDMGR play:[GINFO sfxID:SND_MENU_CLICK]];
		}
		else if(button.buttonId == BTNID_UPGRADE_ATTACK)
		{
			[_imgSelWeapon setPosX:button.pos.x Y:button.pos.y];
			[self setUpgradeAttackItem:button.dataObject];
			
			[SOUNDMGR play:[GINFO sfxID:SND_MENU_CLICK]];
		}
	}
}

@end
