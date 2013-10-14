//
//  DefaultAppDelegate.h
//  MarineBlueHD
//
//  Created by 엔비 on 10. 5. 17..
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>

@class EAGLView;

@interface DefaultAppDelegate : NSObject <UIApplicationDelegate, ADBannerViewDelegate>
{
    UIWindow *window;
    EAGLView *glView;
	UIActivityIndicatorView *_activityIncicator;
	
	UIView *_movieView;
	MPMoviePlayerController *_moviePlayer;
	
//	id displayLink;

	BOOL bannerIsLoading, bannerIsVisible, animating;
	CADisplayLink *displayLink;
}

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) IBOutlet EAGLView *glView;

- (void)initGameMain;

- (void)movieFinishedCallBack:(NSNotification *)aNotification;
- (void)startIntroMoviePlay;

- (void)bannerTurnOn:(ADBannerView *)banner;
- (void)bannerTurnOff:(ADBannerView *)banner;

- (void)onTap:(CGPoint)pt State:(int)state ID:(id)tapID;

@end

