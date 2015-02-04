//
//  DlgShop.h
//  MachDefense
//
//  Created by Dustin on 4/9/14.
//
//

#import "CommonDlg.h"

struct TShopBaseButton
{
    QobButton *btn;
    QobText *text;
    QobText *cr;
    QobText *lv;
    QobText *txt;
};
typedef struct TShopBaseButton TShopBaseButton;

@interface DlgShopBase : QobBase
{
    BOOL _isScroll;
    BOOL _canClick;
    TShopBaseButton _QSLOT[6];
    NSMutableArray *_QLIST;
    QobBase *_base;
    QobText *_cr;
    QobText *_desc;
    QobText *_prise;
    QobButton *_upgradeBtn;
    GobHvM_Player *_mach;
    
    int _buttonId;
    float _startPos,_scrollPos;
    float _topPos, _bottomPos;
}
- (void) createMainMenu;
- (void) updateList;
- (void) updateSlot;
- (void) refreshCR;
- (void) refreshDlg;
- (SpAttackSet *)getAttackSet:(int)unit_id;
- (void) refreshList:(int)unit_id;
- (void) buyAttack:(int)unit_id;
- (void) upgradeMach:(int)unit_id;
- (void) setSelectUpgrade:(int)sel;
- (void) setUpgrade;
- (void) refreshButton;

@end
