//
//  TableData.h
//  iRev
//
//  Created by 엔비 on 09. 03. 29.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

@interface QTable : NSObject
{
	NSMutableArray *_dictKey;
	NSMutableDictionary *_dictData;
	
	int _lineCount;
	int _columnCount;
}

@property(readonly) int row, column;

- (id)initWithFile:(NSString *)fileName;

- (BOOL)loadBuffer:(char *)buffer;

- (int)getDataFrom:(const char *)szLine Pos:(int)pos To:(char *)output;

- (NSString *)getKey:(int)column;
- (NSString *)getString:(int)line Key:(NSString *)key;
- (int)getInt:(int)line Key:(NSString *)key;
- (float)getFloat:(int)line Key:(NSString *)key;

@end
