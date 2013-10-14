/* cocos2d-iphone
 *
 * Copyright (C) 2008 Ricardo Quesada
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; version 3 or (it is your choice) any later
 * version. 
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307, USA.
 *
 */

#import "Tile2D.h"
#import "ImageAttacher.h"
#import "ResMgr_Tile.h"

@implementation ResMgr_Tile
@synthesize deviceType=_deviceType;

static ResMgr_Tile *_sharedMgr = nil;

+ (ResMgr_Tile *)sharedMgr
{
	@synchronized(self)
	{
		if(!_sharedMgr) _sharedMgr = [[ResMgr_Tile alloc] init];
		return _sharedMgr;
	}

	return nil;
}

/*+ (id)alloc
{
	@synchronized(self)
	{
		_sharedMgr = [super alloc];
		return _sharedMgr;
	}

	return nil;
}*/

- (id)init
{
	if(![super init]) return nil;
	
	_dictTile = [[NSMutableDictionary dictionaryWithCapacity: 10] retain];
	
	_deviceType = DEVICE_IPHONE;

#if __IPHONE_3_2 <= __IPHONE_OS_VERSION_MAX_ALLOWED
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) _deviceType = DEVICE_IPAD;
#endif
	
	if(_deviceType == DEVICE_IPHONE && [[UIScreen mainScreen] scale] == 2.0) _deviceType = DEVICE_IPHONE_RETINA;
	
	return self;
}

- (void)dealloc
{
	[_dictTile release];
	[super dealloc];
}

- (Tile2D *)makeTileWithImageAttacher:(ImageAttacher *)attacher
{
	Tile2D *tile = [[Tile2D alloc] initWithData:attacher.data pixelFormat:attacher.pixelFormat pixelsWide:attacher.width pixelsHigh:attacher.height contentSize:attacher.imageSize];
	if(tile != nil)
	{
		[tile setFileName:attacher.fileName];
		[_dictTile removeObjectForKey:attacher.fileName];
		[_dictTile setObject:tile forKey:attacher.fileName];
		[tile autorelease];
		
		[attacher release];
	}
	
	return tile;
}

- (Tile2D *)makeAttachTile:(NSString *)tileName FileName:(NSString *)fileName FileCount:(int)fileCnt TileW:(int)tileW TileH:(int)tileH ImgW:(int)imgW ImgH:(int)imgH
{
	int tileCntX = tileW / imgW;
	int tileCntY = tileH / imgH;
	ImageAttacher *attacher = [[ImageAttacher alloc] initWithWidth:tileW Height:tileH Name:tileName];
	for(int i = 0; i < fileCnt; i++)
	{
		NSString *strFileName = [NSString stringWithFormat:@"%@_%04d.png",fileName, i + 1];
		[attacher attachImage:[self getImage:strFileName] ToX:(i%(int)tileCntX)*(int)imgW+(int)(imgW/2) Y:tileH - (i/(int)tileCntX+1)*(int)imgH+(int)(imgH/2)];
	}		
	Tile2D *tile = [self makeTileWithImageAttacher:attacher];
	[tile tileSplitX:tileCntX splitY:tileCntY];
	
	return tile;
}

- (Tile2D *)getUniTile:(NSString*)uniName
{
	BOOL isRetina = NO;
	NSString *fileName = nil, *path = nil;
	
	if(_deviceType == DEVICE_IPAD)
	{
		fileName = [NSString stringWithFormat:@"iPad_%@", uniName];
		path = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
	}
	else
	{
		if(_deviceType == DEVICE_IPHONE_RETINA)
		{
			NSString *name = [uniName stringByDeletingPathExtension];
			NSString *ext = [uniName pathExtension];
			fileName = [NSString stringWithFormat:@"iPon_%@@2x.%@", name, ext];
			path = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
			isRetina = YES;
		}
		
		if(path == nil)
		{
			fileName = [NSString stringWithFormat:@"iPon_%@", uniName];
			path = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
			isRetina = NO;
		}
	}
		
	Tile2D * tile;
	if((tile = [_dictTile objectForKey:fileName])) return tile;
	
/*	NSMutableArray *imagePathComponents = [NSMutableArray arrayWithArray:[fileName pathComponents]];
	NSString *imageFilename = [imagePathComponents lastObject];
	[imagePathComponents removeLastObject];
	NSString *imageDirectory = [NSString pathWithComponents:imagePathComponents];
	path = [[NSBundle mainBundle] pathForResource:imageFilename ofType:nil inDirectory:imageDirectory];*/
	
	if(path != nil)
	{
		tile = [[Tile2D alloc] initWithImage:[UIImage imageWithContentsOfFile:path]];
		if(tile != nil)
		{
			[tile setFileName:fileName];
			[tile setForRetina:isRetina];
			[_dictTile setObject:tile forKey:fileName];
			[tile autorelease];
		}
	}
	
	return tile;
}

