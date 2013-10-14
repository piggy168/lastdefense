//
//  ImageAttatcher.m
//  MarineBlue
//
//  Created by 엔비 on 10. 5. 13..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <OpenGLES/ES1/glext.h>
#import "ImageAttacher.h"
#import "Texture2D.h"

@implementation ImageAttacher
@synthesize fileName=_fileName;
@synthesize width=_width, height=_height;
@synthesize data=_data;
@synthesize pixelFormat=_pixelFormat;
@synthesize imageSize=_imageSize;


- (id)initWithWidth:(int)width Height:(int)height Name:(NSString *)name
{
	[super init];
	
	_fileName = [[NSString alloc] initWithString:name];
	
	int i;
	BOOL sizeToFit = NO;
	
	_info = kCGImageAlphaLast;
	_hasAlpha = YES;
	_pixelFormat = kTexture2DPixelFormat_Default;
	
	_imageSize = CGSizeMake(width, height);
	_width = width;
	_height = height;
	
	_transform = CGAffineTransformIdentity;
	
	if((_width != 1) && (_width & (_width - 1)))
	{
		i = 1;
		while((sizeToFit ? 2 * i : i) < _width) i *= 2;
		_width = i;
	}

	if((_height != 1) && (_height & (_height - 1)))
	{
		i = 1;
		while((sizeToFit ? 2 * i : i) < _height) i *= 2;
		_height = i;
	}

	unsigned maxTextureSize = 1024;
	if( _width > maxTextureSize || _height > maxTextureSize )
	{
		return self;
	}
	
	_colorSpace = CGColorSpaceCreateDeviceRGB();
	_data = malloc(_height * _width * 4);
	_info = _hasAlpha ? kCGImageAlphaPremultipliedLast : kCGImageAlphaNoneSkipLast; 
	_context = CGBitmapContextCreate(_data, _width, _height, 8, 4 * _width, _colorSpace, _info | kCGBitmapByteOrder32Big);				
	CGColorSpaceRelease(_colorSpace);

	CGContextClearRect(_context, CGRectMake(0, 0, _width, _height));
	CGContextTranslateCTM(_context, 0, _height - _imageSize.height);
	
	if(!CGAffineTransformIsIdentity(_transform)) CGContextConcatCTM(_context, _transform);
	
	// Repack the pixel data into the right format
	
//	self = [self initWithData:data pixelFormat:pixelFormat pixelsWide:width pixelsHigh:height contentSize:imageSize];
	
	return self;
}

- (void)dealloc
{
	CGContextRelease(_context);
	free(_data);
	
	[super dealloc];
}

- (void)makeAlphaTile
{
	void					*data = _data, *tempData = nil;
	unsigned char*			inPixel8;
	unsigned char*			outPixel8;

	tempData = malloc(_height * _width);
	inPixel8 = (unsigned char *)data + 3;
	outPixel8 = (unsigned char *)tempData;
	for(int i = 0; i < _width * _height; i++, inPixel8 += 4)
	{
		*outPixel8++ = *inPixel8 / 2;
	}
	free(_data);
	_data = tempData;
	
	_pixelFormat = kTexture2DPixelFormat_A8;
}

