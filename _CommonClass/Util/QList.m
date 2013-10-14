//
//  QListMgr.m
//  HeavyMach
//
//  Created by 엔비 on 09. 01. 04.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "QList.h"


@implementation QList

@synthesize size = _dataCnt;

- (id)initWithUnitSize:(int)size
{
	[super init];
	
	_unitSize = size;
	_poolSize = size;
	_dataCnt = 0;
	
	if(_dataPool != NULL) free(_dataPool);
	_dataPool = malloc(sizeof(void *) * _poolSize);
	
	return self;
}

-(void)dealloc
{
	free(_dataPool);
	
	[super dealloc];
}

- (void)addData:(void *)data
{
	if(_dataCnt == _poolSize) [self extendPool];
	
	_dataPool[_dataCnt++] = data;
}

- (bool)setData:(void *)data ToIndex:(int)idx
{
	if(idx >= _poolSize) return false;
	
	_dataPool[idx] = data;
	return true;
}

- (void *)getData:(int)n
{
	if(n < 0 || n >= _dataCnt) return NULL;
	return _dataPool[n];
}

- (void)extendPool
{
	void **ptr = _dataPool;
	_dataPool = malloc(sizeof(void *) * (_poolSize + _unitSize));
	memcpy(_dataPool, ptr, sizeof(void *) * _dataCnt);
	_poolSize += _unitSize;
	free(ptr);
}

@end
