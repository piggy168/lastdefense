//
//  GuiGame.h
//  HeavyMach
//
//  Created by 엔비 on 08. 12. 13.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

@class QobImageFont;
@class WndBuildSlot;
@class DlgRadar;
@class DlgUpgradeBase;
@class DlgSystemMenu;
@class DlgBuildMach;
@class DlgSpecialAttack;
@class DlgFormation;
@class DlgUpgradeEquip;

enum EUiType
{
	UITYPE_NONE,
	UITYPE_MAKE_MACH, UITYPE_MAKE_SPATTACK, UITYPE_FORMATION
//	UITYPE_SHOP, UITYPE_SYSTEM, 
};

enum EBuildType
{
	BUILDTYPE_MACH, BUILDTYPE_BOT, BUILDTYPE_TURRET, BUILDTYPE_SPATTACK
};

enum EBaseUpgradeStep
{
	BUGS_NONE, BUGS_READY, BUGS_OPEN, BUGS_UPGRADE, BUGS_CLOSE
};

struct TPassiveSlot
{
	bool use;
	QobImage *imgIcon;
	QobImageFont *txtLeftTime;
	float fTime;
};
typedef struct TPassiveSlot TPassiveSlot;

@interface GuiGame : QobBase
{
	QobImage *_baseSubMenu;
	WndBuildSlot *_buildSlot;
	DlgRadar *_dlgRadar;
	DlgSystemMenu *_dlgSysMenu;
	
	DlgUpgradeEquip *_dlgUpgrade;
	DlgBuildMach *_dlgBuildMach;
	DlgSpecialAttack *_dlgBuildSpAttack;
	DlgFormation *_dlgFormation;
	DlgUpgradeBase *_dlgUpgradeBase;
	QobBase *_dlgSubUI[3];
	
	QobImage *_imgUpgradeCell;
	QobText *_textUpgradeCell;

	QobBase *_gameUI, *_baseBuildSlot;
	QobButton *_makeBtn[3], *_btnSysMenu, *_btnUpgradeBase, *_btnUpgradeEquip;
	int _uiType, _baseUpgradeStep;
	float _destUiPos;
	
	QobImage *_uiTitle, *_gaugeEnemy, *_gaugeMyBase;
	QobImageFont *_numScore, *_numCr, *_numStage, *_numMineral, *_numMaxMineral;
	
	CGPoint _placeNameStartPos, _placeNameEndPos;
	QobImage *_imgPlaceName;

	QobImage *_imgMsgBox;
	QobText *_txtMsg;
	float _msgTime, _msgPos;
	bool _autoHideMsg;
	bool _hideMsg;
	
	float _uiDefaultPos, _uiWorldMargin;
}

@property(readonly) WndBuildSlot *buildSlot;
@property(readonly) DlgUpgradeEquip *dlgUpgrade;
@property(readonly) DlgBuildMach *dlgBuildMach;
@property(readonly) DlgSpecialAttack *dlgSpAttack;
@property(readonly) DlgRadar *dlgRader;

- (void)turnOffButtons:(int)btnID;
- (void)turnOnButtons;

- (void)onClearStage;
- (void)onStartStage;
- (void)setUiType:(int)uiType;
- (void)setAttackPos:(CGPoint)pos;

- (void)refreshBuildMachDlg;

- (void)setMessage:(NSString *)msg BG:(int)bg AutoHide:(bool)autoHide;
- (void)hideMessage;

- (void)refreshEnemyGauge:(float)scale;
- (void)refreshMyGauge:(float)scale;
- (void)refreshMaxMineral;
- (void)refreshCellUpgradeCost;

- (void)setPlaceName:(char *)placeName;

@end
