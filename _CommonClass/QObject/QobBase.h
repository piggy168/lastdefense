//
//  QUiBase.h
//  Jumping!
//
//  Created by 엔비 on 08. 09. 26.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

enum EUISteate
{
	UISTATE_NONE, UISTATE_CLICK, UISTATE_DEACTIVE
};

#define SCRPOS_X	[self screenPosX]
#define SCRPOS_Y	[self screenPosY]

@class QobCamera;

@interface QobBase : NSObject
{
	BOOL _visual;
	BOOL _useAtlas;
	BOOL _active;
	int _zLayer;
	int _zOrder;
	int _uiState;
	QobCamera *_cam;
	CGPoint _pos, _worldPos;
	float _fixedPos;
	float _alpha;
	float _scaleX;
	float _scaleY;
	float _rotate;
	BOOL _show;
	BOOL _uiObject;
	BOOL _remove;
	BOOL _isInScreen;
	
	CGRect _boundRect;
	
	QobBase *_parent;
	NSMutableArray *_childArray;
}

@property(readwrite) BOOL visual;
@property(readonly) BOOL useAtlas;
@property(readwrite) int layer;
@property(readwrite) int z;
@property(readonly) BOOL removeThis;
@property(readonly) BOOL isInScreen;
@property(readwrite) float alpha;
@property(readwrite) float scaleX;
@property(readwrite) float scaleY;
@property(readwrite) float rotate;
@property(readonly) CGPoint pos;
@property(readonly) CGRect boundRect;

- (void)tick;
- (void)draw;
- (void)setCam:(QobCamera *)cam;
- (bool)isInCam;
- (bool)isInPtX:(float)x Y:(float)y;
- (bool)isCollideBound:(QobBase *)obj;
- (void)addChild:(QobBase *)child;
- (int)childCount;
- (QobBase *)childAtIndex:(int)idx;
- (void)remove;
- (void)setActive:(BOOL)active;
- (void)setLayer:(int)layer;
- (void)setZOrder:(int)z;
- (void)setParent:(QobBase *)parent;
- (void)setFixedPos:(bool)fixed;
- (void)setScale:(float)scale;
//- (CGPoint *)localPos;
- (void)setPosX:(float)x;
- (void)setPosY:(float)y;
- (void)setPosX:(float)x Y:(float)y;
- (void)addPos:(const CGPoint *)add;
- (void)addPosX:(float)add;
- (void)addPosY:(float)add;
- (void)subPos:(const CGPoint *)add;
- (void)easyOutTo:(const CGPoint *)dest Div:(float)div Min:(float)min;
- (void)calcWorldPos;
- (float)worldPosX;
- (float)worldPosY;
- (float)screenPosX;
- (float)screenPosY;
- (void)setShow:(bool)show;
- (bool)isShow;
- (void)setUiReceiver:(bool)uiReceiver;

- (BOOL)onTap:(CGPoint)pt State:(int)state ID:(id)tapID;

@end
