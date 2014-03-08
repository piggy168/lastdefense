//
//  DlgWeaponList.m
//  MachDefense
//
//  Created by HaeJun Byun on 10. 9. 3..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "DlgBuildMach.h"
#import "DlgUpgradeEquip.h"
#import "DlgUpgradeItem.h"
#import "GuiGame.h"
#import "GobHvM_Player.h"
#import "WndBuildSlot.h"
#import "ImageAttacher.h"
#import "UiObjMach.h"

@implementation DlgBuildMach
@synthesize buildMachType=_buildMachType, buildBtnCnt=_buildBtnCnt;

- (id)init
{
	[super init];
	
	Tile2D *tile;
	QobImage *img;
	
/*	tile = [TILEMGR getTile:@"MakeMach_WeaponArmor.png"];
	[tile tileSplitX:1 splitY:2];
	
	img = [[QobImage alloc] initWithTile:tile tileNo:0];
	[img setPosX:-322 Y:18];
	[self addChild:img];*/
	
	tile = [TILEMGR getTileForRetina:@"SelMach.png"];
	[tile tileSplitX:1 splitY:1];
	img = [[QobImage alloc] initWithTile:tile tileNo:0];
	[img setBlendType:BT_ADD];
	[img setShow:false];
	[img setLayer:VLAYER_FOREMOST];
	[self addChild:img];
	_imgSelWeapon = img;
	
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:self selector:@selector(handleButton:) name:@"PushButton" object:nil];
	[nc addObserver:self selector:@selector(handleButton:) name:@"ReleaseButton" object:nil];
	[nc addObserver:self selector:@selector(handleButton:) name:@"PopButton" object:nil];

	return self;
}

- (void)removeAllButtons
{
	TBuildButton *buildBtn;
	for(int i = 0; i < _buildBtnCnt; i++)
	{
		buildBtn = &_buildButton[i];
		if(buildBtn != NULL)
		{
			buildBtn->buildSet->buildCount = 0;
//			[_buildButton[i].btn remove];
		}
	}
	
	[_imgButtonBG remove];
	_imgButtonBG = nil;

	_buildBtnCnt = 0;
}

