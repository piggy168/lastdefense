#import "SendSampleChallengeController.h"

#import "OFChallengeDefinition.h"
#import "OFChallengeDefinitionService.h"
#import "OFChallengeDefinitionStats.h"
#import "OFChallengeService+Private.h"
#import "OFChallengeService.h"
#import "OFPaginatedSeries.h"
#import "OFPaginatedSeriesHeader.h"

#import "OFViewHelper.h"
#import "OFDefaultTextField.h"
#import "OpenFeint.h"
#import "OpenFeint+UserOptions.h"
#import "OpenFeint+NSNotification.h"

#import "SampleChallengeData.h"

@implementation SendSampleChallengeController

- (void)_sendChallenge
{
    [challengeText resignFirstResponder];
    
	
	NSData* data = [NSData dataWithBytes:[challengeData.text UTF8String] length:[challengeData.text length]];

	[OFChallengeService 
		displaySendChallengeModal:selectedChallenge.resourceId 
		challengeText:challengeText.text
		challengeData:data];
}

- (void)setNumUnviewedChallenges:(int)numUnviewedChallenges
{
	newChallengesLabel.text = [NSString stringWithFormat:@"New Challenges: %d", numUnviewedChallenges];
}

- (void)_reloadAllData
{
	[self setNumUnviewedChallenges:[OpenFeint unviewedChallengesCount]];
	[challengeDefinitions removeAllObjects];
	
	OFDelegate success(self, @selector(loadedChallenges:));
	OFDelegate failure(self, @selector(failedLoadingChallenges));
	[OFChallengeDefinitionService getIndexOnSuccess:success onFailure:failure];
	
	OFDelegate statsSuccess(self, @selector(loadedStats:));
	OFDelegate statsFailure(self, @selector(failedLoadingStats));
	[OFChallengeDefinitionService getChallengeDefinitionStatsForLocalUser:1
													  clientApplicationId:[OpenFeint clientApplicationId]
																onSuccess:statsSuccess 
																onFailure:statsFailure];
	
	OFDelegate sentSuccess(self, @selector(loadedSentChallenges:));
	OFDelegate sentFailure(self, @selector(failedLoadingSentChallenges));
	[OFChallengeService getSentChallengesForLocalUserAndLocalApplication:1
																		 onSuccess:sentSuccess 
																		 onFailure:sentFailure];
	
}

- (void)loadedChallenges:(OFPaginatedSeries*)loadedChallenges
{
	[challengeDefinitions addObjectsFromArray:loadedChallenges.objects];
	
	[challengePicker reloadAllComponents];
	if ([challengeDefinitions count] > 0)
	{
		selectedChallenge = [(OFChallengeDefinition*)[challengeDefinitions objectAtIndex:0] retain];
	}
}

- (void)failedLoadingChallenges
{
	[[[[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed downloading challenge definitions" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] autorelease] show];
	OFSafeRelease(selectedChallenge);
	[challengeDefinitions removeAllObjects];
}

- (void)loadedStats:(OFPaginatedSeries*)loadedStats
{
	int numWon = 0;
	for (OFChallengeDefinitionStats* stats in loadedStats)
	{
		
		numWon += [stats localUsersWins];
	}
	wonChallengesLabel.text = [NSString stringWithFormat:@"Won Challenges: %d", numWon];
}

- (void)failedLoadingStats
{
	wonChallengesLabel.text = @"Error loading won challenges";
}

- (void)loadedSentChallenges:(OFPaginatedSeries*)loadedSentChallenges
{
	sentChallengesLabel.text = [NSString stringWithFormat:@"Sent Challenges: %d", loadedSentChallenges.header.totalObjects];
}

- (void)failedLoadingSentChallenges
{
	sentChallengesLabel.text = @"Error loading sent challenges";
}

- (void)_unviewedChallengesChanged:(NSNotification*)notice
{
	NSUInteger unviewedChallenges = [(NSNumber*)[[notice userInfo] objectForKey:OFNSNotificationInfoUnviewedChallengeCount] unsignedIntegerValue];
	[self setNumUnviewedChallenges:unviewedChallenges];
}

- (void)awakeFromNib
{
	challengeDefinitions = [[NSMutableArray arrayWithCapacity:10] retain];
	
	challengeText.manageScrollViewOnFocus = YES;
	challengeText.closeKeyboardOnReturn = YES;
	challengeData.manageScrollViewOnFocus = NO;
	challengeData.closeKeyboardOnReturn = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_unviewedChallengesChanged:) name:OFNSNotificationUnviewedChallengeCountChanged object:nil];
	UIScrollView* scrollView = OFViewHelper::findFirstScrollView(self.view);
	scrollView.contentSize = OFViewHelper::sizeThatFitsTight(scrollView);

	[self _reloadAllData];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:OFNSNotificationUnviewedChallengeCountChanged object:nil];
	[super viewWillDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	const unsigned int numOrientations = 4;
	UIInterfaceOrientation myOrientations[numOrientations] = { UIInterfaceOrientationPortrait, UIInterfaceOrientationLandscapeLeft, UIInterfaceOrientationLandscapeRight, UIInterfaceOrientationPortraitUpsideDown };
	return [OpenFeint shouldAutorotateToInterfaceOrientation:interfaceOrientation withSupportedOrientations:myOrientations andCount:numOrientations];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	[OpenFeint setDashboardOrientation:self.interfaceOrientation];
	[super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

- (void)dealloc
{
	OFSafeRelease(challengePicker);

	OFSafeRelease(challengeText);
	OFSafeRelease(challengeData);

	OFSafeRelease(challengeDefinitions);
	OFSafeRelease(selectedChallenge);
	OFSafeRelease(newChallengesLabel);
	OFSafeRelease(wonChallengesLabel);
	OFSafeRelease(sentChallengesLabel);
	[super dealloc];
}

- (IBAction)sendChallenge
{
	if (!selectedChallenge)
		return;
	
	if ([challengeText.text length] == 0)
	{
		[[[[UIAlertView alloc] initWithTitle:@"Problem" message:@"Challenge text must not be (null)" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] autorelease] show];
		return;
	}
	
	if ([OpenFeint hasUserApprovedFeint])
	{
		[self _sendChallenge];
	}
	else
	{
		OFDelegate nilDelegate;
		OFDelegate sendChallengeDelegate(self, @selector(_sendChallenge));
		[OpenFeint presentUserFeintApprovalModal:sendChallengeDelegate deniedDelegate:nilDelegate];
	}
}

- (bool)canReceiveCallbacksNow
{
	return YES;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return challengeDefinitions ? 1 : 0;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	return [challengeDefinitions count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
	if ((NSInteger)[challengeDefinitions count] <= row)
		return @"";
		
	OFChallengeDefinition* challenge = (OFChallengeDefinition*)[challengeDefinitions objectAtIndex:row];
	return challenge.title;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
	NSInteger numDefinitions = (NSInteger)[challengeDefinitions count];
	if (challengeDefinitions && numDefinitions > row && row >= 0)
	{
		selectedChallenge = [(OFChallengeDefinition*)[challengeDefinitions objectAtIndex:row] retain];
	}
	else
	{
		OFSafeRelease(selectedChallenge);
	}
}

@end
