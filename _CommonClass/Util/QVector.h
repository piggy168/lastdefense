//
//  QUtil.h
//  HvM2_MapBuilder
//
//  Created by 엔비 on 09. 08. 17.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

@interface QVector : NSObject
{
}

+ (void)vector:(CGPoint *)v SetX:(float)x Y:(float)y;
+ (void)vector:(CGPoint *)v SetAngle:(float)rad Len:(float)len;
+ (void)vector:(CGPoint *)v Add:(const CGPoint *)vec;
+ (void)vector:(CGPoint *)v Sub:(const CGPoint *)vec;
+ (void)vector:(CGPoint *)v Mul:(float)f;
+ (void)vector:(CGPoint *)v Div:(float)f;

+ (float)vector:(CGPoint *)v Length:(CGPoint *)v2;
+ (float)vector:(CGPoint *)v LengthSq:(CGPoint *)v2;

+ (float)length:(const CGPoint *)v;
+ (float)lengthSq:(const CGPoint *)v;
+ (void)normalize:(CGPoint *)v;
+ (float)angle:(const CGPoint *)v;
+ (float)vector:(const CGPoint *)v1 Dot:(const CGPoint *)v2;
+ (float)vector:(const CGPoint *)v1 Cross:(const CGPoint *)v2;
+ (float)vec:(CGPoint)v1 Dot:(CGPoint)v2;
+ (float)vec:(CGPoint)v1 Cross:(CGPoint)v2;
+ (CGPoint)vector:(CGPoint *)v Rotate:(float)angle;

+ (void)easyOut:(CGPoint *)v To:(const CGPoint *)dest Div:(float)div;
+ (void)easyOut:(CGPoint *)v To:(const CGPoint *)dest Div:(float)div Min:(float)min;
+ (void)follow:(CGPoint *)v To:(const CGPoint *)dest Vel:(float)vel;
@end