-(UIImage*)image:(CGImageRef)imag Rotate:(UIImageOrientation)orient
{
    CGRect             bnds = CGRectZero;
    UIImage*           copy = nil;
    CGContextRef       ctxt = nil;
    CGRect             rect = CGRectZero;
    CGAffineTransform  tran = CGAffineTransformIdentity;
	float tmp;
	
    rect.size.width  = CGImageGetWidth(imag);
    rect.size.height = CGImageGetHeight(imag);
    
    bnds = rect;
    
    switch (orient)
    {
        case UIImageOrientationUp:
			// would get you an exact copy of the original
			assert(false);
			return nil;
			
        case UIImageOrientationUpMirrored:
			tran = CGAffineTransformMakeTranslation(rect.size.width, 0.0);
			tran = CGAffineTransformScale(tran, -1.0, 1.0);
			break;
			
        case UIImageOrientationDown:
			tran = CGAffineTransformMakeTranslation(rect.size.width,
													rect.size.height);
			tran = CGAffineTransformRotate(tran, M_PI);
			break;
			
        case UIImageOrientationDownMirrored:
			tran = CGAffineTransformMakeTranslation(0.0, rect.size.height);
			tran = CGAffineTransformScale(tran, 1.0, -1.0);
			break;
			
        case UIImageOrientationLeft:
			tmp = bnds.size.width;
			bnds.size.width = bnds.size.height;
			bnds.size.height = tmp;
//			bnds = swapWidthAndHeight(bnds);
			tran = CGAffineTransformMakeTranslation(0.0, rect.size.width);
			tran = CGAffineTransformRotate(tran, 3.0 * M_PI / 2.0);
			break;
			
        case UIImageOrientationLeftMirrored:
			tmp = bnds.size.width;
			bnds.size.width = bnds.size.height;
			bnds.size.height = tmp;
			//			bnds = swapWidthAndHeight(bnds);
			tran = CGAffineTransformMakeTranslation(rect.size.height,
													rect.size.width);
			tran = CGAffineTransformScale(tran, -1.0, 1.0);
			tran = CGAffineTransformRotate(tran, 3.0 * M_PI / 2.0);
			break;
			
        case UIImageOrientationRight:
			tmp = bnds.size.width;
			bnds.size.width = bnds.size.height;
			bnds.size.height = tmp;
			//			bnds = swapWidthAndHeight(bnds);
			tran = CGAffineTransformMakeTranslation(rect.size.height, 0.0);
			tran = CGAffineTransformRotate(tran, M_PI / 2.0);
			break;
			
        case UIImageOrientationRightMirrored:
			tmp = bnds.size.width;
			bnds.size.width = bnds.size.height;
			bnds.size.height = tmp;
			//			bnds = swapWidthAndHeight(bnds);
			tran = CGAffineTransformMakeScale(-1.0, 1.0);
			tran = CGAffineTransformRotate(tran, M_PI / 2.0);
			break;
			
        default:
			// orientation value supplied is invalid
			assert(false);
			return nil;
    }
	
    UIGraphicsBeginImageContext(bnds.size);
    ctxt = UIGraphicsGetCurrentContext();
	
    switch (orient)
    {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
			CGContextScaleCTM(ctxt, -1.0, 1.0);
			CGContextTranslateCTM(ctxt, -rect.size.height, 0.0);
			break;
			
        default:
			CGContextScaleCTM(ctxt, 1.0, -1.0);
			CGContextTranslateCTM(ctxt, 0.0, -rect.size.height);
			break;
    }
	
    CGContextConcatCTM(ctxt, tran);
    CGContextDrawImage(UIGraphicsGetCurrentContext(), rect, imag);
    
    copy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
	
    return copy;
}

- (void)attachImage:(UIImage *)uiImage ToX:(int)x Y:(int)y
{
	CGSize					imageSize;
	CGImageRef				image;

	image = [uiImage CGImage];
	imageSize = CGSizeMake(CGImageGetWidth(image), CGImageGetHeight(image));

	CGContextDrawImage(_context, CGRectMake(x-imageSize.width/2, y-imageSize.height/2, imageSize.width, imageSize.height), image);
}

- (void)attachImage:(UIImage *)uiImage ToX:(int)x Y:(int)y Rotate:(UIImageOrientation)orient
{
	CGSize		imageSize;
	UIImage		*image;
	CGImageRef	imgRef;
	
	image = [self image:[uiImage CGImage] Rotate:orient];
	imgRef = [image CGImage];
	imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
	
	CGContextDrawImage(_context, CGRectMake(x-imageSize.width/2, y-imageSize.height/2, imageSize.width, imageSize.height), imgRef);
//	[image release];
}

- (void)attachText:(NSString *)text ToX:(int)x Y:(int)y Align:(UITextAlignment)alignment Font:(NSString*)fontName FontSize:(CGFloat)size
{
	UIFont *font = [UIFont fontWithName:fontName size:size];
	CGSize textSize = [text sizeWithFont:font];
	switch(alignment)
	{
		case UITextAlignmentCenter:	x -= textSize.width / 2.f;	break;
		case UITextAlignmentRight:	x -= textSize.width;		break;
	}
	
	y -= (int)(textSize.height / 2);
	
	CGContextSelectFont(_context, [fontName UTF8String], size, kCGEncodingMacRoman);
	CGContextSetRGBFillColor(_context, 1, 1, 1, 1);
	CGContextSetTextMatrix(_context, CGAffineTransformScale(CGAffineTransformIdentity, 1.f, 1.f));
	CGContextShowTextAtPoint(_context, x, y, [text UTF8String], [text length]);
}

@end
