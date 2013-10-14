//
//  GuiSelectSlot.m
//  HeavyMach
//
//  Created by 엔비 on 08. 12. 17.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "GuiSelectSlot.h"
#import "QobButton.h"
#import "QobImageFont.h"
#import "QUIAlertView.h"

@implementation GuiSelectSlot
@synthesize sel=_sel;

- (id)init
{
	[super init];

	_tileResMgr = [[ResMgr_Tile alloc] init];

	Tile2D *tile = nil;
	QobImage *img = nil;
	QobButton *btn = nil;
	
	[SOUNDMGR playBGM:@"UI_BGM.mp3"];
	
	tile = [_tileResMgr getUniTile:@"SelSlot_BG.jpg"];
	img = [[QobImage alloc] initWithTile:tile tileNo:0];
	[img setPosX:_glView.surfaceSize.width/2 Y:_glView.surfaceSize.height/2];
	[self addChild:img];
		
	tile = [_tileResMgr getTileForRetina:@"Common_Btn_BACK.png"];
	[tile tileSplitX:1 splitY:2];
	btn = [[QobButton alloc] initWithTile:tile TileNo:0 ID:BTNID_BACK];
	btn.pushDepth = 0.f;
	btn.releaseHeight = 0.f;
	btn.releaseDelay = 0.f;
	[btn setReleaseTileNo:1];
//	[btn setBoundWidth:80 Height:60];
	if(_glView.deviceType == DEVICE_IPAD) [btn setPosX:224 Y:80];
	else  [btn setPosX:80 Y:30];
	[self addChild:btn];
	
	tile = [_tileResMgr getTileForRetina:@"Common_Btn_DEL.png"];
	[tile tileSplitX:1 splitY:2];
	btn = [[QobButton alloc] initWithTile:tile TileNo:0 ID:BTNID_DELSLOT];
	btn.pushDepth = 0.f;
	btn.releaseHeight = 0.f;
	btn.releaseDelay = 0.f;
	[btn setReleaseTileNo:1];
//	[btn setBoundWidth:80 Height:60];
	if(_glView.deviceType == DEVICE_IPAD) [btn setPosX:384 Y:80];
	else [btn setPosX:160 Y:30];
	[self addChild:btn];
	
	tile = [_tileResMgr getTileForRetina:@"Common_Btn_NEW.png"];
	[tile tileSplitX:1 splitY:2];
	btn = [[QobButton alloc] initWithTile:tile TileNo:0 ID:BTNID_OK];
	btn.pushDepth = 0.f;
	btn.releaseHeight = 0.f;
	btn.releaseDelay = 0.f;
	[btn setReleaseTileNo:1];
//	[btn setBoundWidth:80 Height:60];
	if(_glView.deviceType == DEVICE_IPAD) [btn setPosX: 544 Y:80];
	else [btn setPosX: 240 Y:30];
	[self addChild:btn];
	
	_sel = -1;
	_pSelSlot = NULL;
	for(int i = 0; i < MAX_SAVESLOT; i++)
	{
		[self refreshSlot:i];
	}
	
	if(_sel == -1) _sel = 1;

	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:self selector:@selector(handleButton:) name:@"PushButton" object:nil];
	[nc addObserver:self selector:@selector(handleButton:) name:@"PopButton" object:nil];

	return self;
}

- (void)dealloc
{
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc removeObserver:self];

	[_tileResMgr removeAllTiles];
	[_tileResMgr release];
	
	[super dealloc];
}

- (void)tick
{
	[super tick];
}

