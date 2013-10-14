//
//  GobSmokeEffect.m
//  HeavyMach
//
//  Created by 엔비 on 08. 12. 27.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "GobTrailEffect.h"


@implementation GobTrailEffect

@synthesize windEffect=_windEffect, diffuseEffect=_diffuseEffect;

- (id)init
{
	[super init];
	
	_windEffect = true;
	_diffuseEffect = true;

	return self;
}

- (void)setTrailWidth:(float)width Len:(float)len BlockCnt:(int)cnt FadeDelay:(float)delay FadeTime:(float)time
{
	_visual = true;
	
	_blockWidth = width;
	_blockLen = len;
	_blockCnt = cnt;
	_fadeDelay = delay;
	_fadeTime = time;
	
	if(_colors) free(_colors);
	if(_coords) free(_coords);
	if(_vertices) free(_vertices);
	if(_posArray) free(_posArray);
	
	_colors = malloc(sizeof(GLfloat) * (cnt + 1) * 8);
	_coords = malloc(sizeof(CGPoint) * (cnt + 1) * 2);
	_vertices = malloc(sizeof(CGPoint) * (cnt + 1) * 2);
	_posArray = malloc(sizeof(TTrailPos) * cnt + 1);
	
	_lastPos = 0;
	_oddCoord = false;
}

- (void)dealloc
{
	if(_colors) free(_colors);
	if(_coords) free(_coords);
	if(_vertices) free(_vertices);
	if(_posArray) free(_posArray);
	
	[super dealloc];
}

- (void)addValidPosX:(float)x Y:(float)y IsAdd:(bool)add
{
	CGPoint *curCoord;
	CGPoint *curVertex;
	GLfloat *curColor;
	TTrailPos *posArray = _posArray;
	TTrailPos *posArrayLast, *posArrayCur;
	
	if(_lastPos > _blockCnt)
	{
		memcpy(posArray, &posArray[1], sizeof(TTrailPos) * _blockCnt);
		memcpy(_colors, &_colors[8], sizeof(GLfloat) * _blockCnt * 8);
		memcpy(_coords, &_coords[2], sizeof(CGPoint) * _blockCnt * 2);
		memcpy(_vertices, &_vertices[2], sizeof(CGPoint) * _blockCnt * 2);
		--_lastPos;
	}
	
	posArrayLast = &posArray[_lastPos];
	
	posArrayLast->pt.x = x;
	posArrayLast->pt.y = y;
	posArrayLast->time = GWORLD.time;
	
	if(!_oddCoord)
	{
		curCoord = &_coords[_lastPos*2];
		curCoord->x = 0;			curCoord->y = _tile.maxT;	curCoord++;
		curCoord->x = _tile.maxS;	curCoord->y = _tile.maxT;
	}
	else
	{
		curCoord = &_coords[_lastPos*2];
		curCoord->x = 0;			curCoord->y = 0;			curCoord++;
		curCoord->x = _tile.maxS;	curCoord->y = 0;
	}
	
	if(_lastPos > 0)
	{
		posArrayLast->normal.x = (y - (posArrayLast-1)->pt.y);
		posArrayLast->normal.y = -(x - (posArrayLast-1)->pt.x);
		float len = sqrt(posArrayLast->normal.x * posArrayLast->normal.x + posArrayLast->normal.y * posArrayLast->normal.y);
		posArrayLast->normal.x = posArrayLast->normal.x / len * _blockWidth / 2.f;
		posArrayLast->normal.y = posArrayLast->normal.y / len * _blockWidth / 2.f;

		if(add && _lastPos > 1)
		{
			int curPos = _lastPos - 1;
			CGPoint v1, v2;
			posArrayCur = &posArray[curPos];
			v1.x = (posArrayCur-1)->pt.x - posArrayCur->pt.x;
			v1.y = (posArrayCur-1)->pt.y - posArrayCur->pt.y;
			len = sqrt(v1.x * v1.x + v1.y * v1.y);
			v1.x = v1.x / len * _blockWidth;
			v1.y = v1.y / len * _blockWidth;
			
			v2.x = (posArrayCur+1)->pt.x - posArrayCur->pt.x;
			v2.y = (posArrayCur+1)->pt.y - posArrayCur->pt.y;
			len = sqrt(v2.x * v2.x + v2.y * v2.y);
			v2.x = v2.x / len * _blockWidth;
			v2.y = v2.y / len * _blockWidth;
			
			float cross = v1.x * v2.y - v1.y * v2.x;
			if(cross > 0.1f)
			{
				float width = _blockWidth + RANDOMF(6.f);
				posArrayCur->normal.x = (v1.x + v2.x);
				posArrayCur->normal.y = (v1.y + v2.y);
				len = sqrt(posArrayCur->normal.x * posArrayCur->normal.x + posArrayCur->normal.y * posArrayCur->normal.y);
				posArrayCur->normal.x = posArrayCur->normal.x / len * width / 2.f;
				posArrayCur->normal.y = posArrayCur->normal.y / len * width / 2.f;
				
				curVertex = &_vertices[curPos*2];
				curVertex->x = posArrayCur->pt.x + posArrayCur->normal.x;
				curVertex->y = posArrayCur->pt.y + posArrayCur->normal.y;
				curVertex++;
				curVertex->x = posArrayCur->pt.x - posArrayCur->normal.x;
				curVertex->y = posArrayCur->pt.y - posArrayCur->normal.y;
			}
		}
		else
		{
			posArray->normal.x = posArrayLast->normal.x;
			posArray->normal.y = posArrayLast->normal.y;
			
			curVertex = _vertices;
			curVertex->x = posArray->pt.x + posArray->normal.x;
			curVertex->y = posArray->pt.y + posArray->normal.y;
			curVertex++;
			curVertex->x = posArray->pt.x - posArray->normal.x;
			curVertex->y = posArray->pt.y - posArray->normal.y;
		}
	}
	else
	{
		posArrayLast->normal.x = 0.f;
		posArrayLast->normal.y = 0.f;
	}
	
	curVertex = &_vertices[_lastPos*2];
	curVertex->x = posArrayLast->pt.x + posArrayLast->normal.x;
	curVertex->y = posArrayLast->pt.y + posArrayLast->normal.y;
	curVertex++;
	curVertex->x = posArrayLast->pt.x - posArrayLast->normal.x;
	curVertex->y = posArrayLast->pt.y - posArrayLast->normal.y;
	
	curColor = &_colors[_lastPos*8];
	*curColor = 1.f;		curColor++;			// r
	*curColor = 1.f;		curColor++;			// g
	*curColor = 1.f;		curColor++;			// b
	*curColor = 1.f;		curColor++;			// a
	
	*curColor = 1.f;		curColor++;			// r
	*curColor = 1.f;		curColor++;			// g
	*curColor = 1.f;		curColor++;			// b
	*curColor = 1.f;		curColor++;			// a
	
	if(add)
	{
		_lastPos++;
		_oddCoord = !_oddCoord;
	}
}

