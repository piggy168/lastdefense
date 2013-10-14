//
//  UiObjMachParts.m
//  MachDefense
//
//  Created by HaeJun Byun on 10. 12. 2..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "UiObjMachParts.h"
#import "ImageAttacher.h"

@implementation UiObjMachParts
@synthesize reverse=_reverse;

- (void)setPartsInfo:(PartsInfo *)partsInfo
{
	_partsInfo = partsInfo;
}

- (CGPoint)getSocketPos:(unsigned char)n
{
	CGPoint pos = {0, 0};
	
	if(_baseParts != nil)
	{
		pos = [_baseParts getSocketPos:_baseSocket];
	}
	
	if(_partsInfo != nil)
	{
		if([_partsInfo getSocket:0] != NULL)
		{
			CGPoint *base = [_partsInfo getSocket:0];
			if(n == 0)
			{
				pos.x -= base->x;
				if(_reverse) pos.y += base->y;
				else pos.y -= base->y;
			}
			else
			{
				CGPoint *pt = [_partsInfo getSocket:n];
				if(pt != NULL)
				{
					pos.x += pt->x - base->x;
					if(_reverse) pos.y -= pt->y - base->y;
					else pos.y += pt->y - base->y;
				}
			}
		}
	}
	
	return pos;
}

- (void)setBaseParts:(UiObjMachParts *)base Socket:(unsigned char)socket
{
	_baseParts = base;
	_baseSocket = socket;
	_pos = [self getSocketPos:0];
	_basePos = [base getSocketPos:socket];
}

- (void)setChildParts:(UiObjMachParts *)child Socket:(unsigned char)socket
{
	[child setBaseParts:self Socket:socket];
	CGPoint pos = [self getSocketPos:0];
	_pos = pos;
}

- (void)attachTo:(ImageAttacher *)attacher X:(int)x Y:(int)y
{
	UIImageOrientation rotate = _reverse ? UIImageOrientationLeftMirrored : UIImageOrientationLeft;
	[attacher attachImage:[TILEMGR getImage:[NSString stringWithFormat:@"%@.png", _partsInfo.name]] ToX:x-_pos.y/GWORLD.deviceScale Y:y+_pos.x/GWORLD.deviceScale Rotate:rotate];
}

@end
