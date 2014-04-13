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
    BOOL _isClick;
    NSMutableArray *_QSLOT;
    QobBase *_base;
    QobText *_cr;
    
    float _startPos,_scrollPos;
    float _topPos, _bottomPos;
}

- (void) updateList;

@end
