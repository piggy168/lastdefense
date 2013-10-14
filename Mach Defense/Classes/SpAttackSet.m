//
//  SpAttackSet.m
//  MachDefense
//
//  Created by HaeJun Byun on 10. 11. 23..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SpAttackSet.h"

@implementation SpAttackSet
@synthesize onSlot=_onSlot, attackName=_attackName, level=_level, maxLevel=_maxLevel, count=_count;

- (void)dealloc
{
	[super dealloc];
}

- (void)setAttackSet:(TSpAttackSet *)attackSet ToLevel:(int)level
{
	if(level < 0) return;
	if(level >= 16) return;
	
	memcpy(&_attackSet[level], attackSet, sizeof(TSpAttackSet));
}

- (TSpAttackSet *)attackSet
{
	if(_level < 0) _level = 0;
	if(_level >= _maxLevel) _level = _maxLevel - 1;
	
	return &_attackSet[_level];
}

- (TSpAttackSet *)nextAttackSet
{
	if(_level < 0) return NULL;
	if(_level >= _maxLevel - 1) return NULL;
	
	return &_attackSet[_level+1];
}

@end
