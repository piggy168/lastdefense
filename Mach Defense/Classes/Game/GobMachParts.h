//
//  GobMachParts.h
//  HeavyMach
//
//  Created by 엔비 on 08. 12. 07.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//


@interface GobMachParts : QobImage
{
	GobHvMach *_hvMach;
	QobImage *_imgShadow;
	PartsInfo *_partsInfo;
	GobMachParts *_baseParts;
	unsigned char _baseSocket;
	CGPoint _basePos;
//	CGPoint _offset;
	CGPoint _addPos;
	CGPoint _rotPos;
	int _curMuzzle;
	float _prevPos;
	float _prevRot;
	float _scale;
	float _drawScale;
	float _shadowLen;
	bool _useBaseRot;
}

@property(readwrite) float scale;
@property(readwrite) bool useBaseRot;
@property(readonly) unsigned char baseSocket;
@property(readonly) CGPoint addPos;
@property(readwrite) CGPoint rotPos;
@property(readonly) GobMachParts *baseParts;

- (float)getScale;
- (void)setHvMach:(GobHvMach *)mach;
- (void)setPartsInfo:(PartsInfo *)partsInfo;
- (PartsInfo *)getPartsInfo;

- (void)setChildParts:(GobMachParts *)child Socket:(unsigned char)socket;
- (void)setBaseParts:(GobMachParts *)base Socket:(unsigned char)socket;
- (CGPoint)getSocketPos:(unsigned char)n;

- (void)setNextMuzzle;
- (CGPoint)getMuzzlePos;
- (void)setAddPosX:(float)x;
- (void)setAddPosY:(float)y;

- (void)refreshRotationPos;

@end
