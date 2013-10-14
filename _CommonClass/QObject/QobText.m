//
//  QobText.m
//  HeavyMach2
//
//  Created by 엔비 on 09. 08. 25.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "QobText.h"


@implementation QobText

- (id)initWithString:(NSString*)string Size:(CGSize)size Align:(UITextAlignment)align Font:(NSString*)font FontSize:(CGFloat)fontSize Retina:(bool)retina
{
	[super init];
	
	_visual = true;
	_fixedPos = true;

	if(_text) [_text release];
	if(retina && TILEMGR.deviceType == DEVICE_IPHONE)
	{
		size.width *= .5f;
		size.height *= .5f;
		fontSize *= .5f;
	}
	Tile2D *text = [[Tile2D alloc] initWithString:string dimensions:size alignment:align fontName:font fontSize:fontSize];
	if(retina && TILEMGR.deviceType == DEVICE_IPHONE_RETINA) [text setForRetina:YES];
	[text tileSplitX:1 splitY:1];
	
	[self setColorR:255 G:255 B:255];

	_boundRect.origin.x = -(text.width / 2.f);
	_boundRect.origin.y = -(text.height / 2.f);
	_boundRect.size.width = text.width / 2.f;
	_boundRect.size.height = text.height / 2.f;
	
	_text = text;
	
	return self;
}

- (id)initWithString:(NSString*)string Size:(CGSize)size Align:(UITextAlignment)align Font:(NSString*)font FontSize:(CGFloat)fontSize
{
	[self initWithString:string Size:size Align:align Font:font FontSize:fontSize Retina:false];
	
	return self;
}

- (void)setColorR:(unsigned char)r G:(unsigned char)g B:(unsigned char)b
{
	if(_text != nil) [_text setColorR:r G:g B:b];
}

- (void)draw
{
	if(_text != nil)
	{
		[_text drawTile:0 x:SCRPOS_X y:SCRPOS_Y blendType:BT_NORMAL alpha:_alpha scaleX:_scaleX scaleY:_scaleY rotate:_rotate];
	}
}


@end
