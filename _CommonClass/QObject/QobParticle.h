//
//  ObjectBall.h
//  Jumping!
//
//  Created by 엔비 on 08. 09. 15.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ColVector;

@interface QobParticle : QobImage
{
	CGPoint _vel, _scaleScale;
	float _g;
	float _radius;
	float _rotVel;
	float _scaleVel;
	float _easyOutScale;
	float _easyOutValue;
	float _velAdd;
	float _liveTime;
	float _startTime;
	float _sinRotate;
	float _sinRotValue;
	float _maxAlpha;
	
	ColVector *_col;
	float _groundPos;
	
	int _aniFrame;
	BOOL _tileAni;
	BOOL _waterAni;
	BOOL _selfRemove;
	BOOL _fadeOut;
	BOOL _removeScreenOut;
	
	float _waterAniValue;
}	

- (void)reset;
- (void)start;

@property(readonly) CGPoint vel;
@property(readwrite) float g;
@property(readwrite) float radius;
@property(readwrite) float rotVel, sinRotate, sinRotValue;
@property(readwrite) float scaleVel, easyOutScale, easyOutValue;
@property(readwrite) float groundPos;
@property(readwrite) float velAdd;
@property(readwrite) float maxAlpha;
@property(readwrite) BOOL waterAni, fadeOut;

//- (void)tick;
- (void)processFly;

- (void)setTileAni:(int)frameCnt;
- (void)setLiveTime:(float)time;
- (void)setBound:(ColVector *)col;
- (void)setSelfRemove:(BOOL)selfRemove;

- (void)setColVector:(ColVector *)col;
- (void)setVelX:(float)x Y:(float)y;

@end
