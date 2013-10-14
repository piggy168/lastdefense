//
//  BuildItem.h
//  MachDefense
//
//  Created by HaeJun Byun on 10. 9. 8..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

@class GobHvM_Player;

@interface BuildItem : QobImage
{
	int _setType;
	QobImage *_mach;
	TMachBuildSet *_buildSet;
	CGPoint _buildPos;
	float _buildTime, _buildStartTime, _gaugeSize;
	QobImage *_buildGauge;
}

- (void)setItemWithBuildSet:(MachBuildSet *)info Type:(int)setType;
- (void)setItemWithBuildSet:(MachBuildSet *)info Type:(int)setType Pos:(CGPoint)pos;

@end
