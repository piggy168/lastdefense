//
//  DefaultAppDelegate.m
//  MarineBlueHD
//
//  Created by 엔비 on 10. 5. 17..
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "TestFlight.h"

#import "DefaultAppDelegate.h"
#import "EAGLView.h"
#import "QobAffecter.h"

DefaultAppDelegate *_appDelegate = nil;

@interface DefaultAppDelegate()
- (void) renderScene;
@end

@implementation DefaultAppDelegate

@synthesize window;
@synthesize glView;

- (void)startAnimation
{
    if(!animating)
	{
        CADisplayLink *aDisplayLink;
		aDisplayLink = [[UIScreen mainScreen] displayLinkWithTarget:self selector:@selector(renderScene)];
        [aDisplayLink setFrameInterval:1.f];
        [aDisplayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        displayLink = aDisplayLink;
        
        animating = TRUE;
    }
}

- (void)stopAnimation
{
    if(animating)
	{
        [displayLink invalidate];
        displayLink = nil;
        animating = FALSE;
    }
}

- (void)applicationDidFinishLaunching:(UIApplication *)application
{
#ifdef ANDROID
//    [UIScreen mainScreen].currentMode =
//    [UIScreenMode emulatedMode:UIScreenIPhone3GEmulationMode];
    
    [UIScreen mainScreen].currentMode =
    [UIScreenMode emulatedMode:UIScreenIPhone4EmulationMode];
#endif
    //[TestFlight setDeviceIdentifier:[[UIDevice currentDevice] uniqueIdentifier]];
    [TestFlight takeOff:@"c1a04021-c218-42f3-b16a-c7eb0e1d7570"];
    
	CGRect rect = [[UIScreen mainScreen] bounds];
    NSLog(@"rect %.0f %.0f",rect.size.width, rect.size.height);
    
   // rect = CGRectMake(0, 0, 640, 960);
    
    [glView createViewController:rect.size];
    
    window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];//CGRectMake(0, 0, 640, 960) ];//
    [window addSubview:glView];
    [window makeKeyAndVisible];
    //[window setAutoresizesSubviews:YES];
//    [window sizeThatFits:CGSizeMake(640, 960)];
//    window.center = CGPointMake(320, 480);
    
	//Set up OpenGL projection matrix
    glViewport(0, 0, 640,960);//rect.size.width, rect.size.height);
	glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
	glOrthof(0, rect.size.width, 0, rect.size.height, -1, 1);
	glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
	
	glEnable(GL_BLEND);
	glEnable(GL_TEXTURE_2D);
	glEnableClientState(GL_COLOR_ARRAY);
	glEnableClientState(GL_VERTEX_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);

	glClearColor(1.f, 1.f, 1.f, 1.f);

	[glView setBackgroundColor:[UIColor whiteColor]];
	
	_appDelegate = self;
	
	[self initGameMain];
}

- (void)initGameMain
{
	glClearColor(0.f, 0.f, 0.f, 1.f);

	Tile2D *tile = [TILEMGR getUniTile:@"Title_Main.png"];
	[tile tileSplitX:1 splitY:1];
	[tile drawTile:0 x:_glView.surfaceSize.width/2 y:_glView.surfaceSize.height/2];
	
	tile = [TILEMGR getTileForRetina:@"NowLoading.png"];
	[tile tileSplitX:1 splitY:1];
	[tile drawTile:0 x:_glView.surfaceSize.width * .75f y:_glView.deviceType == DEVICE_IPAD ? 48 : 24];
	
	[glView swapBuffers];

/*	NSString *reqSysVer = @"3.1";
	NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
	if ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending)
	{
		displayLink = [NSClassFromString(@"CADisplayLink") displayLinkWithTarget:self selector:@selector(renderScene)];
		[displayLink setFrameInterval:1];
		[displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	}
	else
	{
		[NSTimer scheduledTimerWithTimeInterval:TICK_INTERVAL target:self selector:@selector(renderScene) userInfo:nil repeats:YES];
	}*/

	g_main = [GameMain alloc];
	[g_main init];
	
/*	Tile2D *tile = [TILEMGR getTile:@"IndieAppsLogo.png"];
	[tile tileSplitX:1 splitY:1];
	QobImage *img = [[QobImage alloc] initWithTile:tile tileNo:0];
	[img setPosX:384 Y:512];
	[img setLayer:VLAYER_SYSTEM];
	[g_main addChild:img];
	QobAffecter *fadeOut = [[QobAffecter alloc] init];
	[fadeOut setFadeOut:1.f];
	[img addChild:fadeOut];*/
	
	[self startAnimation];
}

