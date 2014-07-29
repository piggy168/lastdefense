//
//  GlobalInfo.m
//  HeavyMach
//
//  Created by 엔비 on 08. 12. 05.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "GlobalInfo.h"
//#import "Ranking.h"
#import "MachBuildSet.h"
#import "SpAttackSet.h"
#import "BaseUpgradeSet.h"
#import "WeaponInfo.h"
#import "GuiGame.h"
#import "GobHvM_Player.h"

TGlobalValue g_value;

@implementation GlobalInfo

@synthesize gameMode=_gameMode, slotData=_slotData, localeCode=_localeCode, tileList=_tileList;

static GlobalInfo *_sharedInfo = nil;
static NSString *baseUpgradeName[6] = { @"BaseCannon", @"BaseDefense", @"BuildTime", @"CrResearch", @"CellResearch", @"CellStorage" };

+ (GlobalInfo *)sharedInfo
{
	@synchronized(self)
	{
		if(!_sharedInfo)
		{
			_sharedInfo = [GlobalInfo alloc];
			[_sharedInfo init];
		}
		return _sharedInfo;
	}
	
	return nil;
}

- (id)init
{
	[super init];

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
	_localeCode = [[NSString alloc] initWithString:country];

	_dictMapInfo = [[NSMutableDictionary dictionaryWithCapacity: 10] retain];
	_dictMapName = [[NSMutableDictionary dictionaryWithCapacity: 10] retain];
    _dictUnlockName = [[NSMutableDictionary dictionaryWithCapacity: 10] retain];
	_dictPartsInfo = [[NSMutableDictionary dictionaryWithCapacity: 10] retain];
	_dictMachInfo = [[NSMutableDictionary dictionaryWithCapacity: 10] retain];
	_dictMachBuildInfo = [[NSMutableDictionary dictionaryWithCapacity: 10] retain];
	_dictSpAttackInfo = [[NSMutableDictionary dictionaryWithCapacity: 10] retain];
	_dictBaseUpgradeInfo = [[NSMutableDictionary dictionaryWithCapacity: 10] retain];
	_dictItemInfo = [[NSMutableDictionary dictionaryWithCapacity: 10] retain];
	_dictWeaponInfo = [[NSMutableDictionary dictionaryWithCapacity: 10] retain];
	_listBuyBuildSet = [[NSMutableArray alloc] init];
	_listBuyAttackSet = [[NSMutableArray alloc] init];

	[self openMapInfo];
	[self openPartsInfo];
	[self openMachInfo];
	[self openItemInfo];
	[self openWeaponInfo];
	[self openMachBuildSet];
	[self openSpAttackList];
	[self openBaseUpgradeInfo];
	[self openDescriptionList];
	
	[self loadSFX];
	
//	_ranking = [[Ranking alloc] init];
	
	_gameMode = GMODE_SCENARIO;
	
	_tileList = [[QTable alloc] initWithFile:[[NSBundle mainBundle] pathForResource:@"TileList" ofType:@"tbl"]];

	return self;
}

- (void)dealloc
{
	[_dictMapInfo release];
	[_dictMapName release];
    [_dictUnlockName release];
	[_dictPartsInfo release];
	[_dictMachInfo release];
	[_dictMachBuildInfo release];
	[_dictSpAttackInfo release];
	[_dictBaseUpgradeInfo release];
	[_dictItemInfo release];
	[_dictWeaponInfo release];
	[_dictDescription release];
	[_listBuyBuildSet release];
	[_listBuyAttackSet release];
	
//	[_ranking release];
	[_localeCode release];
	[_tileList release];
	
	[super dealloc];
}

- (void)loadSFX
{
	_sfxID[SND_MENU_CLICK] = [SOUNDMGR getSound:@"UI_Click.wav"];
	_sfxID[SND_BTN_OK] = [SOUNDMGR getSound:@"UI_Btn_OK.wav"];
	_sfxID[SND_BTN_CANCEL] = [SOUNDMGR getSound:@"UI_Btn_Cancel.wav"];
	_sfxID[SND_GETITEM] = [SOUNDMGR getSound:@"Game_GetItem.wav"];
	_sfxID[SND_ONMSG] = [SOUNDMGR getSound:@"SFX_OnMessage.wav"];
	_sfxID[SND_QUICKSLOT] = [SOUNDMGR getSound:@"SFX_QuickSlot.wav"];
	_sfxID[SND_LOWHP] = [SOUNDMGR getSound:@"Game_LowHP.wav"];
	_sfxID[SND_AIRSTRIKE] = [SOUNDMGR getSound:@"SFX_AirStrike.wav"];
	_sfxID[SND_HITMACH_01] = [SOUNDMGR getSound:@"SFX_HitBody01.wav"];
	_sfxID[SND_HITMACH_02] = [SOUNDMGR getSound:@"SFX_HitBody02.wav"];
	_sfxID[SND_HITMACH_03] = [SOUNDMGR getSound:@"SFX_HitBody03.wav"];
	_sfxID[SND_HITMACH_04] = [SOUNDMGR getSound:@"SFX_HitBody04.wav"];
	_sfxID[SND_HITGROUND] = [SOUNDMGR getSound:@"SFX_GroundHit.wav"];
	_sfxID[SND_EXPLGROUND] = [SOUNDMGR getSound:@"SFX_ExplGround.wav"];
	_sfxID[SND_EXPLMACH] = [SOUNDMGR getSound:@"SFX_ExplMach.wav"];
	_sfxID[SND_PLASMADMG] = [SOUNDMGR getSound:@"DmgPlasma.wav"];
	_sfxID[SND_BUILDMACH] = [SOUNDMGR getSound:@"BuildMach.wav"];
	_sfxID[SND_BUILDMACH_COMPLETE] = [SOUNDMGR getSound:@"BuildMachComplete.wav"];
	_sfxID[SND_UI_BUILDMACH] = [SOUNDMGR getSound:@"UIType_BuildMach.wav"];
	_sfxID[SND_UI_SPATTACK] = [SOUNDMGR getSound:@"UIType_SpAttack.wav"];
	_sfxID[SND_UI_FORMATION] = [SOUNDMGR getSound:@"UIType_Formation.wav"];
	_sfxID[SND_INSTALL] = [SOUNDMGR getSound:@"Install.wav"];
	_sfxID[SND_UNINSTALL] = [SOUNDMGR getSound:@"Uninstall.wav"];
	_sfxID[SND_BUY_SPATTACK] = [SOUNDMGR getSound:@"BuySpAttack.wav"];
	_sfxID[SND_UPGRADE_BASE] = [SOUNDMGR getSound:@"UpgradeBase.wav"];
	_sfxID[SND_UPGRADE_MACH] = [SOUNDMGR getSound:@"UpgradeMach.wav"];
	_sfxID[SND_UPGRADE_SPATTACK] = [SOUNDMGR getSound:@"UpgradeSpAttack.wav"];
}

