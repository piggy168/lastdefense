//
//  DlgSummery.m
//  MACHDEFENSE
//
//  Created by HaeJun Byun on 10. 11. 4..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "DlgSummary.h"
#import "DlgBuildMach.h"
#import "DlgSpecialAttack.h"
#import "SpAttackSet.h"
#import "GuiGame.h"

@implementation DlgSummary

- (id)initWithClear:(bool)clear
{
	Tile2D *tile;
	QobButton *btn;
	
	if(clear && GSLOT->stage < 69)
	{
		[super initWithCommonImg:@"CommonUI" TopImg:@"StageClear" Height:320 * GWORLD.deviceScale];
		
		tile = [TILEMGR getTileForRetina:@"SummaryBtn_NextStage.png"];
		[tile tileSplitX:1 splitY:4];
		btn = [self addButton:tile ID:BTNID_STAGECLEAR_NEXT];
		[btn setDeactiveTileNo:2];
	}
	else
	{
		[super initWithCommonImg:@"CommonUI" TopImg:@"Defeat" Height:512 * GWORLD.deviceScale];
		
		tile = [TILEMGR getTileForRetina:@"SummaryBtn_Retry.png"];
		[tile tileSplitX:1 splitY:4];
		btn = [self addButton:tile ID:BTNID_STAGECLEAR_RETRY];
		[btn setDeactiveTileNo:2];
	}
	
	tile = [TILEMGR getTileForRetina:@"SummaryBtn_SelectStage.png"];
	[tile tileSplitX:1 splitY:4];
	btn = [self addButton:tile ID:BTNID_STAGECLEAR_BACK];
	[btn setDeactiveTileNo:2];
	
	tile = [TILEMGR getTileForRetina:@"SummaryBtn_LeaderBoard.png"];
	[tile tileSplitX:1 splitY:4];
	btn = [self addButton:tile ID:BTNID_LEADERBOARD];
	[btn setDeactiveTileNo:2];

	QobText *text = [[QobText alloc] initWithString:[NSString stringWithFormat:@"%@ : %d", [GINFO getDescription:@"KillCount"], GVAL.killEnemies] Size:CGSizeMake(512, 32) Align:UITextAlignmentCenter Font:@"TrebuchetMS-Bold" FontSize:16 Retina:true];
	[text setColorR:160 G:255 B:255];
	[text setPosX:0 Y:-80 * GWORLD.deviceScale];
	[_bgTop addChild:text];
	
	text = [[QobText alloc] initWithString:[NSString stringWithFormat:@"%@ : %d", [GINFO getDescription:@"DeadCount"], GVAL.deadMachs] Size:CGSizeMake(512, 32) Align:UITextAlignmentCenter Font:@"TrebuchetMS-Bold" FontSize:16 Retina:true];
	[text setColorR:160 G:255 B:255];
	[text setPosX:0 Y:-100 * GWORLD.deviceScale];
	[_bgTop addChild:text];
	
	float playTime = GWORLD.time - GWORLD.stageStartTime;
	text = [[QobText alloc] initWithString:[NSString stringWithFormat:@"Play Time : %d' %02d\"", (int)(playTime / 60), (int)playTime % 60] Size:CGSizeMake(512, 32) Align:UITextAlignmentCenter Font:@"TrebuchetMS-Bold" FontSize:16 Retina:true];
	[text setColorR:160 G:255 B:255];
	[text setPosX:0 Y:-120 * GWORLD.deviceScale];
	[_bgTop addChild:text];
	
	if(clear)
	{
		text = [[QobText alloc] initWithString:@"Stage Clear Bonus!" Size:CGSizeMake(512, 32) Align:UITextAlignmentCenter Font:@"TrebuchetMS-Bold" FontSize:24 Retina:true];
		[text setColorR:160 G:255 B:255];
		[text setPosX:0 Y:-160 * GWORLD.deviceScale];
		[_bgTop addChild:text];
		
		int bonus = 500 + GSLOT->stage * 25;
		text = [[QobText alloc] initWithString:[NSString stringWithFormat:@"%d cr", bonus] Size:CGSizeMake(512, 32) Align:UITextAlignmentCenter Font:@"TrebuchetMS-Bold" FontSize:24 Retina:true];
		[text setColorR:255 G:100 B:100];
		[text setPosX:0 Y:-185 * GWORLD.deviceScale];
		[_bgTop addChild:text];
		
		GSLOT->cr += bonus;
		if(GSLOT->stageClearCount[GSLOT->stage] < 1) GSLOT->score += (GSLOT->stage + 1) * 1000;
		
		if(GSLOT->stageClearCount[GSLOT->stage] < 1 && RANDOM(40) < 10)
		{
			if([self addNewMach] == false) [self addNewItem];
		}
		else
		{
			[self addNewItem];
		}
		
		GSLOT->stageClearCount[GSLOT->stage]++;
		
		GSLOT->stage++;
		if(GSLOT->stage > 69) GSLOT->stage = 69;
		if(GSLOT->lastStage < GSLOT->stage) GSLOT->lastStage = GSLOT->stage;
	}

	[GINFO saveDataFile];
	if(strcmp(GSLOT->name, "GimmeCr") != 0) [GAMECENTER reportScore:GSLOT->score forCategory:@"HIGHSCORE"];

	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:self selector:@selector(handleButton:) name:@"PushButton" object:nil];
	[nc addObserver:self selector:@selector(handleButton:) name:@"ReleaseButton" object:nil];
	[nc addObserver:self selector:@selector(handleButton:) name:@"PopButton" object:nil];

	return self;
}

