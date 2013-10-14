//
//  DlgRader.h
//  HeavyMach2
//
//  Created by 엔비 on 09. 12. 07.
//  Copyright 2009 (주)인디앱스. All rights reserved.
//


@interface DlgRadar : QobBase
{
	float _mapScale;
	QobImage *_imgMark;
	Tile2D *_tileMark;
	
	QobLine *_camLine[4];
}

- (void)setCamBottom:(float)bottom Top:(float)top;

@end
