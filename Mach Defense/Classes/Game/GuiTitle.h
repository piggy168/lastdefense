//
//  GuiTitle.h
//  HeavyMach
//
//  Created by 엔비 on 08. 11. 28.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "QobImage.h"
//#import "SoundEffect.h"

enum EnumTitleSFX
{
	TSFX_TITLEIN, TSFX_BANG, TSFX_STARTGAME,
	TSFX_END
};

@interface GuiTitle : QobBase
{
	ResMgr_Tile *_tileResMgr;
	UInt32 _sfx[TSFX_END];
	CGPoint _camPos;
	
	QobImage *_imgBG;
	QobImage *_imgStartGame;
	float _bgScale;
	float _bgRotate;
	float _titleScale;
	float _episodeScale;
	
	bool _playTitleInSnd;
	bool _playEpisodeInSnd;
	bool _playStartGameSnd;
	
	float _startTime;
}

- (void)processTitle;

@end
