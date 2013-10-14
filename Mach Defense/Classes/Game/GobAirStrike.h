//
//  GobSpAttack.h
//  HeavyMach2
//
//  Created by 엔비 on 09. 09. 29.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

@interface GobAirStrike : QobImage
{
	ItemInfo *_item;
	WeaponInfo *_weapon;
	int _type;
	float _startTime;
	CGPoint _vec;
	CGPoint _attackPos;
	GobHvMach *_attackMach;
	int _attackCount;
	float _fireTime, _fireDelay;
}

- (id)initWithItem:(ItemInfo *)item;

- (void)setAttackPosX:(float)x Y:(float)y;

@end
