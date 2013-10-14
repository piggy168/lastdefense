//
//  QobImageFont.h
//  BPop
//
//  Created by 엔비 on 08. 10. 26.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

@interface QobImageFont : QobBase
{
	Tile2D *_tile;
	QobBase *_listNum;

	int _num;
	int _numCnt;
	int _tileList[64];
	float _alignRate;
	float _pitch, _calcScaleX, _calcScaleY;
	
	int _blendType;
	bool _boundCheck;
}

@property(readwrite) int blendType;
@property(readonly) int num;
@property(readwrite) float pitch;

- (id)initWithTile:(Tile2D *)tile;
- (void)setAlignRate:(float)rate;
- (void)setNumber:(int)num;
- (void)setText:(char *)text;
- (void)setBoundCheck:(bool)bCheck;
- (float)getNumWidth;

@end
