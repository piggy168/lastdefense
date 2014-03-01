//
//  GuiGame.m
//  HeavyMach
//
//  Created by 엔비 on 08. 12. 13.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "GuiGame.h"
#import "WndBuildSlot.h"
#import "DlgRadar.h"
#import "DlgUpgradeBase.h"
#import "DlgUpgradeEquip.h"
#import "DlgSystemMenu.h"
#import "DlgBuildMach.h"
#import "DlgSpecialAttack.h"
#import "DlgFormation.h"
#import "QobButton.h"
#import "QobImageFont.h"
#import "QobAffecter.h"
#import "GobHvMach.h"
#import "GobHvM_Player.h"
#import "ScoreNum.h"
#import "GuiHelp.h"
#import "QobParticle.h"
#import "DefaultAppDelegate.h"

extern DefaultAppDelegate *_appDelegate;

@implementation GuiGame
@synthesize buildSlot=_buildSlot, dlgRader=_dlgRadar, dlgUpgrade=_dlgUpgrade, dlgBuildMach=_dlgBuildMach, dlgSpAttack=_dlgBuildSpAttack;

- (id)init
{
	[super init];
	[self setUiReceiver:true];
	
	Tile2D *tile = nil;
	QobImage *img = nil;
	QobButton *btn;
	
	if(_glView.deviceType == DEVICE_IPAD)
	{
		_uiDefaultPos = -384;
		_uiWorldMargin = 384.f + 178;
		_msgPos = 466.f;
	}
	else
	{
		_uiDefaultPos = -215;
		_uiWorldMargin = 240;
		_msgPos = 216.f;
	}

	[self setLayer:VLAYER_UI];

	tile = [TILEMGR getTileForRetina:@"Ani_BuildMach.png"];		[tile tileSplitX:8 splitY:1];
	tile = [TILEMGR getTileForRetina:@"Ani_SpAttack.png"];		[tile tileSplitX:8 splitY:1];
	tile = [TILEMGR getTileForRetina:@"Ani_Formation.png"];		[tile tileSplitX:8 splitY:1];

	if(_glView.deviceType == DEVICE_IPAD)
	{
		tile = [TILEMGR getTileForRetina:@"GameUI_BuildSlot.png"];
		[tile tileSplitX:1 splitY:1];
		img = [[QobImage alloc] initWithTile:tile tileNo:0];
		[img setPosX:-256 Y:0];
		[self addChild:img];
		[img setLayer:VLAYER_FORE];
	}
	
	QobBase *imgBuildSlot = [[QobBase alloc] init];
	if(_glView.deviceType == DEVICE_IPAD) [imgBuildSlot setPosX:256 Y:56];
	else [imgBuildSlot setPosX:96 Y:12];
	[self addChild:imgBuildSlot];
	[imgBuildSlot setLayer:VLAYER_FORE];
	_baseBuildSlot = imgBuildSlot;
	
	tile = [TILEMGR getTileForRetina:@"CellUpgrade.png"];
	[tile tileSplitX:1 splitY:1];
	img = [[QobImage alloc] initWithTile:tile tileNo:0];
	[img setPosX:22 * GWORLD.deviceScale Y:411 * GWORLD.deviceScale];
	[img setLayer:VLAYER_UI];
	[img setShow:false];
	[_baseBuildSlot addChild:img];
	_imgUpgradeCell = img;

	btn = [[QobButton alloc] initWithTile:nil TileNo:0 ID:BTNID_UPGRADE_CELL];
	[btn setBoundWidth:138 * GWORLD.deviceScale Height:64 * GWORLD.deviceScale];
	[btn setPosX:62 * GWORLD.deviceScale Y:426 * GWORLD.deviceScale];
	[btn setLayer:VLAYER_UI];
	[_baseBuildSlot addChild:btn];
	
	tile = [TILEMGR getTileForRetina:@"Btn_UpgradeEquip.png"];
	[tile tileSplitX:1 splitY:4];
	btn = [[QobButton alloc] initWithTile:tile TileNo:0 ID:BTNID_UPGRADE_EQUIP];
	[btn setReleaseTileNo:1];
	[btn setPosX:74 * GWORLD.deviceScale Y:-356 * GWORLD.deviceScale];
	[btn setLayer:VLAYER_UI];
	[imgBuildSlot addChild:btn];
	_btnUpgradeEquip = btn;
	
	tile = [TILEMGR getTileForRetina:@"GameUI_HpGauge.png"];	
	if(_glView.deviceType == DEVICE_IPAD)
	{
		img = [[QobImage alloc] initWithTile:tile tileNo:0];
		[img setPosX:0 Y:494];
		[self addChild:img];
	}
	else
	{
		[tile tileSplitX:2 splitY:1];
		img = [[QobImage alloc] initWithTile:tile tileNo:0];
		[img setUseAtlas:YES];
		[img setPosX:-102 Y:231];
		[self addChild:img];

		img = [[QobImage alloc] initWithTile:tile tileNo:1];
		[img setUseAtlas:YES];
		[img setPosX:32 Y:231];
		[self addChild:img];
	}

	
	tile = [TILEMGR getUniTile:@"GameUI_BG.png"];
	QobImage *bg = [[QobImage alloc] initWithTile:tile tileNo:0];
	[bg setPosX:0 Y:_uiDefaultPos];
	[self addChild:bg];
	_gameUI = bg;
	
	if(_glView.deviceType == DEVICE_IPAD)
	{
		tile = [TILEMGR getTileForRetina:@"UiTitle.png"];
		[tile tileSplitX:1 splitY:4];
		img = [[QobImage alloc] initWithTile:tile tileNo:0];
		[img setPosX:0 Y:16 * GWORLD.deviceScale];
		[bg addChild:img];
		_uiTitle = img;
	}

	tile = [TILEMGR getTileForRetina:@"GameUI_BtmL.png"];
	img = [[QobImage alloc] initWithTile:tile tileNo:0];
	[img setPosX:-256 * GWORLD.deviceScale Y:-384 * GWORLD.deviceScale];
	[bg addChild:img];
	
	tile = [TILEMGR getTileForRetina:@"GameUI_BtmR.png"];
	img = [[QobImage alloc] initWithTile:tile tileNo:0];
	[img setPosX:128 * GWORLD.deviceScale Y:-384 * GWORLD.deviceScale];
	[bg addChild:img];
	
	tile = [TILEMGR getTileForRetina:@"MachButton.png"];
	[tile tileSplitX:2 splitY:4];

	btn = [[QobButton alloc] initWithTile:tile TileNo:0 ID:BTNID_MAKE_MACH];
	[btn setPosX:-89 * GWORLD.deviceScale Y:-50 * GWORLD.deviceScale];
	[bg addChild:btn];
	_makeBtn[0] = btn;
	
	btn = [[QobButton alloc] initWithTile:tile TileNo:2 ID:BTNID_SPECIAL_ATTACK];
	[btn setPosX:2 * GWORLD.deviceScale Y:-50 * GWORLD.deviceScale];
	[bg addChild:btn];
	_makeBtn[1] = btn;
	
/*	btn = [[QobButton alloc] initWithTile:tile TileNo:4 ID:BTNID_FORMATION];
	[btn setPosX:97 * GWORLD.deviceScale Y:-50 * GWORLD.deviceScale];
	[bg addChild:btn];
	_makeBtn[2] = btn;
*/	
	if(_glView.deviceType == DEVICE_IPAD)
	{
		tile = [TILEMGR getTileForRetina:@"NumSet_Cr.png"];
		[tile tileSplitX:16 splitY:1];
		_numScore = [[QobImageFont alloc] initWithTile:tile];
		[_numScore setPosX:-270 Y:484];
		[_numScore setAlignRate:1.f];
		[_numScore setPitch:9];
		[_numScore setNumber:0];
		[self addChild:_numScore];
	}
	else
	{
		tile = [TILEMGR getTileForRetina:@"NumSet_Cr.png"];
		[tile tileSplitX:16 splitY:1];
		_numScore = [[QobImageFont alloc] initWithTile:tile];
		[_numScore setPosX:-154 Y:-5];
		[_numScore setAlignRate:0.f];
		[_numScore setPitch:9];
		[_numScore setNumber:0];
		[bg addChild:_numScore];
	}

	tile = [TILEMGR getTileForRetina:@"NumSet_Cr.png"];
	[tile tileSplitX:16 splitY:1];
	_numCr = [[QobImageFont alloc] initWithTile:tile];
	if(_glView.deviceType == DEVICE_IPAD) [_numCr setPosX:-222 Y:-90];
	else [_numCr setPosX:-88 Y:-49];
	[_numCr setAlignRate:1.f];
	[_numCr setPitch:9];
	[_numCr setNumber:0];
	[bg addChild:_numCr];
	
	tile = [TILEMGR getTileForRetina:@"NumSet_Stage.png"];
	[tile tileSplitX:16 splitY:1];
	_numStage = [[QobImageFont alloc] initWithTile:tile];
	if(_glView.deviceType == DEVICE_IPAD) [_numStage setPosX:-242 Y:-33];
	else [_numStage setPosX:-96 Y:-28];
	[_numStage setAlignRate:.5f];
	[_numStage setPitch:12];
	[_numStage setNumber:0];
	[bg addChild:_numStage];
	
	tile = [TILEMGR getUniTile:@"QuickBtn.png"];
	[tile tileSplitX:2 splitY:2];
	btn = [[QobButton alloc] initWithTile:tile TileNo:0 ID:BTNID_GAMEMENU];
	[btn setReleaseTileNo:1];
	if(_glView.deviceType == DEVICE_IPAD)
	{
		[btn setPosX:288 Y:-20];
		[btn setBoundWidth:180 Height:64];
	}
	else
	{
		[btn setPosX:124 Y:-28];
		[btn setBoundWidth:120 Height:50];
	}
	[bg addChild:btn];
	_btnSysMenu = btn;
	
	btn = [[QobButton alloc] initWithTile:tile TileNo:2 ID:BTNID_UPGRADE_BASE];
	[btn setReleaseTileNo:3];
	if(_glView.deviceType == DEVICE_IPAD)
	{
		[btn setPosX:288 Y:-85];
		[btn setBoundWidth:180 Height:64];
	}
	else
	{
		[btn setPosX:124 Y:-51];
		[btn setBoundWidth:80 Height:22];
	}
	[bg addChild:btn];
	_btnUpgradeBase = btn;
	
	tile = [TILEMGR getTileForRetina:@"EnemyGauge.png"];
	[tile tileSplitX:1 splitY:2];
	img = [[QobImage alloc] initWithTile:tile tileNo:1];
	[img setUseAtlas:true];
	[img setPosX:0 Y:_glView.deviceType == DEVICE_IPAD ? 499 : 233.5];
	[self addChild:img];
	_gaugeEnemy = img;

	img = [[QobImage alloc] initWithTile:tile tileNo:0];
	[img setUseAtlas:true];
	[img setPosX:0 Y:_glView.deviceType == DEVICE_IPAD ? 499 : 233.5];
	[self addChild:img];
	_gaugeMyBase = img;
	

	tile = [TILEMGR getTileForRetina:@"MessageBox.png"];
	[tile tileSplitX:1 splitY:2];
	_imgMsgBox = [[QobImage alloc] initWithTile:tile tileNo:0];
	[_imgMsgBox setPosX:_glView.deviceType == DEVICE_IPAD ? 0 : -32 Y:_msgPos];
	[_imgMsgBox setShow:false];
	[self addChild:_imgMsgBox];

	_dlgRadar = [[DlgRadar alloc] init];
	if(_glView.deviceType == DEVICE_IPAD) [_dlgRadar setPosX:-329 Y:312];
	else [_dlgRadar setPosX:-142 Y:158];
	[self addChild:_dlgRadar];
	[_dlgRadar setLayer:VLAYER_UI];

	tile = [TILEMGR getTileForRetina:@"NumSet_Stage.png"];
	[tile tileSplitX:16 splitY:1];
	_numMineral = [[QobImageFont alloc] initWithTile:tile];
	[_numMineral setPosX:60 * GWORLD.deviceScale Y:438 * GWORLD.deviceScale];
	[_numMineral setAlignRate:1.f];
	[_numMineral setPitch:12];
	[_numMineral setNumber:0];
	[imgBuildSlot addChild:_numMineral];
	
	tile = [TILEMGR getTileForRetina:@"NumSet_Level.png"];
	[tile tileSplitX:16 splitY:1];
	_numMaxMineral = [[QobImageFont alloc] initWithTile:tile];
	[_numMaxMineral setPitch:9];
	[_numMaxMineral setAlignRate:0.f];
	[_numMaxMineral setPosX:84 * GWORLD.deviceScale Y:434 * GWORLD.deviceScale];
	[_numMaxMineral setNumber:0];
	[imgBuildSlot addChild:_numMaxMineral];
	
	_dlgBuildMach = [[DlgBuildMach alloc] init];
	[_dlgBuildMach setPosX:0 Y:0];
	[_dlgBuildMach setShow:false];
	[imgBuildSlot addChild:_dlgBuildMach];
	_dlgSubUI[0] = _dlgBuildMach;

	_dlgBuildSpAttack = [[DlgSpecialAttack alloc] init];
	[_dlgBuildSpAttack setPosX:71 Y:352];
	[_dlgBuildSpAttack setShow:false];
	[imgBuildSlot addChild:_dlgBuildSpAttack];
	_dlgSubUI[1] = _dlgBuildSpAttack;
	
	_dlgFormation = [[DlgFormation alloc] init];
	[_dlgFormation setPosX:71 Y:352];
	[_dlgFormation setShow:false];
	[imgBuildSlot addChild:_dlgFormation];
	_dlgSubUI[2] = _dlgFormation;
	
	_dlgUpgradeBase = [[DlgUpgradeBase alloc] init];
	[_dlgUpgradeBase setPosX:0 Y:-196 * GWORLD.deviceScale];
	[_dlgUpgradeBase setShow:false];
	[_gameUI addChild:_dlgUpgradeBase];
	
/*	tile = [TILEMGR getTile:@"ItemBox.png"];
	[tile tileSplitX:1 splitY:1];
	btn = [[QobButton alloc] initWithTile:tile TileNo:0 ID:BTNID_ORDER_BACK];
	[btn setReleaseTileNo:1];
	[btn setPosX:324 Y:335];
	[btn setBoundWidth:64 Height:64];
	[self addChild:btn];*/
	
	_buildSlot = [[WndBuildSlot alloc] init];
	if(_glView.deviceType == DEVICE_IPAD) [_buildSlot setPosX:-329 Y:140];
	else [_buildSlot setPosX:68 Y:188];
	[_buildSlot setLayer:VLAYER_FORE];
	[self addChild:_buildSlot];
	
	_dlgSysMenu = [[DlgSystemMenu alloc] init];
	[_dlgSysMenu setPosX:_glView.deviceType == DEVICE_IPAD ? 0 : -30 Y:128 * GWORLD.deviceScale];
	[_dlgSysMenu setShow:false];
	[self addChild:_dlgSysMenu];

	_placeNameStartPos = CGPointMake(384, 512);
	_placeNameEndPos = CGPointMake(900, 512);
	
	[self setUiType:UITYPE_MAKE_MACH];
	
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
	if(GSLOT == NULL) return;
	
	if(_baseUpgradeStep == BUGS_READY || _baseUpgradeStep == BUGS_CLOSE)
	{
		float y = _gameUI.pos.y;
		
		if(y == (_uiDefaultPos - 4.f))
		{
			if(_baseUpgradeStep == BUGS_READY)
			{
				_destUiPos = _glView.deviceType == DEVICE_IPAD ? 128.f : 82.f;
				_baseUpgradeStep = BUGS_OPEN;
			}
			else
			{
				y = _uiDefaultPos;
				_baseUpgradeStep = BUGS_NONE;
			}
		}
		else
		{
			EASYOUTE(y, (_uiDefaultPos - 4.f), 5.f, .5f);
		}
		
		[_gameUI setPosY:y];
		[GWORLD setUIPos:y + _uiWorldMargin];
	}
	else if(_baseUpgradeStep == BUGS_OPEN && _gameUI.pos.y != _destUiPos)
	{
		float y = _gameUI.pos.y;
		EASYOUTE(y, _destUiPos, 5.f, .5f);
		if(y == _destUiPos)
		{
			y -= 4.f;
			_destUiPos = y;
			_baseUpgradeStep = BUGS_UPGRADE;
		}
		[_gameUI setPosY:y];
		[GWORLD setUIPos:y + _uiWorldMargin];
	}
	
	if(GVAL.cellUpgrade < 5 && GVAL.mineral >= GVAL.cellUpgradeCost)
	{
		[_imgUpgradeCell setShow:((int)(g_time * 2.f) % 2) == 0];
	}
	else
	{
		[_imgUpgradeCell setShow:false];
	}


	if(_msgTime != 0.f)
	{
		float t = GWORLD.time - _msgTime;
		if(t <= .6f)
		{
			[_imgMsgBox setPosY:fabs(sinf(t / .6f * M_PI * 3.f) * (16.f * (.6f - t))) + _msgPos];
		}
		else
		{
			[_imgMsgBox setPosY:_msgPos];
			if(_autoHideMsg && t > 10.f) [self hideMessage];
		}

		if(_hideMsg)
		{
			if(_imgMsgBox.scaleY > .1f)
			{
				EASYOUT(_imgMsgBox.scaleY, 0.09f, 4.f);
				_txtMsg.scaleY = _imgMsgBox.scaleY;
				if(_imgMsgBox.scaleY <= .1f) _imgMsgBox.scaleY = .1f;
			}
			else
			{
				EASYOUT(_imgMsgBox.scaleX, 0.04f, 4.f);
				if(_imgMsgBox.scaleX <= .05f)
				{
					[_imgMsgBox setShow:false];
					_msgTime = 0.f;
					_hideMsg = false;
				}
			}
		}
	}

	if(_imgPlaceName != nil)
	{
		if(_imgPlaceName.pos.x < _placeNameStartPos.x)
		{
			[_imgPlaceName easyOutTo:&_placeNameStartPos Div:12.f Min:0.1f];
		}
		else
		{
			[_imgPlaceName easyOutTo:&_placeNameEndPos Div:12.f Min:0.1f];
			if(_imgPlaceName.pos.x >= _placeNameEndPos.x)
			{
				[_imgPlaceName remove];
				_imgPlaceName = nil;
			}
		}

	}
	
	if(_numScore.num != GSLOT->cr)
	{
		int num = _numScore.num;
		EASYOUT(num, GSLOT->score, 5);
		if(abs(num - GSLOT->score) < 5) num = GSLOT->score;
		[_numScore setNumber:num];
	}
	
	if(_numCr.num != GSLOT->cr)
	{
		int num = _numCr.num;
		EASYOUT(num, GSLOT->cr, 5);
		if(abs(num - GSLOT->cr) < 5) num = GSLOT->cr;
		[_numCr setNumber:num];
	}
	
	if(_numMineral.num != GVAL.mineral)
	{
		int num = _numMineral.num;
		EASYOUT(num, GVAL.mineral, 5);
		if(abs(num - GVAL.mineral) < 5) num = GVAL.mineral;
		[_numMineral setNumber:num];
	}
	
	[super tick];
}

