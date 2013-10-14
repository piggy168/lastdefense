//
//  Tile2D.h
//  Jumping!
//
//  Created by 엔비 on 08. 09. 10.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "Texture2D.h"

#define BT_NORMAL		0
#define BT_COLOR		1
#define BT_ADD			2
#define BT_BLACK		3
#define BT_ALPHA		4

#define REVERSE_H		1
#define REVERSE_V		2

#define RAD2DEG_VALUE	(180.f / M_PI)

@interface Tile2D : Texture2D
{
	NSString *_fileName;
	
	int _splitX, _splitY;
	int _tileCnt;

	GLfloat _u, _v;
	GLfloat _w, _h;
	
	float _tileWidth;
	float _tileHeight;
	
	float _originX, _originY;

	float _colorR, _colorG, _colorB;
}

@property(readonly) NSString *fileName;
@property(readonly) float tileWidth, tileHeight;
@property(readonly) float u, v, w, h;
@property(readonly) int tileCnt, splitX, splitY;
@property(readwrite) float originX, originY, colorR, colorG, colorB;

- (void)setFileName:(NSString *)name;
- (void)tileSplitX:(int)splitX splitY:(int)splitY;
- (void)setColorR:(unsigned char)r G:(unsigned char)g B:(unsigned char)b;

- (void)drawTile:(int)tileNum x:(float)x y:(float)y blendType:(int)blendType alpha:(float)alpha scaleX:(float)scaleX scaleY:(float)scaleY turnX:(float)turnX turnY:(float)turnY rotate:(float)rotate;
- (void)drawTile:(int)tileNum x:(float)x y:(float)y blendType:(int)blendType alpha:(float)alpha scaleX:(float)scaleX scaleY:(float)scaleY rotate:(float)rotate reverse:(unsigned int)reverse;
- (void)drawTile:(int)tileNum x:(float)x y:(float)y blendType:(int)blendType alpha:(float)alpha scaleX:(float)scaleX scaleY:(float)scaleY rotate:(float)rotate;
- (void)drawTile:(int)tileNum x:(float)x y:(float)y blendType:(int)blendType alpha:(float)alpha;
- (void)drawTile:(int)tileNum x:(float)x y:(float)y scaleX:(float)scaleX scaleY:(float)scaleY rotate:(float)rotate;
- (void)drawTile:(int)tileNum x:(float)x y:(float)y scaleX:(float)scaleX scaleY:(float)scaleY;
- (void)drawTile:(int)tileNum x:(float)x y:(float)y rotate:(float)rotate;
- (void)drawTile:(int)tileNum x:(float)x y:(float)y;

@end