- (void)addTrailPosX:(float)x Y:(float)y
{
	x -= _pos.x;
	y -= _pos.y;
	
	if(_lastPos > 0)
	{
		TTrailPos *posArrayLast = &_posArray[_lastPos-1];
		float lenX = x - posArrayLast->pt.x;
		float lenY = y - posArrayLast->pt.y;
		float scale = lenX * lenX + lenY * lenY;
		
		if(scale >= _blockLen * _blockLen)
		{
			scale = sqrt(scale) / _blockLen;
			
			lenX /= scale;
			lenY /= scale;
			CGPoint pt = posArrayLast->pt;
			
			while(scale >= 1.f)
			{
				pt.x += lenX;
				pt.y += lenY;
				[self addValidPosX:pt.x Y:pt.y IsAdd:true];
				scale -= 1.f;
			}
		}
	}
	else
	{
		[self addValidPosX:x Y:y IsAdd:true];
	}
	
	[self addValidPosX:x Y:y IsAdd:false];
}

- (void)tick
{
	if(!GWORLD.pause)
	{
		float dt = 0;
		float vel, vx, vy;
		float alpha = 1.f;
		bool live = false;
		CGPoint *curVertex = _vertices;
		TTrailPos *curPos = _posArray;
		
		for(int i = 0; i <= _lastPos; i++)
		{
			dt = GWORLD.time - curPos->time;
			if(dt > _fadeDelay)
			{
				dt -= _fadeDelay;
				if(dt < _fadeTime)	alpha = 1.f - dt / _fadeTime;
				else				alpha = 0.f;
				
				if(i == 0)			alpha = 0.f;
				
				_colors[i * 8 + 3] = alpha;			// a
				_colors[i * 8 + 7] = alpha;			// a
			}
			else
			{
				alpha = 1.f;
			}
			
			if(alpha != 0.f)
			{
				if(_diffuseEffect != 0.f)
				{
					vel = RANDOMF(_diffuseEffect);
					vx = curPos->normal.x * vel;
					vy = curPos->normal.y * vel;
					curVertex->x += vx;
					curVertex->y += vy;
					(curVertex+1)->x -= vx;
					(curVertex+1)->y -= vy;
				}

				if(_windEffect != 0.f)
				{
					vel = sinf(curPos->time * 30.f) / (_windEffect + RANDOMF(_windEffect / 2.f));
					vx = curPos->normal.x * vel;
					vy = curPos->normal.y * vel;
					curVertex->x += vx;
					curVertex->y += vy;
					(curVertex+1)->x += vx;
					(curVertex+1)->y += vy;
				}
				
				live = true;
			}
			
			curPos++;
			curVertex += 2;
		}
		
		if(_lastPos > 0 && !live)
		{
			[self remove];
		}
	}
	
	[super tick];
}

- (bool)isInCam
{
	return true;
}

- (void)draw
{
	if(_lastPos < 2) return;
	
	glPushMatrix();
	
	glTranslatef(SCRPOS_X, SCRPOS_Y, 0);
	switch(_blendType)
	{
		case BT_NORMAL:	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);	break;
		case BT_COLOR:	glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_ALPHA);	break;
		case BT_ADD:	glBlendFunc(GL_SRC_ALPHA, GL_ONE);					break;
		case BT_BLACK:	glBlendFunc(GL_ONE_MINUS_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);		break;
	}
	glBindTexture(GL_TEXTURE_2D, _tile.name);
//	glEnable(GL_BLEND);
	glColorPointer (4, GL_FLOAT, 0, _colors);
	glTexCoordPointer(2, GL_FLOAT, 0, _coords);
	glVertexPointer(2, GL_FLOAT, 0, _vertices);
	glDrawArrays(GL_TRIANGLE_STRIP, 0, (_lastPos + 1) * 2);
	
	glPopMatrix();
}

@end
