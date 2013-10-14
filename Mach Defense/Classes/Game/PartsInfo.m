//
//  PartsInfo.m
//  HeavyMach
//
//  Created by 엔비 on 08. 12. 05.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "PartsInfo.h"


@implementation PartsInfo

@synthesize useCommonTile=_useCommonTile, name=_partsName, tileNo=_tileNo, partsType=_partsType, tileCnt=_tileCnt, socketCnt=_socketCnt;

- (void)dealloc
{
	[_tileName release];
	[super dealloc];
}

- (void)setPartsName:(char *)name
{
	_partsName = [[NSString alloc] initWithUTF8String:name];

	char szTileName[256];
	strcpy(szTileName, name);
	strcat(szTileName, ".png");
	_tileName = [[NSString alloc] initWithUTF8String:szTileName];
}

- (void)setTileName:(NSString *)name
{
	if(_tileName) [_tileName release];
	_tileName = [[NSString alloc] initWithFormat:@"%@.png", name];
}

- (NSString *)getTileName
{
	return _tileName;
}

- (void)setSocketCnt:(unsigned char)n
{
	if(_socketCnt != 0) return;
	
	_socketCnt = n;
	_socketList = malloc(sizeof(CGPoint) * _socketCnt);
}

- (void)setSocket:(unsigned char)n X:(float)x Y:(float)y
{
	if(n >= _socketCnt) return;

	if(_glView.deviceType == DEVICE_IPAD)
	{
		_socketList[n].x = (int)x;
		_socketList[n].y = (int)y;
	}
	else
	{
		_socketList[n].x = ((int)x * .5f);
		_socketList[n].y = ((int)y * .5f);
	}
}

- (CGPoint *)getSocket:(unsigned char)n
{
	if(n >= _socketCnt) return NULL;
	return &_socketList[n];
}

@end
