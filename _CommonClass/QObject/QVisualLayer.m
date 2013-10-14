//
//  QVisualLayer.m
//  HeavyMach
//
//  Created by 엔비 on 08. 12. 11.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "QVisualLayer.h"


@implementation QVisualLayer

@synthesize zSort=_zOrderSort, visualCnt=_visualCnt;

- (id)initWithUnitSize:(int)size
{
	[super init];
	
	_zOrderSort = false;
	_unitSize = size;
	_poolSize = size;
	_visualCnt = 0;
	
	_visualPool = (QobBase **)malloc(sizeof(QobBase *) * _poolSize);
	_listAtlas = [[NSMutableArray alloc] init];
//	_atlas = [[TextureAtlas alloc] initWithTexture:[TILEMGR getTile:@"npc99_idle_0001.png"] capacity:128];
	
	return self;
}

-(void)dealloc
{
	free(_visualPool);
	[_listAtlas release];
	
	[super dealloc];
}

- (void)insertObject:(QobBase *)object
{
	int vCnt = _visualCnt;

	if(!_zOrderSort || vCnt == 0)
	{
		if(!object.useAtlas)
		{
			[self addObject:object];
		}
	}
	else
	{
		int poolSize = _poolSize;
		int size = (vCnt + 1) / 2;
		int idx = vCnt / 2;
		BOOL findPos = false;
		QobBase **pool = _visualPool;

		while(!findPos)
		{
			if(size > 1) size /= 2;
			
			if(object.z >= pool[poolSize - idx - 1].z)
			{
				idx += size;
			}
			else if(idx > 0 && object.z < pool[poolSize - idx - 1].z)
			{
				if(object.z >= pool[poolSize - idx].z) findPos = true;
				else idx -= size;
			}
			
			if(idx == 0 || idx == vCnt) findPos = true;
		}
		
		if(idx == vCnt)
		{
			[self addObject:object];
		}
		else
		{
			if(vCnt == poolSize) [self extendPool];
			
			memcpy(&pool[poolSize - vCnt - 1], &pool[poolSize - vCnt], sizeof(QobBase *) * (vCnt - idx));
			pool[poolSize - idx - 1] = object;
			++_visualCnt;
		}
	}
}

- (void)addObject:(QobBase *)object
{
	if(_visualCnt == _poolSize) [self extendPool];
	
	_visualPool[_poolSize - ++_visualCnt] = object;
}

- (void)removeAllAtlas
{
	[_listAtlas removeAllObjects];
}

- (TextureAtlas *)findAtlas:(QobImage *)me
{
	TextureAtlas *atlas;
	for(int i = 0; i < _listAtlas.count; i++)
	{
		atlas = [_listAtlas objectAtIndex:i];
		if(atlas && atlas.texture == me.tile && atlas.blendType == me.blendType) return atlas;
	}
	
	return nil;
}

- (TextureAtlas *)makeCleanAtlas:(Tile2D *)tile
{
	TextureAtlas *atlas;
	for(int i = 0; i < _listAtlas.count; i++)
	{
		atlas = [_listAtlas objectAtIndex:i];
		if(atlas && atlas.texture == tile && atlas.blendType == BT_NORMAL) return atlas;
	}
	
	atlas = [[TextureAtlas alloc] initWithTexture:tile capacity:32];
	[atlas setBlendType:BT_NORMAL];
	[_listAtlas addObject:atlas];
	[atlas autorelease];

	return atlas;
}

- (TQuadInfo *)getMyAtlasQuad:(QobImage *)me
{
	Tile2D *tile = me.tile;
	TextureAtlas *atlas = [self findAtlas:me];

	if(atlas == nil)
	{
		atlas = [[TextureAtlas alloc] initWithTexture:tile capacity:32];
		[atlas setBlendType:me.blendType];
		[_listAtlas addObject:atlas];
		[atlas release];
	}

	if(atlas.totalQuads >= atlas.capacity)
	{
		[atlas resizeCapacity:atlas.capacity * 2];
	}
	
	return &atlas.quads[atlas.totalQuads++];
}

- (QobBase *)getObject:(int)n
{
	if(n < 0 || n >= _visualCnt) return nil;
	return _visualPool[_poolSize - n - 1];
}

- (void)extendPool
{
	QobBase **ptr = _visualPool;
	_visualPool = (QobBase **)malloc(sizeof(QobBase *) * (_poolSize + _unitSize));
	memcpy(&_visualPool[_unitSize], ptr, sizeof(QobBase *) * _visualCnt);
	_poolSize += _unitSize;
	free(ptr);
}

- (void)clearAllVisual
{
	_visualCnt = 0;
}

- (void)drawVisual
{
	int vCnt = _visualCnt;
	int poolSize = _poolSize;
	QobBase **pool = _visualPool;

//	ENABLE_DEFAULT_GL_STATES();
//	glEnable(GL_BLEND);

	if(vCnt > 0)
	{
		do
		{
			[pool[--poolSize] draw];
		} while(--vCnt);
	}
	
	for(int i = 0; i < _listAtlas.count; i++)
	{
		TextureAtlas *atlas = [_listAtlas objectAtIndex:i];
		if(atlas)
		{
			[atlas drawQuads];
			[atlas removeAllQuads];
		}
	}

//	glDisable(GL_BLEND);
//	DISABLE_DEFAULT_GL_STATES();
	
	[self clearAllVisual];
}

@end