- (UInt32)sfxID:(int)nSndID
{
	if(nSndID < 0 || nSndID >= SND_MAX) return 0;
	
	return _sfxID[nSndID];
}

- (void)setLocaleCode:(const char *)locale
{
	if(_localeCode != nil) [_localeCode release];
	
//	if(locale && strcmp(locale, "kr") == 0) _localeCode = [[NSString alloc] initWithString:@"kr"];
//	else
        _localeCode = [[NSString alloc] initWithString:@"us"];
	
	[self openDescriptionList];
}

- (int)runCount
{
	return _saveData.runCount;
}

- (void)updateBaseUpgrade
{
	BaseUpgradeSet *set;
	TBaseUpgradeSet *info;
	
	set = [GINFO getBaseUpgradeSet:@"CellStorage"];
	info = [set upgradeSet];
	GVAL.maxMineral = info->param;
	GVAL.mineralUpgradeValue = GVAL.maxMineral;
	
	set = [GINFO getBaseUpgradeSet:@"CellResearch"];
	info = [set upgradeSet];
	GVAL.incMineral = info->param;

	set = [GINFO getBaseUpgradeSet:@"BuildTime"];
	info = [set upgradeSet];
	GVAL.buildTime = info->param;
	
	set = [GINFO getBaseUpgradeSet:@"CrResearch"];
	info = [set upgradeSet];
	GVAL.crGen = info->param;
	
	set = [GINFO getBaseUpgradeSet:@"BaseDefense"];
	info = [set upgradeSet];
	GVAL.baseDef = info->param;
	
	GVAL.maxMineral += GVAL.cellUpgrade * GVAL.mineralUpgradeValue;
	GVAL.cellUpgradeCost = (int)(GVAL.maxMineral * .6f);
}

- (bool)existEmptySlot
{
	int maxSlot = _glView.deviceType == DEVICE_IPAD ? MAX_SAVESLOT : 4;
	for(int i = 0; i < maxSlot; i++)
	{
		if(!_saveData.slot[i].use) return true;
	}
	
	return false;
}

- (int)initSlotWithName:(NSString *)name Country:(NSString *)country
{
	int n = -1;
	for(int i = 0; i < MAX_SAVESLOT && n == -1; i++)
	{
		if(!_saveData.slot[i].use) n = i;
	}
	
	if(n != -1)
	{
		TSaveSlotData *slot = &_saveData.slot[n];
		
		memset(slot, 0, sizeof(TSaveSlotData));
		slot->use = true;
		time(&slot->createTime);
		strcpy(slot->name, [name UTF8String]);
		strcpy(slot->country, [country UTF8String]);

#ifdef DEBUG
		if(strcmp(slot->name, "GimmeCr") == 0)			// cheat
		{
			slot->cr = 10000000;
		}
#endif
		
		slot->bgmVol = .8f;
		slot->sfxVol = 1.f;
		
		[self selectSlot:n];
		[self saveDataFile];
	}
	
	return n;
}

