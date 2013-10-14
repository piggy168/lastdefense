//
//  GobItem.m
//  iFlying!
//
//  Created by 엔비 on 09. 05. 03.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "GobFieldItem.h"
#import "GobHvM_Player.h"
#import "GobHvM_Bot.h"
#import "Collider.h"

@implementation GobFieldItem
@synthesize itemInfo=_itemInfo, itemID=_itemID, value=_value;

- (id)initWithItem:(ItemInfo *)item
{
	Tile2D *tile = [TILEMGR getTileForRetina:@"Efx_Item2.png"];
	[tile tileSplitX:1 splitY:1];
	[super initWithTile:tile tileNo:0];
	[self setUseAtlas:true];
	[self setBlendType:BT_ADD];

	_itemID = [[NSString alloc] initWithString:item.code];
	_itemInfo = item;
	
	int iconId = _itemInfo.icon / 1000, iconTile = (_itemInfo.icon % 1000) - 1;
	
	tile = [TILEMGR getTileForRetina:[NSString stringWithFormat:@"Icon_%d.png", iconId]];
	[tile tileSplitX:4 splitY:4];
	_imgIcon = [[QobImage alloc] initWithTile:tile tileNo:iconTile];
	if(_itemInfo.type != ITEM_COIN && _itemInfo.type != ITEM_ENERGYCELL) [_imgIcon setScale:.5f];
	[_imgIcon setUseAtlas:true];
	[_imgIcon setRotate:RANDOMFC(1.f)];
	[self addChild:_imgIcon];
	[_imgIcon setLayer:VLAYER_BG];
	
	float dir = RANDOMF(M_PI * 2.f);
	float vel = RANDOMF(4.f) + 3.f;
	_vel.x = cos(dir) * vel;
	_vel.y = sin(dir) * vel;
	_checkLen = 100.f * GWORLD.deviceScale;
	_maxCheckLen = 400.f * GWORLD.deviceScale;
	_incLen = 10.f * GWORLD.deviceScale;
	
	_createTime = GWORLD.time;
	
//	[self setUseAtlas:true];
	return self;
}

- (void)dealloc
{
	[_itemID release];
	
	[super dealloc];
}
  
- (void)tick
{
	float lenX, lenY;
	if(_picker != nil)
	{
		lenX = _picker.pos.x - _pos.x;
		lenY = _picker.pos.y - _pos.y;
		
		EASYOUT(_vel.x, lenX * 0.05f, 10.f);
		EASYOUT(_vel.y, lenY * 0.05f, 10.f);
		EASYOUT(_speed, .1f, 100.f);
		
		[self addPos:&_vel];

		if(fabs(lenX) < 20 && fabs(lenY) < 20)
		{
			[_picker pickupItem:_itemInfo Count:_value];
			[self remove];
		}
	}
	else 
	{
		EASYOUTE(_vel.x, 0.f, 7.f, 0.01f);
		EASYOUTE(_vel.y, 0.f, 7.f, 0.01f);
		[self addPos:&_vel];
	}
	
	if(!_remove && _picker == nil && GWORLD.time - _checkTime > .5f)
	{
		if(_checkLen < _maxCheckLen) _checkLen += _incLen;
		
		GobHvM_Player *player;
		for(int i = 0; _picker == nil && i < [GWORLD.listPlayer childCount]; i++)
		{
			player = (GobHvM_Player *)[GWORLD.listPlayer childAtIndex:i];
			if(player != nil && player.machType == MACHTYPE_BIPOD && player.hp > 0)
			{
				lenX = player.pos.x - _pos.x;
				lenY = player.pos.y - _pos.y;
				
				if(fabs(lenX) < _checkLen && fabs(lenY) < _checkLen)
				{
					_picker = player;
				}
			}
		}
		
		if(_picker == nil && GWORLD.time - _createTime > 180.f)
		{
			[self remove];
		}

		_checkTime = GWORLD.time;
	}
	
	_rotate = RANDOMF(M_PI * 2.f);
	_scaleX = _scaleY = .5f + sinf(GWORLD.time * 10.f) * .01f;
	_alpha = .2f + RANDOMF(.8f);
	
	[super tick];
}

- (void)pickerDead:(GobHvM_Player *)player
{
	if(_picker == player) _picker = nil;
}


@end
