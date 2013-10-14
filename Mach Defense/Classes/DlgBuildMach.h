//
//  DlgWeaponList.h
//  MachDefense
//
//  Created by HaeJun Byun on 10. 9. 3..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

@class GobHvM_Player;

enum EBuildMachType
{
	BMT_BUILDMACH, BMT_UPGRADEMACH
};

struct TBuildButton
{
	TMachBuildSet *buildSet;
	QobButton *btn;
	QobImage *imgDimd, *buildIcon[5];
};
typedef struct TBuildButton TBuildButton;

@interface DlgBuildMach : QobBase
{
	QobImage *_imgSelWeapon, *_imgButtonBG;
	MachBuildSet *_selBuildSet;
	
	int _buildMachType;
	int _buildBtnCnt;
	TBuildButton _buildButton[32];
	
	float _buildTime, _checkTime;
}

@property(readonly) int buildMachType, buildBtnCnt;

- (void)removeAllButtons;
- (void)refreshButtonsWithType:(int)type;

- (void)setAttackPos:(CGPoint)pos;

@end
