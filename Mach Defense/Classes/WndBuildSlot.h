//
//  WndBuildSlot.h
//  MachDefense
//
//  Created by HaeJun Byun on 10. 9. 8..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

@interface WndBuildSlot : QobBase
{
	float _itemHeight;
}

- (void)removeAllItems;
- (void)addBuildItemWithBuildSet:(MachBuildSet *)info Type:(int)setType;
- (void)addBuildItemWithBuildSet:(MachBuildSet *)info Type:(int)setType Pos:(CGPoint)pos;
- (int)buildCount;

@end
