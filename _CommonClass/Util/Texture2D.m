#import <OpenGLES/ES1/glext.h>
#import "Texture2D.h"


//CONSTANTS:

#define kMaxTextureSize	 1024

//CLASS IMPLEMENTATIONS:

static Texture2DPixelFormat defaultAlphaPixelFormat = kTexture2DPixelFormat_Default;

@implementation Texture2D

@synthesize contentSize=_size, pixelFormat=_format, width=_width, height=_height, name=_name, maxS=_maxS, maxT=_maxT, forRetina=_forRetina;

- (id)initWithData:(const void*)data pixelFormat:(Texture2DPixelFormat)pixelFormat pixelsWide:(NSUInteger)width pixelsHigh:(NSUInteger)height contentSize:(CGSize)size
{
	if((self = [super init]))
	{
		glGenTextures(1, &_name);
		glBindTexture(GL_TEXTURE_2D, _name);
		
		[self setAntiAliasTexParameters];
		
		switch(pixelFormat)
		{
			case kTexture2DPixelFormat_RGBA8888:
//				glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, width, height, GL_RGBA, GL_UNSIGNED_BYTE, data);
				glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, data);
				break;
			case kTexture2DPixelFormat_RGBA4444:
				glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_SHORT_4_4_4_4, data);
				break;
			case kTexture2DPixelFormat_RGB5A1:
				glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_SHORT_5_5_5_1, data);
				break;
			case kTexture2DPixelFormat_RGB565:
				glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, width, height, 0, GL_RGB, GL_UNSIGNED_SHORT_5_6_5, data);
				break;
			case kTexture2DPixelFormat_A8:
				glTexImage2D(GL_TEXTURE_2D, 0, GL_ALPHA, width, height, 0, GL_ALPHA, GL_UNSIGNED_BYTE, data);
				break;
			default:
				[NSException raise:NSInternalInconsistencyException format:@""];
				
		}
		
		_size = size;
		_width = width;
		_height = height;
		_format = pixelFormat;
		_maxS = size.width / (float)width;
		_maxT = size.height / (float)height;
		
		_hasPremultipliedAlpha = NO;
	}					
	return self;
}

- (void)dealloc
{
	if(_name) glDeleteTextures(1, &_name);
	[super dealloc];
}

- (NSString*)description
{
	return [NSString stringWithFormat:@"<%@ = %08X | Name = %i | Dimensions = %ix%i | Coordinates = (%.2f, %.2f)>", [self class], self, _name, _width, _height, _maxS, _maxT];
}

@end

@implementation Texture2D (Image)
	
