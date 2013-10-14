//
//  QChunk.m
//  MachBuilder
//
//  Created by 엔비 on 09. 08. 12.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "QChunk.h"


@implementation QChunk

@synthesize size=_size, type=_type, dataSize=_dataSize, data=_data, subCount=_subCount;

- (id)init
{
	[super init];
	
	_size = 0;
	_type = 0;
	
	_dataSize = 0;
	_data = NULL;
	
	_subCount = 0;
	
	_listSubChunk = [[NSMutableArray alloc] init];
	
	return self;
}

- (void)dealloc
{
	free(_data);
	[_listSubChunk removeAllObjects];
	[_listSubChunk release];
	
	[super dealloc];
}

- (QChunk *)getSubChunk:(int)n
{
	if(n < 0 || n >= _subCount) return nil;
	return [_listSubChunk objectAtIndex:n];
}

- (QChunk *)addChunk:(QChunk *)chunk
{
	[_listSubChunk addObject:chunk];
	
	_size = [self getChunkSize];
	_subCount = [_listSubChunk count];
	
	return chunk;
}

- (int)getChunkSize
{
	_size = 16 + _dataSize;
	
	for(int i = 0; i < _listSubChunk.count; i++)
	{
		_size += [[self getSubChunk:i] getChunkSize];
	}
	
	return _size;
}

- (void)setData:(void *)data Size:(int)size
{
	free(_data);
	_data = malloc(size);
	memcpy(_data, data, size);
	_dataSize = size;
	
	_size = [self getChunkSize];
}

- (bool)saveChunkWithName:(const char *)fileName
{
	FILE *fp = fopen(fileName, "wb");
	if(!fp) return false;
	
	[self saveChunkWithFp:fp];
	
	fclose(fp);
	return true;
}

- (bool)saveChunkWithFp:(FILE *)fp
{
	if(!fp) return false;
	
	fwrite(&_size, sizeof(int), 1, fp);
	fwrite(&_type, sizeof(int), 1, fp);
	fwrite(&_dataSize, sizeof(int), 1, fp);
	if(_dataSize > 0) fwrite(_data, 1, _dataSize, fp);
	
	_subCount = _listSubChunk.count;
	fwrite(&_subCount, sizeof(int), 1, fp);
	for(int i = 0; i < _subCount; i++)
	{
		[[self getSubChunk:i] saveChunkWithFp:fp];
	}
	
	return true;
}

- (bool)loadChunkWithName:(const char *)fileName
{
	FILE *fp = fopen(fileName, "rb");
	if(!fp) return false;
	
	[self loadChunkWithFp:fp];
	
	fclose(fp);
	return true;
}

- (bool)loadChunkWithFp:(FILE *)fp
{
	if(!fp) return false;
	
	fread(&_size, sizeof(int), 1, fp);
	fread(&_type, sizeof(int), 1, fp);
	fread(&_dataSize, sizeof(int), 1, fp);
	if(_dataSize > 0)
	{
		_data = malloc(_dataSize);
		fread(_data, 1, _dataSize, fp);
	}
	
	int subCnt;
	fread(&subCnt, sizeof(int), 1, fp);
	for(int i = 0; i < subCnt; i++)
	{
		QChunk *chunk = [[QChunk alloc] init];
		[chunk loadChunkWithFp:fp];
		
		[self addChunk:chunk];
	}
	return true;
}

@end
