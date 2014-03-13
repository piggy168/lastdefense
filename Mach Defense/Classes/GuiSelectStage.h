//
//  GuiSelectStage.h
//  MachDefense
//
//  Created by HaeJun Byun on 10. 12. 6..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define MAX_WORLDMAP 4

@interface GuiSelectStage : QobBase
{
	ResMgr_Tile *_tileResMgr;
	QobBase *_buttonBase;
	QobImage *_imgSel, *_imgWorldMap;
    QobButton *_btnFight;

	int _sel;
	float _camPos, _dragPos, _dragVel, _btnHeight, _lowerLimit, _btmLimit, _lastPosition;
}

- (void)handleButton:(NSNotification *)note;
- (void)createWorldMap;

@end
