//
//  GameMain.h
//  Jumping!
//
//  Created by 엔비 on 08. 09. 15.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@class QobBase;
@class QobButton;
@class QobImage;
@class QobParticle;
@class GobWorld;
@class GobHvMach;
@class GobHvM_Player;
@class GuiTitle;
@class GuiSelectSlot;
@class GuiSelectStage;
@class GuiGame;
@class DlgShop;
@class DlgShopSpecial;

#define GWORLD [g_main getWorld]
#define GAMEUI [g_main getGameUI]
#define QUICKSLOT [GAMEUI quickSlot]

enum EGameScreen
{
	GSCR_BEGIN,
	GSCR_TITLE, GSCR_SELECTSLOT, GSCR_SELECTSTAGE, GSCR_GAME, GSCR_CLEARSTAGE,
    GSCR_SHOPMACH,GSCR_SHOPSPECIAL,
	GSCR_END
};

enum EScreenChange
{
	SCRCHG_START, SCRCHG_CLOSE1, SCRCHG_CLOSE2, SCRCHG_ROLL1, SCRCHG_LOADING, SCRCHG_ROLL2, SCRCHG_OPEN1, SCRCHG_OPEN2, SCRCHG_END
};

/*enum EScreenChange
{
	SCRCHG_START, SCRCHG_FADEOUT, SCRCHG_LOADING, SCRCHG_FADEIN, SCRCHG_END
};*/

enum EAlertID
{
	ALERT_VISITINDIEAN,
	ALERT_DELETESLOT,
	ALERT_DESTROYMACH,
};

@class QobImageFont;

@interface GameMain : QobBase
{
	int _screen;
	int _prevScreen;
	int _scrChangeState;
	
	QobImageFont *_numDrawCall, *_numFPS;

	GobWorld *_world;
	GuiGame *_uiGame;
	GuiTitle *_uiTitle;
	GuiSelectSlot *_uiSelSlot;
	GuiSelectStage *_uiSelStage;
    DlgShop *_uiShopMach;
    DlgShopSpecial *_uiShopSpecial;
	
	QobBase *_layerLoading;
	Tile2D *_tileLoadingImg;
	QobImage *_imgLoading[2];
	QobImage *_imgLoadingCenter;
//	QobImage *_imgLoadingL;
//	QobImage *_imgLoadingR;
//	CGPoint _loadingPt[4];
//	float _startPos[4], _destPos[4], _checkPos[2];
	UInt32 _sfxLoadingOpen;
	UInt32 _sfxLoadingClose;

	UIAlertView *_alertBox;
	int _alertId;
	
	double _startTime;
	double _lastTime;
	int _frames;
    float _loading_alpha;
}

@property(readonly) int screen;
@property(readonly) Tile2D *loadingImg;

- (void)start;

- (void)changeScreen:(int)screen;
- (void)clearAllScreen;
- (void)refreshScreen;
- (void)makeScreen:(int)screen;
- (void)setScreen_Title;
- (void)setScreen_SelectSlot;
- (void)setScreen_SelectStage;
- (void)setScreen_Game;
- (void)setScreen_Shop:(int)type;

- (void)setAlertTitle:(NSString *)title Message:(NSString *)msg AlertId:(int)Id CancelBtn:(bool)cancel;

- (GobWorld *)getWorld;
- (GuiGame *)getGameUI;

- (void)movieFinishedCallBack:(NSNotification *)aNotification;
- (void)startIntroMoviePlay;

- (void)sendScore:(int)score ToMode:(int)mode;

@end
