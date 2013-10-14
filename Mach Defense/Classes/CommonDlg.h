//
//  CommonDlg.h
//  MachDefense
//
//  Created by HaeJun Byun on 10. 11. 22..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

@interface CommonDlg : QobBase
{
	QobImage *_bgTop, *_bgMid, *_bgBtm;
	float _height;
	int _buttonCount;
}

- (id)initWithCommonImg:(NSString *)commonImg TopImg:(NSString *)topImg Height:(float)height;
- (void)setHeight:(float)height;
- (QobButton *)addButton:(Tile2D *)tile ID:(unsigned int)buttonID;

@end
