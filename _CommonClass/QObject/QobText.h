//
//  QobText.h
//  HeavyMach2
//
//  Created by 엔비 on 09. 08. 25.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Texture2D.h"

@interface QobText : QobBase
{
	Tile2D *_text;
	float _color[3];
}

- (id)initWithString:(NSString*)string Size:(CGSize)size Align:(UITextAlignment)align Font:(NSString*)font FontSize:(CGFloat)fontSize Retina:(bool)retina;
- (id)initWithString:(NSString*)string Size:(CGSize)size Align:(UITextAlignment)align Font:(NSString*)font FontSize:(CGFloat)fontSize;
- (void)setColorR:(unsigned char)r G:(unsigned char)g B:(unsigned char)b;

@end
