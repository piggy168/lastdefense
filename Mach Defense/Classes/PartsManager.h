//
//  PartsManager.h
//  HM2HD
//
//  Created by 엔비 on 10. 7. 19..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

@interface PartsTile : NSObject
{
	Tile2D *tile, *shadowTile;
	int tileNo;
}

@property (nonatomic, retain) Tile2D *tile, *shadowTile;
@property (readwrite)int tileNo;

@end


@interface PartsManager : NSObject
{
	NSMutableDictionary *_dictPartsImage;
	NSMutableArray *_listAttachedTile;
	NSMutableDictionary *_dictPartsTile;
	NSMutableArray *_listUnitImages[10];
	
	NSMutableArray *_listBodyParts, *_listOtherParts;
}

- (void)addMach:(const char *)machName;
- (void)clear;

- (void)bakePartsTiles;
- (void)loadPartsTiles;

- (PartsTile *)getPartsTile:(NSString *)fileName;

@end
