//
//  GlobalInfo.h
//  HeavyMach
//
//  Created by 엔비 on 08. 12. 05.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#define GINFO	[GlobalInfo sharedInfo]
#define GSLOT	GINFO.slotData
#define GVAL	g_value

enum ESoundID
{
	SND_MENU_CLICK, SND_BTN_OK, SND_BTN_CANCEL,
	SND_GETITEM, SND_LOWHP, SND_AIRSTRIKE,
	SND_ONMSG, SND_QUICKSLOT, 
	SND_HITMACH_01, SND_HITMACH_02, SND_HITMACH_03, SND_HITMACH_04,
	SND_HITGROUND, SND_EXPLGROUND, SND_EXPLMACH, SND_PLASMADMG, 
	SND_BUILDMACH, SND_BUILDMACH_COMPLETE,
	SND_UI_BUILDMACH, SND_UI_SPATTACK, SND_UI_FORMATION,
	SND_INSTALL, SND_UNINSTALL, SND_BUY_SPATTACK,
	SND_UPGRADE_BASE, SND_UPGRADE_MACH, SND_UPGRADE_SPATTACK,
	SND_MAX
};

enum EMachChunk
{
	MCNK_PARTSLIST, MCNK_PARTS,
	MCNK_MACHLIST, MCNK_MACH, MCNK_MACHPARTS
};

enum EMapChunk
{
	MCNK_MAPLIST, MCNK_MAP, MCNK_WARPGATE, MCNK_COLBOX, MCNK_SPAWNER
};

enum EWeaponChunk
{
	WCNK_WEAPONLIST, WCNK_WEAPONDATA
};

enum EWeaponUpgradeType
{
	WPNUG_MG, WPNUG_MSL, WPNUG_SG, WPNUG_LG, WPNUG_HMG, WPNUG_HMSL, WPNUG_PG, MAX_WPNUG_TYPE
};

struct TMissionData
{
	char mId[8];
	bool accept;
	char didRequire[10];
	bool requireComplete;
	bool complete;
};
typedef struct TMissionData TMissionData;

struct TSaveMachData
{
	bool onSlot;
	char name[32];
	int level;
};
typedef struct TSaveMachData TSaveMachData;

struct TSaveSpAttackData
{
	bool onSlot;
	char name[32];
	int level, count;
};
typedef struct TSaveSpAttackData TSaveSpAttackData;

struct TSaveSlotData
{
	time_t createTime;
	time_t lastAccess;

	BOOL use;
	int runCount;
	char name[32];
	char country[4];

	int stage, lastStage, cr;
	
	int spAttackCount;
	TSaveSpAttackData spAttackData[64];
	int machCount;
	TSaveMachData machData[128];
	
	char baseUpgrade[16];
	char stageClearCount[245];
	
	bool formation[7];
	
	int score;
	float bgmVol, sfxVol;
};
typedef struct TSaveSlotData TSaveSlotData;

struct TDataFile
{
	int randSeed;
	int runCount;
	int version;
	int purchased[254];
	int loadingGallery;
	TSaveSlotData slot[MAX_SAVESLOT];
	int checkSum;
};
typedef struct TDataFile TDataFile;

struct TGlobalValue
{
	int selSaveSlot;
	float moveLimit;
	float mineral, maxMineral, mineralUpgradeValue, incMineral;
	float buildTime, crGen, baseDef;
	int killEnemies, deadMachs;
	int cellUpgrade, cellUpgradeCost;
};
typedef struct TGlobalValue TGlobalValue;

@class MachBuildSet;
@class SpAttackSet;
@class BaseUpgradeSet;
//@class Ranking;

@interface GlobalInfo : NSObject
{
	NSMutableDictionary *_dictPartsInfo;
	NSMutableDictionary *_dictMachInfo;
	NSMutableDictionary *_dictItemInfo;
	NSMutableDictionary *_dictWeaponInfo;
	NSMutableDictionary *_dictMachBuildInfo;
	NSMutableDictionary *_dictSpAttackInfo;
	NSMutableDictionary *_dictBaseUpgradeInfo;
	NSMutableDictionary *_dictMapInfo;
	NSMutableDictionary *_dictMapName;
    CGPoint _listMapPosition[70];
	NSMutableDictionary *_dictDescription;
	NSMutableArray *_listBuyBuildSet;
	NSMutableArray *_listBuyAttackSet;
	
	QTable *_tileList;
	
	NSString *_localeCode;
//	Ranking *_ranking;

	int _selectedSlot;
	int _gameMode;
	
	UInt32 _sfxID[SND_MAX];

	TDataFile _saveData;
	TSaveSlotData *_slotData;
}

@property(readwrite) int gameMode;
@property(readwrite) TSaveSlotData *slotData;
//@property(readonly) Ranking *ranking;
@property(readonly) NSString *localeCode;
@property(readonly) QTable *tileList;

+ (GlobalInfo *)sharedInfo;

- (void)setLocaleCode:(const char *)locale;
- (int)runCount;

- (void)loadSFX;
- (UInt32)sfxID:(int)nSndID;
- (float)readfloat:(Byte *) buffer offset:(int) offset;

- (void)updateBaseUpgrade;

- (bool)existEmptySlot;
- (int)initSlotWithName:(NSString *)name Country:(NSString *)country;
- (bool)selectSlot:(int)n;
- (void)deleteSlot:(int)n;
- (TSaveSlotData *)slotData:(int)n;

- (void)openDataFile;
- (void)saveDataFile;

- (bool)openMapInfo;
- (QChunk *)getMapInfo:(NSString *)mapName;
- (NSString *)getMapName:(NSString *)mapId;
- (CGPoint)getMapPosition:(NSString *)mapId;
- (CGPoint)getMapPositionFromIndex:(int)nMapIndex;

- (int)readPartsChunk:(char *)data Pos:(int)pos;
- (bool)openPartsInfo;
- (PartsInfo *)getPartsInfo:(NSString *)partsName;

- (int)readMachChunk:(char *)data Pos:(int)pos Length:(int)len;
- (bool)openMachInfo;
- (MachInfo *)getMachInfo:(NSString *)machName;

- (bool)openMachBuildSet;
- (MachBuildSet *)getMachBuildSet:(NSString *)buildName;
- (bool)existBuyBuildSet:(NSString *)buildName;
- (MachBuildSet *)buyBuildSet:(NSString *)buildName;
- (void)clearBuyBuildSet;
- (NSArray *)listBuyBuildSet;

- (bool)openSpAttackList;
- (SpAttackSet *)getSpAttackSet:(NSString *)attackName;
- (bool)existBuyAttackSet:(NSString *)attackName;
- (SpAttackSet *)buyAttackSet:(NSString *)attackName Count:(int)cnt;
- (void)clearAttackSet;
- (NSArray *)listBuyAttackSet;

- (bool)openBaseUpgradeInfo;
- (BaseUpgradeSet *)getBaseUpgradeSet:(NSString *)upgradeName;

- (bool)openItemInfo;
- (ItemInfo *)getItemInfo:(NSString *)itemCode;
- (NSArray *)allItems;

- (bool)openWeaponInfo;
- (WeaponInfo *)getWeaponInfo:(NSString *)weaponName;
- (void)restoreWeaponSound;

- (bool)openDescriptionList;
- (NSString *)getDescription:(NSString *)key;


@end
