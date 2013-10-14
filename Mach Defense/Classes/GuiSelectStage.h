//
//  GuiSelectStage.h
//  MachDefense
//
//  Created by HaeJun Byun on 10. 12. 6..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface GuiSelectStage : QobBase
{
	ResMgr_Tile *_tileResMgr;
	QobBase *_buttonBase;
	QobImage *_imgSel;

	int _sel;
	float _camPos, _dragPos, _dragVel, _btnHeight, _topLimit, _btmLimit;
}

- (void)handleButton:(NSNotification *)note;

@end
