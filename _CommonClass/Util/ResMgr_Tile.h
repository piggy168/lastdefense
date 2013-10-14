#import "Tile2D.h"

#define TILEMGR		[ResMgr_Tile sharedMgr]

enum EDeviceType
{
	DEVICE_UNKNOWN, DEVICE_IPAD, DEVICE_IPHONE, DEVICE_IPHONE_RETINA
};

@class ImageAttacher;

@interface ResMgr_Tile : NSObject
{
	NSMutableDictionary *_dictTile;
	int _deviceType;
}

@property(readonly) int deviceType;

+ (ResMgr_Tile *)sharedMgr;

- (Tile2D *)makeTileWithImageAttacher:(ImageAttacher *)attacher;
- (Tile2D *)makeAttachTile:(NSString *)tileName FileName:(NSString *)fileName FileCount:(int)fileCnt TileW:(int)tileW TileH:(int)tileH ImgW:(int)imgW ImgH:(int)imgH;

- (Tile2D *)getUniTile:(NSString*)uniName;
- (Tile2D *)getTile:(NSString*)fileName;
- (Tile2D *)getTileForRetina:(NSString*)fileName;
- (Tile2D *)getTileWithURL:(NSString*)url;
- (Tile2D *)getAlphaTile:(NSString*)fileName;

- (UIImage *)getImage:(NSString*)fileName;

- (void)removeAllTiles;
- (void)removeTile:(NSString *)tileName;

@end
