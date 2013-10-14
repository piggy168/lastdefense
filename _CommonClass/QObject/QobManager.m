//
//  QobManager.m
//  HeavyMach
//
//  Created by 엔비 on 08. 11. 30.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "QobManager.h"
#import "QVisualLayer.h"


@implementation QobManager
@synthesize drawCount = _drawCount, drawCall=_drawCall;

static QobManager *_sharedMgr = nil;

+ (QobManager *)sharedMgr
{
	@synchronized(self)
	{
		if(!_sharedMgr) _sharedMgr = [[QobManager alloc] init];
		return _sharedMgr;
	}
	
	return nil;
}

- (id)init
{
	[super init];
	
	_uiReceiverArray = [[NSMutableArray alloc] init];
	_addArray = [[NSMutableArray alloc] init];
	_deleteArray = [[NSMutableArray alloc] init];
	
	int cnt = VLAYER_MAX;
	do
	{
		_visualLayer[cnt-1] = [[QVisualLayer alloc] initWithUnitSize:100];
	} while(--cnt);
	
//	_visualLayer[VLAYER_BACK].zSort = true;
//	_visualLayer[VLAYER_MIDDLE].zSort = true;
	
	_cam = nil;
	
//	NSLog(@"QOBMGR init : %@", [self description]);
	return self;
}

- (void)dealloc
{
	for(int i = 0; i < VLAYER_MAX; i++)
	{
		[_visualLayer[i] release];
	}
	
	[_uiReceiverArray release];
	[_addArray release];
	[_deleteArray release];
	
	[TILEMGR release];
	[SOUNDMGR release];
	
	[super dealloc];
}

- (void)removeAllAtlas
{
	for(int i = 0; i < VLAYER_MAX; i++)
	{
		[_visualLayer[i] removeAllAtlas];
	}
}

- (TextureAtlas *)makeCleanAtlas:(Tile2D *)tile ToLayer:(int)layer
{
	return [_visualLayer[layer] makeCleanAtlas:tile];
}

- (TQuadInfo *)getMyAtlasQuad:(QobImage *)me;
{
	return [_visualLayer[me.layer] getMyAtlasQuad:me];
}

- (void)setMainCam:(QobCamera *)cam
{
	_cam = cam;
}

- (void)addVisual:(QobBase *)obj Layer:(int)layer
{
	if(layer < 0) layer = 0;
	if(layer >= VLAYER_MAX) layer = VLAYER_MAX;
	[_visualLayer[layer] insertObject:obj];
}

- (void)drawVisual
{
	_drawCount = 0;
	for(int i = 0; i < VLAYER_MAX; i++)
	{
		[_visualLayer[i] drawVisual];
	}
	
	_drawCall = _drawCount;
}

- (void)addUiReceiver:(QobBase *)obj
{
	// 중복검사 해야하지 않나??
	[_addArray addObject:obj];
//	[_uiReceiverArray addObject:obj];			// 중간에 끼워 넣는 방식으로 바꾸어야 한다.
}

- (void)removeUiReceiver:(QobBase *)obj
{
	[_deleteArray addObject:obj];
//	[_uiReceiverArray removeObject:obj];
}

- (BOOL)onTap:(CGPoint)pt State:(int)state ID:(id)tapID
{
	BOOL on = false;
	
	if(_addArray.count > 0)
	{
		[_uiReceiverArray addObjectsFromArray:_addArray];
		[_addArray removeAllObjects];
	}
	if(_deleteArray.count > 0)
	{
		[_uiReceiverArray removeObjectsInArray:_deleteArray];
		[_deleteArray removeAllObjects];
	}
	
	QobBase *obj;
	NSMutableArray *array = _uiReceiverArray;
	int count = [_uiReceiverArray count];
	
	do
	{
		obj = [array objectAtIndex:count-1];
		if(obj != nil && [obj isShow]) on = [obj onTap:pt State:state ID:tapID];
	} while(!on && --count);
		
	return on;
}

@end
