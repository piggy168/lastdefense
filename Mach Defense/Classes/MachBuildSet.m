//
//  MachBuildInfo.m
//  MachDefense
//
//  Created by HaeJun Byun on 10. 10. 19..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MachBuildSet.h"
#import "UiObjMach.h"

@implementation MachBuildSet
@synthesize onSlot=_onSlot, uiMach=_uiMach, machName=_machName, setType=_setType, level=_level, maxLevel=_maxLevel;

- (void)dealloc
{
	for(int i = 0; i < 16; i++)
	{
		if(_buildSet[i].parts != NULL) free(_buildSet[i].parts);
	}
	
	[_uiMach release];
	
	[super dealloc];
}

- (void)setBuildSet:(TMachBuildSet *)buildSet ToLevel:(int)level
{
	if(level < 0) return;
	if(level >= 16) return;
	
	memcpy(&_buildSet[level], buildSet, sizeof(TMachBuildSet));
	if(_maxLevel < level + 1) _maxLevel = level + 1;
}

- (TMachBuildSet *)buildSet
{
	if(_level < 0) _level = 0;
	if(_level >= _maxLevel) _level = _maxLevel - 1;
	
	return &_buildSet[_level];
}

- (TMachBuildSet *)nextBuildSet
{
	if(_level < 0) return NULL;
	if(_level >= _maxLevel - 1) return NULL;
	
	return &_buildSet[_level+1];
}

- (void)setLevel:(int)level
{
	if(level < _maxLevel)
	{
		_level = level;
		
		if(_uiMach != nil) [_uiMach release];
		_uiMach = [[UiObjMach alloc] init];
		[_uiMach setName:_machName];
		if(_setType == BST_PARTS)
		{
			[_uiMach setParts:@"DummyParts" partsType:PARTS_BASE];
			[_uiMach setParts:_buildSet[_level].parts->foot.strParam partsType:PARTS_FOOT];
			[_uiMach setParts:_buildSet[_level].parts->armor.strParam partsType:PARTS_BODY];
			[_uiMach setParts:_buildSet[_level].parts->weapon.strParam partsType:PARTS_WPN];
		}
		else
		{
			[_uiMach makeMachFromName:_buildSet[_level].name->szMachName];
		}
		[_uiMach bakeTile];
	}
}

- (Tile2D *)machTile
{
	if(_uiMach == nil) return nil;
	
	return _uiMach.tile;
}

@end
