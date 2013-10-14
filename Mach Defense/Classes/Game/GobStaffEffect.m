//
//  GobStaffEffect.m
//  iFlying!
//
//  Created by 엔비 on 09. 05. 19.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "GobStaffEffect.h"

@implementation GobStaffEffect

- (void)setBase:(QobBase *)base resMgr:(ResMgr_Tile *)resMgr tileNo:(int)tileNo speed:(float)speed
{
	_base = base;
	_resMgr = resMgr;
	_regenTile = tileNo;
	_speed = speed;
}

- (void)tick
{
	if(_pos.x > -240.f && _regenTile != -1)
	{
		Tile2D *tile = [_resMgr getTile:@"Staff.png"];
		QobParticle *light = [[QobParticle alloc] init];
		[light setTile:tile tileNo:_regenTile];
		[light setPosX:_pos.x + 360.f Y:_pos.y];
		[light setVelX:_speed Y:0];
		[light setBlendType:BT_ADD];
		[light setLiveTime:4.5f];
		[light setSelfRemove:true];
		[_base addChild:light];
		[light start];
		
		_regenTile = -1;
	}
	
	[super tick];
}

@end
