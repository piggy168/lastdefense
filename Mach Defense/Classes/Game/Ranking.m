//
//  Ranking.m
//  HeavyMach2
//
//  Created by 엔비 on 10. 2. 25..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Ranking.h"
#import "cocoslive.h"
#import "ccMacros.h"
#import "GuiCommandCenter.h"

@implementation Ranking

- (void)requestScore:(int)offset
{
	_offset = offset;
	CLScoreServerRequest *req = [[CLScoreServerRequest alloc] initWithGameName:GAME_NAME delegate:self];
	[req requestScores:kQueryAllTime limit:7 offset:offset flags:kQueryFlagIgnore category:@"EXP"];
	[req release];
}

- (void)scoreRequestOk:(id)sender
{
	NSArray *score = [sender parseScores];
	_globalScore = [NSMutableArray arrayWithArray:score];
	
	[g_main.uiCmdCenter refreshRanking:_globalScore Offset:_offset];
}

- (void)scoreRequestFail:(id)sender
{
	NSLog(@"ScoreRequestFail");
}

- (void)requestRankForScore:(int)score;
{
	CLScoreServerRequest *req = [[CLScoreServerRequest alloc] initWithGameName:GAME_NAME delegate:self];
	[req requestRankForScore:score andCategory:@"EXP"];
	[req release];
}

- (void)scoreRequestRankOk:(id)sender
{
	int rank = [sender parseRank];
	[g_main.uiCmdCenter refreshMyRanking:rank];
}

- (void)postScore
{
	if(GSLOT == NULL || strcmp(GSLOT->name, "GimmeCr") == 0) return;
	
	CLScoreServerPost *post = [[CLScoreServerPost alloc] initWithGameName:GAME_NAME gameKey:GAME_KEY delegate:self];
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:2];
	
	[dict setObject:@"EXP" forKey:@"cc_category"];
	[dict setObject:[NSNumber numberWithInt:GSLOT->exp/10] forKey:@"cc_score"];
	[dict setObject:[NSNumber numberWithInt:GSLOT->level+1] forKey:@"usr_level"];
	[dict setObject:[NSString stringWithUTF8String:GSLOT->name] forKey:@"cc_playername"];
//	[dict setObject:[NSString stringWithUTF8String:GSLOT->country] forKey:@"cc_country"];
	[dict setObject:[NSNumber numberWithFloat:(float)GSLOT->completeCnt*100.f/(float)GSLOT->missionCnt] forKey:@"usr_mission"];
	
	TInvenItem *item;
	item = [GINFO.inven getItemFromPos:GSLOT->equip[EQUIP_BODY]];
	if(item != nil) [dict setObject:item->info.code forKey:@"usr_parts_body"];
	item = [GINFO.inven getItemFromPos:GSLOT->equip[EQUIP_FOOT]];
	if(item != nil) [dict setObject:item->info.code forKey:@"usr_parts_foot"];
	item = [GINFO.inven getItemFromPos:GSLOT->equip[EQUIP_WPN_L]];
	if(item != nil) [dict setObject:item->info.code forKey:@"usr_parts_wpnL"];
	item = [GINFO.inven getItemFromPos:GSLOT->equip[EQUIP_WPN_R]];
	if(item != nil) [dict setObject:item->info.code forKey:@"usr_parts_wpnR"];

	[post updateScore:dict];
	[post release];
}

- (void)scorePostOk:(id)sender
{
	NSLog(@"ScorePostOK");
}

- (void)scorePostFail:(id)sender
{
	NSLog(@"ScorePostFail");
}

@end
