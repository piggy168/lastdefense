//
//  BaseUpgradeSet.h
//  MachDefense
//
//  Created by HaeJun Byun on 10. 12. 1..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

struct TBaseUpgradeSet
{
	int upgradeCost;
	float param;
};
typedef struct TBaseUpgradeSet TBaseUpgradeSet;

@interface BaseUpgradeSet : NSObject
{
	NSString *_upgradeName;
	TBaseUpgradeSet _upgradeSet[16];
	
	int _level, _maxLevel;
}

@property(retain) NSString *upgradeName;
@property(readwrite) int level, maxLevel;

- (void)setUpgradeSet:(TBaseUpgradeSet *)upgradeSet ToLevel:(int)level;
- (TBaseUpgradeSet *)upgradeSet;
- (TBaseUpgradeSet *)nextUpgradeSet;

@end