- (void)refreshButtonsWithType:(int)type
{
	Tile2D *tile;
	QobButton *btn;
	QobImage *img;
	NSArray *listBuildSet = [GINFO listBuyBuildSet];
	
	_buildMachType = type;

	[_imgSelWeapon setShow:false];
	[GAMEUI.dlgUpgrade setUpgradeMachItem:nil];
	
	NSString *attachTileName = @"MachBuildUI";
//	tile = [TILEMGR getTile:attachTileName];
//	if(tile != nil) [TILEMGR removeTile:tile];
	if(_imgButtonBG != nil) [_imgButtonBG remove];
    
    NSLog(@"refreshButtonsWithType");
	
	int x = 200;
	ImageAttacher *attacher = [[ImageAttacher alloc] initWithWidth:256 Height:1024 Name:attachTileName];
	[attacher attachImage:[TILEMGR getImage:@"GameUI_MachSlot.png"] ToX:256-64 Y:484];

	int btnCnt = 0;
	float basePos = 864;
	for(MachBuildSet *buildSet in listBuildSet)
	{
		if(buildSet == nil || !buildSet.onSlot || btnCnt >= 7) continue;
		TMachBuildSet *set = [buildSet buildSet];
		if(set == NULL/* || set->buildUnitType != unitType*/) continue;
		
		[attacher attachImage:[TILEMGR getImage:@"Btn_BuildMachBG.png"] ToX:x Y:basePos];
		[attacher attachImage:[TILEMGR getImage:@"Btn_BuildMach.png"] ToX:x-19 Y:basePos-17];
		
		[buildSet.uiMach attachTo:attacher X:x Y:basePos];
		
/*		NSString *machName = [GINFO getDescription:[NSString stringWithFormat:@"MN_%@", buildSet.machName]];
		if(machName == nil) machName = buildSet.machName;
		[attacher attachText:machName ToX:x Y:basePos-40 Align:UITextAlignmentCenter Font:@"TrebuchetMS-Bold" FontSize:10];
*/		if(type == BMT_BUILDMACH)
		{
			[attacher attachText:[NSString stringWithFormat:@"%d", set->cost] ToX:x-60 Y:basePos+31 Align:UITextAlignmentCenter Font:@"TrebuchetMS-Bold" FontSize:14];
		}
		else
		{
			[attacher attachImage:[TILEMGR getImage:@"Btn_BuildMachUpgrade.png"] ToX:x-73 Y:basePos-18];
			[attacher attachText:[NSString stringWithFormat:@"%d/%d", buildSet.level+1, buildSet.maxLevel] ToX:x-60 Y:basePos+31 Align:UITextAlignmentCenter Font:@"TrebuchetMS-Bold" FontSize:14];
			[attacher attachText:[NSString stringWithFormat:@"%dcr", set->upgradeCost] ToX:x-42 Y:basePos-21 Align:UITextAlignmentRight Font:@"TrebuchetMS-Bold" FontSize:12];
		}
		basePos -= 102.f;
		btnCnt++;
	}
	tile = [TILEMGR makeTileWithImageAttacher:attacher];
	if(_glView.deviceType != DEVICE_IPAD)
    {
        [tile setForRetina:YES];
    }
	[tile tileSplitX:1 splitY:1];
	img = [[QobImage alloc] initWithTile:tile tileNo:0];
	[img setPosX:0 Y:0];
	[self addChild:img];
	_imgButtonBG = img;
	
	_buildBtnCnt = 0;
	basePos = 352 * GWORLD.deviceScale;
	x = 72 * GWORLD.deviceScale;
	for(MachBuildSet *buildSet in listBuildSet)
	{
		if(buildSet == nil || !buildSet.onSlot || _buildBtnCnt >= 7) continue;
		TMachBuildSet *set = [buildSet buildSet];
		if(set == NULL) continue;
		
		_buildButton[_buildBtnCnt].buildSet = set;

		tile = [TILEMGR getTileForRetina:@"Btn_BuildMachBG.png"];
		[tile tileSplitX:1 splitY:1];

		btn = [[QobButton alloc] initWithTile:nil TileNo:0 ID:BTNID_MAKEMACH_SELMACH];
		[btn setBoundWidth:180 * GWORLD.deviceScale Height:96 * GWORLD.deviceScale];
		[btn setDataObject:buildSet];
		[btn setIntData:_buildBtnCnt];
		[btn setPosX:x Y:basePos];
		[_imgButtonBG addChild:btn];
		_buildButton[_buildBtnCnt].btn = btn;
		basePos -= 102.f * GWORLD.deviceScale;
		
		NSString *machName = [GINFO getDescription:[NSString stringWithFormat:@"MN_%@", buildSet.machName]];
		if(machName == nil) machName = buildSet.machName;
		QobText *text = [[QobText alloc] initWithString:machName Size:CGSizeMake(128, 16) Align:UITextAlignmentCenter Font:@"TrebuchetMS-Bold" FontSize:11 Retina:true];
		[text setColorR:240 G:255 B:255];
		[text setPosY:-43 * GWORLD.deviceScale];
		[text setLayer:VLAYER_FOREMOST];
		[btn addChild:text];

		if(type == BMT_BUILDMACH)
		{
			for(int j = 0; j < set->multiBuild; j++)
			{
				tile = [TILEMGR getTileForRetina:@"Btn_BuildMachInd.png"];
				[tile tileSplitX:2 splitY:1];
				img = [[QobImage alloc] initWithTile:tile tileNo:1];
				[img setUseAtlas:TRUE];
				[img setPosX:-45 * GWORLD.deviceScale Y:(-3-j*13) * GWORLD.deviceScale];
				[btn addChild:img];
				if(j < 5) _buildButton[_buildBtnCnt].buildIcon[j] = img;
			}

			tile = [TILEMGR getTileForRetina:@"BuildMach_Cover.png"];
			[tile tileSplitX:1 splitY:1];
			img = [[QobImage alloc] initWithTile:tile tileNo:1];
			[img setUseAtlas:TRUE];
			[img setLayer:VLAYER_FOREMOST];
			[img setShow:false];
			[img setPosX:-19 * GWORLD.deviceScale Y:-17 * GWORLD.deviceScale];
			[btn addChild:img];
			_buildButton[_buildBtnCnt].imgDimd = img;
		}
		else
		{
			if(GSLOT->cr >= set->upgradeCost)
			{
				tile = [TILEMGR getTileForRetina:@"Btn_BuildMachUpgradeOn.png"];
				[tile tileSplitX:1 splitY:1];
				img = [[QobImage alloc] initWithTile:tile tileNo:1];
				[img setUseAtlas:TRUE];
				[img setPosX:-72 * GWORLD.deviceScale Y:-3 * GWORLD.deviceScale];
				[btn addChild:img];
				_buildButton[_buildBtnCnt].imgDimd = img;
			}
			else
			{
				_buildButton[_buildBtnCnt].imgDimd = nil;
			}

		}

		_buildBtnCnt++;
	}
}
 
