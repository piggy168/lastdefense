#import "SampleRootController.h"

#import "OFControllerLoader.h"
#import "OFViewHelper.h"
#import "OpenFeint.h"

// temp
#import "OFHighScoreService.h"
#import "OFCloudStorageService.h"

@interface SampleRootController ()
	- (bool)canReceiveCallbacksNow;
	- (void)_push:(NSString*)name;
@end

@implementation SampleRootController

- (void) _push:(NSString*)name
{
	[self.navigationController pushViewController:OFControllerLoader::load(name) animated:YES];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	UIScrollView* scroll = OFViewHelper::findFirstScrollView(self.view);
	scroll.contentSize = OFViewHelper::sizeThatFitsTight(self.view);
}

- (IBAction) onLaunchDashboard
{
	[OpenFeint launchDashboard];
	//[OpenFeint launchDashboardWithHighscorePage:@"255819430"];
}

- (IBAction) onExploreChallenges
{
	[self _push:@"SendSampleChallenge"];

}

- (IBAction) onExploreLeaderboards
{
	[self _push:@"SampleLeaderboardList"];
}

- (IBAction) onExploreAchivements
{
	[self _push:@"SampleAchievementList"];
}

- (IBAction) onExploreSocialNetworkPosts
{
	[self _push:@"PostToSocialNetworkSample"];
}

- (IBAction) onExploreCloudStorage
{
	[self _push:@"CloudStorageDemo"];
}

- (bool)canReceiveCallbacksNow
{
	return true;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	const unsigned int numOrientations = 4;
	UIInterfaceOrientation myOrientations[numOrientations] = { UIInterfaceOrientationPortrait, UIInterfaceOrientationPortraitUpsideDown, UIInterfaceOrientationLandscapeLeft, UIInterfaceOrientationLandscapeRight };
	return [OpenFeint shouldAutorotateToInterfaceOrientation:interfaceOrientation withSupportedOrientations:myOrientations andCount:numOrientations];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	[OpenFeint setDashboardOrientation:toInterfaceOrientation];
	[super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

@end
