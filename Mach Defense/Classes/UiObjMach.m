//
//  UiObjMach.m
//  MachDefense
//
//  Created by HaeJun Byun on 10. 12. 2..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "UiObjMach.h"
#import "ImageAttacher.h"

@implementation UiObjMach
@synthesize tile=_bakedTile;

- (id)init
{
	[super init];
	
	_listParts = [[NSMutableArray alloc] init];
	
	return self;
}

- (void)dealloc
{
	[_listParts release];
	[_machName release];
	
	[super dealloc];
}

- (void)setName:(NSString *)name
{
	if(_machName != nil) [_machName release];
	_machName = [[NSString alloc] initWithString:name];
}

- (UiObjMachParts *)addParts:(PartsInfo *)partsInfo
{
	UiObjMachParts *parts = nil;
	
	parts = [[UiObjMachParts alloc] init];
	[parts setPartsInfo:partsInfo];
	[_listParts addObject:parts];
	
	return parts;
}

- (UiObjMachParts *)addParts:(PartsInfo *)partsInfo BaseParts:(UiObjMachParts *)parts BaseSocket:(unsigned char)socket
{
	UiObjMachParts *newParts = [self addParts:partsInfo];
	
	if(parts != nil)
	{
		[parts setChildParts:newParts Socket:socket];
	}
	
	return newParts;
}

- (int)decodeChunk:(UiObjMachParts *)baseParts Data:(char *)data Pos:(int)pos
{
	UiObjMachParts *newParts = nil;
	char *pData = NULL;
	/*int size = *(int *)(data + pos);*/		pos += sizeof(int);
	int type = *(int *)(data + pos);			pos += sizeof(int);
	int dataSize = *(int *)(data + pos);		pos += sizeof(int);
	if(dataSize > 0)
	{
		int dataPos = 0;
		pData = data + pos;
		
		if(type == MCNK_MACH)
		{
			dataPos += 24;
			/*_hp = *(int *)(pData + dataPos);*/								dataPos += sizeof(int);
			/*_exp = *(int *)(pData + dataPos);*/								dataPos += sizeof(int);
			/*_machType = *(unsigned char *)(pData + dataPos);*/				dataPos += sizeof(unsigned char);
		}
		else if(type == MCNK_MACHPARTS)
		{
			char szPartsName[24];
			strcpy(szPartsName, pData);											dataPos += 24;
			unsigned char baseSocket = *(unsigned char *)(pData + dataPos);		dataPos += 1;
			/*unsigned char z = *(unsigned char *)(pData + dataPos);*/			dataPos += 1;
			PartsInfo *partsInfo = [GINFO getPartsInfo:[NSString stringWithUTF8String:szPartsName]];
			
			if(partsInfo != nil)
			{
				newParts = [self addParts:partsInfo BaseParts:baseParts BaseSocket:baseSocket];
			}
		}
		
		pos += dataSize;
	}
	
	int subCnt = *(int *)(data + pos);		pos += sizeof(int);
	for(int i = 0; i < subCnt; i++)
	{
		pos = [self decodeChunk:newParts Data:data Pos:pos];
	}
	
	return pos;
}

- (UiObjMachParts *)setParts:(NSString *)partsName partsType:(int)type
{
	PartsInfo *partsInfo = [GINFO getPartsInfo:partsName];
	if(partsInfo == nil) return nil;
	
	UiObjMachParts *parts = nil;
	
	switch(type)
	{
		case PARTS_BASE:
			parts = [self addParts:partsInfo];
			_partsBase = parts;
			break;
		case PARTS_FOOT:
			parts = [self addParts:partsInfo];
			_partsFootL = parts;
			if(_partsBase != nil) [_partsBase setChildParts:_partsFootL Socket:1];
			
			parts = [self addParts:partsInfo];
			_partsFootR = parts;
			if(_partsBase != nil) [_partsBase setChildParts:_partsFootR Socket:2];
			break;
		case PARTS_BODY:
			parts = [self addParts:partsInfo];
			_partsBody = parts;
			if(_partsBase != nil) [_partsBase setChildParts:_partsBody Socket:3];
			break;
		case PARTS_WPN:
			parts = [self addParts:partsInfo];
			_partsWpnL = parts;
			if(_partsBody != nil) [_partsBody setChildParts:_partsWpnL Socket:1];
			
			parts = [self addParts:partsInfo];
			[parts setReverse:true];
			_partsWpnR = parts;
			if(_partsBody != nil) [_partsBody setChildParts:_partsWpnR Socket:2];
			break;
	}
	
	return parts;
}

- (bool)makeMachFromName:(const char *)machName
{
	MachInfo *info = [GINFO getMachInfo:[NSString stringWithUTF8String:machName]];
	if(info == nil || info.data == nil) return false;
	int len = [info.data length];
	if(len <= 0) return false;
	
	
	char *buffer =  malloc(len);
	[info.data getBytes:buffer length:len];
	
	[self decodeChunk:nil Data:buffer Pos:0];
//	if(_machName != nil) [_machName release];
//	_machName = [[NSString alloc] initWithUTF8String:machName];
	
	free(buffer);
	
	return true;
}

- (void)attachTo:(ImageAttacher *)attacher X:(int)x Y:(int)y
{
	for(UiObjMachParts *parts in _listParts)
	{
		[parts attachTo:attacher X:x Y:y];
	}
}

- (void)bakeTile
{
	ImageAttacher *attacher = [[ImageAttacher alloc] initWithWidth:128 Height:128 Name:_machName];
	[self attachTo:attacher X:64 Y:64];
	_bakedTile = [TILEMGR makeTileWithImageAttacher:attacher];
	if(TILEMGR.deviceType != DEVICE_IPAD) [_bakedTile setForRetina:YES];
	[_bakedTile tileSplitX:1 splitY:1];
}

@end