- (bool)selectSlot:(int)n
{
	if(n < 0 || n >= MAX_SAVESLOT) return false;
	if(!_saveData.slot[n].use) return false;
	
	_selectedSlot = n;

	if(GSLOT != NULL) free(GSLOT);
	GSLOT = (TSaveSlotData *)malloc(sizeof(TSaveSlotData));
	memcpy(GSLOT, &_saveData.slot[n], sizeof(TSaveSlotData));
	
	for(MachBuildSet *buildSet in [_dictMachBuildInfo allValues])
	{
		[buildSet setLevel:0];
	}
	
	for(SpAttackSet *attackSet in [_dictSpAttackInfo allValues])
	{
		attackSet.level = 0;
		attackSet.count = 0;
	}
	
	[self clearBuyBuildSet];
	[self resetAttackSet];
	
	if(GSLOT->machCount == 0)
	{
		MachBuildSet *buildSet;
   		buildSet = [self buyBuildSet:@"Griffon"];			buildSet.onSlot = true;
        buildSet = [self buyBuildSet:@"Phoenix"];             buildSet.onSlot = true;
        buildSet = [self buyBuildSet:@"Unicorn"];             buildSet.onSlot = true;
        buildSet = [self buyBuildSet:@"Cerberus"];             buildSet.onSlot = true;
        
        buildSet = [self buyBuildSet:@"Manticore"];             buildSet.onSlot = false;
        buildSet = [self buyBuildSet:@"Pagasus"];             buildSet.onSlot = false;
        buildSet = [self buyBuildSet:@"Hydra"];             buildSet.onSlot = false;
		buildSet = [self buyBuildSet:@"G-Claw"];			buildSet.onSlot = false;
		buildSet = [self buyBuildSet:@"U-Horn"];				buildSet.onSlot = false;
		buildSet = [self buyBuildSet:@"P-Sting"];				buildSet.onSlot = false;
		buildSet = [self buyBuildSet:@"H-Fume"];			buildSet.onSlot = false;
        buildSet = [self buyBuildSet:@"C-Fang"];             buildSet.onSlot = false;
        buildSet = [self buyBuildSet:@"M-Spine"];             buildSet.onSlot = false;
        buildSet = [self buyBuildSet:@"Minotaur"];             buildSet.onSlot = false;

		SpAttackSet *attackSet;
		attackSet = [self buyAttackSet:@"AirStrike-Bomb" Count:2];		attackSet.onSlot = true;
		attackSet = [self buyAttackSet:@"AirStrike-Missile" Count:2];	attackSet.onSlot = true;
		attackSet = [self buyAttackSet:@"AirStrike-Nuclear" Count:0];	attackSet.onSlot = false;
		attackSet = [self buyAttackSet:@"Crossfire-Missile" Count:0];	attackSet.onSlot = false;
        attackSet = [self buyAttackSet:@"AirStrike-EMP" Count:0];       attackSet.onSlot = false;
//		[self addSpAttack:"02001" Cnt:2];
//		[self addSpAttack:"02011" Cnt:2];
//		[self addSpAttack:"02021" Cnt:1];
	}
	else
	{
		for(int i = 0; i < GSLOT->machCount; i++)
		{
			NSString *name = [NSString stringWithUTF8String:GSLOT->machData[i].name];
			MachBuildSet *buildSet = [self buyBuildSet:name];
			buildSet.onSlot = GSLOT->machData[i].onSlot;
			[buildSet setLevel:GSLOT->machData[i].level];
		}

		for(int i = 0; i < GSLOT->spAttackCount; i++)
		{
			NSString *name = [NSString stringWithUTF8String:GSLOT->spAttackData[i].name];
			SpAttackSet *attackSet = [self buyAttackSet:name Count:GSLOT->spAttackData[i].count];
			attackSet.onSlot = GSLOT->spAttackData[i].onSlot;
			attackSet.level = GSLOT->spAttackData[i].level;
		}
	}
	
	for(int i = 0; i < 6; i++)
	{
		BaseUpgradeSet *upgradeSet = [self getBaseUpgradeSet:baseUpgradeName[i]];
		upgradeSet.level = GSLOT->baseUpgrade[i];
	}

	[GINFO setLocaleCode:GSLOT->country];
	
	time(&GSLOT->lastAccess);
	[SOUNDMGR setBGMVolume:GSLOT->bgmVol];
	[SOUNDMGR setSFXVolume:GSLOT->sfxVol];
	
	if(GSLOT->score == 0 && GSLOT->lastStage > 0)
	{
		int scoreSeed = 1000;
		for(int i = 0; i < GSLOT->lastStage; i++)
		{
			GSLOT->score += scoreSeed;
			scoreSeed += 1500;
		}
		GSLOT->score += GSLOT->cr;
	}
	
	// 임시 초기값 //////////////////			// cheat
#ifdef DEBUG
//	GSLOT->stage = 20;
//	GSLOT->cr = 20000;
//	GSLOT->maxHp = 256;
//    GSLOT->lastStage = 10;//MAX_STAGE;
//	GSLOT->machCount = 7;
#endif
	///////////////////////////////
	
	return true;
}

- (void)deleteSlot:(int)n
{
	if(n < 0 || n >= MAX_SAVESLOT) return;
	
	if(GSLOT)
	{
		free(GSLOT);
		GSLOT = NULL;
	}
	memmove(&_saveData.slot[n], &_saveData.slot[n+1], sizeof(TSaveSlotData) * (MAX_SAVESLOT - n - 1));
	_saveData.slot[MAX_SAVESLOT-1].use = NO;
}

- (TSaveSlotData *)slotData:(int)n
{
	if(n < 0 || n >= MAX_SAVESLOT) return NULL;
	
	return &_saveData.slot[n];
}

#define MAX_HPOFFSET	270

- (void)openDataFile
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *filePath = [[paths objectAtIndex:0] stringByAppendingString:@"/MachDefense.sav"];
	NSData *saveData = [[NSData alloc] initWithContentsOfFile:filePath];
	bool loadSuccess = false;

	if(saveData != nil)
	{
		if([saveData length] == sizeof(_saveData))
		{
			char *buffer;
			int i, len = [saveData length], sum = 0;
			buffer = malloc(len);
			[saveData getBytes:buffer length:len];
			
			srandom(*(int *)buffer);
			for(i = 4; i < len-4; i++)
			{
				buffer[i] ^= RANDOM(256);
				sum += buffer[i];
			}
			
			if(*(int *)(buffer + i) == sum)
			{
				memcpy((char *)&_saveData, buffer, len);
				free(buffer);
				if(_saveData.runCount < 0) _saveData.runCount = 0;
				_saveData.runCount++;
				loadSuccess = true;
			}
		}
		
		[saveData release];
	}
	
	if(!loadSuccess)
	{
		for(int i = 0; i < MAX_SAVESLOT; i++)
		{
			_saveData.slot[i].use = false;
		}
        
        [GINFO initSlotWithName:@"FinalForce" Country:@"us"];
        //_saveData.slot[0].use = true;
		//_saveData.runCount = 1;
	}
}

