//
//  BaseUpgradeSet.m
//  MachDefense
//
//  Created by HaeJun Byun on 10. 12. 1..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BaseUpgradeSet.h"


@implementation BaseUpgradeSet
@synthesize upgradeName=_upgradeName, level=_level, maxLevel=_maxLevel;

- (void)dealloc
{
	[super dealloc];
}

- (void)setUpgradeSet:(TBaseUpgradeSet *)upgradeSet ToLevel:(int)level
{
	if(level < 0) return;
	if(level >= 16) return;
	
	memcpy(&_upgradeSet[level], upgradeSet, sizeof(TBaseUpgradeSet));
}

- (TBaseUpgradeSet *)upgradeSet
{
	if(_level < 0) _level = 0;
	if(_level >= _maxLevel) _level = _maxLevel - 1;
	
	return &_upgradeSet[_level];
}

- (TBaseUpgradeSet *)nextUpgradeSet
{
	if(_level < 0) return NULL;
	if(_level >= _maxLevel - 1) return NULL;
	
	return &_upgradeSet[_level+1];
}

@end
