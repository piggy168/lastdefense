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
#import "GobHvM_Player.h"

@implementation DlgSummary

- (id)initWithClear:(bool)clear
{
    _nStage = GSLOT->stage;
	Tile2D *tile;
	QobButton *btn;
    
	if(clear && GSLOT->stage < MAX_STAGE-1)
	{
		[super initWithCommonImg:@"CommonUI" TopImg:@"StageClear" Height:320 * GWORLD.deviceScale];
		
		tile = [TILEMGR getTileForRetina:@"Common_btn_next.png"];
		[tile tileSplitX:1 splitY:3];
		btn = [self addButton:tile ID:BTNID_STAGECLEAR_NEXT];
        [btn setPosX:52 Y:-114];
        [_bgMid addChild:btn];
//		[btn setDeactiveTileNo:2];
	}
	else
	{
		[super initWithCommonImg:@"CommonUI" TopImg:@"Defeat" Height:512 * GWORLD.deviceScale];
		
		tile = [TILEMGR getTileForRetina:@"Common_btn_retry.png"];
		[tile tileSplitX:1 splitY:3];
		btn = [self addButton:tile ID:BTNID_STAGECLEAR_RETRY];
        [btn setPosX:40 Y:-112];
        [_bgMid addChild:btn];
//		[btn setDeactiveTileNo:2];
	}
	
	tile = [TILEMGR getTileForRetina:@"Common_btn_map.png"];
	[tile tileSplitX:1 splitY:3];
	btn = [self addButton:tile ID:BTNID_STAGECLEAR_BACK];
    [btn setPosX:-46 Y:-110];
    [_bgMid addChild:btn];
//	[btn setDeactiveTileNo:2];
    
    QobText *title_text = [[QobText alloc] initWithString:@"RESULT" Size:CGSizeMake(360, 26) Align:UITextAlignmentCenter Font:@"TrebuchetMS-Bold" FontSize:26 Retina:true];
    [title_text setColorR:255 G:255 B:255];
    [title_text setPosX:20 Y:118];
    [_bgMid addChild:title_text];

	QobText *text = [[QobText alloc] initWithString:[NSString stringWithFormat:@"%@ : %d", [GINFO getDescription:@"KillCount"], GVAL.killEnemies] Size:CGSizeMake(256, 32) Align:UITextAlignmentLeft Font:@"TrebuchetMS-Bold" FontSize:20 Retina:true];
	[text setColorR:160 G:255 B:255];
	[text setPosX:0 Y:130 * GWORLD.deviceScale];
	[_bgMid addChild:text];
    
    text = [[QobText alloc] initWithString:[NSString stringWithFormat:@"Hit Damage : %ld", GVAL.giveDamage] Size:CGSizeMake(256, 32) Align:UITextAlignmentLeft Font:@"TrebuchetMS-Bold" FontSize:20 Retina:true];
	[text setColorR:160 G:255 B:255];
	[text setPosX:0 Y:100 * GWORLD.deviceScale];
	[_bgMid addChild:text];
	
	text = [[QobText alloc] initWithString:[NSString stringWithFormat:@"%@ : %d", [GINFO getDescription:@"DeadCount"], GVAL.deadMachs] Size:CGSizeMake(256, 32) Align:UITextAlignmentLeft Font:@"TrebuchetMS-Bold" FontSize:20 Retina:true];
	[text setColorR:160 G:255 B:255];
	[text setPosX:0 Y:70 * GWORLD.deviceScale];
	[_bgMid addChild:text];
	
	float playTime = GWORLD.time - GWORLD.stageStartTime;
	text = [[QobText alloc] initWithString:[NSString stringWithFormat:@"Play Time : %d' %02d\"", (int)(playTime / 60), (int)playTime % 60] Size:CGSizeMake(256, 32) Align:UITextAlignmentLeft Font:@"TrebuchetMS-Bold" FontSize:20 Retina:true];
	[text setColorR:160 G:255 B:255];
	[text setPosX:0 Y:40 * GWORLD.deviceScale];
	[_bgMid addChild:text];
	
	if(clear)
	{
		text = [[QobText alloc] initWithString:@"MISSION COMPLETED!!" Size:CGSizeMake(512, 32) Align:UITextAlignmentCenter Font:@"TrebuchetMS-Bold" FontSize:26 Retina:true];
		[text setColorR:255 G:255 B:255];
		[text setPosX:0 Y:-6];
		[_bgMid addChild:text];
		
        tile = [TILEMGR getTileForRetina:@"Icon_32.png"];
        [tile tileSplitX:4 splitY:4];
        QobImage *img = [[QobImage alloc] initWithTile:tile tileNo:8];
        [img setPosX:-80 * GWORLD.deviceScale Y:-45 * GWORLD.deviceScale];
        [_bgMid addChild:img];
        
		int bonus = 500 + GSLOT->stage * 25;
		text = [[QobText alloc] initWithString:[NSString stringWithFormat:@"+%d", bonus] Size:CGSizeMake(256, 32) Align:UITextAlignmentLeft Font:@"TrebuchetMS-Bold" FontSize:24 Retina:true];
		[text setColorR:255 G:100 B:100];
		[text setPosX:40 Y:-45 * GWORLD.deviceScale];
		[_bgMid addChild:text];
		
		GSLOT->cr += bonus;
		if(GSLOT->stageClearCount[GSLOT->stage] < 1) GSLOT->score += (GSLOT->stage + 1) * 1000;
		if([self addNewMach] == false) [self addNewItem];
		
		GSLOT->stageClearCount[GSLOT->stage]++;
		
		GSLOT->stage++;
		if(GSLOT->stage > 69) GSLOT->stage = 69;
		if(GSLOT->lastStage < GSLOT->stage) GSLOT->lastStage = GSLOT->stage;
	}

	[GINFO saveDataFile];
//	if(strcmp(GSLOT->name, "GimmeCr") != 0) [GAMECENTER reportScore:GSLOT->score forCategory:@"HIGHSCORE"];

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
    
    NSString *strMapID = [NSString stringWithFormat:@"%d",_nStage+1];
    NSString *strUnlock = [GINFO getUnlockName:strMapID];
    if([strUnlock compare:@"-"] != NSOrderedSame)
    {
        
        MachBuildSet *buildSet = [GINFO getMachBuildSet:strUnlock];
        if(buildSet && buildSet.level > 0)
            return false;

		QobText *text = [[QobText alloc] initWithString:@"Unlocked new Mach." Size:CGSizeMake(512, 32) Align:UITextAlignmentCenter Font:@"TrebuchetMS-Bold" FontSize:24 Retina:true];
		[text setColorR:160 G:255 B:255];
		[text setPosX:0 Y:-90 * GWORLD.deviceScale];
		[_bgMid addChild:text];
        
        QobImage *img = [[QobImage alloc] initWithTile:[buildSet machTile] tileNo:0];
        [img setUseAtlas:true];
        [img setPosX:0 Y:-84];
        [_bgMid addChild:img];
				
        text = [[QobText alloc] initWithString:strUnlock Size:CGSizeMake(512, 32) Align:UITextAlignmentCenter Font:@"TrebuchetMS-Bold" FontSize:20 Retina:true];
        [text setColorR:255 G:100 B:100];
        [text setPosX:0 Y:-117 * GWORLD.deviceScale];
        [_bgMid addChild:text];
        
        MachBuildSet *reward = [GINFO buyBuildSet:strUnlock];
        if(GAMEUI.dlgBuildMach.buildBtnCnt < 7) reward.onSlot = true;
		
		ret = true;
	}
	
	return ret;
}

