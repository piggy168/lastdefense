//
//  Ranking.h
//  HeavyMach2
//
//  Created by 엔비 on 10. 2. 25..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#define GAME_NAME	@"HeavyMach2"
#define GAME_KEY	@"d8a9900029553c9827628d878b9df970"
@interface Ranking : NSObject
{
	int _offset;
	NSMutableArray *_globalScore;
}

- (void)requestScore:(int)offset;
- (void)requestRankForScore:(int)score;
- (void)postScore;

@end
