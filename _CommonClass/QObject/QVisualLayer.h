//
//  QVisualLayer.h
//  HeavyMach
//
//  Created by 엔비 on 08. 12. 11.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

@interface QVisualLayer : NSObject
{
	QobBase **_visualPool;

	BOOL _zOrderSort;
	int _unitSize;
	int _poolSize;
	int _visualCnt;
	
	NSMutableArray *_listAtlas;
}

@property(readwrite) BOOL zSort;
@property(readonly) int visualCnt;

- (id)initWithUnitSize:(int)size;

- (void)insertObject:(QobBase *)object;
- (void)addObject:(QobBase *)object;

- (void)removeAllAtlas;
- (TextureAtlas *)makeCleanAtlas:(Tile2D *)tile;
- (TextureAtlas *)findAtlas:(QobImage *)me;
- (TQuadInfo *)getMyAtlasQuad:(QobImage *)me;
- (QobBase *)getObject:(int)n;

- (void)extendPool;

- (void)clearAllVisual;
- (void)drawVisual;

@end
