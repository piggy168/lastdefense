//
//  PartsManager.m
//  HM2HD
//
//  Created by 엔비 on 10. 7. 19..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PartsManager.h"
#import "ImageAttacher.h"

@implementation PartsTile
@synthesize tile, shadowTile, tileNo;
@end;


@implementation PartsManager

- (id)init
{
	[super init];
	
	_dictPartsImage = [[NSMutableDictionary dictionaryWithCapacity: 10] retain];
	_listAttachedTile = [[NSMutableArray alloc] init];
	_dictPartsTile = [[NSMutableDictionary dictionaryWithCapacity: 10] retain];

	for(int i = 0; i < 10; i++)
	{
		_listUnitImages[i] = [[NSMutableArray alloc] init];
	}
	
	_listBodyParts = [[NSMutableArray alloc] init];
	_listOtherParts = [[NSMutableArray alloc] init];
	return self;
}

- (void)dealloc
{
	[_dictPartsImage release];
	[_dictPartsTile release];
	[_listAttachedTile release];
	
	for(int i = 0; i < 10; i++)
	{
		[_listUnitImages[i] release];
	}

	[_listBodyParts release];
	[_listOtherParts release];

	[super dealloc];
}

- (void)addTile:(NSString *)fileName
{
	UIImage *uiImage = [_dictPartsImage objectForKey:fileName];
	if(uiImage != nil) return;
	
	uiImage = [TILEMGR getImage:fileName];
	if(uiImage == nil) return;

	[_dictPartsImage setObject:uiImage forKey:fileName];

	CGImageRef image = [uiImage CGImage];
	int unit = 0, width = 1;
	int unitSize = (CGImageGetWidth(image) > CGImageGetHeight(image)) ? CGImageGetWidth(image) : CGImageGetHeight(image);

	while(width < unitSize)
	{
		width *= 2;
		unit++;
	}
	unitSize = width;
	
	if(unit < 10)
	{
		[_listUnitImages[unit] addObject:fileName];
	}
}

- (int)decodeChunk:(char *)data Pos:(int)pos
{
	char *pData = NULL;
	/*int size = *(int *)(data + pos);*/		pos += sizeof(int);
	int type = *(int *)(data + pos);			pos += sizeof(int);
	int dataSize = *(int *)(data + pos);		pos += sizeof(int);
	if(dataSize > 0)
	{
		int dataPos = 0;
		pData = data + pos;
		
		if(type == MCNK_MACHPARTS)
		{
			char szPartsName[24];
			strcpy(szPartsName, pData);			dataPos += 24;
			PartsInfo *partsInfo = [GINFO getPartsInfo:[NSString stringWithUTF8String:szPartsName]];
			
			if(partsInfo != nil)
			{
//				[self addTile:[partsInfo getTileName]];
				if(partsInfo.partsType == PARTS_BODY) [_listBodyParts addObject:[partsInfo getTileName]];
				else [_listOtherParts addObject:[partsInfo getTileName]];
			}
		}
		
		pos += dataSize;
	}
	
	int subCnt = *(int *)(data + pos);			pos += sizeof(int);
	for(int i = 0; i < subCnt; i++)
	{
		pos = [self decodeChunk:data Pos:pos];
	}
	
	return pos;
}

- (void)addMach:(const char *)machName
{
	MachInfo *info = [GINFO getMachInfo:[NSString stringWithUTF8String:machName]];
	if(info == nil || info.data == nil) return;
	int len = [info.data length];
	if(len <= 0) return;
	
	char *buffer =  malloc(len);
	[info.data getBytes:buffer length:len];
	
	[self decodeChunk:buffer Pos:0];
	
	free(buffer);
}

- (void)clear
{
	[_dictPartsTile removeAllObjects];
	[_listAttachedTile removeAllObjects];
}

- (void)bakePartsTiles
{
	for(int i = 0; i < 10; i++)
	{
		int tileCount = _listUnitImages[i].count;
		
		if(tileCount > 0)
		{
			int unitSize = (int)pow(2, i), validSize;
			int tileCntX, tileCntY;
			int imgWidth = unitSize * tileCount;
			int imgHeight = ((imgWidth-1) / 512 + 1) * unitSize;
			if(imgWidth > 512) imgWidth = 512;
			if(imgHeight > 512)
			{
				imgHeight = 512;
			}

			validSize = 1;
			while(validSize < imgWidth) validSize *= 2;
			imgWidth = validSize;

			validSize = 1;
			while(validSize < imgHeight) validSize *= 2;
			imgHeight = validSize;
			
			tileCntX = imgWidth / unitSize;
			tileCntY = imgHeight / unitSize;

			int x = unitSize/2, y = imgHeight - unitSize/2;
			ImageAttacher *attacher = [[ImageAttacher alloc] initWithWidth:imgWidth Height:imgHeight Name:[NSString stringWithFormat:@"PartsTile%d", unitSize]];
			for(int j = 0; j < tileCount; j++)
			{
				NSString *tileName = [_listUnitImages[i] objectAtIndex:j];
				UIImage *uiImage = [_dictPartsImage objectForKey:tileName];
				if(uiImage) [attacher attachImage:uiImage ToX:x Y:y];
				x += unitSize;
				if(x > imgWidth)
				{
					x = unitSize/2;
					y -= unitSize;
				}
			}
			
			Tile2D *tile = [[Tile2D alloc] initWithData:attacher.data pixelFormat:attacher.pixelFormat pixelsWide:attacher.width pixelsHigh:attacher.height contentSize:attacher.imageSize];
			if(tile != nil)
			{
				[tile setFileName:attacher.fileName];
				[_listAttachedTile addObject:tile];
				[tile autorelease];
			}
			[tile tileSplitX:tileCntX splitY:tileCntY];
			
			[attacher makeAlphaTile];
			Tile2D *shadowTile = [[Tile2D alloc] initWithData:attacher.data pixelFormat:attacher.pixelFormat pixelsWide:attacher.width pixelsHigh:attacher.height contentSize:attacher.imageSize];
			if(shadowTile != nil)
			{
				[shadowTile setColorR:0 G:0 B:0];
				[shadowTile setFileName:attacher.fileName];
				[_listAttachedTile addObject:shadowTile];
				[shadowTile autorelease];
			}
			[shadowTile tileSplitX:tileCntX splitY:tileCntY];
			
			for(int j = 0; j < tileCount; j++)
			{
				NSString *tileName = [_listUnitImages[i] objectAtIndex:j];
				PartsTile *partsTile = [[PartsTile alloc] init];
				partsTile.tile = tile;
				partsTile.shadowTile = shadowTile;
				partsTile.tileNo = j;
				
				[_dictPartsTile setObject:partsTile forKey:tileName];
				[partsTile release];
			}
			
			[attacher release];
			[_listUnitImages[i] removeAllObjects];
		}
	}

	[_dictPartsImage removeAllObjects];
}

- (void)loadPartsTiles
{
	Tile2D *tile;
	
	for(NSString *fileName in _listOtherParts)
	{
		tile = [[GWORLD tileResMgr] getTile:fileName];
		[QOBMGR makeCleanAtlas:tile ToLayer:VLAYER_MIDDLE];
	}

	for(NSString *fileName in _listBodyParts)
	{
		tile = [[GWORLD tileResMgr] getTile:fileName];
		[QOBMGR makeCleanAtlas:tile ToLayer:VLAYER_MIDDLE];
	}
}

- (PartsTile *)getPartsTile:(NSString *)fileName
{
	return [_dictPartsTile objectForKey:fileName];
}

@end