- (void)refreshSlot:(int)idx
{
	Tile2D *tile = nil;
	char szCreateDate[32], szAccessDate[32];
	TSaveSlotData *pData = [GINFO slotData:idx];
	
	if(_slotBase[idx] != nil)
	{
		[_slotBase[idx] remove];
		_slotBase[idx] = nil;
	}
	
	if(pData->use)
	{
		tile = [_tileResMgr getUniTile:@"SelSlot_Sel.png"];
		[tile tileSplitX:1 splitY:2];
		_slotBase[idx] = [[QobButton alloc] initWithTile:tile TileNo:1 ID:BTNID_SELSLOT];
		[_slotBase[idx] setReleaseTileNo:0];
		[_slotBase[idx] setIntData:idx];
		if(_glView.deviceType == DEVICE_IPAD) [_slotBase[idx] setBoundWidth:512 Height:120];
		else [_slotBase[idx] setBoundWidth:256 Height:60];
		[self addChild:_slotBase[idx]];

		if(_sel == -1 || _pSelSlot == NULL || _pSelSlot->lastAccess < pData->lastAccess)
		{
//			if(_sel != -1 && _mach[_sel] != nil) [_mach[_sel] setMoveVel:0.f];
			_sel = idx;
			_pSelSlot = pData;
		}
		
		QobText *text = [[QobText alloc] initWithString:[NSString stringWithUTF8String:pData->name] Size:CGSizeMake(256, 32) Align:UITextAlignmentLeft Font:@"TrebuchetMS-Bold" FontSize:20 Retina:true];
		[text setColorR:0 G:0 B:0];
		if(_glView.deviceType == DEVICE_IPAD) [text setPosX:-40 Y:26];
		else [text setPosX:-24 Y:20];
		[_slotBase[idx] addChild:text];
		
		text = [[QobText alloc] initWithString:[NSString stringWithUTF8String:pData->name] Size:CGSizeMake(256, 32) Align:UITextAlignmentLeft Font:@"TrebuchetMS-Bold" FontSize:20 Retina:true];
		[text setColorR:160 G:255 B:255];
		if(_glView.deviceType == DEVICE_IPAD) [text setPosX:-40 Y:27];
		else [text setPosX:-24 Y:21];
		[_slotBase[idx] addChild:text];

		text = [[QobText alloc] initWithString:[NSString stringWithFormat:@"%d", pData->score] Size:CGSizeMake(256, 32) Align:UITextAlignmentRight Font:@"TrebuchetMS-Bold" FontSize:18 Retina:true];
		[text setColorR:160 G:255 B:255];
		if(_glView.deviceType == DEVICE_IPAD) [text setPosX:80 Y:26];
		else [text setPosX:40 Y:20];
		[_slotBase[idx] addChild:text];
		
		tile = [_tileResMgr getTileForRetina:[NSString stringWithFormat:@"%s.png", pData->country]];
		QobImage *img = [[QobImage alloc] initWithTile:tile tileNo:0];
		if(_glView.deviceType == DEVICE_IPAD) [img setPosX:-200 Y:30];
		else [img setPosX:-100 Y:23];
		[_slotBase[idx] addChild:img];

		struct tm time = *localtime(&pData->createTime);
		sprintf(szCreateDate, "%04d/%02d/%02d %02d:%02d:%02d", time.tm_year + 1900, time.tm_mon + 1, time.tm_mday, time.tm_hour, time.tm_min, time.tm_sec);
		
		time = *localtime(&pData->lastAccess);
		sprintf(szAccessDate, "%04d/%02d/%02d %02d:%02d:%02d", time.tm_year + 1900, time.tm_mon + 1, time.tm_mday, time.tm_hour, time.tm_min, time.tm_sec);
		
		tile = [_tileResMgr getTile:@"NumSet01b.png"];
		[tile tileSplitX:16 splitY:1];
		QobImageFont *date = [[QobImageFont alloc] initWithTile:tile];
		[date setPitch:6.f];
		[date setAlignRate:0.f];
		[date setText:szCreateDate];
		if(_glView.deviceType == DEVICE_IPAD) [date setPosX:-100 Y:-2];
		else [date setPosX:-90 Y:-2];
		[_slotBase[idx] addChild:date];
		
		date = [[QobImageFont alloc] initWithTile:tile];
		[date setPitch:6.f];
		[date setAlignRate:0.f];
		[date setText:szAccessDate];
		if(_glView.deviceType == DEVICE_IPAD) [date setPosX:-100 Y:-22];
		else [date setPosX:-90 Y:-20];
		[_slotBase[idx] addChild:date];

		if(_glView.deviceType == DEVICE_IPAD) tile = [_tileResMgr getTile:@"NumSet_Cr.png"];
		else tile = [_tileResMgr getTile:@"NumSet01b.png"];
		[tile tileSplitX:16 splitY:1];
		QobImageFont *imgTxt = [[QobImageFont alloc] initWithTile:tile];
		if(_glView.deviceType == DEVICE_IPAD) [imgTxt setPitch:11.f];
		else [imgTxt setPitch:6.f];
		[imgTxt setAlignRate:1.f];
		[imgTxt setNumber:pData->lastStage + 1];
		if(_glView.deviceType == DEVICE_IPAD) [imgTxt setPosX:140 Y:1];
		else [imgTxt setPosX:74 Y:-1];
		[_slotBase[idx] addChild:imgTxt];

		imgTxt = [[QobImageFont alloc] initWithTile:tile];
		if(_glView.deviceType == DEVICE_IPAD) [imgTxt setPitch:11.f];
		else [imgTxt setPitch:6.f];
		[imgTxt setAlignRate:1.f];
		[imgTxt setNumber:pData->cr];
		if(_glView.deviceType == DEVICE_IPAD) [imgTxt setPosX:180 Y:-25];
		else [imgTxt setPosX:88 Y:-21];
		[_slotBase[idx] addChild:imgTxt];
	}
/*	else
	{
		tile = [_tileResMgr getTile:@"SelSlot_Empty.png"];
		[tile tileSplitX:1 splitY:2];
		_slotBase[idx] = [[QobButton alloc] initWithTile:tile TileNo:1 ID:BTNID_SELSLOT];
		[_slotBase[idx] setReleaseTileNo:0];
		[_slotBase[idx] setIntData:idx];
		[self addChild:_slotBase[idx]];
	}*/

	if(_glView.deviceType == DEVICE_IPAD) [_slotBase[idx] setPosX:_glView.surfaceSize.width/2 Y:740 - idx * 120];
	else [_slotBase[idx] setPosX:_glView.surfaceSize.width/2 Y:340 - idx * 80];
	
	[self refreshSelect];
}

