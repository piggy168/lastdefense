//
//  ScoreNum.h
//  BPop
//
//  Created by 엔비 on 08. 10. 26.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "QobImageFont.h"

enum EScoreState
{
	SS_CALCSCORE, SS_MOVESCORE, SS_ADDSCORE, SS_REMOVE
};

@interface ScoreNum : QobImageFont
{
	bool _dynamicScore;
	int _scoreState;
	float _scoreAddTime;
	CGPoint _scorePos;
}

@property(readwrite) bool dynamicScore;

- (void)processCalcScore;
- (void)processMoveScore;
- (void)processAddScore;

- (void)setScorePosX:(int)x Y:(int)y;
- (void)setScoreState:(int)state;
- (void)addScore:(int)score;

@end