- (void)turnOffButtons:(int)btnID
{
	if(btnID == BTNID_GAMEMENU)
	{
		[_btnUpgradeBase setActive:FALSE];
		[_baseBuildSlot setActive:FALSE];
		for(int i = 0; i < 3; i++)
		{
			[_makeBtn[i] setActive:FALSE];
		}
	}
	else if(btnID == BTNID_UPGRADE_BASE)
	{
		[_btnSysMenu setActive:FALSE];
		[_baseBuildSlot setActive:FALSE];
		for(int i = 0; i < 3; i++)
		{
			[_makeBtn[i] setActive:FALSE];
		}
	}
	else if(btnID == BTNID_UPGRADE_EQUIP)
	{
		[_btnSysMenu setActive:FALSE];
		[_btnUpgradeBase setActive:FALSE];
	}
	else
	{
		[_btnSysMenu setActive:FALSE];
		[_btnUpgradeBase setActive:FALSE];
		[_baseBuildSlot setActive:FALSE];
		for(int i = 0; i < 3; i++)
		{
			[_makeBtn[i] setActive:FALSE];
		}
	}
	
}

- (void)turnOnButtons
{
	[_btnSysMenu setActive:TRUE];
	[_btnUpgradeBase setActive:TRUE];
	[_baseBuildSlot setActive:TRUE];
	for(int i = 0; i < 3; i++)
	{
		[_makeBtn[i] setActive:TRUE];
	}
}

