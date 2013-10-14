//
//  GobStaffEffect.h
//  iFlying!
//
//  Created by 엔비 on 09. 05. 19.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "QobParticle.h"

@interface GobStaffEffect : QobParticle
{
	QobBase *_base;
	ResMgr_Tile *_resMgr;
	int _regenTile;
	float _speed;
}

- (void)setBase:(QobBase *)base resMgr:(ResMgr_Tile *)resMgr tileNo:(int)tileNo speed:(float)speed;

@end
