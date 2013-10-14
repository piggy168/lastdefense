//
//  DlgShop.m
//  MachDefense
//
//  Created by HaeJun Byun on 10. 10. 28..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "DlgUpgradeBase.h"
#import "GuiGame.h"
#import "GobHvM_Player.h"
#import "GobMachParts.h"
#import "BaseUpgradeSet.h"
#import "QobLine.h"

@implementation DlgUpgradeBase

static NSString *baseUpgradeName[6] = { @"BaseCannon", @"BaseDefense", @"BuildTime", @"CrResearch", @"CellResearch", @"CellStorage" };

- (id)init
{
	[super init];
	
	Tile2D *tile = [TILEMGR getTileForRetina:@"Btn_UpgradeBase_Upgrade.png"];
	[tile tileSplitX:1 splitY:4];
	QobButton *btn = [[QobButton alloc] initWithTile:tile TileNo:0 ID:BTNID_UPGRADE_BASE_UPGRADE];
	[btn setDeactiveTileNo:2];
	if(_glView.deviceType == DEVICE_IPAD) [btn setPosX:0];
	else [btn setPosX:-28];
	[btn setPosY:-400 * GWORLD.deviceScale];
	[self addChild:btn];
	_btnUpgrade = btn;
	
	tile = [TILEMGR getTileForRetina:@"Btn_UpgradeBase_Close.png"];
	[tile tileSplitX:1 splitY:4];
	btn = [[QobButton alloc] initWithTile:tile TileNo:0 ID:BTNID_UPGRADE_BASE];
	[btn setDeactiveTileNo:2];
	if(_glView.deviceType == DEVICE_IPAD) [btn setPosX:256];
	else [btn setPosX:96];
	[btn setPosY:-400 * GWORLD.deviceScale];
	[self addChild:btn];
	
	[self setSelUpgrade:-1];
	
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

- (void)addButtonInfo:(QobButton *)btn Info:(NSString *)upgradeName
{
	QobText *text;
	NSString *strInfo;
	BaseUpgradeSet *upgradeSet = [GINFO getBaseUpgradeSet:upgradeName];
	TBaseUpgradeSet *upgradeInfo = [upgradeSet upgradeSet];
	TBaseUpgradeSet *nextUpgradeInfo = [upgradeSet nextUpgradeSet];
	
	[btn setActive:GSLOT->cr >= upgradeInfo->upgradeCost && nextUpgradeInfo != NULL];
	
	text = [[QobText alloc] initWithString:[NSString stringWithFormat:@"%d cr", upgradeInfo->upgradeCost] Size:CGSizeMake(64, 16) Align:UITextAlignmentRight Font:@"TrebuchetMS-Bold" FontSize:16 Retina:true];
	[text setColorR:240 G:255 B:255];
	[text setPosX:12 * GWORLD.deviceScale Y:2 * GWORLD.deviceScale];
	[btn addChild:text];
	
	text = [[QobText alloc] initWithString:[NSString stringWithFormat:@"Lv. %d/%d", upgradeSet.level+1, upgradeSet.maxLevel] Size:CGSizeMake(64, 16) Align:UITextAlignmentLeft Font:@"TrebuchetMS-Bold" FontSize:12 Retina:true];
	[text setColorR:240 G:255 B:255];
	[text setPosX:94 * GWORLD.deviceScale];
	[text setLayer:VLAYER_FORE_UI];
	[btn addChild:text];
	
	if([upgradeName compare:baseUpgradeName[0]] == NSOrderedSame)			// Base Cannon
	{
		NSString *wpnName = [NSString stringWithFormat:@"BaseWpn%02d", upgradeSet.level + 1];
		WeaponInfo *wpnInfo = [GINFO getWeaponInfo:wpnName];
		if(wpnInfo)
		{
			wpnName = [NSString stringWithFormat:@"BaseWpn%02d", upgradeSet.level + 2];
			WeaponInfo *nextWpnInfo = [GINFO getWeaponInfo:wpnName];
			if(nextWpnInfo)
			{
				strInfo = [NSString stringWithFormat:@"%@ : %d(%+d)", [GINFO getDescription:@"Stat_Atk"], wpnInfo.atkPoint, nextWpnInfo.atkPoint - wpnInfo.atkPoint];
				text = [[QobText alloc] initWithString:strInfo Size:CGSizeMake(128, 16) Align:UITextAlignmentLeft Font:@"TrebuchetMS-Bold" FontSize:12 Retina:true];
				[text setColorR:240 G:255 B:255];
				[text setPosX:180 * GWORLD.deviceScale];
				[btn addChild:text];
			}
			else
			{
				strInfo = [NSString stringWithFormat:@"%@ : %d(F)", [GINFO getDescription:@"Stat_Atk"], wpnInfo.atkPoint];
				text = [[QobText alloc] initWithString:strInfo Size:CGSizeMake(128, 16) Align:UITextAlignmentLeft Font:@"TrebuchetMS-Bold" FontSize:12 Retina:true];
				[text setColorR:240 G:255 B:255];
				[text setPosX:180 * GWORLD.deviceScale];
				[btn addChild:text];
			}

		}
	}
	else if([upgradeName compare:baseUpgradeName[1]] == NSOrderedSame)		// Base Defense
	{
		if(nextUpgradeInfo)
		{
			strInfo = [NSString stringWithFormat:@"%@ : %d(%+d)", [GINFO getDescription:@"Stat_Def"], (int)(upgradeInfo->param / 100), (int)(nextUpgradeInfo->param - upgradeInfo->param) / 100];
			text = [[QobText alloc] initWithString:strInfo Size:CGSizeMake(128, 16) Align:UITextAlignmentLeft Font:@"TrebuchetMS-Bold" FontSize:12 Retina:true];
			[text setColorR:240 G:255 B:255];
			[text setPosX:180 * GWORLD.deviceScale];
			[btn addChild:text];
		}
		else
		{
			strInfo = [NSString stringWithFormat:@"%@ : %d(F)", [GINFO getDescription:@"Stat_Def"], (int)(upgradeInfo->param / 100)];
			text = [[QobText alloc] initWithString:strInfo Size:CGSizeMake(128, 16) Align:UITextAlignmentLeft Font:@"TrebuchetMS-Bold" FontSize:12 Retina:true];
			[text setColorR:240 G:255 B:255];
			[text setPosX:180 * GWORLD.deviceScale];
			[btn addChild:text];
		}
	}
	else if([upgradeName compare:baseUpgradeName[2]] == NSOrderedSame)		// Build Time
	{
	}
	else if([upgradeName compare:baseUpgradeName[3]] == NSOrderedSame)		// Cr Research
	{
	}
	else if([upgradeName compare:baseUpgradeName[4]] == NSOrderedSame)		// Cell Research
	{
	}
	else if([upgradeName compare:baseUpgradeName[5]] == NSOrderedSame)		// Cell Storage
	{
		if(nextUpgradeInfo)
		{
			strInfo = [NSString stringWithFormat:@"Size : %d(%+d)", (int)upgradeInfo->param, (int)(nextUpgradeInfo->param - upgradeInfo->param)];
			text = [[QobText alloc] initWithString:strInfo Size:CGSizeMake(128, 16) Align:UITextAlignmentLeft Font:@"TrebuchetMS-Bold" FontSize:12 Retina:true];
			[text setColorR:240 G:255 B:255];
			[text setPosX:185 * GWORLD.deviceScale];
			[btn addChild:text];
		}
		else
		{
			strInfo = [NSString stringWithFormat:@"Size : %d(F)", (int)upgradeInfo->param];
			text = [[QobText alloc] initWithString:strInfo Size:CGSizeMake(128, 16) Align:UITextAlignmentLeft Font:@"TrebuchetMS-Bold" FontSize:12 Retina:true];
			[text setColorR:240 G:255 B:255];
			[text setPosX:185 * GWORLD.deviceScale];
			[btn addChild:text];
		}
	}
}

- (void)refreshDlg
{
	Tile2D *tile;
	QobButton *btn;
	
	if(_dlgBase) [_dlgBase remove];
	_dlgBase = [[QobBase alloc] init];
	[self addChild:_dlgBase];
	
	_lineBase = nil;

	GobHvM_Player *mach = [[GobHvM_Player alloc] init];
	[mach setPosX:_glView.deviceType == DEVICE_IPAD ? -240 : -140 Y:-20 * GWORLD.deviceScale];
	[mach setUiModel:true];
	[_dlgBase addChild:mach];
	[mach setMachType:MACHTYPE_TURRET];
	[mach setState:MACHSTATE_STOP];
	[mach setDir:M_PI/2.f];
	[mach setParts:@"DummyParts" partsType:PARTS_BASE];

	BaseUpgradeSet *upgradeSet = [GINFO getBaseUpgradeSet:baseUpgradeName[1]];
	NSString *strName = [NSString stringWithFormat:@"Base%02d", upgradeSet.level + 1];
	[mach setParts:strName partsType:PARTS_BODY];

	upgradeSet = [GINFO getBaseUpgradeSet:baseUpgradeName[0]];
	strName = [NSString stringWithFormat:@"BaseWpn%02d", upgradeSet.level + 1];
	GobMachParts *parts = [mach setParts:strName partsType:PARTS_WPN];
	[parts refreshRotationPos];
	_machPos.x = mach.pos.x;
	_machPos.y = mach.pos.y;
	_wpnPos.x = parts.rotPos.x + _machPos.x;
	_wpnPos.y = parts.rotPos.y + _machPos.y;
	
	int btnPos[6] = { 10, -54, -128, -192, -256, -320 };
	for(int i = 0; i < 6; i++)
	{
		tile = [TILEMGR getTileForRetina:[NSString stringWithFormat:@"Btn_BaseUpgrade_%@.png", baseUpgradeName[i]]];
		[tile tileSplitX:1 splitY:4];
		btn = [[QobButton alloc] initWithTile:tile TileNo:0 ID:BTNID_UPGRADE_BASE_ITEM];
		[btn setDeactiveTileNo:2];
		[btn setIntData:i];
		if(i < 2) [btn setPosX:_glView.deviceType == DEVICE_IPAD ? 128 : 36];
		[btn setPosY:btnPos[i] * GWORLD.deviceScale];
		[_dlgBase addChild:btn];
		[self addButtonInfo:btn Info:baseUpgradeName[i]];
		
		_upgradeBtn[i] = btn;
	}
	
	[self setSelUpgrade:-1];
}

- (void)drawLineFromButton:(QobButton *)btn To:(CGPoint)pt
{
	if(_lineBase != nil) [_lineBase remove];
	_lineBase = [[QobBase  alloc] init];
	[_lineBase setLayer:VLAYER_FORE_UI];
	[_dlgBase addChild:_lineBase];
	
	float bx = btn.pos.x - 206 * GWORLD.deviceScale;
	CGPoint len = { pt.x - bx, pt.y - btn.pos.y };
	CGPoint midPos;
	
	if(fabs(len.y) > fabs(len.x) / 2) midPos = CGPointMake(bx, pt.y - fabs(len.x) / 2);
	else midPos = CGPointMake(pt.x + len.y / 2, btn.pos.y);
	
	Tile2D *tile = [TILEMGR getTileForRetina:@"UpgradeTarget.png"];
	[tile tileSplitX:2 splitY:1];
	QobImage *img = [[QobImage alloc] initWithTile:tile tileNo:0];
	[img setPosX:bx Y:btn.pos.y];
	[_lineBase addChild:img];
	
	img = [[QobImage alloc] initWithTile:tile tileNo:1];
	[img setPosX:pt.x Y:pt.y];
	[_lineBase addChild:img];
	
	tile = [TILEMGR getTileForRetina:@"UpgradeLine.png"];
	QobLine *line = [[QobLine alloc] initWithTile:tile tileNo:0];
	[line initTexWidth:8 * GWORLD.deviceScale Len:64 * GWORLD.deviceScale MaxBlocks:16];
	[line setBlendType:BT_NORMAL];
	[line setShow:true];
	[line setLineX1:bx Y1:btn.pos.y X2:midPos.x Y2:midPos.y];
	[_lineBase addChild:line];

	line = [[QobLine alloc] initWithTile:tile tileNo:0];
	[line initTexWidth:8 * GWORLD.deviceScale Len:64 * GWORLD.deviceScale MaxBlocks:16];
	[line setBlendType:BT_NORMAL];
	[line setShow:true];
	[line setLineX1:midPos.x Y1:midPos.y X2:pt.x Y2:pt.y];
	[_lineBase addChild:line];
}

- (void)setSelUpgrade:(int)sel
{
	CGPoint lineTo;
	_selUpgrade = sel;
	
	for(int i = 0; i < 6; i++)
	{
		[_upgradeBtn[i] setDefaultTileNo:i == sel ? 1 : 0];
	}
	
	[_btnUpgrade setActive:sel != -1];
	if(sel != -1)
	{
		if(sel == 0) [self drawLineFromButton:_upgradeBtn[sel] To:_wpnPos]; 
		else if(sel == 1) [self drawLineFromButton:_upgradeBtn[sel] To:_machPos];
		else
		{
			if(_glView.deviceType == DEVICE_IPAD)
			{
				if(sel == 2) lineTo = CGPointMake(-90, 145);
				else if(sel == 3) lineTo = CGPointMake(-240, 105);
				else if(sel == 4) lineTo = CGPointMake(300, 566);
				else if(sel == 5) lineTo = CGPointMake(352, 562);
			}
			else
			{
				if(sel == 2) lineTo = CGPointMake(-45, 72);
				else if(sel == 3) lineTo = CGPointMake(-149, 52);
				else if(sel == 4) lineTo = CGPointMake(118, 251);
				else if(sel == 5) lineTo = CGPointMake(143, 249);
			}
			[self drawLineFromButton:_upgradeBtn[sel] To:lineTo];
		}
	}

/*	if(_upgradeCost)
	{
		[_upgradeCost remove];
		_upgradeCost = nil;
	}
	
	BaseUpgradeSet *upgradeSet = [GINFO getBaseUpgradeSet:baseUpgradeName[_selUpgrade]];
	if(upgradeSet != nil && upgradeSet.level < upgradeSet.maxLevel)
	{
		TBaseUpgradeSet *upgrade = [upgradeSet upgradeSet];
		if(upgrade != NULL && GSLOT->cr >= upgrade->upgradeCost)
		{
			[_btnUpgrade setActive:true];
			
			QobText *text = [[QobText alloc] initWithString:[NSString stringWithFormat:@"%d", upgrade->upgradeCost] Size:CGSizeMake(64, 16) Align:UITextAlignmentRight Font:@"TrebuchetMS-Bold" FontSize:14];
			[text setColorR:240 G:255 B:255];
			[text setPosX:20 Y:32];
			[_btnUpgrade addChild:text];
			_upgradeCost = text;
		}
	}*/
}

- (void)setUpgrade
{
	if(_selUpgrade == -1) return;
	
	BaseUpgradeSet *upgradeSet = [GINFO getBaseUpgradeSet:baseUpgradeName[_selUpgrade]];
	if(upgradeSet == nil || upgradeSet.level >= upgradeSet.maxLevel) return;
	TBaseUpgradeSet *upgrade = [upgradeSet upgradeSet];
	if(upgrade == NULL || GSLOT->cr < upgrade->upgradeCost) return;
	
	upgradeSet.level++;
	GSLOT->cr -= upgrade->upgradeCost;
	
	[GINFO updateBaseUpgrade];
	[GAMEUI refreshMaxMineral];
	[GAMEUI refreshCellUpgradeCost];

	if(_selUpgrade == 0)
	{
		NSString *strName = [NSString stringWithFormat:@"BaseWpn%02d", upgradeSet.level + 1];
		[GWORLD.baseMach setParts:strName partsType:PARTS_WPN];
	}
	else if(_selUpgrade == 1)
	{
//		NSString *strName = [NSString stringWithFormat:@"Base%02d", upgradeSet.level + 1];
//		GobMachParts *parts = [GWORLD.baseMach setParts:strName partsType:PARTS_BODY];
		[GWORLD.baseMach setHp:GVAL.baseDef];
		[GWORLD.baseMach setHpMax:GVAL.baseDef];
		[GAMEUI refreshMyGauge:1.f];
	}
	
	[SOUNDMGR play:[GINFO sfxID:SND_UPGRADE_BASE]];
	
	[self refreshDlg];
}

- (void)handleButton:(NSNotification *)note
{
	if(![self isShow]) return;
	
	QobButton *button = [note object];
	if(button == nil) return;
	
	if([[note name]isEqualToString:@"PushButton"])
	{
		if(button.buttonId == BTNID_UPGRADE_BASE_ITEM)
		{
		}
	}
	if([[note name]isEqualToString:@"ReleaseButton"])
	{
		if(button.buttonId == BTNID_UPGRADE_BASE_ITEM)
		{
		}
	}
	else if([[note name]isEqualToString:@"PopButton"])
	{
		if(button.buttonId == BTNID_UPGRADE_BASE_ITEM)
		{
			[self setSelUpgrade:button.intData];
			[SOUNDMGR play:[GINFO sfxID:SND_MENU_CLICK]];
		}
		else if(button.buttonId == BTNID_UPGRADE_BASE_UPGRADE)
		{
			[self setUpgrade];
			[SOUNDMGR play:[GINFO sfxID:SND_MENU_CLICK]];
		}
	}
}

@end
