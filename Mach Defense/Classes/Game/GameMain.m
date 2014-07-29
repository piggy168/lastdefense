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
#import "DlgShop.h"
#import "DlgShopSpecial.h"
#import "QobAffecter.h"

GameMain *g_main = nil;
float g_time = 0.0;

@implementation GameMain
@synthesize screen=_screen, loadingImg=_tileLoadingImg;

- (id)init
{
	[super init];
	
    _uiShopMach = nil;
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
    srandom(time(NULL));
	[SOUNDMGR setMaxDistance:800.f];
	
	GINFO;
	_startTime = 0.f;
	
	_layerLoading = [[QobBase alloc] init];
	[_layerLoading setLayer:VLAYER_SYSTEM];
	[_layerLoading setShow:false];
	[self addChild:_layerLoading];
	
	Tile2D *tile;
	tile = [TILEMGR getTile:@"loading_screen01.png"];
    [tile setForRetina:YES];
	_imgLoading[0] = [[QobImage alloc] initWithTile:tile tileNo:0];
    if(_glView.deviceType != DEVICE_IPAD) [_imgLoading[0] setScale:1.f];
    else [_imgLoading[0] setScale:0.5f];
    [_imgLoading[0] setBlendType:BT_ALPHA];
	[_imgLoading[0] setLayer:VLAYER_SYSTEM];
	[_layerLoading addChild:_imgLoading[0]];
    [_imgLoading[0] setPosX:168 Y:260];
	
	tile = [TILEMGR getTile:@"loading_screen02.png"];
    [tile setForRetina:YES];
	_imgLoading[1] = [[QobImage alloc] initWithTile:tile tileNo:0];
    if(_glView.deviceType != DEVICE_IPAD) [_imgLoading[1] setScale:1.f];
    else [_imgLoading[1] setScale:0.5f];
    [_imgLoading[1] setBlendType:BT_ALPHA];
	[_imgLoading[1] setLayer:VLAYER_SYSTEM];
	[_layerLoading addChild:_imgLoading[1]];
    [_imgLoading[1] setPosX:168 Y:260];
	
	tile = [TILEMGR getTile:@"NowLoading.png"];
    [tile setForRetina:YES];
	_imgLoadingCenter = [[QobImage alloc] initWithTile:tile tileNo:0];
	if(_glView.deviceType == DEVICE_IPAD) [_imgLoadingCenter setPosX:_glView.surfaceSize.width/2 Y:168];
	else [_imgLoadingCenter setPosX:160 Y:200];
    [_imgLoadingCenter setBlendType:BT_ALPHA];
	[_imgLoadingCenter setLayer:VLAYER_SYSTEM];
	[_layerLoading addChild:_imgLoadingCenter];
	
	//_sfxLoadingOpen = [SOUNDMGR getSound:@"Loading_Open.wav"];
	//_sfxLoadingClose = [SOUNDMGR getSound:@"Loading_Close.wav"];
	
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
            _loading_alpha = 1.0f;
            [_imgLoading[0] setAlpha:_loading_alpha];
            [_imgLoading[1] setAlpha:_loading_alpha];
            [_imgLoadingCenter setAlpha:_loading_alpha];
			[_layerLoading setShow:true];
						
			_scrChangeState = SCRCHG_OPEN1;
//			[SOUNDMGR play:_sfxLoadingClose];
		}
        else if(_scrChangeState == SCRCHG_OPEN1)
        {
            [self refreshScreen];
            _scrChangeState = SCRCHG_CLOSE1;
        }
        else if(_scrChangeState == SCRCHG_CLOSE1)
        {
            if (_loading_alpha) _loading_alpha *= 0.9f;
            [_imgLoading[0] setAlpha:_loading_alpha];
            [_imgLoading[1] setAlpha:_loading_alpha];
            [_imgLoadingCenter setAlpha:_loading_alpha];
            
            if(_loading_alpha <= 0.05f) _scrChangeState = SCRCHG_OPEN2;
        }
        else
        {
            [_layerLoading setShow:false];
            _scrChangeState = SCRCHG_END;
        }
	}

//#ifdef _ON_DEBUG_
//	double now = CFAbsoluteTimeGetCurrent();
//	if(_lastTime == 0) _lastTime = now;
//	_frames++;
//	
//	if(now > _lastTime + .5f)
//	{
//		char format[16];
//		sprintf(format,"%.1f", _frames / (now - _lastTime));
//		[_numFPS setText:format];
//		
//		_frames = 0;
//		_lastTime = now;
//	}
//
//	[_numDrawCall setNumber:QOBMGR.drawCall];
//#endif

	[super tick];
}

- (void)clearAllScreen
{
	if(_uiTitle != nil)			{ [_uiTitle remove];				_uiTitle = nil; }
	if(_uiSelSlot != nil)		{ [_uiSelSlot remove];				_uiSelSlot = nil; }
	if(_uiSelStage != nil)		{ [_uiSelStage remove];				_uiSelStage = nil; }
    if(_uiShopMach != nil)
    {
        [_uiShopMach remove];
        _uiShopMach = nil;
    }
    
    if(_uiShopSpecial != nil)
    {
        [_uiShopSpecial remove];
        _uiShopSpecial = nil;
    }
	
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
    
    if(random()%2==0)
    {
        [_imgLoading[1] setShow:true];
        if(_glView.deviceType == DEVICE_IPAD) [_imgLoadingCenter setPosX:_glView.surfaceSize.width/2 Y:168];
        else [_imgLoadingCenter setPosX:160 Y:200];
    }
    else
    {
        [_imgLoading[1] setShow:false];
        if(_glView.deviceType == DEVICE_IPAD) [_imgLoadingCenter setPosX:_glView.surfaceSize.width/2 Y:168];
        else [_imgLoadingCenter setPosX:160 Y:320];
    }

	_screen = screen;
	_scrChangeState = SCRCHG_START;
}

- (void)makeScreen:(int)screen
{
    _screen = screen;
    [self refreshScreen];
    _prevScreen = _screen;
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
        case GSCR_SHOPMACH:			[self setScreen_Shop:GSCR_SHOPMACH];			break;
        case GSCR_SHOPSPECIAL:      [self setScreen_Shop:GSCR_SHOPSPECIAL];         break;
	}
}

- (void)setScreen_Shop:(int)type
{
    if(type == _prevScreen) return;
    
    if(_uiShopMach)
    {
        [_uiShopMach remove];
        _uiShopMach = nil;
    }
    
    if(_uiShopSpecial)
    {
        [_uiShopSpecial remove];
        _uiShopSpecial = nil;
    }
    
    if(type == GSCR_SHOPMACH)
    {
        _uiShopMach = [[DlgShop alloc] init];
        [_uiShopMach setPosX:_glView.surfaceSize.width/2 Y:_glView.surfaceSize.height/2];
        [self addChild:_uiShopMach];
        //[_uiShopMach release];
    }
    else if(type == GSCR_SHOPSPECIAL)
    {
        _uiShopSpecial = [[DlgShopSpecial alloc] init];
        [_uiShopSpecial setPosX:_glView.surfaceSize.width/2 Y:_glView.surfaceSize.height/2];
        [self addChild:_uiShopSpecial];
        //[_uiShopSpecial release];
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
