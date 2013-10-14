//
//  GobItem.h
//  iFlying!
//
//  Created by 엔비 on 09. 05. 03.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//


@interface GobFieldItem : QobImage
{
	GobHvM_Player *_picker;
	ItemInfo *_itemInfo;
	NSString *_itemID;
	QobImage *_imgIcon;
	CGPoint _vel;
	float _speed, _checkLen, _maxCheckLen, _incLen;
	int _value;
	
	float _createTime, _checkTime;
}

@property(readonly) ItemInfo *itemInfo;
@property(readonly) NSString *itemID;
@property(readwrite) int value;

- (id)initWithItem:(ItemInfo *)item;
- (void)pickerDead:(GobHvM_Player *)player;

@end
