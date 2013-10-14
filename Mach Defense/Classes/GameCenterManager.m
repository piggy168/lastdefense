//
//  GameCenterManager.m
//  MachDefense
//
//  Created by HaeJun Byun on 11. 1. 3..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GameCenterManager.h"


@implementation GameCenterManager
static GameCenterManager *_sharedMgr = nil;

@synthesize isAuth=_isAuth;

+ (GameCenterManager *)sharedMgr
{
	@synchronized(self)
	{
		if(!_sharedMgr)
		{
			_sharedMgr = [GameCenterManager alloc];
			[_sharedMgr init];
		}
		return _sharedMgr;
	}
	
	return nil;
}

- (BOOL)isGameCenterAvailable
{
	// Check for presence of GKLocalPlayer API.
	Class gcClass = (NSClassFromString(@"GKLocalPlayer"));
	
	// The device must be running running iOS 4.1 or later.
	NSString *reqSysVer = @"4.1";
	NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
	BOOL osVersionSupported = ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending);
	
	return (gcClass && osVersionSupported);
}

- (void)authenticateLocalPlayer
{
	[[GKLocalPlayer localPlayer] authenticateWithCompletionHandler:^(NSError *error)
	 {
		 if(error == nil)
		 {
			 // Insert code here to handle a successful authentication.
		 }
		 else
		 {
			 // Your application can process the error parameter to report the error to the player.
		 }
	 }];
}

- (void)registerForAuthenticationNotification
{
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc addObserver: self selector:@selector(authenticationChanged) name:GKPlayerAuthenticationDidChangeNotificationName object:nil];
}

- (void)authenticationChanged
{
    if([GKLocalPlayer localPlayer].isAuthenticated)
	{
        // Insert code here to handle a successful authentication.
		_isAuth = YES;
	}
	else
	{
		// Insert code here to clean up any outstanding Game Center-related classes.
		_isAuth = NO;
	}
}

- (void)retrieveFriends
{
	GKLocalPlayer *lp = [GKLocalPlayer localPlayer];
	if(lp.authenticated)
	{
		[lp loadFriendsWithCompletionHandler:^(NSArray *friends, NSError *error)
		 {
			 if (error == nil)
			 {
				 // use the player identifiers to create player objects.
			 }
			 else
			 {
				 // report an error to the user.
			 }
		 }];
	}
}

- (void)loadPlayerData:(NSArray *)identifiers
{
	[GKPlayer loadPlayersForIdentifiers:identifiers withCompletionHandler:^(NSArray *players, NSError *error)
	 {
		 if (error != nil)
		 {
			 // Handle the error.
		 }
		 if (players != nil)
		 {
			 // Process the array of GKPlayer objects.
		 }
	 }];
}

- (void)reportScore:(int64_t)score forCategory:(NSString*)category
{
	GKScore *scoreReporter = [[[GKScore alloc] initWithCategory:category] autorelease];
	scoreReporter.value = score;
	
	[scoreReporter reportScoreWithCompletionHandler:^(NSError *error)
	 {
		 if(error != nil)
		 {
			 // handle the reporting error
		 }
	 }];
}

- (void)retrieveTopTenScores
{
	GKLeaderboard *leaderboardRequest = [[GKLeaderboard alloc] init];
	if (leaderboardRequest != nil)
	{
		leaderboardRequest.playerScope = GKLeaderboardPlayerScopeGlobal;
		leaderboardRequest.timeScope = GKLeaderboardTimeScopeAllTime;
		leaderboardRequest.range = NSMakeRange(1,10);
		[leaderboardRequest loadScoresWithCompletionHandler: ^(NSArray *scores, NSError *error) {
			if (error != nil)
			{
				// handle the error.
			}
			if (scores != nil)
			{
				// process the score information.
			}
		}];
	}
}

- (void)receiveMatchBestScores:(GKMatch*) match
{
	GKLeaderboard *query = [[GKLeaderboard alloc] initWithPlayerIDs: match.playerIDs];
	if (query != nil)
	{
		[query loadScoresWithCompletionHandler: ^(NSArray *scores, NSError *error) {
			if (error != nil)
			{
				// handle the error.
			}
			if (scores != nil)
			{
				// process the score information.
			}
		}];
	}
}

- (void)loadCategoryTitles
{
	[GKLeaderboard loadCategoriesWithCompletionHandler:^(NSArray *categories, NSArray *titles, NSError *error)
	{
		if (error != nil)
		{
			// handle the error
		}
		else
		{
			// use the category and title information
		}
	}];
}

@end