- (void)movieFinishedCallBack:(NSNotification *)aNotification
{
	glClearColor(0.f, 0.f, 0.f, 1.f);

//	glClear(GL_COLOR_BUFFER_BIT);
	Tile2D *tile = [TILEMGR getUniTile:@"Title_Main.png"];
	[tile tileSplitX:1 splitY:1];
	[tile drawTile:0 x:_glView.surfaceSize.width/2 y:_glView.surfaceSize.height/2];
	
	tile = [TILEMGR getTileForRetina:@"NowLoading.png"];
	[tile tileSplitX:1 splitY:1];
	[tile drawTile:0 x:_glView.surfaceSize.width * .75f y:_glView.deviceType == DEVICE_IPAD ? 48 : 24];
	
	[glView swapBuffers];

	MPMoviePlayerController *player = [aNotification object];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:player];
	
	player.controlStyle = MPMovieControlStyleFullscreen;
	[player stop];
	[player autorelease];
	[_movieView removeFromSuperview];
	
	[self initGameMain];
}

- (void)startIntroMoviePlay
{
	NSString *introFile = @"LogoIntro_480";
	if(glView.deviceType == DEVICE_IPAD) introFile = @"LogoIntro_1024";
	else if(glView.deviceType == DEVICE_IPHONE_RETINA) introFile = @"LogoIntro_960";
	else if(glView.deviceType == DEVICE_IPHONE) introFile = @"LogoIntro_480";

	NSString *url = [[NSBundle mainBundle] pathForResource:introFile ofType:@"mov"];
    MPMoviePlayerViewController *playerViewController = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL fileURLWithPath:url]];
    _moviePlayer = [playerViewController moviePlayer];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieFinishedCallBack:) name:MPMoviePlayerPlaybackDidFinishNotification object:_moviePlayer];
	_movieView = playerViewController.view;
//	_movieView.frame = CGRectMake(0, 0, 1024, 768);
//	[_movieView setCenter:CGPointMake(384, 512)];
//	_movieView.transform = CGAffineTransformRotate(playerViewController.view.transform, M_PI/2.f);
    [glView addSubview:_movieView];

	[_moviePlayer.backgroundView setBackgroundColor:[UIColor whiteColor]];
	_moviePlayer.controlStyle = MPMovieControlStyleNone;

    [_moviePlayer play];

	[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
}

- (void)renderScene
{
	glClear(GL_COLOR_BUFFER_BIT);
	
	g_time += TICK_INTERVAL;

	[g_main tick];
	[QOBMGR drawVisual];

	[glView swapBuffers];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
//	[SOUNDMGR setPause];
//	if(g_main != nil && g_main.screen == GSCR_GAME) [GWORLD setPause:true];
	[self stopAnimation];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
/*	if(g_main != nil)
	{
		[SOUNDMGR init];
		[SOUNDMGR setMaxDistance:800.f];
		
		[GINFO loadSFX];
		[GINFO restoreWeaponSound];
		
		if(g_main.screen == GSCR_GAME)
		{
			[SOUNDMGR playBGM:@"GamePlay.mp3"];
			[SOUNDMGR setBGMVolume:GSLOT->bgmVol];
			[SOUNDMGR setSFXVolume:GSLOT->sfxVol];
			
			[GWORLD setPause:false];
		}
		else
		{
			[SOUNDMGR playBGM:@"Intro.mp3"];
		}
	}*/
	[self startAnimation];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
//	[SOUNDMGR setBackground];
	[self stopAnimation];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)bannerTurnOn:(ADBannerView *)banner
{

}

- (void)bannerTurnOff:(ADBannerView *)banner
{
}


- (void)dealloc
{
	NSLog(@"AppDelegate Dealloc");
	
	[displayLink invalidate];
	displayLink = nil;

	[g_main release];
	[window release];
	[glView release];
	
	[super dealloc];
}

- (void)onTap:(CGPoint)pt State:(int)state ID:(id)tapID
{
	float tmp = pt.x;
	switch(glView.interfaceOrientation)
	{
		case UIInterfaceOrientationLandscapeRight:
			pt.x = glView.surfaceSize.height - pt.y;
			pt.y = tmp;
			break;
		case UIInterfaceOrientationLandscapeLeft:
			pt.x = pt.y;
			pt.y = glView.surfaceSize.width - tmp;
			break;
	}
	
	if(g_main != nil) [QOBMGR onTap:pt State:state ID:tapID];
	else [[NSNotificationCenter defaultCenter] postNotificationName:MPMoviePlayerPlaybackDidFinishNotification object:_moviePlayer];
}

@end
