/*
 *  GameDef.h
 *  Indiean co ltd
 *
 *  Created by 엔비 on 08. 09. 17.
 *  Copyright 2008 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef __GAMEDEF__
#define __GAMEDEF__

#define RANDOM_SEED				srandom((unsigned)(mach_absolute_time() & 0xFFFFFFFF))
#define RANDOMF(max)			((float)random() / (float)RAND_MAX * (float)max)
#define RANDOMFC(max)			((float)random() / (float)RAND_MAX * ((float)max * 2.f) - (float)max)
#define RANDOM(max)				(random() % max)

#define EASYOUT(a, b, t)		(a += (b - a) / t)
#define EASYOUTE(a, b, t, e)	if(a!=b && fabs(a-b) > e) a += (b-a)/t; else a = b 
#define FOLLOW(a, b, s)			if(a-b > s) a -= s; else if(b-a > s) a += s; else a = b

#define GRAVITY					2.f

#define M_2PI					6.283185f

#define MAX_PARTS				12
#define MAX_PARTICLE			256
#define MAX_PATH				12
#define MAX_TARGET				16
#ifdef _LITE_VERSION_
	#define MAX_STAGE			7
#else
	#define MAX_STAGE			70
#endif

#define MAX_SAVESLOT			5

//#define MAP_LEN				2048
//#define MAP_HALF_LEN			1024

//#define MAX_SLOPE				.7f
#define MAX_MACHPARTS			10

#define BUILDSLOT_SIZE			7
#define BOTSLOT_SIZE			3

#define LEADERBOARD_EXP			@"415634"

enum EGameMode
{
	GMODE_SCENARIO, GMODE_SURVIVAL
};

enum EButtonID
{
	BTNID_BEGIN = 1000,
	BTNID_OK, BTNID_YES, BTNID_NO,
	BTNID_BACK, BTNID_DEL,
    BTNID_BASE, BTNID_UNIT, BTNID_BOMB,
	BTNID_TO_SELSLOT, BTNID_SELSLOT, BTNID_DELSLOT,
	BTNID_DELSLOT_OK, BTNID_DELSLOT_NO,
	BTNID_TO_SELSTAGE, BTNID_SELSTAGE, BTNID_BUYFULLVERSION, 
	BTNID_STAGECLEAR_BACK, BTNID_STAGECLEAR_NEXT, BTNID_STAGECLEAR_RETRY, BTNID_STAGECLEAR_EXIT,
	BTNID_ORDER_BACK,
	BTNID_UPGRADE_CELL, BTNID_UPGRADE_EQUIP, BTNID_UPGRADE_EQUIP_CLOSE,
	BTNID_UPGRADEMACH_UPGRADE, BTNID_UPGRADEMACH_INSTALL, BTNID_UPGRADEMACH_UNINSTALL,
	BTNID_UPGRADEATTACK_UPGRADE, BTNID_UPGRADEATTACK_BUY, BTNID_UPGRADEATTACK_INSTALL, BTNID_UPGRADEATTACK_UNINSTALL,
	BTNID_UPGRADE_BASE_ITEM, BTNID_UPGRADE_BASE_UPGRADE,
	BTNID_MAKE_MACH, BTNID_FORMATION, BTNID_SPECIAL_ATTACK, 
	BTNID_MAKEMACH_SELMACH, 
	BTNID_SPATTACK_SELATTACK, BTNID_SPATTACK_OK, BTNID_SPATTACK_CANCEL,
	BTNID_UPGRADE_MACH, BTNID_UPGRADE_ATTACK, BTNID_UPGRADE_BASE, BTNID_BUY_ITEM, 
	BTNID_GAMEMENU, 
	BTNID_RESUME_GAME, BTNID_SAVE_EXIT, BTNID_VISIT_INDIEAPPS, BTNID_HELP, BTNID_LEADERBOARD,
	BTNID_THUMB_BGM, BTNID_THUMB_SFX, 
	BTNID_TO_RANKING = 6000, BTNID_RANK_PREV, BTNID_RANK_NEXT,
};

enum EPartsType
{
	PARTS_BASE, PARTS_BTM, PARTS_FOOT, PARTS_BODY, PARTS_WPN, PARTS_WPN_L, PARTS_WPN_R, PARTS_PROP
};

enum EMachType
{
	MACHTYPE_BIPOD, MACHTYPE_TANK, MACHTYPE_AIRCRAFT, MACHTYPE_TURRET, MACHTYPE_TRAIN, MACHTYPE_BOT
};

enum EBotType
{
	BOT_ATTACKER, BOT_DEFENDER, BOT_PICKER, BOT_REPAIR
};

#endif