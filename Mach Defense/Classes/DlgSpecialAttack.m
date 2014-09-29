//
//  DlgBuildSpAttack.m
//  MachDefense
//
//  Created by HaeJun Byun on 10. 10. 6..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "DlgSpecialAttack.h"
#import "DlgUpgradeItem.h"
#import "DlgUpgradeEquip.h"
#import "GuiGame.h"
#import "GobHvM_Player.h"
#import "WndBuildSlot.h"
#import "SpAttackSet.h"

@implementation DlgSpecialAttack
@synthesize uiType=_uiType, buildBtnCnt=_buildBtnCnt;

- (void)setSelAttack:(SpAttackSet *)attack
{
	if(attack != nil && attack.count <= 0) attack = nil;
	
	_selAttack = attack;
	[_imgSelAttack setShow:attack != nil];
	
	if(attack != nil)
	{
		[GAMEUI setMessage:[GINFO getDescription:@"TapToAttackPos"] BG:0 AutoHide:false];
	}
	else
	{
		[GAMEUI hideMessage];
	}
}

- (id)init
{
	[super init];
	NSLog(@"DlgSpecialAttack");
	Tile2D *tile;
	QobImage *img;
	
	tile = [TILEMGR getTile:@"GameUI_MachSlot.png"];
	[tile tileSplitX:1 splitY:1];
	img = [[QobImage alloc] initWithTile:tile tileNo:0];
	[img setPosX:-40 Y:-350];
    [img setLayer:0];
	[self addChild:img];
    
//    tile = [TILEMGR getTileForRetina:@"GameUI_MachSlot.png"];
//    [tile tileSplitX:1 splitY:1];
//    img = [[QobImage alloc] initWithTile:tile tileNo:1];
//    [img setPosX:-19 * GWORLD.deviceScale Y:-17 * GWORLD.deviceScale];
//    [img setLayer:1];
//    [self addChild:img];

	
	tile = [TILEMGR getTileForRetina:@"SelMach.png"];
	[tile tileSplitX:1 splitY:1];
	img = [[QobImage alloc] initWithTile:tile tileNo:0];
	[img setShow:false];
	[img setBlendType:BT_ADD];
	[img setLayer:VLAYER_UI];
	[self addChild:img];
	_imgSelAttack = img;
	
	[self setSelAttack:nil];
	
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

- (void)initDialog
{
	[self setSelAttack:nil];
}

- (void)refreshButtonsWithType:(int)type
{
	Tile2D *tile;
	QobButton *btn;
	QobImage *img;
	QobText *text;
	float basePos = _glView.deviceType == DEVICE_IPAD ? 0 : -176;
	
	_uiType = type;

	[_imgSelAttack setShow:false];
	[GAMEUI.dlgUpgrade setUpgradeAttackItem:nil];

	if(_buttons) [_buttons remove];
	_buttons = [[QobBase alloc] init];
	[self addChild:_buttons];
	
	_upgradeInd = [[QobBase alloc] init];
	[_buttons addChild:_upgradeInd];
    
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
	
	_buildBtnCnt = 0;
	NSArray *array = [GINFO listBuyAttackSet];
	for(SpAttackSet *set in array)
	{
		if(set.count <= 0) continue;
		TSpAttackSet *attack = [set attackSet];
		
		tile = [TILEMGR getTileForRetina:[NSString stringWithFormat:@"Icon%05d.png", attack->itemId]];
		[tile tileSplitX:1 splitY:1];
		btn = [[QobButton alloc] initWithTile:tile TileNo:0 ID:BTNID_SPATTACK_SELATTACK];
		[btn setReleaseTileNo:0];
		[btn setDataObject:set];
		[btn setPosX:_glView.deviceType == DEVICE_IPAD ? 1 : -35 Y:basePos];
        [btn setLayer:3];
		[_buttons addChild:btn];
		
		tile = [TILEMGR getTileForRetina:@"Side_bar_bomb_box.png"];
		[tile tileSplitX:1 splitY:1];
		QobImage *body = [[QobImage alloc] initWithTile:tile tileNo:1];
		[body setUseAtlas:TRUE];
		[body setPosX:-19 * GWORLD.deviceScale Y:-17 * GWORLD.deviceScale];
        [body setLayer:1];
		[btn addChild:body];
		
//		text = [[QobText alloc] initWithString:[NSString stringWithFormat:@"%d/%d", set.level+1, set.maxLevel] Size:CGSizeMake(64, 16) Align:UITextAlignmentCenter Font:@"TrebuchetMS-Bold" FontSize:14 Retina:true];
//		[text setLayer:VLAYER_FOREMOST];
//		[text setColorR:240 G:255 B:255];
//		[text setPosX:-60 * GWORLD.deviceScale Y:28 * GWORLD.deviceScale];
//		[btn addChild:text];

		text = [[QobText alloc] initWithString:[NSString stringWithFormat:@"%d", set.count] Size:CGSizeMake(64, 16) Align:UITextAlignmentCenter Font:@"TrebuchetMS-Bold" FontSize:13 Retina:true];
		[text setLayer:4];
		[text setColorR:240 G:255 B:255];
		[text setPosX:0 Y:-42 * GWORLD.deviceScale];
		[btn addChild:text];

		if(type == BSAT_UPGRADEATTACK)
		{
			TSpAttackSet *nextAttack = [set nextAttackSet];
			int upgradeCost = nextAttack ? attack->upgradeCost + (nextAttack->cost - attack->cost) * set.count : 0;
			tile = [TILEMGR getTileForRetina:@"Btn_BuildMachUpgrade.png"];
			[tile tileSplitX:1 splitY:1];
			img = [[QobImage alloc] initWithTile:tile tileNo:0];
			[img setUseAtlas:true];
			[img setPosX:-54 * GWORLD.deviceScale Y:-1 * GWORLD.deviceScale];
			[body addChild:img];

			text = [[QobText alloc] initWithString:[NSString stringWithFormat:@"%dcr", upgradeCost] Size:CGSizeMake(64, 16) Align:UITextAlignmentRight Font:@"TrebuchetMS-Bold" FontSize:12 Retina:true];
			[text setLayer:VLAYER_FOREMOST];
			[text setColorR:240 G:255 B:255];
			[text setPosX:0 Y:-6 * GWORLD.deviceScale];
			[img addChild:text];

			if(GSLOT->cr >= upgradeCost && upgradeCost != 0)
			{
				tile = [TILEMGR getTileForRetina:@"Btn_BuildMachUpgradeOn.png"];
				[tile tileSplitX:1 splitY:1];
				img = [[QobImage alloc] initWithTile:tile tileNo:1];
				[img setUseAtlas:TRUE];
				[img setPosX:-71 Y:basePos - 3 * GWORLD.deviceScale];
				[_upgradeInd addChild:img];
//				_buildButton[_buildBtnCnt].imgDimd = img;
			}
		}
		
		basePos -= 102.f * GWORLD.deviceScale;
		_buildBtnCnt++;
	}
}

- (void)setAttack
{
	if(_selAttack != nil && _selAttack.count > 0)
	{
		TSpAttackSet *set = [_selAttack attackSet];
		if(set)
		{
			ItemInfo *item = [GINFO getItemInfo:[NSString stringWithFormat:@"%05d", set->itemId]];
			if(item != nil)
			{
				if([item.strParam hasPrefix:@"AS_"])
				{
					[GWORLD setAirstrike:item To:_attackPos];
					_selAttack.count--;
					[self refreshButtonsWithType:BSAT_BUILDATTACK];
					[GAMEUI hideMessage];
				}
				else if([item.strParam hasPrefix:@"CF_"])
				{
					int cnt = [GWORLD setCrossfire:item To:_attackPos];
					if(cnt > 0)
					{
						_selAttack.count--;
						[self refreshButtonsWithType:BSAT_BUILDATTACK];
						[GAMEUI hideMessage];
					}
					else
					{
						[GAMEUI setMessage:[GINFO getDescription:@"NoMoreMach"] BG:0 AutoHide:5.f];
					}

				}
			}
		}
	}
	
	[self initDialog];
}

- (void)upgradeAttack:(SpAttackSet *)buildSet Cost:(int)cost
{
	if(buildSet == nil) return;
	if(GSLOT->cr < cost) return;
	
	if(buildSet.level < buildSet.maxLevel)
	{
		buildSet.level++;
		GSLOT->cr -= cost;
	}
	
	[self refreshButtonsWithType:BSAT_UPGRADEATTACK];
	[GAMEUI.dlgUpgrade refreshAttackButtons];
	[GAMEUI.dlgUpgrade setUpgradeAttackItem:buildSet];
	
	[SOUNDMGR play:[GINFO sfxID:SND_UPGRADE_SPATTACK]];
}

- (void)buyAttack:(SpAttackSet *)buildSet Cost:(int)cost
{
	if(buildSet == nil) return;
	if(GSLOT->cr < cost) return;
	
	buildSet.count++;
	GSLOT->cr -= cost;
	
	[self refreshButtonsWithType:BSAT_UPGRADEATTACK];
	[GAMEUI.dlgUpgrade refreshAttackButtons];
	[GAMEUI.dlgUpgrade setUpgradeAttackItem:buildSet];
	
	[SOUNDMGR play:[GINFO sfxID:SND_BUY_SPATTACK]];
}

- (void)installAttack:(SpAttackSet *)buildSet
{
	if(buildSet == nil) return;
	
	buildSet.onSlot = true;
	[self refreshButtonsWithType:BSAT_UPGRADEATTACK];
	[GAMEUI.dlgUpgrade refreshAttackButtons];
	
	[SOUNDMGR play:[GINFO sfxID:SND_INSTALL]];
}

- (void)uninstallAttack:(SpAttackSet *)buildSet
{
	if(buildSet == nil) return;
	
	buildSet.onSlot = false;
	[self refreshButtonsWithType:BSAT_UPGRADEATTACK];
	[GAMEUI.dlgUpgrade refreshAttackButtons];
	
	[SOUNDMGR play:[GINFO sfxID:SND_UNINSTALL]];
}

- (void)setAttackPos:(CGPoint)pos
{
	_attackPos = pos;
	
	if(_selAttack != nil) [self setAttack];
}

- (void)handleButton:(NSNotification *)note
{
	if(![self isShow]) return;
	
	QobButton *button = [note object];
	if(button == nil) return;
	
	if([[note name]isEqualToString:@"PushButton"])
	{
		if(button.buttonId == BTNID_SPATTACK_SELATTACK)
		{
			[_imgSelAttack setPosX:button.pos.x Y:button.pos.y];
			if(_uiType == BSAT_BUILDATTACK)
			{
				[self setSelAttack:button.dataObject];
			}
			else
			{
				[GAMEUI.dlgUpgrade setUpgradeAttackItem:button.dataObject];
				
				[_imgSelAttack setShow:true];
			}
			[SOUNDMGR play:[GINFO sfxID:SND_MENU_CLICK]];
		}
	}
	else if([[note name]isEqualToString:@"PopButton"])
	{
		if(button.buttonId == BTNID_UPGRADEATTACK_UPGRADE)
		{
			[self upgradeAttack:button.dataObject Cost:button.intData];
			[SOUNDMGR play:[GINFO sfxID:SND_MENU_CLICK]];
		}
		else if(button.buttonId == BTNID_UPGRADEATTACK_BUY)
		{
			[self buyAttack:button.dataObject Cost:button.intData];
			[SOUNDMGR play:[GINFO sfxID:SND_MENU_CLICK]];
		}
		else if(button.buttonId == BTNID_UPGRADEATTACK_INSTALL)
		{
			[self installAttack:button.dataObject];
			[SOUNDMGR play:[GINFO sfxID:SND_MENU_CLICK]];
		}
		else if(button.buttonId == BTNID_UPGRADEATTACK_UNINSTALL)
		{
			[self uninstallAttack:button.dataObject];
			[SOUNDMGR play:[GINFO sfxID:SND_MENU_CLICK]];
		}
	}
}

@end
