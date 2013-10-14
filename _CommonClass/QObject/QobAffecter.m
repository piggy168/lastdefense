//
//  QobAffecter.m
//  HeavyMach2
//
//  Created by 엔비 on 09. 11. 05.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "QobAffecter.h"


@implementation QobAffecter


- (void)setDest:(CGPoint)dest
{
	_dest = dest;
	_affecterType = AFFECTER_MOVE;
}

- (void)setFadeOut:(float)time
{
	_affecterType = AFFECTER_FADEOUT;
	_startTime = g_time;
	_endTime = time;
}

- (void)tick
{
	if(_affecterType == AFFECTER_MOVE)
	{
		if(_parent.pos.x != _pos.x || _parent.pos.y != _pos.y)
		{
			[_parent easyOutTo:&_pos Div:3.f Min:.5f];
		}
		else
		{
			[self remove];
		}
	}
	else if(_affecterType == AFFECTER_FADEOUT)
	{
		float alpha = 1.f - (g_time - _startTime) / _endTime;
		if(alpha > 1.f)
		{
			alpha = 1.f;
		}
		else if(alpha <= 0.f)
		{
			alpha = 0.f;
			[_parent remove];
		}
		
		[_parent setAlpha:alpha];
	}
	
	[super tick];
}

@end