- (id)initWithImage:(UIImage *)uiImage
{
	NSUInteger				width, height, i;
	CGContextRef			context = nil;
	void*					data = nil;;
	CGColorSpaceRef			colorSpace;
	void*					tempData;
	unsigned int*			inPixel32;
	unsigned short*			outPixel16;
	BOOL					hasAlpha;
	CGImageAlphaInfo		info;
	CGAffineTransform		transform;
	CGSize					imageSize;
	Texture2DPixelFormat    pixelFormat;
	CGImageRef				image;
	BOOL					sizeToFit = NO;
	
	image = [uiImage CGImage];
	
	if(image == NULL)
	{
		[self release];
		return nil;
	}
		
	info = CGImageGetAlphaInfo(image);
	hasAlpha = ((info == kCGImageAlphaPremultipliedLast) || (info == kCGImageAlphaPremultipliedFirst) || (info == kCGImageAlphaLast) || (info == kCGImageAlphaFirst) ? YES : NO);
	
	size_t bpp = CGImageGetBitsPerComponent(image);
	if(CGImageGetColorSpace(image))
	{
		if(hasAlpha || bpp >= 8) pixelFormat = defaultAlphaPixelFormat;
		else pixelFormat = kTexture2DPixelFormat_RGB565;
	}
	else  //NOTE: No colorspace means a mask image
	{
		pixelFormat = kTexture2DPixelFormat_A8;
	}
	
	imageSize = CGSizeMake(CGImageGetWidth(image), CGImageGetHeight(image));
	transform = CGAffineTransformIdentity;
	
	width = imageSize.width;
	
	if((width != 1) && (width & (width - 1)))
	{
		i = 1;
		while((sizeToFit ? 2 * i : i) < width) i *= 2;
		width = i;
	}
	height = imageSize.height;
	if((height != 1) && (height & (height - 1)))
	{
		i = 1;
		while((sizeToFit ? 2 * i : i) < height) i *= 2;
		height = i;
	}
	
	
	unsigned maxTextureSize = 2048;
	if( width > maxTextureSize || height > maxTextureSize )
	{
//		CCLOG(@"cocos2d: WARNING: Image (%d x %d) is bigger than the supported %d x %d", width, height, maxTextureSize, maxTextureSize);
		return nil;
	}
	
	// Create the bitmap graphics context
	
	switch(pixelFormat)
	{          
		case kTexture2DPixelFormat_RGBA8888:
		case kTexture2DPixelFormat_RGBA4444:
		case kTexture2DPixelFormat_RGB5A1:
			colorSpace = CGColorSpaceCreateDeviceRGB();
			data = malloc(height * width * 4);
			info = hasAlpha ? kCGImageAlphaPremultipliedLast : kCGImageAlphaNoneSkipLast; 
			context = CGBitmapContextCreate(data, width, height, 8, 4 * width, colorSpace, info | kCGBitmapByteOrder32Big);				
			CGColorSpaceRelease(colorSpace);
			break;
		case kTexture2DPixelFormat_RGB565:
			colorSpace = CGColorSpaceCreateDeviceRGB();
			data = malloc(height * width * 4);
			info = kCGImageAlphaNoneSkipLast;
			context = CGBitmapContextCreate(data, width, height, 8, 4 * width, colorSpace, info | kCGBitmapByteOrder32Big);
			CGColorSpaceRelease(colorSpace);
			break;
		case kTexture2DPixelFormat_A8:
			data = malloc(height * width);
			info = kCGImageAlphaOnly; 
			context = CGBitmapContextCreate(data, width, height, 8, width, NULL, info);
			break;                    
		default:
			[NSException raise:NSInternalInconsistencyException format:@"Invalid pixel format"];
	}
	
	
	CGContextClearRect(context, CGRectMake(0, 0, width, height));
	CGContextTranslateCTM(context, 0, height - imageSize.height);
	
	if(!CGAffineTransformIsIdentity(transform))
		CGContextConcatCTM(context, transform);
	CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(image), CGImageGetHeight(image)), image);
	
	// Repack the pixel data into the right format
	
	if(pixelFormat == kTexture2DPixelFormat_RGB565)
	{
		//Convert "RRRRRRRRRGGGGGGGGBBBBBBBBAAAAAAAA" to "RRRRRGGGGGGBBBBB"
		tempData = malloc(height * width * 2);
		inPixel32 = (unsigned int*)data;
		outPixel16 = (unsigned short*)tempData;
		for(i = 0; i < width * height; ++i, ++inPixel32)
			*outPixel16++ = ((((*inPixel32 >> 0) & 0xFF) >> 3) << 11) | ((((*inPixel32 >> 8) & 0xFF) >> 2) << 5) | ((((*inPixel32 >> 16) & 0xFF) >> 3) << 0);
		free(data);
		data = tempData;
		
	}
	else if(pixelFormat == kTexture2DPixelFormat_RGBA4444)
	{
		//Convert "RRRRRRRRRGGGGGGGGBBBBBBBBAAAAAAAA" to "RRRRGGGGBBBBAAAA"
		tempData = malloc(height * width * 2);
		inPixel32 = (unsigned int*)data;
		outPixel16 = (unsigned short*)tempData;
		for(i = 0; i < width * height; ++i, ++inPixel32)
			*outPixel16++ = 
			((((*inPixel32 >> 0) & 0xFF) >> 4) << 12) | // R
			((((*inPixel32 >> 8) & 0xFF) >> 4) << 8) | // G
			((((*inPixel32 >> 16) & 0xFF) >> 4) << 4) | // B
			((((*inPixel32 >> 24) & 0xFF) >> 4) << 0); // A
		
		
		free(data);
		data = tempData;
		
	}
	else if (pixelFormat == kTexture2DPixelFormat_RGB5A1)
	{
		//Convert "RRRRRRRRRGGGGGGGGBBBBBBBBAAAAAAAA" to "RRRRRGGGGGBBBBBA"
		tempData = malloc(height * width * 2);
		inPixel32 = (unsigned int*)data;
		outPixel16 = (unsigned short*)tempData;
		for(i = 0; i < width * height; ++i, ++inPixel32)
			*outPixel16++ = 
			((((*inPixel32 >> 0) & 0xFF) >> 3) << 11) | // R
			((((*inPixel32 >> 8) & 0xFF) >> 3) << 6) | // G
			((((*inPixel32 >> 16) & 0xFF) >> 3) << 1) | // B
			((((*inPixel32 >> 24) & 0xFF) >> 7) << 0); // A
		
		
		free(data);
		data = tempData;
	}
	self = [self initWithData:data pixelFormat:pixelFormat pixelsWide:width pixelsHigh:height contentSize:imageSize];
	
	// should be after calling super init
	_hasPremultipliedAlpha = (info == kCGImageAlphaPremultipliedLast || info == kCGImageAlphaPremultipliedFirst);
	
	CGContextRelease(context);
	free(data);
	
	return self;
}