- (void)onClearStage
{
	[_dlgBuildMach removeAllButtons];
	[_buildSlot removeAllItems];
}

- (void)onStartStage
{
	[_imgUpgradeCell setShow:false];
	
	[_dlgBuildMach refreshButtonsWithType:BMT_BUILDMACH];
	[_dlgBuildSpAttack refreshButtonsWithType:BSAT_BUILDATTACK];
	[_dlgFormation refreshButtons];

	[self refreshMyGauge:1.f];
	[self refreshEnemyGauge:1.f];
	[self refreshMaxMineral];
	[self refreshCellUpgradeCost];
	[self turnOnButtons];
	[_numStage setNumber:GSLOT->stage + 1];
	[GWORLD setUIPos:_gameUI.pos.y + _uiWorldMargin];
}

- (void)setUiType:(int)uiType
{
	_uiType = uiType;
	
	for(int i = 0; i < 3; i++)
	{
		if(uiType < 4) [_dlgSubUI[i] setShow:i == (_uiType-1)];
		[_makeBtn[i] setDefaultTileNo:(i == uiType - 1) ? i*2+1 : i*2];
	}
	
	if(uiType < 4 && _uiTitle != nil) [_uiTitle setTileNo:uiType-1];
	
	if(uiType == UITYPE_MAKE_MACH)
	{
		[_btnUpgradeEquip setShow:true];
		[_btnUpgradeEquip setDefaultTileNo:0];
		[_btnUpgradeEquip setReleaseTileNo:1];
	}
	else if(uiType == UITYPE_MAKE_SPATTACK)
	{
		[_btnUpgradeEquip setShow:true];
		[_btnUpgradeEquip setDefaultTileNo:2];
		[_btnUpgradeEquip setReleaseTileNo:3];
	}
	else
	{
		[_btnUpgradeEquip setShow:false];
	}

	
	[self hideMessage];
	
//	[GWORLD onTarget:false];
}

