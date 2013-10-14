//
//  GuiTitle.m
//  HeavyMach
//
//  Created by 엔비 on 08. 11. 28.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "GuiTitle.h"
#import "DefaultAppDelegate.h"

extern DefaultAppDelegate *_appDelegate;

@implementation GuiTitle

- (id)init
{
	[super init];
	[self setUiReceiver:true];
	
	_bgScale = 1.8f;
	_bgRotate = -.05f;
	_camPos.x = 100.f;
	_camPos.y = -10.f;
	_titleScale  = 50.f;
	_episodeScale = 40.f;
	
	[SOUNDMGR playBGM:@"Intro.mp3"];
	
/*	_cam = [[QobCamera alloc] init];
	[_cam setScreenWidth:_glView.surfaceSize.width Height:_glView.surfaceSize.height];
	[_cam setPosX:_glView.surfaceSize.width / 2 Y:_glView.surfaceSize.width / 2];
	[self addChild:_cam];*/

	_sfx[TSFX_TITLEIN] = [SOUNDMGR getSound:@"Title_TitleIn.wav"];
	_sfx[TSFX_BANG] = [SOUNDMGR getSound:@"Title_Bang.wav"];
	_sfx[TSFX_STARTGAME] = [SOUNDMGR getSound:@"Title_TapToStart.wav"];
	
	_tileResMgr = [[ResMgr_Tile alloc] init];
	
	Tile2D *tile = [_tileResMgr getUniTile:@"Title_Main.png"];
	QobImage *img = [[QobImage alloc] initWithTile:tile tileNo:0];
	[img setPosX:0 Y:0];
	[self addChild:img];
	_imgBG = img;
//	[_imgBG setScale:_bgScale];
	
	tile = [_tileResMgr getTile:@"Main_Copyright.png"];
	img = [[QobImage alloc] initWithTile:tile tileNo:0];
	[img setPosX:0 Y:-500];
	[self addChild:img];
	
	tile = [_tileResMgr getTile:@"Main_TapToStart.png"];
	img = [[QobImage alloc] initWithTile:tile tileNo:0];
	[img setPosX:0 Y:_glView.deviceType == DEVICE_IPAD ? -64 : -32];
	[self addChild:img];
	_imgStartGame = img;
	[_imgStartGame setShow:false];
	
	_playTitleInSnd = false;
	_playEpisodeInSnd = false;
	_playStartGameSnd = false;
	_startTime = g_time;
	
	[_appDelegate bannerTurnOn:nil];

	return self;
}

- (void)dealloc
{
	[_tileResMgr removeAllTiles];
	[_tileResMgr release];
	
	[super dealloc];
}

#define TITLE_INTIME			6.2f
#define EPISODE_INTIME			7.7f
#define TAPSTART_INTIME			0.f

- (void)tick
{
	if(g_main.screen == GSCR_TITLE) [self processTitle];
	[super tick];
}

- (void)processTitle
{
	if(g_time > _startTime + TAPSTART_INTIME)
	{
		float dt = g_time - (_startTime + TAPSTART_INTIME);
		dt = fmod(dt, 2.f);
		if(dt < .2f)
		{
			if(!_playStartGameSnd)
			{
				[SOUNDMGR play:_sfx[TSFX_STARTGAME]];
				_playStartGameSnd = true;
			}
			
			if(RANDOM(10) < 6) [_imgStartGame setShow:RANDOM(2) == 0 ? true : false];
		}
		else if(dt < 1.2f)
		{
			[_imgStartGame setShow:true];
		}
		else if(_playStartGameSnd)
		{
			_playStartGameSnd = false;
			[_imgStartGame setShow:false];
		}
	}
}

- (BOOL)onTap:(CGPoint)pt State:(int)state ID:(id)tapID
{
	if(state == TAP_END)
	{
		if(g_time < _startTime + TAPSTART_INTIME)
		{
			_startTime = g_time - TAPSTART_INTIME;
//			[_imgTitleBig setShow:false];
		}
		else
		{
			[_appDelegate bannerTurnOff:nil];
			[g_main changeScreen:GSCR_SELECTSLOT];
		}
	}
	
	return true;
}

@end