- (id)initAlphaWithImage:(UIImage *)uiImage
{
	NSUInteger				width, height, i;
	CGContextRef			context = nil;
	void					*data = nil, *tempData = nil;
	CGColorSpaceRef			colorSpace;
	unsigned char*			inPixel8;
	unsigned char*			outPixel8;
	BOOL					hasAlpha;
	CGImageAlphaInfo		info;
	CGAffineTransform		transform;
	CGSize					imageSize;
	Texture2DPixelFormat    pixelFormat;
	CGImageRef				image;
//	UIImageOrientation		orientation;
	BOOL					sizeToFit = NO;
	
	image = [uiImage CGImage];
//	orientation = [uiImage imageOrientation]; 
	
	if(image == NULL)
	{
		[self release];
		NSLog(@"Image is Null");
		return nil;
	}
	
	info = CGImageGetAlphaInfo(image);
	hasAlpha = ((info == kCGImageAlphaPremultipliedLast) || (info == kCGImageAlphaPremultipliedFirst) || (info == kCGImageAlphaLast) || (info == kCGImageAlphaFirst) ? YES : NO);
	if(CGImageGetColorSpace(image))
	{
		if(hasAlpha) pixelFormat = kTexture2DPixelFormat_RGBA8888;
		else pixelFormat = kTexture2DPixelFormat_RGB565;
	}
	else  //NOTE: No colorspace means a mask image
	{
		pixelFormat = kTexture2DPixelFormat_A8;
	}
	
	imageSize = CGSizeMake(CGImageGetWidth(image), CGImageGetHeight(image));
	transform = CGAffineTransformIdentity;
	
	width = imageSize.width;
	
	if((width != 1) && (width & (width - 1)))
	{
		i = 1;
		while((sizeToFit ? 2 * i : i) < width)
		{
			i *= 2;
		}
		width = i;
	}
	height = imageSize.height;
	if((height != 1) && (height & (height - 1)))
	{
		i = 1;
		while((sizeToFit ? 2 * i : i) < height)
		{
			i *= 2;
		}
		height = i;
	}
	while((width > kMaxTextureSize) || (height > kMaxTextureSize))
	{
		width /= 2;
		height /= 2;
		transform = CGAffineTransformScale(transform, 0.5, 0.5);
		imageSize.width *= 0.5;
		imageSize.height *= 0.5;
	}
	
	switch(pixelFormat)
	{		
		case kTexture2DPixelFormat_RGBA8888:
			colorSpace = CGColorSpaceCreateDeviceRGB();
			data = malloc(height * width * 4);
			context = CGBitmapContextCreate(data, width, height, 8, 4 * width, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
			CGColorSpaceRelease(colorSpace);
			break;
		case kTexture2DPixelFormat_RGB565:
			colorSpace = CGColorSpaceCreateDeviceRGB();
			data = malloc(height * width * 4);
			context = CGBitmapContextCreate(data, width, height, 8, 4 * width, colorSpace, kCGImageAlphaNoneSkipLast | kCGBitmapByteOrder32Big);
			CGColorSpaceRelease(colorSpace);
			break;
		case kTexture2DPixelFormat_A8:
			data = malloc(height * width);
			context = CGBitmapContextCreate(data, width, height, 8, width, NULL, kCGImageAlphaOnly);
			break;				
		default:
			[NSException raise:NSInternalInconsistencyException format:@"Invalid pixel format"];
	}
	
	CGContextClearRect(context, CGRectMake(0, 0, width, height));
	CGContextTranslateCTM(context, 0, height - imageSize.height);
	
	if(!CGAffineTransformIsIdentity(transform)) CGContextConcatCTM(context, transform);
	CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(image), CGImageGetHeight(image)), image);
		
	tempData = malloc(height * width);
	inPixel8 = (unsigned char *)data + 3;
	outPixel8 = (unsigned char *)tempData;
	for(i = 0; i < width * height; i++, inPixel8 += 4)
	{
		*outPixel8++ = *inPixel8 / 2;
	}
	free(data);
	data = tempData;

	self = [self initWithData:data pixelFormat:kTexture2DPixelFormat_A8 pixelsWide:width pixelsHigh:height contentSize:imageSize];
	
	CGContextRelease(context);
	free(data);
	
	return self;
}

