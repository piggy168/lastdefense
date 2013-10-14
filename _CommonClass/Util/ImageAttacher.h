//
//  ImageAttatcher.h
//  MarineBlue
//
//  Created by 엔비 on 10. 5. 13..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ImageAttacher : NSObject
{
	NSString				*_fileName;
	NSUInteger				_width, _height;
	CGContextRef			_context;
	void*					_data;
	CGColorSpaceRef			_colorSpace;
	void*					_tempData;
	unsigned int*			_inPixel32;
	unsigned short*			_outPixel16;
	BOOL					_hasAlpha;
	CGImageAlphaInfo		_info;
	CGAffineTransform		_transform;
	CGSize					_imageSize;
	Texture2DPixelFormat    _pixelFormat;
	CGImageRef				_image;
	BOOL					_sizeToFit;	
}

@property(readonly) NSString *fileName;
@property(readonly) NSUInteger width, height;
@property(readonly) void *data;
@property(readonly) Texture2DPixelFormat pixelFormat;
@property(readonly) CGSize imageSize;

- (id)initWithWidth:(int)width Height:(int)height Name:(NSString *)name;

- (void)attachImage:(UIImage *)uiImage ToX:(int)x Y:(int)y;
- (void)attachImage:(UIImage *)uiImage ToX:(int)x Y:(int)y Rotate:(UIImageOrientation)orient;
- (void)attachText:(NSString *)text ToX:(int)x Y:(int)y Align:(UITextAlignment)alignment Font:(NSString*)name FontSize:(CGFloat)size;
- (void)makeAlphaTile;

@end