- (Tile2D *)getTile:(NSString*)fileName
{
	BOOL isRetina = NO;
	Tile2D *tile;
	if((tile = [_dictTile objectForKey:fileName])) return tile;
	
	NSMutableArray *imagePathComponents = [NSMutableArray arrayWithArray:[fileName pathComponents]];
	NSString *imageFilename = [imagePathComponents lastObject];
	[imagePathComponents removeLastObject];
	NSString *imageDirectory = [NSString pathWithComponents:imagePathComponents];
	NSString *path = nil;
	
	if(_deviceType == DEVICE_IPHONE_RETINA)
	{
		NSString *name = [imageFilename stringByDeletingPathExtension];
		NSString *ext = [imageFilename pathExtension];
		NSString *retinaFilename = [NSString stringWithFormat:@"%@@2x.%@", name, ext];
		path = [[NSBundle mainBundle] pathForResource:retinaFilename ofType:nil inDirectory:imageDirectory];
		isRetina = YES;
	}
	
	if(path == nil)
	{
		path = [[NSBundle mainBundle] pathForResource:imageFilename ofType:nil inDirectory:imageDirectory];
		isRetina = NO;
	}
	
	if(path != nil)
	{
		tile = [[Tile2D alloc] initWithImage:[UIImage imageWithContentsOfFile:path]];
		if(tile != nil)
		{
			[tile setFileName:fileName];
			[tile setForRetina:isRetina];
			[_dictTile setObject:tile forKey:fileName];
			[tile autorelease];
		}
	}
	
	return tile;
}

- (Tile2D *)getTileForRetina:(NSString*)fileName
{
	Tile2D *tile = [self getTile:fileName];
	if(_deviceType != DEVICE_IPAD) [tile setForRetina:YES];
	
	return tile;
}

- (Tile2D *)getTileWithURL:(NSString*)url
{
	Tile2D * tile;
	if((tile = [_dictTile objectForKey:url])) return tile;

	NSURL *imgURL = [NSURL URLWithString:url];
	UIImage *img = [UIImage imageWithData:[NSData dataWithContentsOfURL:imgURL]];
	tile = [[Tile2D alloc] initWithImage:img];
	if(tile != nil)
	{
		[_dictTile setObject:tile forKey:url];
		[tile autorelease];
	}
	
	return tile;
}

- (Tile2D *)getAlphaTile:(NSString*)fileName
{
	Tile2D * tile;
	
	NSString *keyName = [fileName stringByAppendingString:@"~shd"];
	if((tile = [_dictTile objectForKey:keyName])) return tile;
	
	NSMutableArray *imagePathComponents = [NSMutableArray arrayWithArray:[fileName pathComponents]];
	NSString *imageFilename = [imagePathComponents lastObject];
	[imagePathComponents removeLastObject];
	NSString *imageDirectory = [NSString pathWithComponents:imagePathComponents];
	
	tile = [[Tile2D alloc] initAlphaWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:imageFilename ofType:nil inDirectory:imageDirectory]]];
	if(tile != nil)
	{
		[_dictTile setObject:tile forKey:keyName];
		[tile autorelease];
	}
	
	return tile;
}

- (UIImage *)getImage:(NSString*)fileName
{
	NSMutableArray *imagePathComponents = [NSMutableArray arrayWithArray:[fileName pathComponents]];
	NSString *imageFilename = [imagePathComponents lastObject];
	[imagePathComponents removeLastObject];
	NSString *imageDirectory = [NSString pathWithComponents:imagePathComponents];
	
	return [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:imageFilename ofType:nil inDirectory:imageDirectory]];
}

- (void)removeAllTiles
{
	[_dictTile removeAllObjects];
}

- (void)removeTile:(NSString *)tileName
{
//	NSAssert(tile != nil, @"ResMgr_Tile: tile MUST not be nill");
	[_dictTile removeObjectForKey:tileName];
}

@end
