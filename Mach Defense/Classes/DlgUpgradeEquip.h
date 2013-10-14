//
//  DlgUpgradeEquip.h
//  MachDefense
//
//  Created by HaeJun Byun on 10. 11. 22..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CommonDlg.h"

@class DlgUpgradeItem;

@interface DlgUpgradeEquip : CommonDlg
{
	int _buildBtnCnt;
	QobBase *_buttonsBase;
	QobImage *_imgSelWeapon;
	QobBase *_upgradeInd;
	
	DlgUpgradeItem *_dlgUpgradeItem;
}

- (void)refreshMachButtons;
- (void)refreshAttackButtons;
- (void)setUpgradeMachItem:(MachBuildSet *)buildSet;
- (void)setUpgradeAttackItem:(SpAttackSet *)attackSet;

@end
