//
//  GameCenterManager.h
//  MachDefense
//
//  Created by HaeJun Byun on 11. 1. 3..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#define GAMECENTER	[GameCenterManager sharedMgr]


@interface GameCenterManager : NSObject
{
	BOOL _isAuth;
}

@property (readonly) BOOL isAuth;

+ (GameCenterManager *)sharedMgr;
- (BOOL)isGameCenterAvailable;
- (void)authenticateLocalPlayer;
- (void)registerForAuthenticationNotification;
- (void)authenticationChanged;
- (void)retrieveFriends;
- (void)loadPlayerData:(NSArray *)identifiers;
- (void)reportScore:(int64_t) score forCategory: (NSString*)category;
- (void)retrieveTopTenScores;
- (void)receiveMatchBestScores:(GKMatch*)match;
- (void)loadCategoryTitles;

@end
