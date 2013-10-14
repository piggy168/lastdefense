//
//  ScoreNum.m
//  BPop
//
//  Created by 엔비 on 08. 10. 26.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "ScoreNum.h"
#import "GuiGame.h"


@implementation ScoreNum

@synthesize dynamicScore=_dynamicScore;

- (id)init
{
	[super init];
	
	_visual = true;
	_scoreAddTime = 0.f;
	_scorePos.x = 0.f;
	_scorePos.y = 0.f;
	
	_dynamicScore = true;
	
	return self;
}

- (id)initWithTile:(Tile2D *)tile
{
	[self init];
	[super initWithTile:tile];
	
	return self;
}

- (void)setScorePosX:(int)x Y:(int)y
{
	_scorePos.x = x;
	_scorePos.y = y;
}

- (void)setScoreState:(int)state
{
	_scoreState = state;
}

- (void)addScore:(int)score
{
	_num += score;
//	[self setBoundCheck:true];
	[self setNumber:_num];
	_scoreState = SS_CALCSCORE;
	_scoreAddTime = g_time;
}

- (void)tick
{
	switch (_scoreState)
	{
		case SS_CALCSCORE:	[self processCalcScore];		break;
		case SS_MOVESCORE:	[self processMoveScore];		break;
		case SS_ADDSCORE:	[self processAddScore];			break;
	}
	
	[super tick];
}

- (void)processCalcScore
{
	if(_scoreAddTime != 0.f)
	{
		float dt = g_time - _scoreAddTime;
		if(dt < 0.14f)
		{
			_scaleX = _scaleY = cos(dt / 0.1) + 1.f;
		}
		else
		{
			_scaleX = _scaleY = 1.f;
			if(dt > .5f)
			{
				_scoreAddTime = 0;
				if(_dynamicScore) _scoreState = SS_MOVESCORE;
//				[g_main playSFX:SFX_CALCSCORE];
			}
		}
	}
}

- (void)processMoveScore
{
//	EASYOUT(_scaleX, 1.f, 10.f);
//	EASYOUT(_scaleY, 1.f, 10.f);
	EASYOUT(_alignRate, 0.f, 10.f);
	[self easyOutTo:&_scorePos Div:10.f Min:.1f];
	
	if(fabs(_pos.x - _scorePos.x) < 0.5f && fabs(_pos.y - _scorePos.y) < 0.5f)
	{
		[self setPosX:_scorePos.x Y:_scorePos.y];
		_scoreState = SS_ADDSCORE;
	}
}

- (void)processAddScore
{
	int num = _num;
	EASYOUT(_num, 0.f, 10.f);
	num -= _num;
	
	if(num != 0)
	{
		[self setNumber:_num];
//		[GAMEUI addScore:num];
		if(g_time > _scoreAddTime + .1f)
		{
			_scoreAddTime = g_time;
//			[g_main playSFX:SFX_ADDSCORE];
		}

		if(_num == 0)
		{
			[self remove];
		}
		
	}
}


@end
