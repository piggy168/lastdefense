//
//  BuildItem.m
//  MachDefense
//
//  Created by HaeJun Byun on 10. 9. 8..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BuildItem.h"
#import "GobHvM_Player.h"
#import "GuiGame.h"

@implementation BuildItem

- (id)init
{
	[super init];
	
	Tile2D *tile = [TILEMGR getTileForRetina:@"MakeMach_Mach.png"];
	[tile tileSplitX:1 splitY:1];
	QobImage *img = [[QobImage alloc] initWithTile:tile tileNo:0];
	[img setUseAtlas:true];
	[self addChild:img];
//	[img setLayer:VLAYER_FORE];
	
	tile = [TILEMGR getTileForRetina:@"BuildGauge.png"];
	[tile tileSplitX:1 splitY:1];
	img = [[QobImage alloc] initWithTile:tile tileNo:0];
	[img setPosY:-26 * GWORLD.deviceScale];
	[img setScaleX:0.f];
	[img setUseAtlas:true];
	[self addChild:img];
//	[img setLayer:VLAYER_FORE];
	_buildGauge = img;
	
	if(_glView.deviceType == DEVICE_IPAD) _gaugeSize = 32.f;
	else _gaugeSize = 16.f;
	
	[SOUNDMGR play:[GINFO sfxID:SND_BUILDMACH]];
	
	return self;
}

- (void)setItemWithBuildSet:(MachBuildSet *)info Type:(int)setType
{
	_setType = setType;
	
	QobImage *mach = [[QobImage alloc] initWithTile:[info machTile] tileNo:0];
	[mach setUseAtlas:true];
	[self addChild:mach];
	_mach = mach;
	
	_buildSet = [info buildSet];
	_buildStartTime = GWORLD.time;
	_buildTime = _buildSet->buildTime * GVAL.buildTime;
	
	_buildSet->buildCount++;
}

- (void)setItemWithBuildSet:(MachBuildSet *)info Type:(int)setType Pos:(CGPoint)pos
{
	[self setItemWithBuildSet:info Type:setType];
	_buildPos = pos;
}

- (void)tick
{
	if(_mach) [_mach setPosX:0 Y:0];
	
	float scale = (GWORLD.time - _buildStartTime) / _buildTime;
	if(scale > 1.f)
	{
		scale = 1.f;
		
		if(_setType == BST_PARTS)
		{
			[GWORLD addPlayerMachWithParts:_buildSet->parts X:RANDOMFC(220.f)*GWORLD.deviceScale Y:-GWORLD.mapHalfLen];
//			[mach setDestPosX:mach.pos.x Y:mach.pos.y + 200.f];
		}
		else if(_setType == BST_NAME)
		{
			GobHvM_Player *mach = nil;
			if(_buildSet->buildUnitType == BUT_MACH)
			{
				mach = [GWORLD addPlayerMachWithName:_buildSet->name->szMachName X:0 Y:-GWORLD.mapHalfLen];
			}
			else
			{
				mach = [GWORLD addPlayerMachWithName:_buildSet->name->szBotName X:0 Y:-GWORLD.mapHalfLen];
				[mach setPostBuild:_buildSet->name->szMachName];
			}
			[mach setDestPosX:_buildPos.x Y:_buildPos.y];
		}
		
		[SOUNDMGR play:[GINFO sfxID:SND_BUILDMACH_COMPLETE]];

		_buildSet->buildCount--;
		[self remove];
	}
	[_buildGauge setScaleX:scale];
	[_buildGauge setPosX:_gaugeSize * scale - _gaugeSize];
	
	[super tick];
}

@end
