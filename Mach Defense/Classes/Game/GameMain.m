//
//  GameMain.m
//  Jumping!
//
//  Created by 엔비 on 08. 09. 15.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <time.h>
#import <unistd.h>

#import "GameMain.h"
#import "QobButton.h"
#import "QobParticle.h"
#import "QobImageFont.h"
#import "GobWorld.h"
#import "GobHvMach.h"
#import "GuiTitle.h"
#import "GuiSelectSlot.h"
#import "GuiSelectStage.h"
#import "GuiGame.h"

GameMain *g_main = nil;
float g_time = 0.0;

@implementation GameMain
@synthesize screen=_screen, loadingImg=_tileLoadingImg;

- (id)init
{
	[super init];
	
	_zLayer = VLAYER_MIDDLE;

	[self start];
	_scrChangeState = SCRCHG_END;
	
	if([GAMECENTER isGameCenterAvailable])
	{
		[GAMECENTER authenticateLocalPlayer];
		[GAMECENTER registerForAuthenticationNotification];
	}

#ifdef _ON_DEBUG_
	Tile2D *tile = [TILEMGR getTile:@"NumSet01b.png"];
	[tile tileSplitX:16 splitY:1];
	_numDrawCall = [[QobImageFont alloc] initWithTile:tile];
	[_numDrawCall setPosX:760 Y:1020];
	[_numDrawCall setAlignRate:1.f];
	[_numDrawCall setPitch:6];
	[_numDrawCall setNumber:0];
	[self addChild:_numDrawCall];
	[_numDrawCall setLayer:VLAYER_SYSTEM];

	_numFPS = [[QobImageFont alloc] initWithTile:tile];
	[_numFPS setPosX:720 Y:1020];
	[_numFPS setAlignRate:1.f];
	[_numFPS setPitch:6];
	[_numFPS setNumber:0];
	[self addChild:_numFPS];
	[_numFPS setLayer:VLAYER_SYSTEM];
#endif
	
	return self;
}

- (void)dealloc
{
	[self clearAllScreen];
	[QOBMGR release];
	
	[super dealloc];
}

- (void)start
{
	[SOUNDMGR setMaxDistance:800.f];
	
	GINFO;
	_startTime = 0.f;
	
	_layerLoading = [[QobBase alloc] init];
	[_layerLoading setLayer:VLAYER_SYSTEM];
	[_layerLoading setShow:false];
	[self addChild:_layerLoading];
	
	Tile2D *tile;
	
	tile = [TILEMGR getTile:@"Loading_Left.png"];
	if(_glView.deviceType != DEVICE_IPAD) [tile setForRetina:YES];
	_imgLoading[2] = [[QobImage alloc] initWithTile:tile tileNo:0];
	[_imgLoading[2] setScale:2.f];
	[_imgLoading[2] setLayer:VLAYER_SYSTEM];
	[_layerLoading addChild:_imgLoading[2]];
	
	tile = [TILEMGR getTile:@"Loading_Right.png"];
	if(_glView.deviceType != DEVICE_IPAD) [tile setForRetina:YES];
	_imgLoading[3] = [[QobImage alloc] initWithTile:tile tileNo:0];
	[_imgLoading[3] setScale:2.f];
	[_imgLoading[3] setLayer:VLAYER_SYSTEM];
	[_layerLoading addChild:_imgLoading[3]];
	
	tile = [TILEMGR getTile:@"Loading_Top.png"];
	if(_glView.deviceType != DEVICE_IPAD) [tile setForRetina:YES];
	_imgLoading[0] = [[QobImage alloc] initWithTile:tile tileNo:0];
	[_imgLoading[0] setScale:1.5f];
	[_imgLoading[0] setLayer:VLAYER_SYSTEM];
	[_layerLoading addChild:_imgLoading[0]];
	
	tile = [TILEMGR getTile:@"Loading_Bottom.png"];
	if(_glView.deviceType != DEVICE_IPAD) [tile setForRetina:YES];
	_imgLoading[1] = [[QobImage alloc] initWithTile:tile tileNo:0];
	[_imgLoading[1] setScale:1.5f];
	[_imgLoading[1] setLayer:VLAYER_SYSTEM];
	[_layerLoading addChild:_imgLoading[1]];
	
	tile = [TILEMGR getTile:@"Loading_Center.png"];
	if(_glView.deviceType != DEVICE_IPAD) [tile setForRetina:YES];
	_imgLoadingCenter = [[QobImage alloc] initWithTile:tile tileNo:0];
	if(_glView.deviceType == DEVICE_IPAD) [_imgLoadingCenter setPosX:0 Y:168];
	else [_imgLoadingCenter setPosX:0 Y:84];
	[_imgLoadingCenter setLayer:VLAYER_SYSTEM];
	[_imgLoading[1] addChild:_imgLoadingCenter];
	
	_sfxLoadingOpen = [SOUNDMGR getSound:@"Loading_Open.wav"];
	_sfxLoadingClose = [SOUNDMGR getSound:@"Loading_Close.wav"];
	
	[GINFO openDataFile];
//	[GINFO initSlot:0 Name:@"enbi" Country:@"kr"];

	_world = [[GobWorld alloc] init];
	[self addChild:_world];
	[_world setShow:false];
	
	_uiGame = [[GuiGame alloc] init];
	[_uiGame setPosX:_glView.surfaceSize.width/2 Y:_glView.surfaceSize.height/2];
	[self addChild:_uiGame];
	[_uiGame setShow:false];
	
	_screen = _prevScreen = GSCR_TITLE;
	[self refreshScreen];
}

