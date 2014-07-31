//
//  DlgShop.h
//  MachDefense
//
//  Created by Dustin on 4/9/14.
//
//

#import "CommonDlg.h"

@class SpAttackSet;

@interface DlgShopSpecial : QobBase
{
    BOOL _isScroll;
    BOOL _canClick;
    QobImage *_QSLOT[7];
    NSMutableArray *_QLIST;
    QobBase *_base;
    QobText *_cr;
    
    int _buttonId;
    float _startPos,_scrollPos;
    float _topPos, _bottomPos;
}
- (void) createMainMenu;
- (void) updateList;
- (void) updateSlot;
- (void) refreshCR;
- (SpAttackSet *)getAttackSet:(int)unit_id;
- (void) refreshList:(int)unit_id;
- (void) buyAttack:(int)unit_id;
- (void) upgradeMach:(int)unit_id;

@end
