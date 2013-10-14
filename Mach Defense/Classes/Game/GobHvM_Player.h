//
//  GobHvM_Player.h
//  HeavyMach
//
//  Created by 엔비 on 09. 01. 24.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "GobHvMach.h"

@class GobFieldItem;
@class PartsController_Weapon;

@interface GobHvM_Player : GobHvMach
{
	PartsController_Weapon *_wpnControllerL, *_wpnControllerR;
	float _stopDelay;
	char _postBuild[32];
	bool _isTransform, _isOrder;

	QobImage *_imgPickItem;
	QobText *_txtPickItem;
	int _pickupCoin;
	float _pickupTime;
}

@property(readwrite) bool isOrder;

- (GobMachParts *)setParts:(NSString *)partsName partsType:(int)type;
- (void)setSpAttack:(WeaponInfo *)weapon To:(CGPoint)pos;
- (void)setPostBuild:(const char *)postBuild;
- (void)pickupItem:(ItemInfo *)item Count:(int)count;

@end
