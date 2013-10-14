//
//  DlgShop.h
//  MachDefense
//
//  Created by HaeJun Byun on 10. 10. 28..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

struct TShopMachButton
{
	TMachBuildSet *buildSet;
	QobButton *btn;
	QobImage *imgDimd;
};
typedef struct TShopMachButton TShopMachButton;

@interface DlgUpgradeBase : QobBase
{
	QobBase *_dlgBase, *_lineBase;
	QobButton *_upgradeBtn[6], *_btnUpgrade;
	QobText *_upgradeCost;
	int _selUpgrade;
	CGPoint _machPos, _wpnPos;
}

- (void)setSelUpgrade:(int)sel;
- (void)refreshDlg;

@end
