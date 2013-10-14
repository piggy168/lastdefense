//
//  ItemInfo.m
//  HeavyMach2
//
//  Created by 엔비 on 09. 08. 06.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ItemInfo.h"


@implementation ItemInfo

@synthesize code=_code, name=_name, type=_type, icon=_icon, level=_level, strParam=_strParam, price=_price, param1=_param1, param2=_param2, param3=_param3, isBuy=_isBuy, isSell=_isSell, isSlot=_isSlot, isCount=_isCount;

- (void)setTypeWithString:(NSString *)type
{
	if([type compare:@"Coin"] == 0) _type = ITEM_COIN;
	else if([type compare:@"Mineral"] == 0) _type = ITEM_ENERGYCELL;
	else if([type compare:@"AidKit"] == 0) _type = ITEM_AIDKIT;
	else if([type compare:@"SpAtk"] == 0) _type = ITEM_SPATK;
	else if([type compare:@"Buff"] == 0) _type = ITEM_BUFF;
	else if([type compare:@"Bot"] == 0) _type = ITEM_BOT;
	else if([type compare:@"Etc"] == 0) _type = ITEM_ETC;
	else if([type compare:@"Ticket"] == 0) _type = ITEM_TICKET;
	else if([type compare:@"PtWpn"] == 0) _type = ITEM_PTWPN;
	else if([type compare:@"PtBody"] == 0) _type = ITEM_PTBODY;
	else if([type compare:@"PtBtm"] == 0) _type = ITEM_PTBTM;
	else if([type compare:@"PtArmor"] == 0) _type = ITEM_PTARMOR;
	else if([type compare:@"PtEquip"] == 0) _type = ITEM_PTEQUIP;
}

- (bool)isItemCategory:(int)category
{
	switch(category)
	{
		case 0:					// Weapon
			switch(_type)
			{
				case ITEM_PTWPN:	return true;
				default:			return false;
			}
			break;
		case 1:					// Parts
			switch(_type)
			{
				case ITEM_PTBODY:
				case ITEM_PTBTM:
				case ITEM_PTARMOR:
				case ITEM_PTEQUIP:	return true;
				default:			return false;
			}
			break;
		case 2:					// Bot
			switch(_type)
			{
				case ITEM_BOT:		return true;
				default:			return false;
			}
			break;
		case 3:					// Skill
			switch(_type)
			{
				case ITEM_SPATK:
				case ITEM_BUFF:		return true;
				default:			return false;
			}
			break;
		case 4:					// Etc
			switch(_type)
			{
				case ITEM_AIDKIT:
				case ITEM_TICKET:
				case ITEM_ETC:		return true;
				default:			return false;
			}
			break;
	}
	
	return false;
}

- (NSString *)makeItemDesc:(int)descType
{
	char szDesc[1024];
	char szAdd[1024];
	MachInfo *machInfo;
	WeaponInfo *wpnInfo;

	switch(_type)
	{
		case ITEM_PTWPN:
			wpnInfo = [GINFO getWeaponInfo:_strParam];
			if(wpnInfo != nil)
			{
				switch(wpnInfo.wpnType)
				{
					case WPN_NORMAL:	sprintf(szDesc, "Machine-gun\n\n");			break;
					case WPN_MISSILE:	sprintf(szDesc, "Missile Launcher\n\n");	break;
					case WPN_LASER:		sprintf(szDesc, "Laser-gun\n\n");			break;
					case WPN_SHOTGUN:	sprintf(szDesc, "Shotgun\n\n");				break;
					case WPN_RAILGUN:	sprintf(szDesc, "Railgun\n\n");				break;
				}
				
				sprintf(szAdd, "Atk %d\n", wpnInfo.atkPoint);
				strcat(szDesc, szAdd);
				sprintf(szAdd, "%d / %d / %.2fs / %.1fs\n\n", wpnInfo.dmg, wpnInfo.shotCnt, wpnInfo.shotDly, wpnInfo.reloadDly);
				strcat(szDesc, szAdd);
			}
			break;
		case ITEM_PTBODY:
			sprintf(szDesc, "Body Parts\n\n");
			sprintf(szAdd, "HP : %d\nDef : %d\n\n", (int)_param1, (int)_param2);
			strcat(szDesc, szAdd);
			break;
		case ITEM_PTBTM:
			sprintf(szDesc, "Foot Parts\n\n");
			sprintf(szAdd, "Speed : %d\n\n", (int)_param3);
			strcat(szDesc, szAdd);
			break;
		case ITEM_PTEQUIP:
			sprintf(szDesc, "Equip Parts\n\n");
			break;
		case ITEM_AIDKIT:
			sprintf(szDesc, "Repair Kit\n\n");
			if(_param2 == 0) sprintf(szAdd, "%d point Repair.\n\n", (int)_param1);
			else if(_param2 == 1) sprintf(szAdd, "%d%% Repair.\n\n", (int)_param1);
			strcat(szDesc, szAdd);
			break;
		case ITEM_SPATK:
			sprintf(szDesc, "Special Attack\n\n");
			wpnInfo = [GINFO getWeaponInfo:[NSString stringWithFormat:@"%@_%02d", _strParam, (int)_param1]];
			if(wpnInfo != nil)
			{
				sprintf(szAdd, "Attack Point : %d\n", wpnInfo.atkPoint);
				strcat(szDesc, szAdd);
				sprintf(szAdd, "Damage Range : %d\n\n", wpnInfo.dmgRange);
				strcat(szDesc, szAdd);
			}
			break;
		case ITEM_BUFF:
			sprintf(szDesc, "Special Item\n\n");
			break;
		case ITEM_BOT:
			machInfo = [GINFO getMachInfo:_strParam];
			if(machInfo)
			{
				switch(machInfo.refType)
				{
					case BOT_ATTACKER:	sprintf(szDesc, "Attacker BOT\n\n");	break;
					case BOT_DEFENDER:	sprintf(szDesc, "Defender BOT\n\n");	break;
					case BOT_PICKER:	sprintf(szDesc, "Item Picker BOT\n\n");	break;
					case BOT_REPAIR:	sprintf(szDesc, "Repair BOT\n\n");		break;
				}
				sprintf(szAdd, "HP : %d\n\n", machInfo.hp);
				strcat(szDesc, szAdd);
			}
			else
			{
				sprintf(szDesc, "BOT\n\n");
			}
			break;
		case ITEM_TICKET:	sprintf(szDesc, "Ticket\n\n");				break;
		default:			sprintf(szDesc, "");					break;
	}

	switch(descType)
	{
		case ITEMDESC_SHOP:
			sprintf(szAdd, "Price : %dcr", _price);
			break;
		case ITEMDESC_SELL:
			sprintf(szAdd, "SellPrice : %dcr", _type == ITEM_ETC ? _price : _price/2);
			break;
		default:
			sprintf(szAdd, "");
	}
	
	strcat(szDesc, szAdd);
	
	NSString *desc = [[NSString alloc] initWithUTF8String:szDesc];
	[desc autorelease];
	
	return desc;
}

@end