- (void)dealloc
{
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc removeObserver:self];
	
	[super dealloc];
}

- (void)tick
{
	if(_buildTime != 0.f)
	{
		float dt = g_time - _buildTime;
		if(dt < .5f)
		{
			[_imgSelWeapon setAlpha:(.5f - dt) * 2.f];
		}
		else
		{
			[_imgSelWeapon setShow:false];
			_buildTime = 0.f;
		}

	}
	
	if(_active && g_time > _checkTime)
	{
		_checkTime = g_time + .1f;
		TBuildButton *buildBtn;
		for(int i = 0; i < _buildBtnCnt; i++)
		{
			buildBtn = &_buildButton[i];
			if(_buildMachType == BMT_BUILDMACH)
			{
				if([GAMEUI.buildSlot buildCount] >= BUILDSLOT_SIZE || GVAL.mineral < buildBtn->buildSet->cost || buildBtn->buildSet->buildCount >= buildBtn->buildSet->multiBuild || GWORLD.state != GSTATE_PLAY)
				{
					[buildBtn->btn setActive:false];
					[buildBtn->imgDimd setShow:true];
				}
				else
				{
					[buildBtn->btn setActive:true];
					[buildBtn->imgDimd setShow:false];
				}
				
				for(int j = 0; j < buildBtn->buildSet->multiBuild && j < 5; j++)
				{
					[buildBtn->buildIcon[j] setTileNo:j < buildBtn->buildSet->multiBuild - buildBtn->buildSet->buildCount ? 1 : 0];
				}
			}
			else
			{
				if(buildBtn->imgDimd != nil)
				{
					[buildBtn->imgDimd setShow:((int)(g_time * 2.f) % 2) == 0];
				}
			}

		}
	}
	
	[super tick];
}

- (void)buildMach:(MachBuildSet *)buildSet
{
	if(buildSet != nil)
	{
		TMachBuildSet *set = [buildSet buildSet];
		if(set->buildUnitType == BUT_MACH)
		{
			[GAMEUI hideMessage];
			[GAMEUI.buildSlot addBuildItemWithBuildSet:buildSet Type:buildSet.setType];
			_buildTime = g_time;
		}
		else
		{
			[GAMEUI setMessage:[GINFO getDescription:@"TapToTurretPos"] BG:0 AutoHide:false];
			_selBuildSet = buildSet;
		}
	}
}

