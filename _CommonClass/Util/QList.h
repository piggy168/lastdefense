//
//  QListMgr.h
//  HeavyMach
//
//  Created by 엔비 on 09. 01. 04.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface QList : NSObject
{
	void **_dataPool;
	int _unitSize;
	int _poolSize;
	int _dataCnt;
}

@property(readonly) int size;

- (id)initWithUnitSize:(int)size;

- (void)addData:(void *)data;
- (bool)setData:(void *)data ToIndex:(int)idx;
- (void *)getData:(int)n;
- (void)extendPool;

@end
