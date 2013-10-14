    //
//  EAGLViewController.m
//  MarineBlueHD
//
//  Created by 엔비 on 10. 6. 4..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "EAGLViewController.h"
#import "EAGLView.h"
#import "GuiGame.h"

extern EAGLView *_glView;

@implementation EAGLViewController

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

- (id)init
{
	[super init];

	return self;
}

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
//	if(interfaceOrientation == UIDeviceOrientationLandscapeLeft|| interfaceOrientation == UIDeviceOrientationLandscapeRight)
//		[_glView setInterfaceOrientation:interfaceOrientation];

	if(interfaceOrientation == UIDeviceOrientationPortrait || interfaceOrientation == UIDeviceOrientationPortraitUpsideDown)
	{
		return YES;
		[_glView setInterfaceOrientation:interfaceOrientation];
	}
		
    return NO;
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)showLeaderboard
{
	GKLeaderboardViewController *leaderboardController = [[GKLeaderboardViewController alloc] init];
	if (leaderboardController != nil)
	{
		leaderboardController.leaderboardDelegate = self;
		[self presentModalViewController: leaderboardController animated: YES];
		
		if(g_main.screen == GSCR_GAME && GWORLD != nil)
		{
			[GWORLD setPause:true];
		}
	}
}

- (void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
	[self dismissModalViewControllerAnimated:YES];

	if(g_main.screen == GSCR_GAME && GWORLD != nil)
	{
		[GWORLD setPause:false];
		[GAMEUI turnOnButtons];
	}
}


- (void)dealloc
{
    [super dealloc];
}


@end
