//
//  ResMgr_Sound.m
//  HeavyMach
//
//  Created by 엔비 on 08. 12. 09.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "SoundManager.h"

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
@implementation SoundID
@synthesize soundID=_soundID;
@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
@implementation SoundManager
static SoundManager *_sharedMgr = nil;

+ (SoundManager *)sharedMgr
{
	@synchronized(self)
	{
		if(!_sharedMgr) _sharedMgr = [[SoundManager alloc] init];
		return _sharedMgr;
	}
	
	return nil;
}

/*+ (id)alloc
{
	@synchronized(self)
	{
		_sharedMgr = [super alloc];
		return _sharedMgr;
	}
	
	return nil;
}*/

- (id)init
{
	if(![super init]) return nil;
	
#if !TARGET_IPHONE_SIMULATOR
	SoundEngine_Initialize(22050);				//Setup sound engine. Run  it at 44Khz to match the sound files
#endif
	SoundEngine_SetListenerPosition(0, 0, 0);	// Assume the listener is in the center at the start. The sound will pan as the position of the rocket changes.

	_dictSound = [[NSMutableDictionary dictionaryWithCapacity: 10] retain];
	return self;
}

- (void)setBackground
{
	if(_dictSound) [_dictSound release];
	_dictSound = nil;
	SoundEngine_Teardown();	
}

- (void)setPause
{
	if(_dictSound) [_dictSound release];
	_dictSound = nil;
}

- (void)dealloc
{
	SoundEngine_Teardown();	

	[_dictSound release];
	[super dealloc];
}

- (void)setListnerPosX:(float)x Y:(float)y
{
	SoundEngine_SetListenerPosition(x, y, 0);
	_listnerPos.x = x;
	_listnerPos.y = y;
}

- (void)setMaxDistance:(float)distance
{
	SoundEngine_SetMaxDistance(distance);
}

- (UInt32)getSound:(NSString*)fileName
{
	UInt32 soundID = 0;
	SoundID *sID;
	
	if((sID = [_dictSound objectForKey: fileName])) return sID.soundID;
	
	SoundEngine_LoadEffect([[[NSBundle mainBundle] pathForResource:fileName ofType:@""] UTF8String], &soundID);
	sID = [[SoundID alloc] init];
	sID.soundID = soundID;

	[_dictSound setObject:sID forKey:fileName];
	[sID release];
	
	return soundID;
}

- (void)removeAllSounds
{
	[_dictSound removeAllObjects];
}

- (void)removeSound:(UInt32)soundID
{
//	NSAssert(sound != nil, @"ResMgr_Sound: tile MUST not be nill");
//	[_dictSound removeObjectForKey:sound];
}

- (void)play:(UInt32)sndID
{
	SoundEngine_SetEffectPosition(sndID, 0, 0, 0);
	SoundEngine_StartEffect(sndID);
}

- (void)play:(UInt32)sndID X:(float)x Y:(float)y
{
	SoundEngine_SetEffectPosition(sndID, x, y, 0);
	SoundEngine_StartEffect(sndID);
}

- (void)setSFXVolume:(float)vol
{
	SoundEngine_SetEffectsVolume(vol);
}

- (void)playBGM:(NSString *)fileName
{
	SoundEngine_StopBackgroundMusic(true);
	SoundEngine_UnloadBackgroundMusicTrack();
	SoundEngine_LoadBackgroundMusicTrack([[[NSBundle mainBundle] pathForResource:fileName ofType:@""] UTF8String], false, false);
	SoundEngine_StartBackgroundMusic();
}

- (void)setBGMVolume:(float)vol
{
	SoundEngine_SetBackgroundMusicVolume(vol);
}

@end