- (void)refreshSelect
{
	for(int i = 0; i < MAX_SAVESLOT; i++)
	{
		if(i == _sel)
		{
			[_slotBase[i] setDefaultTileNo:0];
		}
		else
		{
			[_slotBase[i] setDefaultTileNo:1];
		}
	}
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIdx
{
	if(alertView == _NewUserDlg)
	{
		if(buttonIdx == 1)
		{
			NSString *name = [[_NewUserDlg fieldAtIndex:0] text];
			if([name length] >= 1 && [name length] <= 10)
			{
				NSLocale *locale = [NSLocale currentLocale];
				NSString *country;
				if(locale != nil)
				{
					country = [locale objectForKey:NSLocaleCountryCode];
					if(country != nil) country = [country lowercaseString];
					else country = @"us";
				}
				else
				{
					country = @"us";
				}
				
				_sel = [GINFO initSlotWithName:name Country:country];
				if(_sel != -1) [self refreshSlot:_sel];
			}
			else
			{
				[g_main setAlertTitle:@"Incorrect Name" Message:[GINFO getDescription:@"IncorrectName"] AlertId:-1 CancelBtn:false];
			}
		}
		[alertView release];
	}
}

- (void)selectSlot
{
	TSaveSlotData *pData = [GINFO slotData:_sel];
	if(pData && pData->use)
	{
		GVAL.selSaveSlot = _sel;
		[g_main changeScreen:GSCR_SELECTSTAGE];
	}
}

- (void)newSlot
{
	_NewUserDlg = [[QUIAlertView alloc] initWithTitle:@"New User" numberOfTextFields:1 delegate:self cancelButtonTitle:@"cancel" otherButtonTitle:@"OK"];
	UITextField *textField = [_NewUserDlg fieldAtIndex:0];
	textField.placeholder = [NSString stringWithString:@"Name: 1~10 Character"];
	
	[_NewUserDlg show];
}

- (void)handleButton:(NSNotification *)note
{
	QobButton *button = [note object];
	if(button == nil) return;
	
	if([[note name]isEqualToString:@"PushButton"])
	{
		if(button.buttonId == BTNID_SELSLOT)
		{
			if(_sel == button.intData)
			{
				[self selectSlot];
			}
			else
			{
				_sel = button.intData;
				[self refreshSelect];
			}
			
			_sel = button.intData;
			[SOUNDMGR play:[GINFO sfxID:SND_MENU_CLICK]];
		}
	}
	else if([[note name]isEqualToString:@"PopButton"])
	{
		if(button.buttonId == BTNID_OK)
		{
			if([GINFO existEmptySlot]) [self newSlot];
			else [g_main setAlertTitle:@"Not Exist Empty Slot" Message:[GINFO getDescription:@"NotEmptySlot"] AlertId:ALERT_DELETESLOT CancelBtn:false];

			[SOUNDMGR play:[GINFO sfxID:SND_BTN_OK]];
		}
		else if(button.buttonId == BTNID_DELSLOT)
		{
			TSaveSlotData *pData = [GINFO slotData:_sel];
			if(pData && pData->use) [g_main setAlertTitle:@"Delete Slot" Message:[GINFO getDescription:@"DeleteSlot"] AlertId:ALERT_DELETESLOT CancelBtn:true];
			
			[SOUNDMGR play:[GINFO sfxID:SND_BTN_OK]];
		}
		else if(button.buttonId == BTNID_BACK)
		{
			[g_main changeScreen:GSCR_TITLE];
			[SOUNDMGR play:[GINFO sfxID:SND_BTN_OK]];
		}
	}
}

@end
