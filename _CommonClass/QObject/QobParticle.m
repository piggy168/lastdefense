//
//  ObjectParticle.m
//  Jumping!
//
//  Created by 엔비 on 08. 10. 05.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "GameMain.h"
#import "QVector.h"
#import "Collider.h"
#import "QobParticle.h"

@implementation QobParticle

@synthesize vel=_vel, g=_g, radius=_radius, rotVel=_rotVel, sinRotate=_sinRotate, sinRotValue=_sinRotValue, scaleVel=_scaleVel, easyOutScale=_easyOutScale, easyOutValue=_easyOutValue, groundPos=_groundPos, velAdd=_velAdd, waterAni=_waterAni, fadeOut=_fadeOut, maxAlpha=_maxAlpha;

- (id)init
{
	[super init];

	_visual = true;
	_selfRemove = false;

	[self reset];
	
	return self;
}

- (void)reset
{
	_useAtlas = true;
	_tileNo = 0;
	_alpha = 1.f;
    _maxAlpha = 1.f;
	[self setPosX:0.f Y:0.f];
	_vel.x = _vel.y = 0.f;
	_g = 0.f;
	_scaleX = 1.f;
	_scaleY = 1.f;
	_rotate = 0.f;
	_radius = 10.f;
	_rotVel = 0.f;
	_scaleVel = 0.f;
	_easyOutValue = 0.f;
	_velAdd = 0.f;
	_liveTime = 0.f;
	_tileAni = false;
	_aniFrame = 0;
	_startTime = (float)g_time;
	_blendType = BT_ADD;
	
	_col = nil;
	_groundPos = -1000.f;
	_waterAniValue = RANDOMF(20.f) + 50.f;
	_waterAni = false;
	_fadeOut = true;
	
	_scaleScale.x = _scaleScale.y = 1.f;
	
	_selfRemove = false;
}

- (void)setTileAni:(int)frameCnt
{
	_tileAni = true;
	_aniFrame = frameCnt;
	_fadeOut = false;
}

- (void)setLiveTime:(float)time
{
	_liveTime = time;
}

- (void)start
{
	_startTime = (float)g_time;
	_show = true;
}

- (void)dealloc
{
	[super dealloc];
}

- (void)tick
{
	if(!_show) return;

	[self processFly];
	
	if(_liveTime != 0.f)
	{
		float dt = g_time - _startTime;
		if(dt < _liveTime)
		{
			if(_tileAni)
			{
				_tileNo = (int)((dt / _liveTime) * (float)_aniFrame + .5f);
			}
			
			if(_fadeOut)
			{
				_alpha = (1.f - dt / _liveTime) * _maxAlpha;
			}
			
			if(_waterAni)
			{
				_scaleScale.x = 1.f + cosf(dt * _waterAniValue) * .3f;
				_scaleScale.y = 1.f + sinf(dt * _waterAniValue * 1.5f) * .3f;
				_rotate = sinf(dt * _waterAniValue) * 1.f;
				if(_pos.y > _cam.halfScr.height + 40)
				{
					_show = false;
					if(_selfRemove) [self remove];
				}
			}
			
			if(_sinRotate != 0)
			{
				_rotate = sinf(dt * _sinRotate) * _sinRotValue;
			}
			
			if(_easyOutValue != 0.f)
			{
				EASYOUT(_scaleX, _easyOutScale, _easyOutValue);
				EASYOUT(_scaleY, _easyOutScale, _easyOutValue);
			}
			else
			{
				_scaleX += _scaleVel;
				_scaleY += _scaleVel;
			}
		}
		else
		{
			_show = false;
			if(_selfRemove) [self remove];
		}
	}

	[super tick];			// 수퍼클래스의 틱을 나중에 호출해 주어야 한다.
}

- (void)draw
{
	[_tile drawTile:_tileNo x:SCRPOS_X y:SCRPOS_Y blendType:_blendType alpha:_alpha scaleX:_scaleX*_scaleScale.x scaleY:_scaleY*_scaleScale.y rotate:_rotate];
}

- (void)processFly
{
	CGPoint vel = { _vel.x, _vel.y };
	
	vel.y -= _g * TICK_INTERVAL;

	[self addPos:&vel];
	
	_rotate += _rotVel;
	_scaleX += _scaleVel;
	_scaleY += _scaleVel;
	if(_velAdd)
	{
		vel.x += vel.x * _velAdd;
		vel.y += vel.y * _velAdd;
	}
	
	_vel.x = vel.x;		_vel.y = vel.y;
}

- (void)setSelfRemove:(BOOL)selfRemove
{
	_selfRemove = selfRemove;
}

- (void)setBound:(ColVector *)col
{
/*	float normalLen = fabs([_vel dotProduct:[col normal]]);

	Vector2 *normalVel = [[Vector2 alloc] initFromVector:[col normal]];
	[normalVel mul:normalLen];		// normalVel = col.normal * normalLen;

	Vector2 *tangentVel = [[Vector2 alloc] initFromVector:_vel];
	[tangentVel add:normalVel];		// tangentVel = _vel + normalVel;
	[tangentVel mul:.7f];			// tangentVel *= friction;
	
	[normalVel add:tangentVel];
	[normalVel mul:.3f];			// tangentVel *= elastic;
	[_vel copyFrom:normalVel];		// _vel = normalVel + tangentVel;
	
	[normalVel release];
	[tangentVel release];
	
	_rotVel *= 0.4;
	if(_rotVel < .1f) _rotVel = 0.f;*/
}

- (void)setColVector:(ColVector *)col
{
	_col = col;
}

- (void)setVelX:(float)x Y:(float)y
{
	_vel.x = x;
	_vel.y = y;
}

@end