- (void)setAttackPos:(CGPoint)pos
{
	switch(_uiType)
	{
		case UITYPE_MAKE_MACH:
		{
//			[GWORLD setTargetPos:pos];
			[_dlgBuildMach setAttackPos:pos];
		}
			break;
		case UITYPE_MAKE_SPATTACK:
		{
//			[GWORLD setTargetPos:pos];
			[_dlgBuildSpAttack setAttackPos:pos];
		}
			break;
	}
}

- (void)refreshBuildMachDlg
{
	[_dlgBuildMach removeAllButtons];
	[_dlgBuildMach refreshButtonsWithType:BMT_BUILDMACH];
}

- (void)setMessage:(NSString *)msg BG:(int)bg AutoHide:(bool)autoHide;
{
	_autoHideMsg = autoHide;
	_hideMsg = false;
	
	[_imgMsgBox setTileNo:bg];
	[_imgMsgBox setScale:1.f];
	[_imgMsgBox setShow:true];
	
	if(_txtMsg != nil) [_txtMsg remove];
	_txtMsg = [[QobText alloc] initWithString:msg Size:CGSizeMake(512, 24) Align:UITextAlignmentCenter Font:@"TrebuchetMS-Bold" FontSize:16 Retina:true];
	[_txtMsg setScale:1.f];
	[_imgMsgBox addChild:_txtMsg];
	
	_msgTime = GWORLD.time;
	[SOUNDMGR play:[GINFO sfxID:SND_ONMSG]];
}

