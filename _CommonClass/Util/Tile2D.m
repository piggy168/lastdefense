//
//  Tile2D.m
//  Jumping!
//
//  Created by 엔비 on 08. 09. 10.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "Tile2D.h"


@implementation Tile2D

@synthesize fileName=_fileName, tileWidth=_tileWidth, tileHeight=_tileHeight, splitX=_splitX, splitY=_splitY, u=_u, v=_v, w=_w, h=_h, tileCnt=_tileCnt, originX=_originX, originY=_originY, colorR=_colorR, colorG=_colorG, colorB=_colorB;

- (void)dealloc
{
	if(_fileName != nil) [_fileName release];

	[super dealloc];
}

- (void)setFileName:(NSString *)name
{
	if(_fileName != nil) [_fileName release];
	_fileName = [[NSString alloc] initWithString:name];
}

- (void)tileSplitX:(int)splitX splitY:(int)splitY
{
	if(splitX < 1) splitX = 1;
	if(splitY < 1) splitY = 1;
	
	_splitX = splitX;
	_splitY = splitY;
	_tileCnt = _splitX * _splitY;

	_u = _maxS / (float)_splitX;
	_v = _maxT / (float)_splitY;
	_w = (GLfloat)_width * _u / 2.f;
	_h = (GLfloat)_height * _v / 2.f;
	
	_originX = 0.f;
	_originY = 0.f;

	_tileWidth = _size.width / (float)_splitX;
	_tileHeight = _size.height / (float)_splitY;
	
	[self setColorR:255 G:255 B:255];
}

- (void)setColorR:(unsigned char)r G:(unsigned char)g B:(unsigned char)b
{
	_colorR = r / 255.f;
	_colorG = g / 255.f;
	_colorB = b / 255.f;
}

- (void)drawTile:(int)tileNum x:(float)x y:(float)y blendType:(int)blendType alpha:(float)alpha scaleX:(float)scaleX scaleY:(float)scaleY turnX:(float)turnX turnY:(float)turnY rotate:(float)rotate
{
	if(_splitX < 1 || _splitY < 1) [self tileSplitX:1 splitY:1];
	if(tileNum >= _tileCnt) tileNum = _tileCnt - 1;
	
	int tx = tileNum % _splitX;
	int ty = tileNum / _splitX;
	
	glPushMatrix();
	
	if(_forRetina)
	{
		scaleX *= .5f;
		scaleY *= .5f;
	}

	glTranslatef(x - _originX * scaleX, y - _originY * scaleY, 0);
	//	if(scaleX != 1.f || scaleY !=1.f) glScalef(scaleX, scaleY, 1.f);
	if(rotate != 0.f) glRotatef(rotate * RAD2DEG_VALUE, 0.f, 0.f, 1.f);
	
	float cx = tx * _u + _u * .5f;
	float lx = tx * _u;
	float rx = tx * _u + _u;
	float cy = ty * _v + _v * .5f;
	float uy = ty * _v + _v;
	float by = ty * _v;
	
	GLfloat coordinates[] =
	{
		cx,	cy,		lx,	cy,		lx,	uy,
		cx,	uy,		rx,	uy,		rx,	cy,
		rx,	by,		cx,	by,		lx,	by,
		lx,	cy,
	};
	
	scaleX -= fabs(turnX);

	GLfloat vertices[] =
	{
		0,				0,									// center
		-_w * scaleX,	0,									// left - center
		
		-_w * scaleX,	(-_h - _h * turnX) * scaleY,	// left - top
		0,				-_h * scaleY,						// center - top
		_w * scaleX,	(-_h + _h * turnX) * scaleY,	// right - top
		
		_w * scaleX,	0,									// right - center
		
		_w * scaleX,	(_h - _h * turnX) * scaleY,		// right - bottom
		0,				_h * scaleY,						// center - bottom
		-_w * scaleX,	(_h + _h * turnX) * scaleY,		// left - bottom
		
		-_w * scaleX,	0,									// left - center
	};
/*	GLfloat vertices[] =	{	-_w * scaleX / turnY,		-_h * scaleY * turnX,
								 _w * scaleX / turnY,		-_h * scaleY / turnX,
								-_w * scaleX * turnY,		_h * scaleY * turnX,
								 _w * scaleX * turnY,		_h * scaleY / turnX,	};*/
	GLfloat colors[] =
	{
		_colorR,	_colorG,	_colorB,	alpha,
		_colorR,	_colorG,	_colorB,	alpha,
		_colorR,	_colorG,	_colorB,	alpha,
		_colorR,	_colorG,	_colorB,	alpha,
		_colorR,	_colorG,	_colorB,	alpha,
		_colorR,	_colorG,	_colorB,	alpha,
		_colorR,	_colorG,	_colorB,	alpha,
		_colorR,	_colorG,	_colorB,	alpha,
		_colorR,	_colorG,	_colorB,	alpha,
		_colorR,	_colorG,	_colorB,	alpha
	};
	
	switch(blendType)
	{
		case BT_NORMAL:
//			glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
//			glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
			if(_format == kTexture2DPixelFormat_RGBA8888) glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
			else glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
			break;
		case BT_ALPHA:	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);					break;
		case BT_COLOR:	glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_ALPHA);	break;
		case BT_ADD:	glBlendFunc(GL_SRC_ALPHA, GL_ONE);					break;
		case BT_BLACK:	glBlendFunc(GL_ONE, GL_ONE);		break;
	}
	
	//	glEnable(GL_TEXTURE_2D);
//	glBindTexture(GL_TEXTURE_2D, _name);
//	glEnable(GL_BLEND);
	glColorPointer (4, GL_FLOAT, 0, colors);
	glTexCoordPointer(2, GL_FLOAT, 0, coordinates);
	glVertexPointer(2, GL_FLOAT, 0, vertices);
	glDrawArrays(GL_TRIANGLE_FAN, 0, 10);