- (void)upgradeMach:(MachBuildSet *)buildSet
{
	if(buildSet == nil) return;
	TMachBuildSet *set = [buildSet buildSet];
	if(GSLOT->cr < set->upgradeCost) return;
	
	if(buildSet.level < buildSet.maxLevel)
	{
		buildSet.level++;
		GSLOT->cr -= set->upgradeCost;
		_buildTime = g_time;
	}
	
	[self refreshButtonsWithType:BMT_UPGRADEMACH];
	[GAMEUI.dlgUpgrade refreshMachButtons];
	[GAMEUI.dlgUpgrade setUpgradeMachItem:buildSet];
	
	[SOUNDMGR play:[GINFO sfxID:SND_UPGRADE_MACH]];
}

- (void)installMach:(MachBuildSet *)buildSet
{
	if(buildSet == nil) return;
	
	buildSet.onSlot = true;
	[self refreshButtonsWithType:BMT_UPGRADEMACH];
	[GAMEUI.dlgUpgrade refreshMachButtons];
	[GAMEUI.dlgUpgrade setUpgradeMachItem:buildSet];
	
	[SOUNDMGR play:[GINFO sfxID:SND_INSTALL]];
}

- (void)uninstallMach:(MachBuildSet *)buildSet
{
	if(buildSet == nil) return;
	
	buildSet.onSlot = false;
	[self refreshButtonsWithType:BMT_UPGRADEMACH];
	[GAMEUI.dlgUpgrade refreshMachButtons];
	[GAMEUI.dlgUpgrade setUpgradeMachItem:buildSet];
	
	[SOUNDMGR play:[GINFO sfxID:SND_UNINSTALL]];
}

- (void)setAttackPos:(CGPoint)pos
{
/*	_buildInfo.buildPos = pos;
	_isTapPos = true;
	
	if(_selTurret != -1)
	{
		[GWORLD setTargetPos:pos];
		[self buildMach];
	}
	[_btnOK setActive:_selTurret != -1 && _isTapPos];*/
	if(_selBuildSet == nil) return;
	[GAMEUI.buildSlot addBuildItemWithBuildSet:_selBuildSet Type:_selBuildSet.setType Pos:pos];
	[GAMEUI hideMessage];
	[GWORLD setTargetPos:pos];

	_buildTime = g_time;
	_selBuildSet = nil;
}


- (void)handleButton:(NSNotification *)note
{
	if(![self isShow]) return;
	
	QobButton *button = [note object];
	if(button == nil) return;
	
	if([[note name]isEqualToString:@"PushButton"])
	{
		if(button.buttonId == BTNID_MAKEMACH_SELMACH)
		{
			[_imgSelWeapon setPosX:button.pos.x Y:button.pos.y];
			[_imgSelWeapon setShow:true];
			[_imgSelWeapon setAlpha:1.f];
		}
	}
	if([[note name]isEqualToString:@"ReleaseButton"])
	{
		if(button.buttonId == BTNID_MAKEMACH_SELMACH)
		{
			[_imgSelWeapon setShow:false];
		}
	}
	else if([[note name]isEqualToString:@"PopButton"])
	{
		if(button.buttonId == BTNID_MAKEMACH_SELMACH)
		{
			[_imgSelWeapon setPosX:button.pos.x Y:button.pos.y];
			if(_buildMachType == BMT_BUILDMACH)
			{
				[self buildMach:button.dataObject];
			}
			else
			{
				[GAMEUI.dlgUpgrade setUpgradeMachItem:button.dataObject];
			}

			[SOUNDMGR play:[GINFO sfxID:SND_MENU_CLICK]];
		}
		else if(button.buttonId == BTNID_UPGRADEMACH_UPGRADE)
		{
			[self upgradeMach:button.dataObject];
			[SOUNDMGR play:[GINFO sfxID:SND_MENU_CLICK]];
		}
		else if(button.buttonId == BTNID_UPGRADEMACH_INSTALL)
		{
			[self installMach:button.dataObject];
			[SOUNDMGR play:[GINFO sfxID:SND_MENU_CLICK]];
		}
		else if(button.buttonId == BTNID_UPGRADEMACH_UNINSTALL)
		{
			[self uninstallMach:button.dataObject];
			[SOUNDMGR play:[GINFO sfxID:SND_MENU_CLICK]];
		}
	}
}

@end
