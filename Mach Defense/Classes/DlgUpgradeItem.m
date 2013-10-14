//
//  DlgUpgradeMach.m
//  MachDefense
//
//  Created by HaeJun Byun on 10. 11. 22..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "DlgUpgradeItem.h"
#import "DlgBuildMach.h"
#import "DlgSpecialAttack.h"
#import "GuiGame.h"
#import "MachBuildSet.h"
#import "SpAttackSet.h"
#import "GobHvM_Player.h"

@implementation DlgUpgradeItem

- (id)initWithBuildSet:(MachBuildSet *)buildSet
{
	[super init];
	
	int upgradeCost;
	Tile2D *tile;
	QobImage *img;
	QobButton *btn;
	GobHvM_Player *mach, *nextMach;
	NSString *strInfo;
	int atk1, atk2, rng1, rng2, def1, def2, spd1, spd2;
	
	tile = [TILEMGR getTileForRetina:@"UpgradeMachBG.png"];
	[tile tileSplitX:1 splitY:1];
	img = [[QobImage alloc] initWithTile:tile tileNo:0];
	[self addChild:img];

	TMachBuildSet *set = [buildSet buildSet];
	upgradeCost = set->upgradeCost;
	
	NSString *machName = [GINFO getDescription:[NSString stringWithFormat:@"MN_%@", buildSet.machName]];
	if(machName == nil) machName = buildSet.machName;

	QobText *text = [[QobText alloc] initWithString:[NSString stringWithFormat:@"%@  Lv. %d", machName, buildSet.level+1] Size:CGSizeMake(256, 20) Align:UITextAlignmentCenter Font:@"TrebuchetMS" FontSize:16 Retina:true];
	[text setColorR:240 G:255 B:255];
	[text setPosX:-62 * GWORLD.deviceScale Y:69 * GWORLD.deviceScale];
	[self addChild:text];

	mach = [[GobHvM_Player alloc] init];
	[mach setPosX:-128 * GWORLD.deviceScale Y:10 * GWORLD.deviceScale];
	[self addChild:mach];
	[mach setDir:M_PI / 2.f];
	[mach setState:MACHSTATE_STOP];
	[mach setUiModel:true];
	[mach setLayer:VLAYER_FORE_UI];
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
		[nextMach setPosX:-4 * GWORLD.deviceScale Y:10 * GWORLD.deviceScale];
		[self addChild:nextMach];
		[nextMach setDir:M_PI / 2.f];
		[nextMach setState:MACHSTATE_STOP];
		[nextMach setUiModel:true];
		[nextMach setLayer:VLAYER_FORE_UI];
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
		strInfo = [NSString stringWithFormat:@"%@ : %d(%+d)", [GINFO getDescription:@"Stat_Atk"], atk1, atk2-atk1];
		text = [[QobText alloc] initWithString:strInfo Size:CGSizeMake(128, 16) Align:UITextAlignmentLeft Font:@"TrebuchetMS-Bold" FontSize:12 Retina:true];
		[text setColorR:240 G:255 B:255];
		[text setPosX:-120 * GWORLD.deviceScale Y:-44 * GWORLD.deviceScale];
		[self addChild:text];
		
		strInfo = [NSString stringWithFormat:@"%@ : %d(%+d)", [GINFO getDescription:@"Stat_Rng"], rng1, rng2-rng1];
		text = [[QobText alloc] initWithString:strInfo Size:CGSizeMake(128, 16) Align:UITextAlignmentLeft Font:@"TrebuchetMS-Bold" FontSize:12 Retina:true];
		[text setColorR:240 G:255 B:255];
		[text setPosX:20 * GWORLD.deviceScale Y:-44 * GWORLD.deviceScale];
		[self addChild:text];
		
		strInfo = [NSString stringWithFormat:@"%@ : %d(%+d)", [GINFO getDescription:@"Stat_Def"], def1, def2-def1];
		text = [[QobText alloc] initWithString:strInfo Size:CGSizeMake(128, 16) Align:UITextAlignmentLeft Font:@"TrebuchetMS-Bold" FontSize:12 Retina:true];
		[text setColorR:240 G:255 B:255];
		[text setPosX:-120 * GWORLD.deviceScale Y:-60 * GWORLD.deviceScale];
		[self addChild:text];
		
		strInfo = [NSString stringWithFormat:@"%@ : %d(%+d)", [GINFO getDescription:@"Stat_Spd"], spd1, spd2-spd1];
		text = [[QobText alloc] initWithString:strInfo Size:CGSizeMake(128, 16) Align:UITextAlignmentLeft Font:@"TrebuchetMS-Bold" FontSize:12 Retina:true];
		[text setColorR:240 G:255 B:255];
		[text setPosX:20 * GWORLD.deviceScale Y:-60 * GWORLD.deviceScale];
		[self addChild:text];
	}
	else
	{
		strInfo = [NSString stringWithFormat:@"%@ : %d", [GINFO getDescription:@"Stat_Atk"], atk1];
		text = [[QobText alloc] initWithString:strInfo Size:CGSizeMake(128, 16) Align:UITextAlignmentLeft Font:@"TrebuchetMS-Bold" FontSize:12 Retina:true];
		[text setColorR:240 G:255 B:255];
		[text setPosX:-120 * GWORLD.deviceScale Y:-44 * GWORLD.deviceScale];
		[self addChild:text];
		
		strInfo = [NSString stringWithFormat:@"%@ : %d", [GINFO getDescription:@"Stat_Rng"], rng1];
		text = [[QobText alloc] initWithString:strInfo Size:CGSizeMake(128, 16) Align:UITextAlignmentLeft Font:@"TrebuchetMS-Bold" FontSize:12 Retina:true];
		[text setColorR:240 G:255 B:255];
		[text setPosX:20 * GWORLD.deviceScale Y:-44 * GWORLD.deviceScale];
		[self addChild:text];
		
		strInfo = [NSString stringWithFormat:@"%@ : %d", [GINFO getDescription:@"Stat_Def"], def1];
		text = [[QobText alloc] initWithString:strInfo Size:CGSizeMake(128, 16) Align:UITextAlignmentLeft Font:@"TrebuchetMS-Bold" FontSize:12 Retina:true];
		[text setColorR:240 G:255 B:255];
		[text setPosX:-120 * GWORLD.deviceScale Y:-60 * GWORLD.deviceScale];
		[self addChild:text];
		
		strInfo = [NSString stringWithFormat:@"%@ : %d", [GINFO getDescription:@"Stat_Spd"], spd1];
		text = [[QobText alloc] initWithString:strInfo Size:CGSizeMake(128, 16) Align:UITextAlignmentLeft Font:@"TrebuchetMS-Bold" FontSize:12 Retina:true];
		[text setColorR:240 G:255 B:255];
		[text setPosX:20 * GWORLD.deviceScale Y:-60 * GWORLD.deviceScale];
		[self addChild:text];
	}


	tile = [TILEMGR getTileForRetina:@"UpgradeBtn_Upgrade.png"];
	[tile tileSplitX:1 splitY:4];
	btn = [[QobButton alloc] initWithTile:tile TileNo:0 ID:BTNID_UPGRADEMACH_UPGRADE];
	[btn setDataObject:buildSet];
	[btn setActive:GSLOT->cr >= upgradeCost];
	[btn setPosX:148 * GWORLD.deviceScale Y:-38 * GWORLD.deviceScale];
	[self addChild:btn];

	text = [[QobText alloc] initWithString:[NSString stringWithFormat:@"%d", upgradeCost] Size:CGSizeMake(64, 16) Align:UITextAlignmentRight Font:@"TrebuchetMS-Bold" FontSize:16 Retina:true];
	[text setColorR:240 G:255 B:255];
	[text setPosX:-8 * GWORLD.deviceScale Y:12 * GWORLD.deviceScale];
	[btn addChild:text];

	if(buildSet.onSlot)
	{
		tile = [TILEMGR getTileForRetina:@"UpgradeBtn_Uninstall.png"];
		[tile tileSplitX:1 splitY:4];
		btn = [[QobButton alloc] initWithTile:tile TileNo:0 ID:BTNID_UPGRADEMACH_UNINSTALL];
		[btn setDataObject:buildSet];
		[btn setPosX:148 * GWORLD.deviceScale Y:-96 * GWORLD.deviceScale];
		[self addChild:btn];
	}
	else
	{
		tile = [TILEMGR getTileForRetina:@"UpgradeBtn_Install.png"];
		[tile tileSplitX:1 splitY:4];
		btn = [[QobButton alloc] initWithTile:tile TileNo:0 ID:BTNID_UPGRADEMACH_INSTALL];
		[btn setDataObject:buildSet];
		[btn setPosX:148 * GWORLD.deviceScale Y:-96 * GWORLD.deviceScale];
		[btn setActive:GAMEUI.dlgBuildMach.buildBtnCnt < 7];
		[self addChild:btn];
	}

	return self;
}

