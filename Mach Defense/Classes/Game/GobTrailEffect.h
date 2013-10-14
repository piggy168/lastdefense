//
//  GobSmokeEffect.h
//  HeavyMach
//
//  Created by 엔비 on 08. 12. 27.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

struct TTrailPos
{
	CGPoint pt;
	CGPoint normal;
	float time;
};
typedef struct TTrailPos TTrailPos;


@interface GobTrailEffect : QobImage
{
	float _blockWidth, _blockLen;
	int _blockCnt;
	
	float _fadeDelay;
	float _fadeTime;
	
	CGPoint *_coords;
	CGPoint *_vertices;
	GLfloat *_colors;
	TTrailPos *_posArray;
	
	int _lastPos;
	bool _oddCoord;
	float _windEffect;
	float _diffuseEffect;
}

@property(readwrite) float windEffect, diffuseEffect;

- (void)setTrailWidth:(float)width Len:(float)len BlockCnt:(int)cnt FadeDelay:(float)delay FadeTime:(float)time;
- (void)addTrailPosX:(float)x Y:(float)y;
- (void)addValidPosX:(float)x Y:(float)y IsAdd:(bool)add;

- (void)draw;

@end
