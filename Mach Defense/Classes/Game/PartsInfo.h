//
//  PartsInfo.h
//  HeavyMach
//
//  Created by 엔비 on 08. 12. 05.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

@interface PartsInfo : NSObject
{
	bool _useCommonTile;
	NSString *_partsName;
	NSString *_tileName;
	int _tileNo;
	unsigned char _partsType;
	unsigned char _tileCnt;
	unsigned char _socketCnt;
	CGPoint *_socketList;
}

@property(readwrite) bool useCommonTile;
@property(readwrite) int tileNo;
@property(readwrite) unsigned char partsType, tileCnt, socketCnt;
@property(readonly) NSString *name;

- (void)setPartsName:(char *)name;
- (void)setTileName:(NSString *)name;
- (NSString *)getTileName;
- (void)setSocketCnt:(unsigned char)n;
- (void)setSocket:(unsigned char)n X:(float)x Y:(float)y;
- (CGPoint *)getSocket:(unsigned char)n;

@end
