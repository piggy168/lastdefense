//
//  Collider.h
//  Jumping!
//
//  Created by 엔비 on 08. 09. 17.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ColVector : NSObject
{
	int _data;
	CGPoint _origin;
	CGPoint _second;
	CGPoint _dir;
	CGPoint _normal;
	CGPoint _colNormal;
	float _length;
	float _angle;
	
	ColVector *_prev;
	ColVector *_next;
}

- (id)initWithOrigin:(const CGPoint *)origin Second:(const CGPoint *)secondPos;

@property(readwrite) int data;
@property(readwrite) CGPoint origin, second;
@property(readwrite) CGPoint dir, normal, colNormal;
@property(readonly) float length, angle;
@property(readonly) ColVector *prev, *next;

- (void)setOrigin:(const CGPoint *)origin Second:(const CGPoint *)secondPos;

- (void)setPrev:(ColVector *)prev;
- (void)setNext:(ColVector *)next;

- (float)checkCollide:(CGPoint *)pos Vel:(const CGPoint *)vel ReverseCol:(bool)reverseCol;
- (float)checkCollide:(CGPoint *)pos ColRadius:(float)colRadius;
//- (CGPoint)checkCollide:(CGPoint *)pos Dir:(const CGPoint *)dir ColRadius:(float)colRadius;
//- (CGPoint)checkCollide:(CGPoint *)pos Vel:(const CGPoint *)vel ColRadius:(float)colRadius;

- (void)draw;

@end

