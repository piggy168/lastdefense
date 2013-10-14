//
//  QobCamera.m
//  HeavyMach
//
//  Created by 엔비 on 08. 11. 20.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "QobCamera.h"


@implementation QobCamera

@synthesize halfScr=_halfScr, offsetX=_offsetX, offsetY=_offsetY;

- (id)init
{
	[super init];
	CGRect rect = [[UIScreen mainScreen] bounds];	
	
	_halfScr.width = rect.size.width/2;
	_halfScr.width = rect.size.height/2;
	
	_offsetX = 0;
	_offsetY = 0;
	
	_quakeStartTime = 0.f;

	return self;
}

- (void)dealloc
{
//	[_halfScr release];
//	[_offset release];
	
	[super dealloc];
}

- (void)tick
{
	if(_quakeStartTime != 0.f)
	{
		float dt = g_time - _quakeStartTime;
		if(dt < _quakeDelay)
		{
			_offsetY = sin(fmod(dt, _quakePitch) / _quakePitch * M_PI) * _quakeSize * (1.f - dt / _quakeDelay);
		}
		else
		{
			_quakeStartTime = 0.f;
			_offsetX = _offsetY = 0.f;
		}
	}
	
	[super tick];
}

- (void)setScreenWidth:(float)width Height:(float)height
{
//	_halfScr.width = (width - 20) / 2.f;
//	_halfScr.height = (height + 40) / 2.f;
	_halfScr.width = width / 2.f;
	_halfScr.height = height / 2.f;
}

- (void)setQuake:(float)size Count:(int)cnt Delay:(float)delay
{
	_quakeStartTime = g_time;
	_quakeDelay = delay;
	_quakeSize = size;
	_quakePitch = delay / (float)cnt;
}

@end
