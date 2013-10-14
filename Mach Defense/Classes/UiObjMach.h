//
//  UiObjMach.h
//  MachDefense
//
//  Created by HaeJun Byun on 10. 12. 2..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "UiObjMachParts.h"

@interface UiObjMach : NSObject
{
	NSString *_machName;
	Tile2D *_bakedTile;
	NSMutableArray *_listParts;

	UiObjMachParts *_partsBase;
	UiObjMachParts *_partsFootL;
	UiObjMachParts *_partsFootR;
	UiObjMachParts *_partsBody;
	UiObjMachParts *_partsWpnL;
	UiObjMachParts *_partsWpnR;
}

@property(readonly) Tile2D *tile;

- (void)setName:(NSString *)name;
- (bool)makeMachFromName:(const char *)machName;
- (UiObjMachParts *)setParts:(NSString *)partsName partsType:(int)type;

- (void)attachTo:(ImageAttacher *)attacher X:(int)x Y:(int)y;
- (void)bakeTile;

@end
