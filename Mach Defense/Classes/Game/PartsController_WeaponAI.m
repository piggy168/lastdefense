//
//  PartsController_WeaponAI.m
//  HeavyMach2
//
//  Created by 엔비 on 09. 08. 31.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PartsController_WeaponAI.h"


@implementation PartsController_WeaponAI

- (void)tick
{
	if(_hvMach != nil && _baseParts != nil && !_hvMach.uiModel && _hvMach.hp > 0)
	{
		if(_hvMach.target != nil && _hvMach.target.hp > 0)
		{
			CGPoint dir = {_hvMach.target.pos.x - _hvMach.pos.x, _hvMach.target.pos.y - _hvMach.pos.y};
			float rot = atan2(dir.y, dir.x);
			
			if(rot - _baseParts.rotate > M_PI) _baseParts.rotate += M_2PI;
			else if(rot - _baseParts.rotate < -M_PI) _baseParts.rotate -= M_2PI;
			
			EASYOUT(_baseParts.rotate, rot, 10.f);
			
			if(_hvMach.machType != MACHTYPE_BIPOD)
			{
				if(fabs(_baseParts.rotate - rot) < 0.1f) _hvMach.weaponReady = true;
				else _hvMach.weaponReady = false;
			}
		}
		else
		{
			float rot = _hvMach.rotate;
			if(rot - _baseParts.rotate > M_PI) _baseParts.rotate += M_2PI;
			else if(rot - _baseParts.rotate < -M_PI) _baseParts.rotate -= M_2PI;
			
			EASYOUT(_baseParts.rotate, rot + cosf((GWORLD.time - _startTime) / 2.f) * .5f, 8.f);
//			FOLLOW(_baseParts.rotate, rot + cosf((GWORLD.time - _startTime) / 2.f) * (RANDOMF(.1f) + .1f), 0.01f);
		}
	}

	[super tick];
}

@end