//	glDisable(GL_BLEND);
	//	glDisable(GL_TEXTURE_2D);
	
	glPopMatrix();

	QOBMGR.drawCount++;
}

- (void)drawTile:(int)tileNum x:(float)x y:(float)y blendType:(int)blendType alpha:(float)alpha scaleX:(float)scaleX scaleY:(float)scaleY rotate:(float)rotate reverse:(unsigned int)reverse
{
	if(_splitX < 1 || _splitY < 1) [self tileSplitX:1 splitY:1];
	if(tileNum >= _tileCnt) tileNum = _tileCnt - 1;
	
	int tx = tileNum % _splitX;
	int ty = tileNum / _splitX;
	
	glPushMatrix();

	if(_forRetina)
	{
		scaleX *= .5f;
		scaleY *= .5f;
	}

	if(reverse & REVERSE_H) glTranslatef(x + _originX * scaleX, y - _originY * scaleY, 0);
	else glTranslatef(x - _originX * scaleX, y - _originY * scaleY, 0);
//	if(scaleX != 1.f || scaleY !=1.f) glScalef(scaleX, scaleY, 1.f);
	if(rotate != 0.f) glRotatef(rotate * RAD2DEG_VALUE, 0.f, 0.f, 1.f);

	GLfloat coordinates[] = {	tx * _u,			ty * _v + _v,
								tx * _u + _u,		ty * _v + _v,
								tx * _u,			ty * _v,
								tx * _u + _u,		ty * _v		};
	GLfloat vertices[] =	{	-_w * scaleX,		-_h * scaleY,
								 _w * scaleX,		-_h * scaleY,
								-_w * scaleX,		_h * scaleY,
								 _w * scaleX,		_h * scaleY			};
	GLfloat colors[] =		{	_colorR,	_colorG,	_colorB,	alpha,
		_colorR,	_colorG,	_colorB,	alpha,
		_colorR,	_colorG,	_colorB,	alpha,
		_colorR,	_colorG,	_colorB,	alpha	};

/*	GLfloat colors[] =		{	alpha,	alpha,	alpha,	alpha,
								alpha,	alpha,	alpha,	alpha,
								alpha,	alpha,	alpha,	alpha,
								alpha,	alpha,	alpha,	alpha	};*/		// True Color

	switch(blendType)
	{
		case BT_NORMAL:
//			glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
//			glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
			if(_format == kTexture2DPixelFormat_RGBA8888) glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
			else glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
			break;
		case BT_ALPHA:	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);					break;
		case BT_COLOR:	glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_ALPHA);					break;
		case BT_ADD:	glBlendFunc(GL_SRC_ALPHA, GL_ONE);									break;
		case BT_BLACK:	glBlendFunc(GL_ONE, GL_ONE);		break;
	}
	
	if(reverse & REVERSE_H)
	{
		vertices[0] = vertices[4] = _w * scaleX;
		vertices[2] = vertices[6] = -_w * scaleX;
	}

	if(reverse & REVERSE_V)
	{
		vertices[1] = vertices[3] = _h * scaleY;
		vertices[5] = vertices[7] = -_h * scaleY;
	}
	
//	glEnable(GL_TEXTURE_2D);
	glBindTexture(GL_TEXTURE_2D, _name);
//	glEnable(GL_BLEND);
	glColorPointer (4, GL_FLOAT, 0, colors);
	glTexCoordPointer(2, GL_FLOAT, 0, coordinates);
	glVertexPointer(2, GL_FLOAT, 0, vertices);
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
//	glDisable(GL_BLEND);
//	glDisable(GL_TEXTURE_2D);
	
	glPopMatrix();
	
	QOBMGR.drawCount++;
}

- (void)drawTile:(int)tileNum x:(float)x y:(float)y blendType:(int)blendType alpha:(float)alpha scaleX:(float)scaleX scaleY:(float)scaleY rotate:(float)rotate
{
	[self drawTile:tileNum x:x y:y blendType:blendType alpha:alpha scaleX:scaleX  scaleY:scaleY rotate:rotate reverse:0];
}

- (void)drawTile:(int)tileNum x:(float)x y:(float)y
{
	[self drawTile:tileNum x:x y:y blendType:BT_NORMAL alpha:1.f scaleX:1.f scaleY:1.f rotate:0.f reverse:0];
}

- (void)drawTile:(int)tileNum x:(float)x y:(float)y blendType:(int)blendType alpha:(float)alpha
{
	[self drawTile:tileNum x:x y:y blendType:blendType alpha:alpha scaleX:1.f scaleY:1.f rotate:0.f reverse:0];
}

- (void)drawTile:(int)tileNum x:(float)x y:(float)y scaleX:(float)scaleX scaleY:(float)scaleY rotate:(float)rotate
{
	[self drawTile:tileNum x:x y:y blendType:BT_NORMAL alpha:1.f scaleX:scaleX  scaleY:scaleY rotate:rotate reverse:0];
}

- (void)drawTile:(int)tileNum x:(float)x y:(float)y scaleX:(float)scaleX scaleY:(float)scaleY
{
	[self drawTile:tileNum x:x y:y blendType:BT_NORMAL alpha:1.f scaleX:scaleX scaleY:scaleY rotate:0.f reverse:0];
}

- (void)drawTile:(int)tileNum x:(float)x y:(float)y rotate:(float)rotate
{
	[self drawTile:tileNum x:x y:y blendType:BT_NORMAL alpha:1.f scaleX:1.f scaleY:1.f rotate:rotate reverse:0];
}

@end
