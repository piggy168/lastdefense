//
//  QobImage.h
//
//  Created by 엔비 on 08. 10. 26.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

@interface QobImage : QobBase
{
	Tile2D *_tile;
	unsigned int _tileNo;
	int _blendType;
	unsigned int _reverse;
}

@property(readonly) Tile2D *tile;
@property(readwrite) int blendType;
@property(readwrite) unsigned int reverse, tileNo;

- (float)tileWidth;
- (id)initWithTile:(Tile2D *)tile tileNo:(unsigned int)tileNo;
- (void)setTile:(Tile2D *)tile tileNo:(unsigned int)tileNo;
- (void)setTileNo:(unsigned int)tileNo;

- (void)setUseAtlas:(BOOL)use;

@end
