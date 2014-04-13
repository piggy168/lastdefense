//
//  GuiSelectStage.h
//  MachDefense
//
//  Created by HaeJun Byun on 10. 12. 6..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DlgUpgradeEquip.h"

#define MAX_WORLDMAP 4

@class DlgShop;

@interface GuiSelectStage : QobBase
{
    NSMutableArray *_btnMNG;
	ResMgr_Tile *_tileResMgr;
	QobBase *_buttonBase;
    DlgUpgradeEquip *_dlgUpgrade;
    DlgShop *_dlgShop;
	QobImage *_imgSel, *_imgWorldMap;
    QobButton *_btnFight;
    QobText *_cr;

    bool _isClick;
	int _sel;
    int _mode;
	float _camPos, _dragPos, _dragVel, _btnHeight, _lowerLimit, _topLimit, _btmLimit, _lastPosition;
}

- (void)handleButton:(NSNotification *)note;
- (void)createWorldMap;

@end