@end

@implementation Texture2D (Text)

- (id)initWithString:(NSString*)string dimensions:(CGSize)dimensions alignment:(UITextAlignment)alignment fontName:(NSString*)name fontSize:(CGFloat)size
{
	NSUInteger				width,
							height,
							i;
	CGContextRef			context;
	void*					data;
	CGColorSpaceRef			colorSpace;
	UIFont *				font;
	
	font = [UIFont fontWithName:name size:size];
	
	width = dimensions.width;
	if((width != 1) && (width & (width - 1)))
	{
		i = 1;
		while(i < width) i *= 2;
		width = i;
	}
	height = dimensions.height;
	if((height != 1) && (height & (height - 1)))
	{
		i = 1;
		while(i < height) i *= 2;
		height = i;
	}
	
	colorSpace = CGColorSpaceCreateDeviceGray();
	data = calloc(height, width);
	context = CGBitmapContextCreate(data, width, height, 8, width, colorSpace, kCGImageAlphaNone);
	CGColorSpaceRelease(colorSpace);
	
	CGContextSetGrayFillColor(context, 1.0, 1.0);
	CGContextTranslateCTM(context, 0.0, height);
	CGContextScaleCTM(context, 1.0, -1.0); //NOTE: NSString draws in UIKit referential i.e. renders upside-down compared to CGBitmapContext referential
	UIGraphicsPushContext(context);
	[string drawInRect:CGRectMake(0, 0, dimensions.width, dimensions.height) withFont:font lineBreakMode:UILineBreakModeWordWrap alignment:alignment];
	UIGraphicsPopContext();
	
	self = [self initWithData:data pixelFormat:kTexture2DPixelFormat_A8 pixelsWide:width pixelsHigh:height contentSize:dimensions];
	
	CGContextRelease(context);
	free(data);
	
	return self;
}

@end

@implementation Texture2D (GLFilter)

-(void) generateMipmap
{
	glBindTexture( GL_TEXTURE_2D, self.name );
	glGenerateMipmapOES(GL_TEXTURE_2D);
}

-(void) setTexParameters: (ccTexParams*) texParams
{
	glBindTexture( GL_TEXTURE_2D, self.name );
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, texParams->minFilter );
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, texParams->magFilter );
	glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, texParams->wrapS );
	glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, texParams->wrapT );
}

-(void) setAliasTexParameters
{
	ccTexParams texParams = { GL_NEAREST, GL_NEAREST, GL_CLAMP_TO_EDGE, GL_CLAMP_TO_EDGE };
	[self setTexParameters: &texParams];
}

-(void) setAntiAliasTexParameters
{
	ccTexParams texParams = { GL_LINEAR, GL_LINEAR, GL_CLAMP_TO_EDGE, GL_CLAMP_TO_EDGE };
	[self setTexParameters: &texParams];
}
@end

@implementation Texture2D (Drawing)

- (void) drawAtPoint:(CGPoint)point 
{
	GLfloat		coordinates[] = { 0,	_maxT,
								_maxS,	_maxT,
								0,		0,
								_maxS,	0 };
	GLfloat		width = (GLfloat)_width * _maxS / 2,
				height = (GLfloat)_height * _maxT / 2;
	GLfloat		vertices[] = {	-width + point.x,	-height + point.y,	0.0,
								width + point.x,	-height + point.y,	0.0,
								-width + point.x,	height + point.y,	0.0,
								width + point.x,	height + point.y,	0.0 };
	
	glBindTexture(GL_TEXTURE_2D, _name);
	glVertexPointer(3, GL_FLOAT, 0, vertices);
	glTexCoordPointer(2, GL_FLOAT, 0, coordinates);
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}


- (void) drawInRect:(CGRect)rect
{
	GLfloat	 coordinates[] = {  0,		_maxT,		_maxS,	_maxT,
								0,		0,			_maxS,	0  };
	GLfloat	vertices[] = {	rect.origin.x,							rect.origin.y,							0.0,
							rect.origin.x + rect.size.width,		rect.origin.y,							0.0,
							rect.origin.x,							rect.origin.y + rect.size.height,		0.0,
							rect.origin.x + rect.size.width,		rect.origin.y + rect.size.height,		0.0 };
	
	glBindTexture(GL_TEXTURE_2D, _name);
	glVertexPointer(3, GL_FLOAT, 0, vertices);
	glTexCoordPointer(2, GL_FLOAT, 0, coordinates);
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

@end
