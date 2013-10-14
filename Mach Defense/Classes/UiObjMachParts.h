//
//  UiObjMachParts.h
//  MachDefense
//
//  Created by HaeJun Byun on 10. 12. 2..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//


@interface UiObjMachParts : NSObject
{
	PartsInfo *_partsInfo;
	UiObjMachParts *_baseParts;
	unsigned char _baseSocket;
	CGPoint _basePos, _pos;
	bool _reverse;
	QobImage *_imgShadow;
}

@property(readwrite) bool reverse;

- (void)setPartsInfo:(PartsInfo *)partsInfo;
- (void)setChildParts:(UiObjMachParts *)child Socket:(unsigned char)socket;

- (void)attachTo:(ImageAttacher *)attacher X:(int)x Y:(int)y;

@end
