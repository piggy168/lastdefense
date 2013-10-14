//
//  SpAttackSet.h
//  MachDefense
//
//  Created by HaeJun Byun on 10. 11. 23..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

struct TSpAttackSet
{
	int cost, upgradeCost;
	int itemId;
};
typedef struct TSpAttackSet TSpAttackSet;

@interface SpAttackSet : NSObject
{
	bool _onSlot;
	NSString *_attackName;
	TSpAttackSet _attackSet[16];
	
	int _level, _maxLevel;
	
	int _count;
}

@property(readwrite) bool onSlot;
@property(retain) NSString *attackName;
@property(readwrite) int level, maxLevel, count;

- (void)setAttackSet:(TSpAttackSet *)attackSet ToLevel:(int)level;
- (TSpAttackSet *)attackSet;
- (TSpAttackSet *)nextAttackSet;

@end
