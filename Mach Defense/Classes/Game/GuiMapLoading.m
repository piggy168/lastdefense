//
//  GuiStageClear.m
//  iFlying!
//
//  Created by 엔비 on 09. 04. 21.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "GuiMapLoading.h"
#import "QobButton.h"
#import "GuiGame.h"
#import "ScoreNum.h"


@implementation GuiMapLoading

@synthesize nextStage=_nextStage;

- (id)init
{
	[super init];
	
	Tile2D *tile = nil;
	tile = [TILEMGR getTileForRetina:@"StageClear01.png"];
	_imgBG = [[QobImage alloc] initWithTile:tile tileNo:0];
	[_imgBG setBlendType:BT_ALPHA];
	[_imgBG setPosX:_glView.surfaceSize.width/2 Y:_glView.surfaceSize.height/2];
	[_imgBG setAlpha:0.f];
	[_imgBG setLayer:VLAYER_SYSTEM];
	[self addChild:_imgBG];
	
	_step = SCS_FADEIN;
	
	return self;
}

- (void)dealloc
{
	[super dealloc];
}

- (void)tick
{
	switch (_step)
	{
		case SCS_FADEIN:
			EASYOUT(_imgBG.alpha, 1.f, 20.f);
			if(_imgBG.alpha > .99f)
			{
				_imgBG.alpha = 1.f;
				_step = SCS_CLEAR_OBJECT;
			}
			break;
		case SCS_CLEAR_OBJECT:
			[GWORLD clearAllObject];		// 타일 리소스 매니저 초기화보다 한 틱 앞서 해줘야 한다
			[GAMEUI onClearStage];
			_step = SCS_CLEAR_TILEMGR;
			break;
		case SCS_CLEAR_TILEMGR:
			[GWORLD clearTileResMgr];
			_step = SCS_LOAD_NEXTMAP;
			break;
		case SCS_LOAD_NEXTMAP:
			[GWORLD setStage:_nextStage];
			[GWORLD setGameState:GSTATE_PLAY];
			[GWORLD setPause:false];
			_step = SCS_FADEOUT;
			break;
		case SCS_FADEOUT:
			EASYOUT(_imgBG.alpha, 0.f, 20.f);
			if(_imgBG.alpha < .01f)
			{
				_imgBG.alpha = 0.f;
				_step = SCS_COMPLETE;
			}
			break;
		case SCS_COMPLETE:
			[self remove];
			break;
	}

	[super tick];
}

@end
