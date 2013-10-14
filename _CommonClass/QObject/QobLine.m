//
//  QobLine.m
//  HeavyMach2
//
//  Created by 엔비 on 09. 07. 28.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "QobLine.h"


@implementation QobLine

- (void)dealloc
{
	if(_colors) free(_colors);
	if(_coords) free(_coords);
	if(_vertices) free(_vertices);
//	if(_posArray) free(_posArray);
	
	[super dealloc];
}

- (void)initTexWidth:(float)width Len:(float)len MaxBlocks:(float)cnt
{
	_visual = true;
	
	_blockWidth = width;
	_blockLen = len;
	_blockCnt = cnt;
	_lastPos = 0;
	
	if(_colors) free(_colors);
	if(_coords) free(_coords);
	if(_vertices) free(_vertices);
//	if(_posArray) free(_posArray);
	
	_colors = (GLfloat *)malloc(sizeof(GLfloat) * (cnt + 1) * 8);
	_coords = (CGPoint *)malloc(sizeof(CGPoint) * (cnt + 1) * 2);
	_vertices = (CGPoint *)malloc(sizeof(CGPoint) * (cnt + 1) * 2);
//	_posArray = malloc(sizeof(TTrailPos) * cnt + 1);
}

- (void)setLineX1:(float)x1 Y1:(float)y1 X2:(float)x2 Y2:(float)y2
{
	[self setPosX:x1 Y:y1];
	
	CGPoint vLen = {x2 - x1, y2 - y1};
	float len = sqrt(vLen.x * vLen.x + vLen.y * vLen.y);
	vLen.x /= len;
	vLen.y /= len;
	CGPoint lineWidth = {vLen.x * _blockWidth * .5f, vLen.y * _blockWidth * .5f};
	
	CGPoint *vertices = _vertices;
	CGPoint *coords = _coords;
	GLfloat *colors = _colors;
	int blocks = len / _blockLen;
	float x = 0.f, y = 0.f;
	float modLen = fmod(len, _blockLen);
	float modScale = _tile.maxT * (modLen / _blockLen);
	unsigned int lastPos = 0;
	
	for(; lastPos <= blocks + 1; lastPos++)
	{
		vertices->x = x - lineWidth.y;
		vertices->y = y + lineWidth.x;
		vertices++;
		vertices->x = x + lineWidth.y;
		vertices->y = y - lineWidth.x;
		vertices++;

		coords->x = 0;				
		(coords+1)->x = _tile.maxS;

		if(lastPos % 2 == 0)
		{
			if(lastPos == blocks + 1)
			{
				coords->y = modScale;
				(coords+1)->y = modScale;
			}
			else
			{
				coords->y = _tile.maxT;
				(coords+1)->y = _tile.maxT;
			}
		}
		else
		{
			if(lastPos == blocks + 1)
			{
				coords->y = 1.f - modScale;
				(coords+1)->y = 1.f - modScale;
			}
			else
			{
				coords->y = 0;
				(coords+1)->y = 0;
			}
		}
		coords += 2;

		*(colors++) = 1.f;			// r
		*(colors++) = 1.f;			// g
		*(colors++) = 1.f;			// b
		*(colors++) = 1.f;			// a
		
		*(colors++) = 1.f;			// r
		*(colors++) = 1.f;			// g
		*(colors++) = 1.f;			// b
		*(colors++) = 1.f;			// a

		if(lastPos < blocks)
		{
			x += vLen.x * _blockLen;
			y += vLen.y * _blockLen;
		}
		else
		{
			x += vLen.x * modLen;
			y += vLen.y * modLen;
		}
	}
	
	_lastPos = lastPos;
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
	glDrawArrays(GL_TRIANGLE_STRIP, 0, _lastPos * 2);
	
	glPopMatrix();
}


@end