- (id)initWithAttackSet:(SpAttackSet *)buildSet
{
	[super init];
	
	int upgradeCost, buyCost;
	Tile2D *tile;
	QobImage *img;
	QobButton *btn;
	QobText *text;
	TSpAttackSet *set;
	
	tile = [TILEMGR getTileForRetina:@"UpgradeMachBG.png"];
	[tile tileSplitX:1 splitY:1];
	img = [[QobImage alloc] initWithTile:tile tileNo:0];
	[self addChild:img];
	
	set = [buildSet attackSet];
	upgradeCost = set->upgradeCost;
	buyCost = set->cost;

	text = [[QobText alloc] initWithString:[NSString stringWithFormat:@"%@  Lv. %d", buildSet.attackName, buildSet.level+1] Size:CGSizeMake(256, 20) Align:UITextAlignmentCenter Font:@"TrebuchetMS" FontSize:16 Retina:true];
	[text setColorR:240 G:255 B:255];
	[text setPosX:-62 * GWORLD.deviceScale Y:69 * GWORLD.deviceScale];
	[self addChild:text];

	tile = [TILEMGR getTileForRetina:[NSString stringWithFormat:@"Icon%05d.png", set->itemId]];
	[tile tileSplitX:1 splitY:1];
	img = [[QobImage alloc] initWithTile:tile tileNo:0];
	[img setPosX:-127 * GWORLD.deviceScale Y:12 * GWORLD.deviceScale];
	[self addChild:img];
	
	set = [buildSet nextAttackSet];
	if(set)
	{
		tile = [TILEMGR getTileForRetina:[NSString stringWithFormat:@"Icon%05d.png", set->itemId]];
		[tile tileSplitX:1 splitY:1];
		img = [[QobImage alloc] initWithTile:tile tileNo:0];
		[img setPosX:-3 * GWORLD.deviceScale Y:12 * GWORLD.deviceScale];
		[self addChild:img];
		upgradeCost += (set->cost - buyCost) * buildSet.count;
	}
	else
	{
		upgradeCost = 0;
	}
	
	tile = [TILEMGR getTileForRetina:@"UpgradeBtn_Upgrade.png"];
	[tile tileSplitX:1 splitY:4];
	btn = [[QobButton alloc] initWithTile:tile TileNo:0 ID:BTNID_UPGRADEATTACK_UPGRADE];
	[btn setDataObject:buildSet];
	[btn setIntData:upgradeCost];
	[btn setActive:GSLOT->cr >= upgradeCost && upgradeCost != 0];
	[btn setPosX:148 * GWORLD.deviceScale Y:-38 * GWORLD.deviceScale];
	[self addChild:btn];
	
	text = [[QobText alloc] initWithString:[NSString stringWithFormat:@"%d", upgradeCost] Size:CGSizeMake(64, 16) Align:UITextAlignmentRight Font:@"TrebuchetMS-Bold" FontSize:16 Retina:true];
	[text setColorR:240 G:255 B:255];
	[text setPosX:-8 * GWORLD.deviceScale Y:12 * GWORLD.deviceScale];
	[btn addChild:text];
	
	tile = [TILEMGR getTileForRetina:@"UpgradeBtn_Buy.png"];
	[tile tileSplitX:1 splitY:4];
	btn = [[QobButton alloc] initWithTile:tile TileNo:0 ID:BTNID_UPGRADEATTACK_BUY];
	[btn setDataObject:buildSet];
	[btn setIntData:buyCost];
	[btn setActive:GSLOT->cr >= buyCost];
	[btn setPosX:148 * GWORLD.deviceScale Y:26 * GWORLD.deviceScale];
	[self addChild:btn];
	
	text = [[QobText alloc] initWithString:[NSString stringWithFormat:@"%d", buyCost] Size:CGSizeMake(64, 16) Align:UITextAlignmentRight Font:@"TrebuchetMS-Bold" FontSize:16 Retina:true];
	[text setColorR:240 G:255 B:255];
	[text setPosX:-8 * GWORLD.deviceScale Y:12 * GWORLD.deviceScale];
	[btn addChild:text];

	NSString *strInfo = [NSString stringWithFormat:@"Count : %d", buildSet.count];
	text = [[QobText alloc] initWithString:strInfo Size:CGSizeMake(128, 16) Align:UITextAlignmentLeft Font:@"TrebuchetMS-Bold" FontSize:12 Retina:true];
	[text setColorR:240 G:255 B:255];
	[text setPosX:-120 * GWORLD.deviceScale Y:-44 * GWORLD.deviceScale];
	[self addChild:text];

	if(buildSet.onSlot)
	{
		tile = [TILEMGR getTileForRetina:@"UpgradeBtn_Uninstall.png"];
		[tile tileSplitX:1 splitY:4];
		btn = [[QobButton alloc] initWithTile:tile TileNo:0 ID:BTNID_UPGRADEATTACK_UNINSTALL];
		[btn setDataObject:buildSet];
		[btn setPosX:148 * GWORLD.deviceScale Y:-96 * GWORLD.deviceScale];
		[self addChild:btn];
	}
	else
	{
		tile = [TILEMGR getTileForRetina:@"UpgradeBtn_Install.png"];
		[tile tileSplitX:1 splitY:4];
		btn = [[QobButton alloc] initWithTile:tile TileNo:0 ID:BTNID_UPGRADEATTACK_INSTALL];
		[btn setDataObject:buildSet];
		[btn setPosX:148 * GWORLD.deviceScale Y:-96 * GWORLD.deviceScale];
		[btn setActive:GAMEUI.dlgSpAttack.buildBtnCnt < 7];
		[self addChild:btn];
	}
	
	return self;
}

@end
