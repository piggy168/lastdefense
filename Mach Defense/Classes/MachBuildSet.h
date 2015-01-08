//
//  MachBuildInfo.h
//  MachDefense
//
//  Created by HaeJun Byun on 10. 10. 19..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

@class ItemInfo;

enum MachStatus
{
    machbuild_lock = 0,
    machbuild_unlock = 1,
    machbuild_buy = 2
};

enum EBuildSetType
{
	BST_PARTS, BST_NAME
};

enum EBuildUnitType
{
	BUT_MACH, BUT_UNIT
};

struct TMachBuildParts
{
	int size;
	ItemInfo *armor, *foot, *weapon;
};
typedef struct TMachBuildParts TMachBuildParts;

struct TMachBuildName
{
	int buildType;
	char szBotName[24];
	char szMachName[24];
//	CGPoint buildPos;
};
typedef struct TMachBuildName TMachBuildName;

struct TMachBuildSet
{
	int buildUnitType;
	int cost, upgradeCost, multiBuild;
	float buildTime;
	TMachBuildParts *parts;
	TMachBuildName *name;
	
	int buildCount;
};
typedef struct TMachBuildSet TMachBuildSet;

@class UiObjMach;

@interface MachBuildSet : NSObject
{
	bool _onSlot;
	int _setType;
	NSString *_machName;
	TMachBuildSet _buildSet[16];
	
	UiObjMach *_uiMach;

	int _level, _maxLevel, _status;
}

@property(readwrite) bool onSlot;
@property(retain) NSString *machName;
@property(readwrite) int setType, level, maxLevel, status;
@property(readonly) UiObjMach *uiMach;

- (void)setBuildSet:(TMachBuildSet *)buildSet ToLevel:(int)level;
- (TMachBuildSet *)buildSet;
- (TMachBuildSet *)nextBuildSet;
- (Tile2D *)machTile;

@end
