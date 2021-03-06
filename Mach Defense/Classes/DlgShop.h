//
//  DlgShop.h
//  MachDefense
//
//  Created by Dustin on 4/9/14.
//
//

#import "CommonDlg.h"

@interface DlgShop : QobBase
{
    BOOL _isScroll;
    BOOL _canClick;
    NSMutableArray *_QSLOT;
    NSMutableArray *_QLIST;
    QobBase *_base;
    QobText *_cr;
    
    float _startPos,_scrollPos;
    float _topPos, _bottomPos;
}
- (void) createMainMenu;
- (void) updateList;
- (void) updateSlot;
- (void) refreshCR;
- (void) refreshList:(int)unit_id;
- (void) uninstallMach:(int)unit_id;//(MachBuildSet *)buildSet;
- (void) upgradeMach:(int)unit_id;

@end
