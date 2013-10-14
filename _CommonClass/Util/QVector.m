//
//  QUtil.m
//  HvM2_MapBuilder
//
//  Created by 엔비 on 09. 08. 17.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "QVector.h"


@implementation QVector

+ (void)vector:(CGPoint *)v SetX:(float)x Y:(float)y
{
	v->x = x;
	v->y = y;
}

+ (void)vector:(CGPoint *)v SetAngle:(float)rad Len:(float)len
{
	v->x = cosf(rad) * len;
	v->y = sinf(rad) * len;
}

+ (void)vector:(CGPoint *)v Add:(const CGPoint *)vec
{
	v->x += vec->x;
	v->y += vec->y;
}

+ (void)vector:(CGPoint *)v Sub:(const CGPoint *)vec
{
	v->x -= vec->x;
	v->y -= vec->y;
}

+ (void)vector:(CGPoint *)v Mul:(float)f
{
	v->x *= f;
	v->y *= f;
}

+ (void)vector:(CGPoint *)v Div:(float)f
{
	v->x /= f;
	v->y /= f;
}

+ (float)vector:(CGPoint *)v Length:(CGPoint *)v2
{
	return sqrt((v2->x - v->x) * (v2->x - v->x) + (v2->y - v->y) * (v2->y - v->y));
}

+ (float)vector:(CGPoint *)v LengthSq:(CGPoint *)v2
{
	return (v2->x - v->x) * (v2->x - v->x) + (v2->y - v->y) * (v2->y - v->y);
}

+ (float)length:(const CGPoint *)v
{
	return sqrt(v->x * v->x + v->y * v->y);
}

+ (float)lengthSq:(const CGPoint *)v
{
	return v->x * v->x + v->y * v->y;
}

+ (void)normalize:(CGPoint *)v
{
	float len = sqrt(v->x * v->x + v->y * v->y);
	if(len < 0.00001f)
	{
		v->x = 0.f;
		v->y = 0.f;
	}
	else
	{
		v->x /= len;
		v->y /= len;
	}
}

+ (float)angle:(const CGPoint *)v
{
	return atan2(v->y, v->x);
}

+ (float)vector:(const CGPoint *)v1 Dot:(const CGPoint *)v2
{
	return v1->x * v2->x + v1->y * v2->y;
}

+ (float)vector:(const CGPoint *)v1 Cross:(const CGPoint *)v2
{
	return v1->x * v2->y - v1->y * v2->x;
}

+ (float)vec:(CGPoint)v1 Dot:(CGPoint)v2
{
	return v1.x * v2.x + v1.y * v2.y;
}

+ (float)vec:(CGPoint)v1 Cross:(CGPoint)v2
{
	return v1.x * v2.y - v1.y * v2.x;
}

+ (CGPoint)vector:(CGPoint *)v Rotate:(float)angle
{
	CGPoint ret;
	float cr = cosf(angle), sr = sinf(angle);
	
	ret.x = v->x * cr - v->y * sr;
	ret.y = v->x * sr + v->y * cr;
	
	return ret;
}

+ (void)easyOut:(CGPoint *)v To:(const CGPoint *)dest Div:(float)div
{
	v->x += (dest->x - v->x) / div;
	v->y += (dest->y - v->y) / div;
}

+ (void)easyOut:(CGPoint *)v To:(const CGPoint *)dest Div:(float)div Min:(float)min
{
	if(v->x != dest->x)
	{
		if(fabs(v->x - dest->x) > min) v->x += (dest->x - v->x) / div;
		else v->x = dest->x;
	}
	if(v->y != dest->y)
	{
		if(fabs(v->y - dest->y) > min) v->y += (dest->y - v->y) / div;
		else v->y = dest->y;
	}
}

+ (void)follow:(CGPoint *)v To:(const CGPoint *)dest Vel:(float)vel
{
}

@end
