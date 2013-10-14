//
//  MachInfo.h
//  HeavyMach2
//
//  Created by 엔비 on 09. 08. 28.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MachInfo : NSObject
{
	NSData *_data;
	unsigned int _type, _refType;
	int _hp, _exp, _level;
	int _radius;
	unsigned int _coinGenRate;
	int _coinGen;
	float _speed;
	NSString *_itemGen;
}

@property(readwrite, assign) NSData *data;
@property(readwrite) unsigned int type, refType;
@property(readwrite) int hp, exp, level, radius;
@property(readwrite) float speed;
@property(readwrite) unsigned int coinGenRate;
@property(readwrite) int coinGen;
@property(readwrite, assign) NSString *itemGen;

@end
