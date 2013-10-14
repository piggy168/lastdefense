//
//  Collider.m
//  Jumping!
//
//  Created by 엔비 on 08. 09. 17.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "Collider.h"
#import "QVector.h"

@implementation ColVector

@synthesize data=_data, origin=_origin, second=_second, dir=_dir, normal=_normal, colNormal=_colNormal, length=_length, angle=_angle, prev=_prev, next=_next;

- (id)init
{
	[super init];
	
	_prev = _next = nil;

	return self;
}

- (id)initWithOrigin:(const CGPoint *)origin Second:(const CGPoint *)secondPos
{
	[[self init] setOrigin:origin Second:secondPos];
	
	return self;
}

- (void)dealloc
{
	
	[super dealloc];
}

- (void)setOrigin:(const CGPoint *)origin Second:(const CGPoint *)secondPos
{
	_origin = *origin;
	_second = *secondPos;
	_dir = *secondPos;
	[QVector vector:&_dir Sub:origin];
	_length = [QVector length:&_dir];
	[QVector vector:&_dir Div:_length];
	_normal.x = _dir.y;
	_normal.y = -_dir.x;
	_colNormal = _dir;
	_angle = atan2(-_normal.x, _normal.y);
}

- (void)setPrev:(ColVector *)prev
{
	_prev = prev;
	_colNormal.x = _dir.x + _prev.dir.x;
	_colNormal.y = _dir.y + _prev.dir.y;
	[QVector normalize:&_colNormal];
}

- (void)setNext:(ColVector *)next
{
	_next = next;
}

- (float)checkCollide:(CGPoint *)pos Vel:(const CGPoint *)vel ReverseCol:(bool)reverseCol
{
	CGPoint pt = {pos->x, pos->y};
	[QVector vector:pos Sub:&_origin];
	
	if(!reverseCol && [QVector vector:vel Dot:&_normal] > 0.f)
	{
		pos->x = pt.x;
		pos->y = pt.y;
		return 0.f;
	}
	
	float lenPrev = [QVector vector:&_normal Dot:pos];
	[QVector vector:pos Add:vel];
	float colLen = [QVector vector:&_normal Dot:pos];
	float normalDir = (float)(lenPrev >= 0 && colLen <= 0) * 1.f;
	if(normalDir == 0.f) normalDir = (float)(lenPrev <= 0 && colLen >= 0) * -1.f;	// 역방향 충돌도 검출
	
	if(normalDir != 0)
	{
		if(reverseCol)
		{
			//////////////////////////////////////// for Other
			colLen = colLen / (lenPrev - colLen);
			pos->x += vel->x * colLen;
			pos->y += vel->y * colLen;
		}
		else
		{
			//////////////////////////////////////// for Heavy Mach.
			pos->x += _normal.x * (-colLen + .5f);
			pos->y += _normal.y * (-colLen + .5f);
		}
		
		float dirDotPos = [QVector vector:&_dir Dot:pos];
		if(dirDotPos > _length + 3.f || dirDotPos < -3.f)
		{
			pos->x = pt.x;
			pos->y = pt.y;
			return 0.f;
		}
		
		[QVector vector:pos Add:&_origin];
		return normalDir;
	}
	
	pos->x = pt.x;
	pos->y = pt.y;
	return 0.f;
}

- (float)checkCollide:(CGPoint *)pos ColRadius:(float)colRadius
{
	CGPoint pt = *pos;
	
/*	if(_next != nil)
	{
		pt.x -= _next.origin.x;
		pt.y -= _next.origin.y;
		if([QVector vec:_next.colNormal Dot:pt] > 0.f) return 0.f;
	}
	else */
	{
		pt.x -= _origin.x;
		pt.y -= _origin.y;
		if([QVector vec:_dir Dot:pt] > _length + colRadius) return 0.f;
	}

	pt.x = pos->x - _origin.x;
	pt.y = pos->y - _origin.y;
	if([QVector vec:_colNormal Dot:pt] < 0.f) return 0.f;
	
	float colLen = colRadius - fabs([QVector vector:&_normal Dot:&pt]);
	if(colLen < 0.f) return 0.f;
	
	return colLen;
}

/*- (CGPoint)checkCollide:(CGPoint *)pos Dir:(const CGPoint *)dir ColRadius:(float)colRadius
{
	float dirDotPos = [_dir dotProduct:pos];
	if(dirDotPos > _length || dirDotPos < 0.f) return nil;
	
	float colTan = [dir dotProduct:_normal];
	if(colTan > 0.f) return nil;
	
	float colLen = [_normal dotProduct:pos];
	if(fabs(colLen) >= colRadius) return nil;
	
	float revLen = (colRadius - colLen) / colTan;
	pos.x += dir.x * revLen;
	pos.y += dir.y * revLen;
	
	Vector2 *colPos = [[Vector2 alloc] initFromVector:pos];
	colPos.x -= _normal.x * colRadius;
	colPos.y -= _normal.y * colRadius;
	[colPos add:_origin];
	[colPos autorelease];
	
	return colPos;
}

// 반지름이 0일 경우에도 처리 가능하도록
// 내적, 외적을 이용하면 속도도 빨라지고, 반지름 0인 오브젝트도 충돌검출 가능할 듯 싶은데...
- (CGPoint)checkCollide:(CGPoint *)pos Vel:(const CGPoint *)vel ColRadius:(float)colRadius
{
	Vector2 *colPos = nil;
	Vector2 *checkPos = [[Vector2 alloc] initFromVector:pos];
	Vector2 *moveDir = [[Vector2 alloc] initFromVector:vel];
	
	[checkPos sub:_origin];

	float len = [moveDir length];						// 움직인 거리 계산
	[moveDir div:len];
	
//	colPos = [self checkCollide:checkPos Dir:moveDir];	// 시작 위치에서 충돌 되었는지 검사

	while(colPos == nil && len > colRadius)				// 공 반지름 간격으로 충돌 체크
	{
		checkPos.x += moveDir.x * colRadius;
		checkPos.y += moveDir.y * colRadius;			// checkPos += moveDir * colRadius;

		colPos = [self checkCollide:checkPos Dir:moveDir ColRadius:colRadius];
		
		len -= colRadius;
	}

	if(colPos == nil)
	{
		[checkPos copyFrom:pos];
		[checkPos sub:_origin];
		[checkPos add:vel];
		colPos = [self checkCollide:checkPos Dir:moveDir ColRadius:colRadius];	// 마지막 위치에서 충돌 되었는지 검사
	}
	
	[checkPos release];
	[moveDir release];

	return colPos;
}*/

- (void)draw
{
	GLfloat coordinates[] = { 0, 0, 0, 1, 1, 1, 1, 0 };
	GLfloat vertices[] = { _origin.x, _origin.y, 0.0, _origin.x + _dir.x * _length,	_origin.y + _dir.y * _length, 0.0 };
	
//	glLineWidth(2.f);
	glColor4f(1.f, 0.f, 0.f, 1.f);
	glBindTexture(GL_TEXTURE_2D, 0);
	glVertexPointer(3, GL_FLOAT, 0, vertices);
	glTexCoordPointer(2, GL_FLOAT, 0, coordinates);
	glDrawArrays(GL_LINES, 0, 2);
}

@end

