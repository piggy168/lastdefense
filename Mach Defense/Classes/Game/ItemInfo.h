//
//  ItemInfo.h
//  HeavyMach2
//
//  Created by 엔비 on 09. 08. 06.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

enum EItemType
{
	ITEM_COIN = 0, ITEM_ENERGYCELL, ITEM_AIDKIT, ITEM_SPATK, ITEM_BUFF, ITEM_BOT, ITEM_ETC, ITEM_TICKET, 
	ITEM_PTWPN = 10, ITEM_PTBODY, ITEM_PTBTM, ITEM_PTARMOR, ITEM_PTEQUIP
};

enum EDescType
{
	ITEMDESC_NORMAL, ITEMDESC_SHOP, ITEMDESC_SELL
};

#define ITEMID_COIN		@"00001"
#define ITEMID_MINERAL	@"00101"

@interface ItemInfo : NSObject
{
	NSString *_code;
	NSString *_name;
	int _type;
	int _icon;
	int _level;
	int _price;
	float _param1, _param2, _param3;
	NSString *_strParam;
	bool _isBuy;
	bool _isSell;
	bool _isSlot;
	bool _isCount;
}

@property(readwrite, assign) NSString *code, *name, *strParam;
@property(readwrite) int type, icon, level;
@property(readwrite) int price;
@property(readwrite) float param1, param2, param3;
@property(readwrite) bool isBuy, isSell, isSlot, isCount;

- (void)setTypeWithString:(NSString *)type;
- (bool)isItemCategory:(int)category;
- (NSString *)makeItemDesc:(int)descType;

@end
