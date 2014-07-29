//
//  QUiBase.m
//  Jumping!
//
//  Created by 엔비 on 08. 09. 26.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "QobBase.h"


@implementation QobBase

@synthesize visual=_visual, useAtlas=_useAtlas, layer=_zLayer, z=_zOrder, removeThis=_remove, pos=_pos, alpha=_alpha, scaleX=_scaleX, scaleY=_scaleY, rotate=_rotate, boundRect=_boundRect, isInScreen=_isInScreen;

- (id)init
{
	[super init];
	
	_visual = false;
	_zLayer = -1;
	_zOrder = 0;
	_active = true;
	_remove = false;
	_cam = nil;
	_fixedPos = 0.f;
	_alpha = 1.f;
	_scaleX = 1.f;
	_scaleY = 1.f;
	_rotate = 0.f;
	_uiState = UISTATE_NONE;
	_show = true;
	_uiObject = false;
	_isInScreen = true;
	_childArray = [[NSMutableArray alloc] init];
	_parent = nil;
	
	_boundRect.origin.x = 0;
	_boundRect.origin.y = 0;
	_boundRect.size.width = 1;
	_boundRect.size.height = 1;
	
//	NSLog(@"Add UIObject : %@", [self description]);
	
	return self;
}

- (void)dealloc
{
	[_childArray release];
	
//	NSLog(@"UiObject Dealloc : %@", [self description]);

	[super dealloc];
}

- (void)tick
{
	if(!_show) return;
	
	if(_visual && !_remove)
	{
		_isInScreen = [self isInCam];
		if(_isInScreen) [QOBMGR addVisual:self Layer:_zLayer];
	}

	QobBase *obj;
	NSMutableArray *array = _childArray;
	for(int i = 0; i < [array count]; i++)
	{
		obj = [array objectAtIndex:i];
		if(obj != nil)
		{
			if(obj.removeThis) [array removeObjectAtIndex:i--];
			else [obj tick];
		}
	}
}

- (void)draw
{
}

- (void)setFixedPos:(bool)fixed
{
	if(fixed) _fixedPos = TILEMGR.deviceType == DEVICE_IPHONE_RETINA ? .5f : 1.f;
	else _fixedPos = 0.f;
}

- (void)setScale:(float)scale
{
	_scaleX = _scaleY = scale;
}

/*- (CGPoint *)localPos
{
	return &_pos;
}*/

- (void)setPosX:(float)x
{
	_pos.x = x;

	[self calcWorldPos];
}

- (void)setPosY:(float)y
{
	_pos.y = y;

	[self calcWorldPos];
}

- (void)setPosX:(float)x Y:(float)y
{
	_pos.x = x;
	_pos.y = y;

	[self calcWorldPos];
}

- (void)addPos:(const CGPoint *)add
{
	_pos.x += add->x;
	_pos.y += add->y;
	
	[self calcWorldPos];
}

- (void)addPosX:(float)add
{
	_pos.x += add;
	[self calcWorldPos];
}

- (void)addPosY:(float)add
{
	_pos.y += add;
	[self calcWorldPos];
}

- (void)subPos:(const CGPoint *)sub
{
	_pos.x -= sub->x;
	_pos.y -= sub->y;
	
	[self calcWorldPos];
}

- (void)easyOutTo:(const CGPoint *)dest Div:(float)div Min:(float)min
{
	BOOL chg = NO;
	if(_pos.x != dest->x)
	{
		if(fabs(_pos.x - dest->x) > min) _pos.x += (dest->x - _pos.x) / div;
		else _pos.x = dest->x;
		chg = YES;
	}
	if(_pos.y != dest->y)
	{
		if(fabs(_pos.y - dest->y) > min) _pos.y += (dest->y - _pos.y) / div;
		else _pos.y = dest->y;
		chg = YES;
	}
	
	if(chg) [self calcWorldPos];
}

- (void)calcWorldPos
{
	_worldPos.x = _pos.x;
	_worldPos.y = _pos.y;
	if(_parent)
	{
		_worldPos.x += [_parent worldPosX];
		_worldPos.y += [_parent worldPosY];
	}

	for(QobBase *obj in _childArray)
	{
		if(obj != nil) [obj calcWorldPos];
	}
}

- (float)worldPosX
{
	return _worldPos.x;
}

- (float)worldPosY
{
	return _worldPos.y;
}

