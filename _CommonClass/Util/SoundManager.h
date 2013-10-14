//
//  ResMgr_Sound.h
//  HeavyMach
//
//  Created by 엔비 on 08. 12. 09.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

//#import "SoundEffect.h"

#define SOUNDMGR		[SoundManager sharedMgr]

@interface SoundID : NSObject
{
	UInt32 _soundID;
}
@property(readwrite) UInt32 soundID;

@end


@interface SoundManager : NSObject
{
	NSMutableDictionary *_dictSound;
	CGPoint _listnerPos;
}

+ (SoundManager *)sharedMgr;

- (void)setBackground;
- (void)setPause;

- (void)setListnerPosX:(float)x Y:(float)y;
- (void)setMaxDistance:(float)distance;

- (UInt32)getSound:(NSString *)fileName;
- (void)removeAllSounds;
- (void)removeSound:(UInt32)soundID;

- (void)play:(UInt32)sndID;
- (void)play:(UInt32)sndID X:(float)x Y:(float)y;
- (void)setSFXVolume:(float)vol;

- (void)playBGM:(NSString *)fileName;
- (void)setBGMVolume:(float)vol;

@end
