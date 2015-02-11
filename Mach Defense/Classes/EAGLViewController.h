//
//  EAGLViewController.h
//  MarineBlueHD
//
//  Created by 엔비 on 10. 6. 4..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#if !defined(ANDROID)
@interface EAGLViewController : UIViewController <GKLeaderboardViewControllerDelegate>
{
}
- (void)showLeaderboard;
#else
@interface EAGLViewController : UIViewController
{
}
#endif



@end
