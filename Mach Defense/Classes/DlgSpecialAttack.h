//
//  DlgBuildSpAttack.h
//  MachDefense
//
//  Created by HaeJun Byun on 10. 10. 6..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

@class SpAttackSet;

enum EBuildSpAttackType
{
	BSAT_BUILDATTACK, BSAT_UPGRADEATTACK
};

@interface DlgSpecialAttack : QobBase
{
	int _uiType, _buildBtnCnt;
	SpAttackSet *_selAttack;
	QobBase *_buttons, *_upgradeInd;
	QobImage *_imgSelAttack;
	CGPoint _attackPos;
}

@property(readonly) int uiType, buildBtnCnt;

- (void)setAttackPos:(CGPoint)pos;
- (void)refreshButtonsWithType:(int)type;

@end