- (void)tick
{
	if(_scrChangeState != SCRCHG_END)
	{
		if(_scrChangeState == SCRCHG_START)
		{
			[_layerLoading setShow:true];
			
			if(_glView.deviceType == DEVICE_IPAD)
			{
				_startPos[0] = 1408;		_startPos[1] = -384;
				_startPos[2] = -256;		_startPos[3] = 1024;
				_destPos[0] = 640;			_destPos[1] = 384;
				_destPos[2] = 256;			_destPos[3] = 512;
				_checkPos[0] = 200;			_checkPos[1] = 640;
			}
			else
			{
				_startPos[0] = 672;			_startPos[1] = -192;
				_startPos[2] = -128;		_startPos[3] = 448;
				_destPos[0] = 304;			_destPos[1] = 176;
				_destPos[2] = 96;			_destPos[3] = 224;
				_checkPos[0] = 80;			_checkPos[1] = 304;
			}
			_loadingPt[0].x = _glView.surfaceSize.width/2;	_loadingPt[0].y = _startPos[0];
			_loadingPt[1].x = _glView.surfaceSize.width/2;	_loadingPt[1].y = _startPos[1];
			_loadingPt[2].x = _startPos[2];					_loadingPt[2].y = _glView.surfaceSize.height/2;
			_loadingPt[3].x = _startPos[3];					_loadingPt[3].y = _glView.surfaceSize.height/2;
			
			
			[_imgLoadingCenter setScale:1.5f];
			[_imgLoadingCenter setRotate:0.f];

			_scrChangeState = SCRCHG_CLOSE1;
			[SOUNDMGR play:_sfxLoadingClose];
		}
		else if(_scrChangeState == SCRCHG_CLOSE1)
		{
			EASYOUT(_loadingPt[2].x, _destPos[2], 5.f);
			EASYOUT(_loadingPt[3].x, _destPos[3], 5.f);
			
			if(_loadingPt[2].x >= _checkPos[0])
			{
				_scrChangeState = SCRCHG_CLOSE2;
				[SOUNDMGR play:_sfxLoadingClose];
			}
		}
		else if(_scrChangeState == SCRCHG_CLOSE2)
		{
			EASYOUTE(_loadingPt[0].y, _destPos[0], 6.f, 0.1f);
			EASYOUTE(_loadingPt[1].y, _destPos[1], 6.f, 0.1f);
			EASYOUTE(_loadingPt[2].x, _destPos[2], 5.f, .1f);
			EASYOUTE(_loadingPt[3].x, _destPos[3], 5.f, .1f);
			
			if(_loadingPt[0].y == _checkPos[1])
			{
				_loadingPt[1].y = _destPos[1];
				_scrChangeState = SCRCHG_ROLL1;
			}
		}
		else if(_scrChangeState == SCRCHG_ROLL1)
		{
			EASYOUT(_imgLoadingCenter.scaleX, .9f, 5.f);
			_imgLoadingCenter.scaleY = _imgLoadingCenter.scaleX;
			if(_imgLoadingCenter.scaleX < 1.f)
			{
				[_imgLoadingCenter setScale:1.f];
				_scrChangeState = SCRCHG_LOADING;
			}
		}
		else if(_scrChangeState == SCRCHG_LOADING)
		{
			[self refreshScreen];
			_scrChangeState = SCRCHG_ROLL2;
			[SOUNDMGR play:_sfxLoadingOpen];
		}
		else if(_scrChangeState == SCRCHG_ROLL2)
		{
			EASYOUT(_imgLoadingCenter.scaleX, 1.5f, 5.f);
			_imgLoadingCenter.scaleY = _imgLoadingCenter.scaleX;
			
			if(_imgLoadingCenter.scaleX > 1.4f)
			{
				_scrChangeState = SCRCHG_OPEN2;
			}
		}
		else if(_scrChangeState == SCRCHG_OPEN1)
		{
			EASYOUTE(_loadingPt[2].x, _startPos[2], 10.f, .1f);
			EASYOUTE(_loadingPt[3].x, _startPos[3], 10.f, .1f);
			
			if(_loadingPt[2].x < 0.f)
			{
				_scrChangeState = SCRCHG_OPEN2;
				[SOUNDMGR play:_sfxLoadingOpen];
			}
		}
		else if(_scrChangeState == SCRCHG_OPEN2)
		{
//			EASYOUT(_imgLoadingCenter.rotate, 0, 8.f);
			EASYOUT(_imgLoadingCenter.scaleX, 1.5f, 5.f);
			_imgLoadingCenter.scaleY = _imgLoadingCenter.scaleX;

			EASYOUTE(_loadingPt[0].y, _startPos[0], 10.f, .1f);
			EASYOUTE(_loadingPt[1].y, _startPos[1], 10.f, .1f);
			
			EASYOUTE(_loadingPt[2].x, _startPos[2], 10.f, .1f);
			EASYOUTE(_loadingPt[3].x, _startPos[3], 10.f, .1f);
			
			if(_loadingPt[0].y == _startPos[0])
			{
				[_imgLoadingCenter setScale:1.5f];
				[_layerLoading setShow:false];
				_scrChangeState = SCRCHG_END;
			}
		}
		
		[_imgLoading[0] setPosX:_loadingPt[0].x Y:_loadingPt[0].y];
		[_imgLoading[1] setPosX:_loadingPt[1].x Y:_loadingPt[1].y];
		[_imgLoading[2] setPosX:_loadingPt[2].x Y:_loadingPt[2].y];
		[_imgLoading[3] setPosX:_loadingPt[3].x Y:_loadingPt[3].y];
	}

#ifdef _ON_DEBUG_
	double now = CFAbsoluteTimeGetCurrent();
	if(_lastTime == 0) _lastTime = now;
	_frames++;
	
	if(now > _lastTime + .5f)
	{
		char format[16];
		sprintf(format,"%.1f", _frames / (now - _lastTime));
		[_numFPS setText:format];
		
		_frames = 0;
		_lastTime = now;
	}

	[_numDrawCall setNumber:QOBMGR.drawCall];
#endif

	[super tick];
}

