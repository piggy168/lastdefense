//
//  DlgFormation.h
//  MachDefense
//
//  Created by HaeJun Byun on 11. 1. 17..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface DlgFormation : QobBase
{
	int _btnCnt;
	QobBase *_buttons;
	QobImage *_imgSelFormation;
}

- (void)refreshButtons;

@end
