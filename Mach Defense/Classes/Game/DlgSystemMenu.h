//
//  DlgSystemMenu.h
//  HeavyMach2
//
//  Created by 엔비 on 09. 11. 12.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#include "CommonDlg.h"

@interface DlgSystemMenu : CommonDlg
{
	QobImage *_wndInfo;
	QobButton *_btnBgmVol, *_btnSfxVol;
	float _thumbPos, _thumbSize;
}

@end
