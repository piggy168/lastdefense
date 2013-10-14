//
//  GobBullet.h
//  HeavyMach
//
//  Created by 엔비 on 08. 10. 28.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "QobImage.h"
#import "GobWorld.h"

@class WeaponInfo;
@class GobTrailEffect;

@interface GobBullet : QobImage
{
	bool _toPlayer;
	GobHvMach *_owner;
	WeaponInfo *_info;
	QobImage *_imgBullet, *_imgEffect;
	
	CGPoint _dest;
	CGPoint _spd;
	CGPoint _vel, _velTick;
	CGPoint _fireVel;

	bool _lockOn;
	float _shotLen, _prevLen;
	float _g, _speed;
	float _startTime;
	float _effectRegenTime;
	float _effectDelay;
//	bool _flameShow;
	bool _drop;
	
	GobTrailEffect *_smokeTrail;
//	GobHvMach *_lockonMach;
}

@property(readwrite) bool drop, lockOn;

- (void)setOwner:(GobHvMach *)owner;
- (void)setToPlayer:(bool)toPlayer;
- (void)setFireVel:(CGPoint)vel;
- (void)setFire:(WeaponInfo *)info Angle:(float)angle X:(float)x Y:(float)y DestX:(float)destX DestY:(float)destY;
- (void)setCollide:(bool)enemy;
//- (void)setLockon:(GobHvMach *)mach;


@end