- (float)screenPosX
{
	float ret = _worldPos.x;
	
	if(_cam) ret = ret - _cam.pos.x + _cam.halfScr.width - _cam.offsetX;
	if(_fixedPos == 0.5f) ret = (int)roundf(ret * 2) * .5f;
	else if(_fixedPos == 1.f) ret = (int)roundf(ret);

	return ret;
}

- (float)screenPosY
{
	float ret = _worldPos.y;
	
	if(_cam) ret = ret - _cam.pos.y + _cam.halfScr.height - _cam.offsetY;
	if(_fixedPos == 0.5f) ret = (int)roundf(ret * 2) * .5f;
	else if(_fixedPos == 1.f) ret = (int)roundf(ret);
	
	return ret;
}

- (void)setShow:(bool)show
{
	_show = show;
}

- (bool)isShow
{
	if(_show && _parent != nil) return [_parent isShow];
	
	return _show;
}

- (void)setCam:(QobCamera *)cam
{
	for(QobBase *obj in _childArray)
	{
		if(obj != nil) [obj setCam:cam];
	}

	_cam = cam;
}

- (bool)isInCam
{
	if(!_show) return false;
	if(_cam == nil) return true;
	
	float x = [self screenPosX];
	if(x + _boundRect.size.width < -60.f) return false;
	if(x + _boundRect.origin.x > _cam.halfScr.width * 2.f + 60.f) return false;
		
	float y = [self screenPosY];
	if(y + _boundRect.size.height < -60.f) return false;
	if(y + _boundRect.origin.y > _cam.halfScr.height * 2.f + 60.f) return false;
	
	return true;
}

- (bool)isInPtX:(float)x Y:(float)y
{
	if(x < [self worldPosX] + _boundRect.origin.x) return false;
	if(x > [self worldPosX] + _boundRect.size.width) return false;
	if(y < [self worldPosY] + _boundRect.origin.y) return false;
	if(y > [self worldPosY] + _boundRect.size.height) return false;
	
	return true;
}

- (bool)isCollideBound:(QobBase *)obj
{
	if(_pos.x + _boundRect.origin.x > obj.pos.x + obj.boundRect.size.width) return false;
	if(_pos.x + _boundRect.size.width < obj.pos.x + obj.boundRect.origin.x) return false;
	if(_pos.y + _boundRect.origin.y > obj.pos.y + obj.boundRect.size.height) return false;
	if(_pos.y + _boundRect.size.height < obj.pos.y + obj.boundRect.origin.y) return false;
	
	return true;
}

- (void)addChild:(QobBase *)child
{
	[_childArray addObject:child];
	if(_cam != nil) [child setCam:_cam];
	if(/*_visual && */child.layer == -1) [child setLayer:_zLayer];
	[child setParent: self];
	[child setPosX:child.pos.x Y:child.pos.y];
	[child release];
}

- (int)childCount
{
	return [_childArray count];
}

- (QobBase *)childAtIndex:(int)idx
{
	return [_childArray objectAtIndex:idx];
}

- (void)remove
{
	_remove = true;
	if(_uiObject) [self setUiReceiver:false];

	for(QobBase *obj in _childArray)
	{
		if(obj != nil) [obj remove];
	}
}

- (void)removeAllChild
{
    for(QobBase *obj in _childArray)
	{
		if(obj != nil) [obj remove];
	}
}

- (void)setActive:(BOOL)active
{
	_active = active;

	for(QobBase *obj in _childArray)
	{
		if(obj != nil) [obj setActive:active];
	}
}

- (void)setLayer:(int)layer
{
	_zLayer = layer;

	for(QobBase *obj in _childArray)
	{
		if(obj != nil && obj.layer == -1) [obj setLayer:layer];
	}
}

- (void)setZOrder:(int)z
{
	_zOrder = z;
}

- (void)setParent:(QobBase *)parent
{
	_parent = parent;
}

- (QobBase *)getParent
{
    return _parent;
}

- (void)setUiReceiver:(bool)uiReceiver
{
	if(uiReceiver) [QOBMGR addUiReceiver:self];
	else [QOBMGR removeUiReceiver:self];
	
	_uiObject = uiReceiver;
}

- (BOOL)onTap:(CGPoint)pt State:(int)state ID:(id)tapID
{
	if(!_show) return false;
	
	return false;
}


@end
