//
//  GuiSelectSlot.h
//  HeavyMach
//
//  Created by 엔비 on 08. 12. 17.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

@class QUIAlertView;

@interface GuiSelectSlot : QobBase
{
	ResMgr_Tile *_tileResMgr;
	int _sel;
	TSaveSlotData *_pSelSlot;
	QUIAlertView *_NewUserDlg;
	
	QobButton *_slotBase[MAX_SAVESLOT];
}

@property(readwrite) int sel;

- (void)refreshSlot:(int)idx;
- (void)refreshSelect;

- (void)handleButton:(NSNotification *)note;

@end
