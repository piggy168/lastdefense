//
//  DlgSummery.h
//  MACHDEFENSE
//
//  Created by HaeJun Byun on 10. 11. 4..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CommonDlg.h"


@interface DlgSummary : CommonDlg
{
    int _nStage;
}

- (id)initWithClear:(bool)clear;

- (bool)addNewMach;
- (void)addNewItem;

@end
