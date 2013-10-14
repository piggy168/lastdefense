//
//  QobLine.h
//  HeavyMach2
//
//  Created by 엔비 on 09. 07. 28.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface QobLine : QobImage
{
	float _blockWidth, _blockLen;
	unsigned int _blockCnt;
	unsigned int _lastPos;
	
	float _fadeDelay;
	float _fadeTime;
	
	CGPoint *_coords;
	CGPoint *_vertices;
	GLfloat *_colors;
}

- (void)initTexWidth:(float)width Len:(float)len MaxBlocks:(float)cnt;
- (void)setLineX1:(float)x1 Y1:(float)y1 X2:(float)x2 Y2:(float)y2;

@end
