//
//  WndBuildSlot.m
//  MachDefense
//
//  Created by HaeJun Byun on 10. 9. 8..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "WndBuildSlot.h"
#import "BuildItem.h"

@implementation WndBuildSlot

- (id)init
{
	[super init];
	
	if(_glView.deviceType == DEVICE_IPAD) _itemHeight = 72.f;
	else _itemHeight = 36.f;
	
	return self;
}

- (void)tick
{
	QobBase *obj;
	float y;
	for(int i = 0; i < [_childArray count]; i++)
	{
		obj = [_childArray objectAtIndex:i];
		if(obj != nil)
		{
			y = obj.pos.y;
			if(y != -i * _itemHeight)
			{
				EASYOUTE(y, (-i * _itemHeight), 8.f, .5f);
				[obj setPosY:y];
			}
		}
	}

	[super tick];
}

- (void)removeAllItems
{
	for(int i = 0; i < [_childArray count]; i++)
	{
		QobBase *obj = [_childArray objectAtIndex:i];
		if(obj != nil) [obj remove];
	}
}

- (void)addBuildItemWithBuildSet:(MachBuildSet *)info Type:(int)setType
{
	TMachBuildSet *set = [info buildSet];
	if(_childArray.count < BUILDSLOT_SIZE && GVAL.mineral >= set->cost && set->buildCount < set->multiBuild)
	{
		BuildItem *item = [[BuildItem alloc] init];
		[item setPosX:0 Y:-500];
		[item setItemWithBuildSet:info Type:setType];
		[self addChild:item];
		
		GVAL.mineral -= set->cost;
	}
}

- (void)addBuildItemWithBuildSet:(MachBuildSet *)info Type:(int)setType Pos:(CGPoint)pos
{
	TMachBuildSet *set = [info buildSet];
	if(_childArray.count < BUILDSLOT_SIZE && GVAL.mineral >= set->cost && set->buildCount < set->multiBuild)
	{
		BuildItem *item = [[BuildItem alloc] init];
		[item setPosX:0 Y:-500];
		[item setItemWithBuildSet:info Type:setType Pos:pos];
		[self addChild:item];
		
		GVAL.mineral -= set->cost;
	}
}

- (int)buildCount
{
	return _childArray.count;
}

@end
