#pragma once

#import <UIKit/UIKit.h>
#import "OFCallbackable.h"

@class OFChallengeDefinition;
@class OFDefaultTextField;

@interface SendSampleChallengeController : UIViewController<OFCallbackable, UIPickerViewDataSource, UIPickerViewDelegate>
{
	IBOutlet UIPickerView* challengePicker;
	
	IBOutlet OFDefaultTextField* challengeText;

	IBOutlet OFDefaultTextField* challengeData;
	
	IBOutlet UILabel* newChallengesLabel;
	IBOutlet UILabel* wonChallengesLabel;
	IBOutlet UILabel* sentChallengesLabel;
	NSMutableArray* challengeDefinitions;
	OFChallengeDefinition* selectedChallenge;
}

- (IBAction)sendChallenge;

- (bool)canReceiveCallbacksNow;

@end