- (void)hideMessage
{
	_hideMsg = true;
	[_txtMsg remove];
	_txtMsg = nil;
}

- (void)refreshEnemyGauge:(float)scale
{
//	scale = 1.f;
	[_gaugeEnemy setScaleX:scale];
	if(_glView.deviceType == DEVICE_IPAD) [_gaugeEnemy setPosX:178 - 81 * scale];
	else [_gaugeEnemy setPosX:57 - 40.5 * scale];
}

- (void)refreshMyGauge:(float)scale
{
//	scale = 1.f;
	[_gaugeMyBase setScaleX:scale];
	if(_glView.deviceType == DEVICE_IPAD) [_gaugeMyBase setPosX:-180 + 81 * scale];
	else [_gaugeMyBase setPosX:-128.5 + 40.5 * scale];
}

- (void)refreshMaxMineral
{
	[_numMaxMineral setNumber:GVAL.maxMineral];
}

- (void)refreshCellUpgradeCost
{
	if(_textUpgradeCell != nil) [_textUpgradeCell remove];
	
	NSString *cell;
	if(GVAL.cellUpgrade < 5) cell = [NSString stringWithFormat:@"%d cell", GVAL.cellUpgradeCost];
	else cell = @"FULL    ";
	
	QobText *text = [[QobText alloc] initWithString:cell Size:CGSizeMake(128, 16) Align:UITextAlignmentCenter Font:@"TrebuchetMS-Bold" FontSize:14 Retina:true];
	[text setColorR:255 G:255 B:255];
	[text setPosX:96 * GWORLD.deviceScale Y:411 * GWORLD.deviceScale];
	[text setLayer:VLAYER_FORE_UI];
	[_baseBuildSlot addChild:text];
	_textUpgradeCell = text;
}