- (void)saveDataFile
{
	if(GSLOT)
	{
		GSLOT->machCount = _listBuyBuildSet.count;
		for(int i = 0; i < _listBuyBuildSet.count && i < 128; i++)
		{
			MachBuildSet *buildSet = [_listBuyBuildSet objectAtIndex:i];
			GSLOT->machData[i].onSlot = buildSet.onSlot;
			strcpy(GSLOT->machData[i].name, [buildSet.machName UTF8String]);
			GSLOT->machData[i].level = buildSet.level;
		}
		
		GSLOT->spAttackCount = _listBuyAttackSet.count;
		for(int i = 0; i < _listBuyAttackSet.count && i < 64; i++)
		{
			SpAttackSet *attackSet = [_listBuyAttackSet objectAtIndex:i];
			GSLOT->spAttackData[i].onSlot = attackSet.onSlot;
			strcpy(GSLOT->spAttackData[i].name, [attackSet.attackName UTF8String]);
			GSLOT->spAttackData[i].level = attackSet.level;
			GSLOT->spAttackData[i].count = attackSet.count;
		}
		
		for(int i = 0; i < 6; i++)
		{
			BaseUpgradeSet *upgradeSet = [self getBaseUpgradeSet:baseUpgradeName[i]];
			GSLOT->baseUpgrade[i] = (char)upgradeSet.level;
		}
		
		memcpy(&_saveData.slot[_selectedSlot], GSLOT, sizeof(TSaveSlotData));
	}
	
	RANDOM_SEED;
	_saveData.randSeed = RANDOM(65535);

	char *buffer;
	int i, len = sizeof(_saveData), sum = 0;
	buffer = malloc(len);
	memcpy(buffer, &_saveData, len);
	
	srandom(_saveData.randSeed);
	for(i = 4; i < len-4; i++)
	{
		sum += buffer[i];
		buffer[i] ^= RANDOM(256);
	}
	*(int *)(buffer + i) = sum;
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *filePath = [[paths objectAtIndex:0] stringByAppendingString:@"/MachDefense.sav"];
	NSData *saveData  = [NSData dataWithBytes:buffer length:len]; 
	[saveData writeToFile:filePath atomically:NSAtomicWrite];

	free(buffer);
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (bool)openMapInfo
{
	QChunk *mapChunk = [[QChunk alloc] init];
	[mapChunk loadChunkWithName:[[[NSBundle mainBundle] pathForResource:@"MapInfo" ofType:@"mcb"] UTF8String]];
	
	for(int i = 0; i < mapChunk.subCount; i++)
	{
		QChunk *chunk = [mapChunk getSubChunk:i];
		if(chunk.type == MCNK_MAP)
		{
			[_dictMapInfo setObject:chunk forKey:[NSString stringWithUTF8String:chunk.data]];
		}
	}
	
	[mapChunk release];
	
	QTable *table = [[QTable alloc] initWithFile:[[NSBundle mainBundle] pathForResource:@"MapList" ofType:@"tbl"]];
	for(int i = 0; i < table.row; i++)
	{
		NSString *name = [[NSString alloc] initWithString:[table getString:i Key:@"Stage"]];
		NSString *desc = [[NSString alloc] initWithString:[table getString:i Key:@"ImageFile"]];
        NSString *unlock = [[NSString alloc] initWithString:[table getString:i Key:@"Unlock"]];
        float x = [table getFloat:i Key:@"PositionX"];
        float y = [table getFloat:i Key:@"PositionY"];
        
        _listMapPosition[i] =  CGPointMake(x, y);
        
        NSLog(@"Unlock mach [%@]",unlock);
		
		[_dictMapName setObject:desc forKey:name];
		[_dictUnlockName setObject:unlock forKey:name];
        [unlock release];
		[name release];
		[desc release];
	}
	
	[table release];
	
	return true;
}

- (QChunk *)getMapInfo:(NSString *)mapName
{
	return [_dictMapInfo objectForKey:mapName];
}

- (NSString *)getMapName:(NSString *)mapId
{
	return [_dictMapName objectForKey:mapId];
}

- (NSString *)getUnlockName:(NSString *)mapId
{
	return [_dictUnlockName objectForKey:mapId];
}

- (CGPoint)getMapPosition:(NSString *)mapId
{
    return _listMapPosition[mapId.intValue];
}

- (CGPoint)getMapPositionFromIndex:(int)nMapIndex
{
    return _listMapPosition[nMapIndex];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (int)readPartsChunk:(char *)data Pos:(int)pos
{
	char *pData = NULL;
	/*int size = *(int *)(data + pos);*/		pos += sizeof(int);
	int type = *(int *)(data + pos);			pos += sizeof(int);
	int dataSize = *(int *)(data + pos);		pos += sizeof(int);
	if(dataSize > 0 && type == MCNK_PARTS)
	{
		pData = data + pos;
		
		int dataPos = 0;
		char szPartsName[24];
		strcpy(szPartsName, pData);											dataPos += 24;
		unsigned char partsType = *(unsigned char *)(pData + dataPos);		dataPos += 1;
		unsigned char tileCnt = *(unsigned char *)(pData + dataPos);		dataPos += 1;
		unsigned char socketCnt = *(unsigned char *)(pData + dataPos);		dataPos += 1;
		
		PartsInfo *partsInfo = [[PartsInfo alloc] init];
		[partsInfo setPartsName:szPartsName];
		partsInfo.partsType = partsType;
		partsInfo.tileCnt = tileCnt;
		[partsInfo setSocketCnt:socketCnt];
		
		for(unsigned char i = 0; i < socketCnt; i++)
		{
            float x ;
            memcpy(&x, (pData + dataPos), 4); dataPos += 4;
            float y;
            memcpy(&y, (pData + dataPos), 4); dataPos += 4;

			[partsInfo setSocket:i X:x Y:y];
		}
		
		[_dictPartsInfo setObject:partsInfo forKey:[NSString stringWithUTF8String:szPartsName]];
		[partsInfo release];
	}
	pos += dataSize;

	int subCnt = *(int *)(data + pos);		pos += sizeof(int);
	for(int i = 0; i < subCnt; i++)
	{
		pos = [self readPartsChunk:data Pos:pos];
	}
	
	return pos;
}

- (float)readfloat:(Byte *) buffer offset:(int) offset
{    
    float val=0;
    
    unsigned long result=0;
    result |= ((unsigned long)(buffer[offset]) << 0x18);
    result |= ((unsigned long)(buffer[offset+1]) << 0x10);
    result |= ((unsigned long)(buffer[offset+2]) << 0x08);
    result |= ((unsigned long)(buffer[offset+3]));
    memcpy(&val,&result,4);
    
    return val;
}

- (bool)openPartsInfo
{
	char *buffer = NULL;
	//	int ptr = 0;
	NSData *data = [[NSData alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"PartsInfo" ofType:@"mcb"]];
	int len = [data length];
	if(len > 0)
	{
		buffer = malloc(len);
		[data getBytes:buffer length:len];
		[self readPartsChunk:buffer Pos:0];
		
		free(buffer);
	}
	
	[data release];
	
	QTable *table = [[QTable alloc] initWithFile:[[NSBundle mainBundle] pathForResource:@"PartsList" ofType:@"tbl"]];
	for(int i = 0; i < table.row; i++)
	{
		NSString *partsName = [table getString:i Key:@"PartsName"];
		NSString *tileName = [table getString:i Key:@"TileName"];
		int tileNo = [table getInt:i Key:@"No"];

		if(tileName != nil && [tileName length] > 0 && [tileName compare:@"-"] != NSOrderedSame)
		{
			PartsInfo *partsInfo = [self getPartsInfo:partsName];
			if(partsInfo)
			{
				[partsInfo setUseCommonTile:true];
				[partsInfo setTileName:tileName];
				[partsInfo setTileNo:tileNo];
			}
		}
	}
	[table release];

	return true;
}

- (PartsInfo *)getPartsInfo:(NSString *)partsName
{
	return [_dictPartsInfo objectForKey:partsName];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (int)readMachChunk:(char *)data Pos:(int)pos Length:(int)len
{
	int tmpPos = pos;
	char szMachName[24];
	int size = *(int *)(data + pos);			pos += sizeof(int);
	int type = *(int *)(data + pos);			pos += sizeof(int);
	int dataSize = *(int *)(data + pos);		pos += sizeof(int);
	
	if(type == MCNK_MACH)
	{
		strcpy(szMachName, data + pos);
		MachInfo *machInfo = [self getMachInfo:[NSString stringWithUTF8String:szMachName]];
		if(machInfo != nil)
		{
			NSData *nsData = [[NSData alloc] initWithBytes:data + tmpPos length:size];
			[machInfo setData:nsData];
		}

		pos = tmpPos + size;
	}
	else
	{
		pos += dataSize;
		int subCnt = *(int *)(data + pos);		pos += sizeof(int);
		for(int i = 0; i < subCnt; i++)
		{
			pos = [self readMachChunk:data Pos:pos Length:len];
		}
	}
	
	return pos;
}

- (bool)openMachInfo
{
	QTable *table = [[QTable alloc] initWithFile:[[NSBundle mainBundle] pathForResource:@"MachList" ofType:@"tbl"]];
	for(int i = 0; i < table.row; i++)
	{
		MachInfo *mach = [[MachInfo alloc] init];
		NSString *type = [table getString:i Key:@"Type"];
		if([type compare:@"TANK"] == 0) mach.type = MACHTYPE_TANK;
		else if([type compare:@"TURRET"] == 0) mach.type = MACHTYPE_TURRET;
		else if([type compare:@"PLANE"] == 0) mach.type = MACHTYPE_AIRCRAFT;
		else if([type compare:@"BOT"] == 0) mach.type = MACHTYPE_BOT;

		NSString *refer = [table getString:i Key:@"Refer"];
		if([refer compare:@"BOT_A"] == 0) mach.refType = BOT_ATTACKER;
		else if([refer compare:@"BOT_D"] == 0) mach.refType = BOT_DEFENDER;
		else if([refer compare:@"BOT_P"] == 0) mach.refType = BOT_PICKER;
		else if([refer compare:@"BOT_R"] == 0) mach.refType = BOT_REPAIR;
		
		mach.hp = [table getInt:i Key:@"HP"] * 2;
		mach.exp =[table getInt:i Key:@"EXP"]; 
		mach.speed = [table getFloat:i Key:@"Spd"];
		mach.radius = [table getInt:i Key:@"Rad"]; 
		mach.coinGenRate = [table getInt:i Key:@"Coin%"];
		mach.coinGen = [table getInt:i Key:@"Coin"];
		mach.itemGen = [[NSString alloc] initWithString:[table getString:i Key:@"ItemRegen"]];
		
		if(_glView.deviceType != DEVICE_IPAD)
		{
			mach.speed *= .5f;
			mach.radius *= .5f; 
		}

		[_dictMachInfo setObject:mach forKey:[table getString:i Key:@"MachName"]];
		[mach release];
	}
	
	[table release];
	
	char *buffer = NULL;
	NSData *data = [[NSData alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"MachInfo" ofType:@"mcb"]];
	int len = [data length];
	if(len > 0)
	{
		buffer = malloc(len);
		[data getBytes:buffer length:len];
		[self readMachChunk:buffer Pos:0 Length:len];
		
		free(buffer);
	}
	
	[data release];
	
	return true;
}

- (MachInfo *)getMachInfo:(NSString *)machName
{
	return [_dictMachInfo objectForKey:machName];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (bool)openItemInfo
{
	QTable *table = [[QTable alloc] initWithFile:[[NSBundle mainBundle] pathForResource:@"ItemInfo" ofType:@"tbl"]];
	
	for(int i = 0; i < table.row; i++)
	{
		char szAttr[64];
		NSString *itemName = [table getString:i Key:@"Name"];
		NSString *type = [table getString:i Key:@"Type"];
		NSString *code = [table getString:i Key:@"Code"];
		NSString *strParam = [table getString:i Key:@"strParam"];
		strcpy(szAttr, [[table getString:i Key:@"Attr"] UTF8String]);

		ItemInfo *itemInfo = [[ItemInfo alloc] init];
		itemInfo.code = [[NSString alloc] initWithString:code];
		itemInfo.name = [[NSString alloc] initWithString:itemName];
		itemInfo.icon = [table getInt:i Key:@"Icon"];
		itemInfo.price = [table getInt:i Key:@"Price"];
		itemInfo.level = [table getInt:i Key:@"Lv"];
		itemInfo.param1 = [table getFloat:i Key:@"Param1"];
		itemInfo.param2 = [table getFloat:i Key:@"Param2"];
		itemInfo.param3 = [table getFloat:i Key:@"Param3"];
		itemInfo.strParam = [[NSString alloc] initWithString:strParam];
		for(int j = 0; j < strlen(szAttr); j++)
		{
			if(szAttr[j] == 'B') itemInfo.isBuy = true;
			else if(szAttr[j] == 'S') itemInfo.isSell = true;
			else if(szAttr[j] == 'Q') itemInfo.isSlot = true;
			else if(szAttr[j] == 'C') itemInfo.isCount = true;
		}
		[itemInfo setTypeWithString:type];
		
		[_dictItemInfo setObject:itemInfo forKey:code];
		[itemInfo release];
	}
	
	[table release];
	
	return true;
}

- (ItemInfo *)getItemInfo:(NSString *)itemCode
{
	return [_dictItemInfo objectForKey:itemCode];
}

- (NSArray *)allItems
{
	return [_dictItemInfo allKeys];
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (bool)openMachBuildSet
{
	QTable *table = [[QTable alloc] initWithFile:[[NSBundle mainBundle] pathForResource:@"MachBuild_Parts" ofType:@"tbl"]];
	for(int i = 0; i < table.row; i++)
	{
		NSString *machName = [table getString:i Key:@"MachName"];

		TMachBuildSet buildInfo;
		buildInfo.buildCount = 0;
		buildInfo.cost = [table getInt:i Key:@"Cost"];
		buildInfo.upgradeCost = [table getInt:i Key:@"UpgCost"];
		buildInfo.buildTime = [table getFloat:i Key:@"Bld"];
		buildInfo.multiBuild = [table getInt:i Key:@"Mul"];
		buildInfo.buildUnitType = [[table getString:i Key:@"Type"] compare:@"MACH"] == NSOrderedSame ? BUT_MACH : BUT_UNIT;
		buildInfo.parts = (TMachBuildParts *)malloc(sizeof(TMachBuildParts));
		buildInfo.parts->armor = [self getItemInfo:[table getString:i Key:@"Armor"]];
		buildInfo.parts->weapon = [self getItemInfo:[table getString:i Key:@"Weapon"]];
		buildInfo.parts->foot = [self getItemInfo:[table getString:i Key:@"Foot"]];
		buildInfo.parts->size = [table getInt:i Key:@"Size"];
		
		NSArray *array = [machName componentsSeparatedByString:@"_"];
		machName = [array objectAtIndex:0];
		int level = [[array objectAtIndex:1] intValue];
		
		MachBuildSet *buildSet = [self getMachBuildSet:machName];
		if(buildSet == nil)
		{
			buildSet = [[MachBuildSet alloc] init];
			buildSet.setType = BST_PARTS;
			[_dictMachBuildInfo setObject:buildSet forKey:machName];
		}
		
		[buildSet setMachName:machName];
		[buildSet setBuildSet:&buildInfo ToLevel:level-1];
	}
	[table release];
	
	table = [[QTable alloc] initWithFile:[[NSBundle mainBundle] pathForResource:@"MachBuild_Name" ofType:@"tbl"]];
	for(int i = 0; i < table.row; i++)
	{
		NSString *tmpName;
		NSString *machName = [table getString:i Key:@"MachName"];
		
		TMachBuildSet buildInfo;
		buildInfo.buildCount = 0;
		buildInfo.cost = [table getInt:i Key:@"Cost"];
		buildInfo.upgradeCost = [table getInt:i Key:@"UpgCost"];
		buildInfo.buildTime = [table getFloat:i Key:@"Bld"];
		buildInfo.multiBuild = [table getInt:i Key:@"Mul"];
		buildInfo.buildUnitType = [[table getString:i Key:@"Type"] compare:@"MACH"] == NSOrderedSame ? BUT_MACH : BUT_UNIT;
		buildInfo.name = (TMachBuildName *)malloc(sizeof(TMachBuildName));
		tmpName = [table getString:i Key:@"Bot"];
		strcpy(buildInfo.name->szBotName, [tmpName UTF8String]);
		tmpName = [table getString:i Key:@"Turret"];
		strcpy(buildInfo.name->szMachName, [tmpName UTF8String]);
		
		NSArray *array = [machName componentsSeparatedByString:@"_"];
		machName = [array objectAtIndex:0];
		int level = [[array objectAtIndex:1] intValue];
		
		MachBuildSet *buildSet = [self getMachBuildSet:machName];
		if(buildSet == nil)
		{
			buildSet = [[MachBuildSet alloc] init];
			buildSet.setType = BST_NAME;
			[_dictMachBuildInfo setObject:buildSet forKey:machName];
		}
		
		[buildSet setMachName:machName];
		[buildSet setBuildSet:&buildInfo ToLevel:level-1];
	}
	[table release];

	return true;
}

- (MachBuildSet *)getMachBuildSet:(NSString *)buildName
{
	return [_dictMachBuildInfo objectForKey:buildName];
}

- (bool)existBuyBuildSet:(NSString *)buildName
{
	for(MachBuildSet *buildSet in _listBuyBuildSet)
	{
		if([buildSet.machName compare:buildName] == NSOrderedSame) return true;
	}
	
	return false;
}

- (MachBuildSet *)buyBuildSet:(NSString *)buildName
{
	int insPos = -1;
	MachBuildSet *set = [self getMachBuildSet:buildName];
	TMachBuildSet *buildSet = [set buildSet];
	if(set != nil)
	{
		if(![self existBuyBuildSet:buildName])
		{
			for(int i = 0; i < _listBuyBuildSet.count && insPos == -1; i++)
			{
				MachBuildSet *tmp = [_listBuyBuildSet objectAtIndex:i];
				TMachBuildSet *tmpSet = [tmp buildSet];
				if(buildSet->cost < tmpSet->cost) insPos = i;
				if(buildSet->buildUnitType == BUT_MACH && tmpSet->buildUnitType == BUT_UNIT) insPos = i;
				else if(buildSet->buildUnitType == BUT_UNIT && tmpSet->buildUnitType == BUT_MACH) insPos = -1;
			}

			if(insPos == -1) [_listBuyBuildSet addObject:set];
			else [_listBuyBuildSet insertObject:set atIndex:insPos];
		}
	}
	
	return set;
}

- (void)clearBuyBuildSet
{
	[_listBuyBuildSet removeAllObjects];
}

- (NSArray *)listBuyBuildSet
{
	return _listBuyBuildSet;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (bool)openSpAttackList
{
	QTable *table = [[QTable alloc] initWithFile:[[NSBundle mainBundle] pathForResource:@"SpAttackList" ofType:@"tbl"]];
	for(int i = 0; i < table.row; i++)
	{
		NSString *attackName = [table getString:i Key:@"AttackName"];
		
		TSpAttackSet attackInfo;
		attackInfo.cost = [table getInt:i Key:@"Cost"];
		attackInfo.upgradeCost = [table getInt:i Key:@"UpgCost"];
		attackInfo.itemId = [table getInt:i Key:@"ItemId"];
		
		NSArray *array = [attackName componentsSeparatedByString:@"_"];
		attackName = [array objectAtIndex:0];
		int level = [[array objectAtIndex:1] intValue];
		
		SpAttackSet *attackSet = [self getSpAttackSet:attackName];
		if(attackSet == nil)
		{
			attackSet = [[SpAttackSet alloc] init];
			[_dictSpAttackInfo setObject:attackSet forKey:attackName];
		}
		
		[attackSet setAttackName:attackName];
		[attackSet setAttackSet:&attackInfo ToLevel:level-1];
		if(attackSet.maxLevel < level) attackSet.maxLevel = level;
        if(![self existBuyAttackSet:attackName])
        {
            attackSet.count = 0;
            [_listBuyAttackSet addObject:attackSet];
        }
	}
    NSLog(@"SpAttack count : %d",[_listBuyAttackSet count]);
	[table release];
	
	return true;
}

- (SpAttackSet *)getSpAttackSet:(NSString *)attackName
{
	return [_dictSpAttackInfo objectForKey:attackName];
}

- (bool)existBuyAttackSet:(NSString *)attackName
{
	for(SpAttackSet *attackSet in _listBuyAttackSet)
	{
		if([attackSet.attackName compare:attackName] == NSOrderedSame) return true;
	}
	
	return false;
}

- (SpAttackSet *)buyAttackSet:(NSString *)attackName Count:(int)cnt
{
	SpAttackSet *set = [self getSpAttackSet:attackName];
	if(set != nil)
	{
		if(![self existBuyAttackSet:attackName]) [_listBuyAttackSet addObject:set];
		set.count += cnt;
	}
	
	return set;
}

- (void)clearAttackSet
{
	[_listBuyAttackSet removeAllObjects];
}

- (void)resetAttackSet
{
	for(SpAttackSet *set in _listBuyAttackSet)
    {
        set.count = 0;
    }
}

- (NSArray *)listBuyAttackSet
{
	return _listBuyAttackSet;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (bool)openBaseUpgradeInfo
{
	QTable *table = [[QTable alloc] initWithFile:[[NSBundle mainBundle] pathForResource:@"BaseUpgrade" ofType:@"tbl"]];
	for(int i = 0; i < table.row; i++)
	{
		NSString *upgradeName = [table getString:i Key:@"UpgradeName"];
		
		TBaseUpgradeSet upgradeInfo;
		upgradeInfo.upgradeCost = [table getInt:i Key:@"UpgCost"];
		upgradeInfo.param = [table getFloat:i Key:@"Param"];
		
		NSArray *array = [upgradeName componentsSeparatedByString:@"_"];
		upgradeName = [array objectAtIndex:0];
		int level = [[array objectAtIndex:1] intValue];
		
		BaseUpgradeSet *upgradeSet = [self getBaseUpgradeSet:upgradeName];
		if(upgradeSet == nil)
		{
			upgradeSet = [[BaseUpgradeSet alloc] init];
			[_dictBaseUpgradeInfo setObject:upgradeSet forKey:upgradeName];
		}
		
		[upgradeSet setUpgradeName:upgradeName];
		[upgradeSet setUpgradeSet:&upgradeInfo ToLevel:level-1];
		if(upgradeSet.maxLevel < level) upgradeSet.maxLevel = level;
	}
	[table release];
	
	return true;
}

- (BaseUpgradeSet *)getBaseUpgradeSet:(NSString *)upgradeName
{
	return [_dictBaseUpgradeInfo objectForKey:upgradeName];
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (bool)openWeaponInfo
{
	QTable *table = [[QTable alloc] initWithFile:[[NSBundle mainBundle] pathForResource:@"WeaponInfo" ofType:@"tbl"]];
	
	for(int i = 0; i < table.row; i++)
	{
		NSString *wpnName = [table getString:i Key:@"Parts"];
		NSString *type = [table getString:i Key:@"Type"];
		short dmg = [table getInt:i Key:@"Dmg"];
		short dmgRange = [table getInt:i Key:@"Range"];
		short shotRng = [table getInt:i Key:@"ShtRng"] * 1.5f;
		short shotCnt = [table getInt:i Key:@"ShtCnt"];
		float shotDly = [table getFloat:i Key:@"ShtDly"];
		float reloadDly = [table getFloat:i Key:@"RldDly"];
		float spd = [table getFloat:i Key:@"Speed"];
		float aimRand = [table getFloat:i Key:@"AimRt"];
		float spParam1 = [table getFloat:i Key:@"sp1"];
		float spParam2 = [table getFloat:i Key:@"sp2"];
		NSString *bulletTile = [table getString:i Key:@"BltTile"];
		NSString *effectType = [table getString:i Key:@"EffType"];
		NSString *effectTile = [table getString:i Key:@"EffTile"];
		NSString *explodeTile = [table getString:i Key:@"ExplodeEff"];
		float explodeScale = [table getFloat:i Key:@"ExplScl"];
		short shell = [table getInt:i Key:@"Shell"];
		NSString *fireSfx = [table getString:i Key:@"FireSound"];
		short uiTile = [table getInt:i Key:@"UiTile"];
		
		UInt32 fireSfxID = [fireSfx compare:@"-"] == NSOrderedSame ? UINT_MAX : [SOUNDMGR getSound:fireSfx];

		WeaponInfo *weaponInfo = [[WeaponInfo alloc] init];
		if([type compare:@"Gun"] == 0) weaponInfo.wpnType = WPN_NORMAL;
		else if([type compare:@"Shotgun"] == 0) weaponInfo.wpnType = WPN_SHOTGUN;
		else if([type compare:@"Laser"] == 0) weaponInfo.wpnType = WPN_LASER;
		else if([type compare:@"Railgun"] == 0) weaponInfo.wpnType = WPN_RAILGUN;
		else if([type compare:@"EMP"] == 0) weaponInfo.wpnType = WPN_EMP;
		else if([type compare:@"Bomb"] == 0) weaponInfo.wpnType = WPN_BOMB;
		else if([type compare:@"Missile"] == 0) weaponInfo.wpnType = WPN_MISSILE;
		else if([type compare:@"Sniper"] == 0) weaponInfo.wpnType = WPN_SNIPER;
		else if([type compare:@"Nuclear"] == 0) weaponInfo.wpnType = WPN_NUCLEAR;
		else if([type compare:@"Bullet"] == 0) weaponInfo.wpnType = WPN_BULLET;
		
		if(_glView.deviceType != DEVICE_IPAD)
		{
			dmgRange *= .5f;
			shotRng *= .5f;
			spd *= .5f;
		}
		
		weaponInfo.dmg = dmg;
		weaponInfo.dmgRange = dmgRange;
		weaponInfo.shotRange = shotRng;
		weaponInfo.shotCnt = shotCnt;
		weaponInfo.shotDly = shotDly;
		weaponInfo.spd = spd;
		weaponInfo.aimRate = aimRand;
		weaponInfo.reloadDly = reloadDly;
		weaponInfo.spParam1 = spParam1;
		weaponInfo.spParam2 = spParam2;
		if([bulletTile compare:@"-"] != 0)
		{
			NSArray *array = [bulletTile componentsSeparatedByString:@"_"];
			bulletTile = [array objectAtIndex:0];
			int tileNo = [[array objectAtIndex:1] intValue];

			[weaponInfo setBulletTile:[TILEMGR getTile:[NSString stringWithFormat:@"Blt_%@.png", bulletTile]] TileNo:tileNo];
		}
		
		if([effectType compare:@"Trail"] == 0)
		{
			[weaponInfo setEffectType:BULLETEFF_SMOKETRAIL Tile:[TILEMGR getTileForRetina:[effectTile stringByAppendingString:@".png"]]];
			[weaponInfo.effectTile tileSplitX:1 splitY:1];
		}
		else if([effectType compare:@"Smoke"] == 0)
		{
			[weaponInfo setEffectType:BULLETEFF_SMOKE Tile:[TILEMGR getTileForRetina:[effectTile stringByAppendingString:@".png"]]];
			[weaponInfo.effectTile tileSplitX:1 splitY:1];
		}
		else if([effectType compare:@"Ion"] == 0)
		{
			[weaponInfo setEffectType:BULLETEFF_ION Tile:[TILEMGR getTileForRetina:[effectTile stringByAppendingString:@".png"]]];
			[weaponInfo.effectTile tileSplitX:1 splitY:1];
		}
		else if([effectType compare:@"Laser"] == 0)
		{
			[weaponInfo setEffectType:BULLETEFF_LASER Tile:[TILEMGR getTileForRetina:[effectTile stringByAppendingString:@".png"]]];
			[weaponInfo.effectTile tileSplitX:1 splitY:1];
		}
		else if([effectType compare:@"Rail"] == 0)
		{
			[weaponInfo setEffectType:BULLETEFF_RAILGUN Tile:[TILEMGR getTileForRetina:[effectTile stringByAppendingString:@".png"]]];
			[weaponInfo.effectTile tileSplitX:4 splitY:4];
		}
		else if([effectType compare:@"Flame"] == 0)
		{
			[weaponInfo setEffectType:BULLETEFF_FLAME Tile:[TILEMGR getTileForRetina:[effectTile stringByAppendingString:@".png"]]];
			[weaponInfo.effectTile tileSplitX:1 splitY:1];
		}
		else if([effectType compare:@"Shotgun"] == 0)
		{
			[weaponInfo setEffectType:BULLETEFF_SHOTGUN Tile:[TILEMGR getTileForRetina:[effectTile stringByAppendingString:@".png"]]];
			[weaponInfo.effectTile tileSplitX:1 splitY:1];
		}
		else
		{
			[weaponInfo setEffectType:BULLETEFF_NONE Tile:nil];
		}
		
		if([explodeTile compare:@"-"] != 0)
		{
			[weaponInfo setExplodeTile:[TILEMGR getTileForRetina:[NSString stringWithFormat:@"Efx_%@.png", explodeTile]]];
			weaponInfo.explodeScale = explodeScale;
		}
		
		weaponInfo.shell = shell;
		weaponInfo.fireSFX = fireSfxID;
		weaponInfo.uiTile = uiTile;
		
		[weaponInfo calcAtkPoint];

		[_dictWeaponInfo setObject:weaponInfo forKey:wpnName];
		[weaponInfo release];
	}
	
	[table release];
	
	return true;
}

- (WeaponInfo *)getWeaponInfo:(NSString *)weaponName
{
	return [_dictWeaponInfo objectForKey:weaponName];
}

- (void)restoreWeaponSound
{
	QTable *table = [[QTable alloc] initWithFile:[[NSBundle mainBundle] pathForResource:@"WeaponInfo" ofType:@"tbl"]];
	for(int i = 0; i < table.row; i++)
	{
		NSString *wpnName = [table getString:i Key:@"Parts"];
		
		WeaponInfo *info = [self getWeaponInfo:wpnName];
		if(info)
		{
			NSString *fireSfx = [table getString:i Key:@"FireSound"];
			UInt32 fireSfxID = [fireSfx compare:@"-"] == NSOrderedSame ? UINT_MAX : [SOUNDMGR getSound:fireSfx];
			info.fireSFX = fireSfxID;
		}
	}
	
	[table release];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (bool)openDescriptionList
{
	if(_dictDescription != nil)
	{
		[_dictDescription release];
		_dictDescription = nil;
	}
	_dictDescription = [[NSMutableDictionary dictionaryWithCapacity: 10] retain];
	
	NSString *fileName = [[NSString alloc] initWithFormat:@"Description_%@", _localeCode];
	QTable *table = [[QTable alloc] initWithFile:[[NSBundle mainBundle] pathForResource:fileName ofType:@"tble"]];
	[fileName release];
	
	for(int i = 0; i < table.row; i++)
	{
		NSString *key = [table getString:i Key:@"Key"];
		char szValue[1024];
		strcpy(szValue, [[table getString:i Key:@"Value"] UTF8String]);
		for(int i = 0; i < strlen(szValue); i++)
		{
			if(szValue[i] == '|') szValue[i] = '\n'; 
		}

		NSString *desc = [[NSString alloc] initWithUTF8String:szValue];

		[_dictDescription setObject:desc forKey:key];
		[desc release];
	}
	
	[table release];
	
	return true;
}

- (NSString *)getDescription:(NSString *)key
{
	return [_dictDescription objectForKey:key];
}

@end
