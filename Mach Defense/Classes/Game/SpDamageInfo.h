//
//  SpDamageInfo.h
//  MachDefense
//
//  Created by HaeJun Byun on 10. 11. 9..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//


@interface SpDamageInfo : NSObject
{
	NSString *_key;
	int _type;
	float _delayTime, _damage;
	float _endTime, _dmgTime;
}

@property(retain) NSString *key;
@property(readwrite) int type;
@property(readwrite) float delayTime, damage, endTime, dmgTime;

@end
