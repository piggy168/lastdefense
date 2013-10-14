//
//  PartsController_Weapon.h
//  HeavyMach2
//
//  Created by 엔비 on 09. 07. 31.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PartsController.h"

@interface PartsController_Weapon : PartsController
{
	WeaponInfo *_wpnInfo;

	BOOL _isFire;
	float _fireTime;
	int _fireLeft;
	float _fireBound;
	
	BOOL _isUiWpnL, _isUiWpnR;
}

@property (readwrite)BOOL isUiWpnL, isUiWpnR;

- (void)setReload;
- (void)setWeaponInfo:(WeaponInfo *)wpnInfo;
- (void)setFire:(BOOL)isFire;

@end