- (void)clearAllScreen
{
	if(_uiTitle != nil)			{ [_uiTitle remove];				_uiTitle = nil; }
	if(_uiSelSlot != nil)		{ [_uiSelSlot remove];				_uiSelSlot = nil; }
	if(_uiSelStage != nil)		{ [_uiSelStage remove];				_uiSelStage = nil; }
	
	if(_world != nil && [_world isShow])
	{
		[_world clearAllObject];
		[_world clearTileResMgr];
		[_world setShow:false];
		[_uiGame setShow:false];
	}
	
	[SOUNDMGR setListnerPosX:0 Y:0];
}

- (void)changeScreen:(int)screen
{
	if(_scrChangeState < SCRCHG_OPEN2) return;
	if(screen <= GSCR_BEGIN || screen >= GSCR_END) return;

	_prevScreen = _screen;
	_screen = screen;
	_scrChangeState = SCRCHG_START;
}

- (void)refreshScreen
{
	[self clearAllScreen];
	
	switch(_screen)
	{
		case GSCR_TITLE:			//[self setScreen_Title];				break;
		case GSCR_SELECTSLOT:		//[self setScreen_SelectSlot];		break;
		case GSCR_SELECTSTAGE:		[self setScreen_SelectStage];		break;
		case GSCR_GAME:				[self setScreen_Game];				break;
		case GSCR_CLEARSTAGE:											break;
	}
}