- (void)addNewItem
{
	NSString *newItem[5] = {@"AirStrike-Bomb", @"AirStrike-Missile", @"AirStrike-Nuclear", @"AirStrike-EMP", @"Crossfire-Missile"};
	
	int rnd = RANDOM(5), cnt = RANDOM(4) + 1;
	QobText *text = [[QobText alloc] initWithString:newItem[rnd] Size:CGSizeMake(512, 32) Align:UITextAlignmentCenter Font:@"TrebuchetMS-Bold" FontSize:20 Retina:true];
	[text setColorR:255 G:100 B:100];
	[text setPosX:0 Y:-90 * GWORLD.deviceScale];
	[_bgMid addChild:text];
	
	SpAttackSet *attack = [GINFO buyAttackSet:newItem[rnd] Count:cnt];
	if(GAMEUI.dlgSpAttack.buildBtnCnt < 7) attack.onSlot = true;

	TSpAttackSet *set = [attack attackSet];
	float pos = -cnt * 40 + 40;
	for(; cnt > 0; cnt--)
	{
		Tile2D *tile = [TILEMGR getTileForRetina:[NSString stringWithFormat:@"Icon%05d.png", set->itemId]];
		[tile tileSplitX:1 splitY:1];
		QobImage *img = [[QobImage alloc] initWithTile:tile tileNo:0];
		[img setPosX:pos * GWORLD.deviceScale Y:-140 * GWORLD.deviceScale];
		[_bgMid addChild:img];
		
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
            [GINFO saveDataFile];
			[GWORLD setNextStage];
			[self remove];
//			[SOUNDMGR play:[GINFO sfxID:SND_MENU_CLICK]];
		}
		else if(button.buttonId == BTNID_STAGECLEAR_BACK)
		{
            [GINFO saveDataFile];
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
