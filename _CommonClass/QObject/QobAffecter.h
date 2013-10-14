//
//  QobAffecter.h
//  HeavyMach2
//
//  Created by 엔비 on 09. 11. 05.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

enum EAffecterType
{
	AFFECTER_MOVE, AFFECTER_FADEOUT, AFFECTER_FADEIN
};

@interface QobAffecter : QobBase
{
	int _affecterType;
	CGPoint _dest;
	float _startTime, _endTime;
}

- (void)setDest:(CGPoint)dest;
- (void)setFadeOut:(float)time;

@end