- (void)setScreen_Title
{
	_uiTitle = [[GuiTitle alloc] init];
	[_uiTitle setPosX:_glView.surfaceSize.width/2 Y:_glView.surfaceSize.height/2];
	[self addChild:_uiTitle];
}

- (void)setScreen_SelectSlot
{
	_uiSelSlot = [[GuiSelectSlot alloc] init];
	[self addChild:_uiSelSlot];
}

- (void)setScreen_SelectStage
{
	[GINFO selectSlot:GVAL.selSaveSlot];
	GSLOT->runCount++;
	
	_uiSelStage = [[GuiSelectStage alloc] init];
	[self addChild:_uiSelStage];
}

- (void)setScreen_Game
{
	[_world setShow:true];
	[_uiGame setShow:true];
	
	[_world setStage:GSLOT->stage];
	[_world setPause:false];
	
	[SOUNDMGR playBGM:@"GamePlay.mp3"];
	[SOUNDMGR setBGMVolume:GSLOT->bgmVol];
	[SOUNDMGR setSFXVolume:GSLOT->sfxVol];
}

- (void)setAlertTitle:(NSString *)title Message:(NSString *)msg AlertId:(int)Id CancelBtn:(bool)cancel
{
	_alertId = Id;
	_alertBox = [[UIAlertView  alloc] initWithTitle:title message:msg delegate:self cancelButtonTitle:cancel ? @"Cancel" : nil otherButtonTitles:@"OK", nil];
	[_alertBox show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIdx
{
	if(alertView == _alertBox)
	{
		[alertView release];
		
		if(_alertId == ALERT_DESTROYMACH)
		{
			[self changeScreen:GSCR_TITLE];
		}
		else if(buttonIdx == 1)
		{
			switch(_alertId)
			{
				case ALERT_VISITINDIEAN:
					[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.indieapps.kr"]];
					break;
				case ALERT_DELETESLOT:
					if(_uiSelSlot != nil)
					{
						TSaveSlotData *pData = [GINFO slotData:_uiSelSlot.sel];
						if(pData)
						{
							[GINFO deleteSlot:_uiSelSlot.sel];
							[GINFO saveDataFile];
							
							for(int i = _uiSelSlot.sel; i < MAX_SAVESLOT; i++)
							{
								[_uiSelSlot refreshSlot:i];
							}
							
							[_uiSelSlot setSel:-1];
						}
					}
					break;
			}
		}
		else if(GWORLD != nil)
		{
			[GWORLD setPause:false];
			[_uiGame turnOnButtons];
		}
		
		_alertId = 0;
	}
}	

- (GobWorld *)getWorld
{
	return _world;
}

- (GuiGame *)getGameUI
{
	return _uiGame;
}

- (void)movieFinishedCallBack:(NSNotification *)aNotification
{
	MPMoviePlayerController *movie = [aNotification object];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:movie];
	[movie release];

	[self start];
}

- (void)startIntroMoviePlay
{
	NSString *path = [[NSBundle mainBundle] pathForResource:@"IntroMovie" ofType:@"m4v"];
	MPMoviePlayerController *movie = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL fileURLWithPath:path]];
	movie.scalingMode = MPMovieScalingModeAspectFill;
//	movie.movieControlMode = MPMovieControlModeHidden;
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieFinishedCallBack:) name:MPMoviePlayerPlaybackDidFinishNotification object:movie];
	[movie play];
}

- (void)sendScore:(int)score ToMode:(int)mode
{
}

@end
