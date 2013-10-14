//
//  QChunk.h
//  MachBuilder
//
//  Created by 엔비 on 09. 08. 12.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface QChunk : NSObject
{
	int _size;
	int _type;
	int _dataSize;
	void *_data;
	
	int _subCount;
	NSMutableArray *_listSubChunk;
}

@property(readwrite) int size;
@property(readwrite) int type;
@property(readwrite) int dataSize;
@property(readonly) void *data;
@property(readwrite) int subCount;

- (QChunk *)getSubChunk:(int)n;

- (QChunk *)addChunk:(QChunk *)chunk;
- (int)getChunkSize;

- (void)setData:(void *)data Size:(int)size;

- (bool)saveChunkWithName:(const char *)fileName;
- (bool)saveChunkWithFp:(FILE *)fp;

- (bool)loadChunkWithName:(const char *)fileName;
- (bool)loadChunkWithFp:(FILE *)fp;

@end
