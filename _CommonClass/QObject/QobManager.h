//
//  QobManager.h
//  HeavyMach
//
//  Created by 엔비 on 08. 11. 30.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#include "TextureAtlas.h"

#define QOBMGR			[QobManager sharedMgr]

enum EVLayer
{
	VLAYER_BG = 0, VLAYER_BACK, VLAYER_BACK2, VLAYER_MIDDLE, VLAYER_MIDDLE2, VLAYER_FORE, VLAYER_FORE2, VLAYER_FOREMOST, VLAYER_FOREMOST2,
	VLAYER_UI, VLAYER_UI2, VLAYER_FORE_UI, VLAYER_FORE_UI2, VLAYER_SYSTEM, 
	VLAYER_MAX
};

@class QVisualLayer;
@class QobBase;
@class QobImage;
@class QobCamera;

@interface QobManager : NSObject
{
	NSMutableArray *_uiReceiverArray, *_deleteArray, *_addArray;
	QVisualLayer *_visualLayer[VLAYER_MAX];
	
	QobCamera *_cam;
	
	int _drawCount, _drawCall;
}

@property (readwrite) int drawCount, drawCall;

+ (QobManager *)sharedMgr;

- (void)removeAllAtlas;
- (TextureAtlas *)makeCleanAtlas:(Tile2D *)tile ToLayer:(int)layer;
- (TQuadInfo *)getMyAtlasQuad:(QobImage *)me;

- (void)setMainCam:(QobCamera *)cam;

- (void)addVisual:(QobBase *)obj Layer:(int)layer;
- (void)drawVisual;

- (void)addUiReceiver:(QobBase *)obj;
- (void)removeUiReceiver:(QobBase *)obj;

- (BOOL)onTap:(CGPoint)pt State:(int)state ID:(id)tapID;

@end
