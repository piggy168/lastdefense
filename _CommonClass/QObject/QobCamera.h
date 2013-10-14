//
//  QobCamera.h
//  HeavyMach
//
//  Created by 엔비 on 08. 11. 20.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

@interface QobCamera : QobBase
{
	CGSize _halfScr;
	float _offsetX;
	float _offsetY;
	
	float _quakeStartTime;
	float _quakeDelay;
	float _quakeSize;
	float _quakePitch;
}

@property(readonly) CGSize halfScr;
@property(readwrite) float offsetX;
@property(readwrite) float offsetY;

- (void)setScreenWidth:(float)width Height:(float)height;

- (void)setQuake:(float)size Count:(int)cnt Delay:(float)delay;

@end