- (void)setPlaceName:(char *)placeName
{
	if(_imgPlaceName != nil)
	{
		[_imgPlaceName remove];
		_imgPlaceName = nil;
	}
	
	Tile2D *tile = [TILEMGR getTile:@"PlaceNameBG.png"];
	[tile tileSplitX:1 splitY:1];
	_imgPlaceName = [[QobImage alloc] initWithTile:tile tileNo:0];
	[_imgPlaceName setPosX:-1024 Y:512];
	[self addChild:_imgPlaceName];
	[_imgPlaceName setLayer:VLAYER_UI];

	QobText *txt = [[QobText alloc] initWithString:[NSString stringWithUTF8String:placeName] Size:CGSizeMake(256, 40) Align:UITextAlignmentCenter Font:@"Arial" FontSize:32 Retina:true];
	[txt setColorR:0 G:0 B:0];
	[txt setPosX:2 Y:-2];
	[_imgPlaceName addChild:txt];

	txt = [[QobText alloc] initWithString:[NSString stringWithUTF8String:placeName] Size:CGSizeMake(256, 40) Align:UITextAlignmentCenter Font:@"Arial" FontSize:32 Retina:true];
	[txt setColorR:255 G:255 B:255];
	[_imgPlaceName addChild:txt];
}

- (void)closeSysMenu
{
	[_dlgSysMenu setShow:false];
	[GWORLD setPause:false];
}