- (void)dealloc
{
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc removeObserver:self];
	
	[super dealloc];
}

- (bool)addNewMach
{
	bool ret = false;
	NSString *buildsetName[64];
	int buildsetRate[64], buildsetCount = 0;
	int rateSum = 0, rndSeed;
	QTable *table = [[QTable alloc] initWithFile:[[NSBundle mainBundle] pathForResource:@"MachRegen" ofType:@"tble"]];
	for(int i = 0; i < table.row; i++)
	{
		NSString *machName = [table getString:i Key:@"MachName"];
		if(![GINFO existBuyBuildSet:machName])
		{
			rateSum += [table getInt:i Key:@"Rate"];
			buildsetName[buildsetCount] = machName;
			buildsetRate[buildsetCount] = rateSum;
			buildsetCount++;
		}
	}
	
	if(buildsetCount > 0)
	{
		QobText *text = [[QobText alloc] initWithString:@"You've got a new Mach." Size:CGSizeMake(512, 32) Align:UITextAlignmentCenter Font:@"TrebuchetMS-Bold" FontSize:24 Retina:true];
		[text setColorR:160 G:255 B:255];
		[text setPosX:0 Y:-220 * GWORLD.deviceScale];
		[_bgTop addChild:text];
		
		rndSeed = RANDOM(rateSum);
		for(int i = 0; i < buildsetCount; i++)
		{
			if(rndSeed < buildsetRate[i])
			{
				buildsetCount = 0;
				MachBuildSet *mach = [GINFO buyBuildSet:buildsetName[i]];
				if(GAMEUI.dlgBuildMach.buildBtnCnt < 7) mach.onSlot = true;

				QobImage *img = [[QobImage alloc] initWithTile:[mach machTile] tileNo:0];
				[img setUseAtlas:true];
				[img setPosX:-80 * GWORLD.deviceScale Y:-270 * GWORLD.deviceScale];
				[_bgTop addChild:img];
				
				text = [[QobText alloc] initWithString:buildsetName[i] Size:CGSizeMake(256, 32) Align:UITextAlignmentLeft Font:@"TrebuchetMS-Bold" FontSize:20 Retina:true];
				[text setColorR:255 G:100 B:100];
				[text setPosX:120 * GWORLD.deviceScale Y:-270 * GWORLD.deviceScale];
				[_bgTop addChild:text];
			}
		}
		
		ret = true;
	}

	[table release];
	
	return ret;
}

- (void)addNewItem
{
	NSString *newItem[5] = {@"AirStrike-Bomb", @"AirStrike-Missile", @"AirStrike-Nuclear", @"AirStrike-EMP", @"Crossfire-Missile"};
	
/*	QobText *text = [[QobText alloc] initWithString:@"You've got a new Special Attack." Size:CGSizeMake(512, 32) Align:UITextAlignmentCenter Font:@"Copperplate-Bold" FontSize:24];
	[text setColorR:160 G:255 B:255];
	[text setPosX:0 Y:-220];
	[_bgTop addChild:text];
*/
	int rnd = RANDOM(5), cnt = RANDOM(4) + 1;
	QobText *text = [[QobText alloc] initWithString:newItem[rnd] Size:CGSizeMake(512, 32) Align:UITextAlignmentCenter Font:@"TrebuchetMS-Bold" FontSize:20 Retina:true];
	[text setColorR:255 G:100 B:100];
	[text setPosX:0 Y:-310 * GWORLD.deviceScale];
	[_bgTop addChild:text];
	
	SpAttackSet *attack = [GINFO buyAttackSet:newItem[rnd] Count:cnt];
	if(GAMEUI.dlgSpAttack.buildBtnCnt < 7) attack.onSlot = true;

	TSpAttackSet *set = [attack attackSet];
	float pos = -cnt * 40 + 40;
	for(; cnt > 0; cnt--)
	{
		Tile2D *tile = [TILEMGR getTileForRetina:[NSString stringWithFormat:@"Icon%05d.png", set->itemId]];
		[tile tileSplitX:1 splitY:1];
		QobImage *img = [[QobImage alloc] initWithTile:tile tileNo:0];
		[img setPosX:pos * GWORLD.deviceScale Y:-260 * GWORLD.deviceScale];
		[_bgTop addChild:img];
		
		pos += 80;
	}

}

- (void)handleButton:(NSNotification *)note
{
	if(![self isShow]) return;
	
	QobButton *button = [note object];
	if(button == nil) return;
	
	if([[note name]isEqualToString:@"PushButton"])
	{
	}
	if([[note name]isEqualToString:@"ReleaseButton"])
	{
	}
	else if([[note name]isEqualToString:@"PopButton"])
	{
		if(button.buttonId == BTNID_STAGECLEAR_NEXT)
		{
			[GWORLD setNextStage];
			[self remove];
//			[SOUNDMGR play:[GINFO sfxID:SND_MENU_CLICK]];
		}
		else if(button.buttonId == BTNID_STAGECLEAR_BACK)
		{
			[g_main changeScreen:GSCR_SELECTSTAGE];
			[self remove];
//			[SOUNDMGR play:[GINFO sfxID:SND_MENU_CLICK]];
		}
		else if(button.buttonId == BTNID_STAGECLEAR_RETRY)
		{
			[GWORLD setNextStage];
			[self remove];
//			[SOUNDMGR play:[GINFO sfxID:SND_MENU_CLICK]];
		}
	}
}

@end