- (void)handleButton:(NSNotification *)note
{
	if(![self isShow]) return;
	
	QobButton *button = [note object];
	if(button == nil) return;
	
	if([[note name]isEqualToString:@"PushButton"])
	{
		if(GWORLD.state == GSTATE_PLAY)
		{
			if(!GWORLD.pause)
			{
				if(button.buttonId == BTNID_ORDER_BACK)
				{
					[GWORLD setOrder:ORDER_TAKEBACK];
					[SOUNDMGR play:[GINFO sfxID:SND_MENU_CLICK]];
				}
			}
		}
	}
	else if([[note name]isEqualToString:@"PopButton"])
	{
		if(button.buttonId == BTNID_GAMEMENU)
		{
			bool showDialog = [_dlgSysMenu isShow];
			if(!showDialog)
			{
				[_dlgSysMenu setShow:true];
				[GWORLD setPause:true];
				[self turnOffButtons:button.buttonId];
				[_appDelegate bannerTurnOn:nil];
			}
			else
			{
				[self closeSysMenu];
				[self turnOnButtons];
				[_appDelegate bannerTurnOff:nil];
			}

			[SOUNDMGR play:[GINFO sfxID:SND_MENU_CLICK]];
		}
		else if(button.buttonId == BTNID_UPGRADE_CELL)
		{
			if(GVAL.cellUpgrade < 5 && GVAL.mineral >= GVAL.cellUpgradeCost)
			{
				GVAL.cellUpgrade++;
				GVAL.mineral -= GVAL.cellUpgradeCost;
				[_imgUpgradeCell setShow:false];
				[GINFO updateBaseUpgrade];
				[self refreshMaxMineral];
				[self refreshCellUpgradeCost];
				[SOUNDMGR play:[GINFO sfxID:SND_UPGRADE_BASE]];
			}
		}
		else if(button.buttonId == BTNID_MAKE_MACH)
		{
			[self setUiType:UITYPE_MAKE_MACH];
			if(_dlgUpgrade) [_dlgUpgrade refreshMachButtons];

			Tile2D *tile = [TILEMGR getTile:@"Ani_BuildMach.png"];
			QobParticle *particle = [[QobParticle alloc] init];
			[particle setTile:tile tileNo:0];
			[particle setBlendType:BT_NORMAL];
			[particle setLiveTime:tile.tileCnt * 0.06f];
			[particle setTileAni:tile.tileCnt];
			[particle setSelfRemove:YES];
			[button addChild:particle];
			[particle start];
			
			[SOUNDMGR play:[GINFO sfxID:SND_UI_BUILDMACH]];
		}
		else if(button.buttonId == BTNID_SPECIAL_ATTACK)
		{
			[self setUiType:UITYPE_MAKE_SPATTACK];
			if(_dlgUpgrade) [_dlgUpgrade refreshAttackButtons];

			Tile2D *tile = [TILEMGR getTile:@"Ani_SpAttack.png"];
			QobParticle *particle = [[QobParticle alloc] init];
			[particle setTile:tile tileNo:0];
			[particle setBlendType:BT_NORMAL];
			[particle setLiveTime:tile.tileCnt * 0.06f];
			[particle setTileAni:tile.tileCnt];
			[particle setSelfRemove:YES];
			[button addChild:particle];
			[particle start];

			[SOUNDMGR play:[GINFO sfxID:SND_UI_SPATTACK]];
		}
		else if(button.buttonId == BTNID_FORMATION)
		{
			[self setUiType:UITYPE_FORMATION];

			Tile2D *tile = [TILEMGR getTile:@"Ani_Formation.png"];
			QobParticle *particle = [[QobParticle alloc] init];
			[particle setTile:tile tileNo:0];
			[particle setBlendType:BT_NORMAL];
			[particle setLiveTime:tile.tileCnt * 0.06f];
			[particle setTileAni:tile.tileCnt];
			[particle setSelfRemove:YES];
			[button addChild:particle];
			[particle start];

			[SOUNDMGR play:[GINFO sfxID:SND_UI_FORMATION]];
		}
		else if(button.buttonId == BTNID_UPGRADE_EQUIP || button.buttonId == BTNID_UPGRADE_EQUIP_CLOSE)
		{
			if(_uiType == UITYPE_MAKE_MACH)
			{
				if(_dlgBuildMach.buildMachType == BMT_BUILDMACH)
				{
					DlgUpgradeEquip *upgrade = [[DlgUpgradeEquip alloc] init];
					[upgrade setLayer:VLAYER_UI];
					[upgrade setPosX:_glView.deviceType == DEVICE_IPAD ? -8 : -36 Y:96 * GWORLD.deviceScale];
					[upgrade refreshMachButtons];
					[self addChild:upgrade];
					_dlgUpgrade = upgrade;
					
					[_dlgBuildMach refreshButtonsWithType:BMT_UPGRADEMACH];
					[_dlgBuildSpAttack refreshButtonsWithType:BSAT_UPGRADEATTACK];
					[GWORLD setPause:true];
					
					[self turnOffButtons:button.buttonId];
				}
				else
				{
					[_dlgBuildMach refreshButtonsWithType:BMT_BUILDMACH];
					[_dlgBuildSpAttack refreshButtonsWithType:BMT_BUILDMACH];
					[_dlgUpgrade remove];
					_dlgUpgrade = nil;
					[GWORLD setPause:false];
					
					[self turnOnButtons];
				}
			}
			else if(_uiType == UITYPE_MAKE_SPATTACK)
			{
				if(_dlgBuildSpAttack.uiType == BSAT_BUILDATTACK)
				{
					DlgUpgradeEquip *upgrade = [[DlgUpgradeEquip alloc] init];
					[upgrade setLayer:VLAYER_UI];
					[upgrade setPosX:-8 Y:96 * GWORLD.deviceScale];
					[upgrade refreshAttackButtons];
					_dlgUpgrade = upgrade;

					[self addChild:upgrade];
					[_dlgBuildSpAttack refreshButtonsWithType:BSAT_UPGRADEATTACK];
					[_dlgBuildMach refreshButtonsWithType:BMT_UPGRADEMACH];
					[GWORLD setPause:true];
					
					[self turnOffButtons:button.buttonId];
				}
				else
				{
					[_dlgBuildSpAttack refreshButtonsWithType:BMT_BUILDMACH];
					[_dlgBuildMach refreshButtonsWithType:BMT_BUILDMACH];
					[_dlgUpgrade remove];
					_dlgUpgrade = nil;
					[GWORLD setPause:false];
					
					[self turnOnButtons];
				}
			}

			[SOUNDMGR play:[GINFO sfxID:SND_MENU_CLICK]];
		}
		else if(button.buttonId == BTNID_UPGRADE_BASE)
		{
			bool showDialog = [_dlgUpgradeBase isShow];
			if(!showDialog)
			{
				_baseUpgradeStep = BUGS_READY;
				[_dlgUpgradeBase refreshDlg];
				[_dlgUpgradeBase setShow:true];
				[self turnOffButtons:button.buttonId];
				[GWORLD setPause:true];
			}
			else
			{
				_baseUpgradeStep = BUGS_CLOSE;
				[_dlgUpgradeBase setShow:false];
				[self turnOnButtons];
				[GWORLD setPause:false];
			}

			[SOUNDMGR play:[GINFO sfxID:SND_MENU_CLICK]];
		}
		else if(button.buttonId == BTNID_HELP)
		{
			[self closeSysMenu];
			[GWORLD setPause:true];
			[_appDelegate bannerTurnOff:nil];
			
			GuiHelp *help = [[GuiHelp alloc] initWithLocale:GINFO.localeCode Page:-1];
//			[help setPage:2];
			[self addChild:help];
			[help setLayer:VLAYER_SYSTEM];
			[SOUNDMGR play:[GINFO sfxID:SND_MENU_CLICK]];
		}
		else if(button.buttonId == BTNID_RESUME_GAME)
		{
			[self closeSysMenu];
			[self turnOnButtons];
			[_appDelegate bannerTurnOff:nil];
			
			[GWORLD setPause:false];
			[SOUNDMGR play:[GINFO sfxID:SND_MENU_CLICK]];
		}
		else if(button.buttonId == BTNID_SAVE_EXIT)
		{
			[self closeSysMenu];
			
			[GWORLD setPause:true];
			[SOUNDMGR play:[GINFO sfxID:SND_MENU_CLICK]];
			[_appDelegate bannerTurnOff:nil];
			
			[GINFO saveDataFile];
#ifdef _LITE_VERSION_
			if(strcmp(GSLOT->name, "GimmeCr") != 0) [GAMECENTER reportScore:GSLOT->score forCategory:@"MDL_HIGHSCORE"];
#else
			if(strcmp(GSLOT->name, "GimmeCr") != 0) [GAMECENTER reportScore:GSLOT->score forCategory:@"HIGHSCORE"];
#endif
			[g_main changeScreen:GSCR_TITLE];
		}
		else if(button.buttonId == BTNID_VISIT_INDIEAPPS)
		{
			[self closeSysMenu];
			
			[_appDelegate bannerTurnOff:nil];
			
			[SOUNDMGR play:[GINFO sfxID:SND_MENU_CLICK]];
#ifdef _ON_DEBUG_
			[GWORLD onClearStage];
#else
			[g_main setAlertTitle:@"More Games" Message:[GINFO getDescription:@"VisitIndiean"] AlertId:ALERT_VISITINDIEAN CancelBtn:true];
#endif
		}
		else if(button.buttonId == BTNID_LEADERBOARD)
		{
			[self closeSysMenu];
			
			[_appDelegate bannerTurnOff:nil];
			
			[SOUNDMGR play:[GINFO sfxID:SND_MENU_CLICK]];
			if(GAMECENTER.isAuth) [_glView.viewController showLeaderboard]; 
		}
	}
}

@end
