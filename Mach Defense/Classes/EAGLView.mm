//
//  EAGLView.m
//  HeavyMach2
//
//  Created by 엔비 on 09. 06. 27.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//


#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGLDrawable.h>

#import "EAGLView.h"
#import "DefaultAppDelegate.h"
#import "EAGLViewController.h"

#define USE_DEPTH_BUFFER 0

EAGLView *_glView = nil;

@implementation EAGLView

@synthesize interfaceOrientation=_interfaceOrientation, deviceType=_deviceType, delegate=_delegate, viewController=_viewController, autoresizesSurface=_autoresize, surfaceSize=_size, framebuffer = _viewFramebuffer, pixelFormat = _format, depthFormat = _depthFormat, context = _context;


// You must implement this
+ (Class)layerClass
{
	return [CAEAGLLayer class];
}

//The GL view is stored in the nib file. When it's unarchived it's sent -initWithCoder:
- (id)initWithCoder:(NSCoder*)coder
{
	if((self = [super initWithCoder:coder]))
	{
#ifdef SCREEN_LANDSCAPE
		_interfaceOrientation = UIInterfaceOrientationLandscapeRight;
#else
		_interfaceOrientation = UIDeviceOrientationPortrait;
#endif
		[self setMultipleTouchEnabled:YES];
		[[UIApplication sharedApplication] setStatusBarOrientation:(UIInterfaceOrientation)_interfaceOrientation];
		
		CAEAGLLayer *eaglLayer = (CAEAGLLayer*)[self layer];
		
		_deviceType = DEVICE_IPHONE;
#if __IPHONE_3_2 <= __IPHONE_OS_VERSION_MAX_ALLOWED
		if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) _deviceType = DEVICE_IPAD;
#endif
		if(_deviceType == DEVICE_IPHONE && [[UIScreen mainScreen] scale] == 2.0)
		{
			_deviceType = DEVICE_IPHONE_RETINA;
			self.contentScaleFactor = 2.0;
			eaglLayer.contentsScale = 2.0;
		}

		[eaglLayer setDrawableProperties:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGB565, kEAGLDrawablePropertyColorFormat, nil]];
		_depthFormat = 0;
		
		_context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
		if(_context == nil)
		{
			[self release];
			return nil;
		}
		/*
		if(![self _createSurface])
		{
			[self release];
			return nil;
		}*/
	}
	
//	_viewController = [[EAGLViewController alloc] init];
//	[_viewController setView:self];
	
	_glView = self;
	return self;
}

- (void) createViewController:(CGSize)size
{
    _size = size;
    if(![self _createSurface])
    {
        [self release];
    }
    
  	_viewController = [[EAGLViewController alloc] init];
	[_viewController setView:self];
}

- (BOOL) _createSurface
{
	CAEAGLLayer*			eaglLayer = (CAEAGLLayer*)[self layer];
	CGSize					newSize = _size;
	GLuint					oldRenderbuffer;
	GLuint					oldFramebuffer;
	
	if(![EAGLContext setCurrentContext:_context]) return NO;
	
//	newSize = [eaglLayer bounds].size;
//	newSize.width = roundf(newSize.width);
//	newSize.height = roundf(newSize.height);
//	_size = newSize;
	
	if(_deviceType == DEVICE_IPHONE_RETINA)
	{
		newSize.width *= 2.f;
		newSize.height *= 2.f;
	}
	
	glGetIntegerv(GL_RENDERBUFFER_BINDING_OES, (GLint *) &oldRenderbuffer);
	glGetIntegerv(GL_FRAMEBUFFER_BINDING_OES, (GLint *) &oldFramebuffer);
	
	glGenRenderbuffersOES(1, &_viewRenderbuffer);
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, _viewRenderbuffer);
	
	if(![_context renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable:eaglLayer])
	{
		glDeleteRenderbuffersOES(1, &_viewRenderbuffer);
		glBindRenderbufferOES(GL_RENDERBUFFER_BINDING_OES, oldRenderbuffer);
		return NO;
	}
	
	glGenFramebuffersOES(1, &_viewFramebuffer);
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, _viewFramebuffer);
	glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, _viewRenderbuffer);
	if (_depthFormat)
	{
		glGenRenderbuffersOES(1, &_depthRenderbuffer);
		glBindRenderbufferOES(GL_RENDERBUFFER_OES, _depthRenderbuffer);
		glRenderbufferStorageOES(GL_RENDERBUFFER_OES, _depthFormat, newSize.width, newSize.height);
		glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_DEPTH_ATTACHMENT_OES, GL_RENDERBUFFER_OES, _depthRenderbuffer);
	}
	
	if(!_hasBeenCurrent)
	{
        NSLog(@"_hasBeenCurrent %.0f %.0f",newSize.width, newSize.height);
        NSLog(@"surface %.0f %.0f",_size.width, _size.height);
		glViewport(0, 0, newSize.width, newSize.height);
		glScissor(0, 0, newSize.width, newSize.height);
		_hasBeenCurrent = YES;
	}
	else
	{
		glBindFramebufferOES(GL_FRAMEBUFFER_OES, oldFramebuffer);
	}
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, oldRenderbuffer);
	
	switch(_interfaceOrientation)
	{
		case UIInterfaceOrientationLandscapeRight:
			glTranslatef(0, _size.height, 0);
			glRotatef(-90, 0, 0, 1);
			break;
		case UIInterfaceOrientationLandscapeLeft:
			glTranslatef(_size.width, 0, 0);
			glRotatef(90.f, 0, 0, 1);
			break;
	}
	
	[_delegate didResizeEAGLSurfaceForView:self];
	
	return YES;
}

- (void) _destroySurface
{
	EAGLContext *oldContext = [EAGLContext currentContext];
	
	if (oldContext != _context)
		[EAGLContext setCurrentContext:_context];
	
	if(_depthFormat)
	{
		glDeleteRenderbuffersOES(1, &_depthRenderbuffer);
		_depthRenderbuffer = 0;
	}
	
	glDeleteRenderbuffersOES(1, &_viewRenderbuffer);
	_viewRenderbuffer = 0;
	
	glDeleteFramebuffersOES(1, &_viewFramebuffer);
	_viewFramebuffer = 0;
	
	if(oldContext != _context)
		[EAGLContext setCurrentContext:oldContext];
	else
		[EAGLContext setCurrentContext:nil];
}

/*- (void)setInterfaceOrientation:(GLuint)orientation
{
	if(_interfaceOrientation == orientation) return;
	
	switch(_interfaceOrientation)
	{
		case UIInterfaceOrientationLandscapeRight:
			glTranslatef(_size.height, 0, 0);
			glRotatef(90.f, 0, 0, 1);
			break;
		case UIInterfaceOrientationLandscapeLeft:
			glTranslatef(0, _size.width, 0);
			glRotatef(-90, 0, 0, 1);
			break;
	}

	_interfaceOrientation = orientation;
	[[UIApplication sharedApplication] setStatusBarOrientation:(UIInterfaceOrientation)_interfaceOrientation];
	
	switch(_interfaceOrientation)
	{
		case UIInterfaceOrientationLandscapeRight:
			glTranslatef(0, _size.height, 0);
			glRotatef(-90, 0, 0, 1);
			break;
		case UIInterfaceOrientationLandscapeLeft:
			glTranslatef(_size.width, 0, 0);
			glRotatef(90.f, 0, 0, 1);
			break;
	}
}*/

- (void) dealloc
{
	[self _destroySurface];
	
	[_context release];
	_context = nil;
	
	[super dealloc];
}

- (void) layoutSubviews
{
	CGRect bounds = [self bounds];
	
	if(_autoresize && ((roundf(bounds.size.width) != _size.width) || (roundf(bounds.size.height) != _size.height)))
	{
		[self _destroySurface];
		[self _createSurface];
	}
}

- (void) setAutoresizesEAGLSurface:(BOOL)autoresizesEAGLSurface;
{
	_autoresize = autoresizesEAGLSurface;
	if(_autoresize) [self layoutSubviews];
}

- (void) setCurrentContext
{
	if(![EAGLContext setCurrentContext:_context])
	{
		printf("Failed to set current context %p in %s\n", _context, __FUNCTION__);
	}
}

- (BOOL) isCurrentContext
{
	return ([EAGLContext currentContext] == _context ? YES : NO);
}

- (void) clearCurrentContext
{
	if(![EAGLContext setCurrentContext:nil])
		printf("Failed to clear current context in %s\n", __FUNCTION__);
}

- (void) swapBuffers
{
	EAGLContext *oldContext = [EAGLContext currentContext];
	
	if(oldContext != _context) [EAGLContext setCurrentContext:_context];
	
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, _viewRenderbuffer);
	
	if(![_context presentRenderbuffer:GL_RENDERBUFFER_OES])	printf("Failed to swap renderbuffer in %s\n", __FUNCTION__);
	
	if(oldContext != _context) [EAGLContext setCurrentContext:oldContext];
}

- (CGPoint) convertPointFromViewToSurface:(CGPoint)point
{
	CGRect bounds = [self bounds];
	return CGPointMake((point.x - bounds.origin.x) / bounds.size.width * _size.width, (point.y - bounds.origin.y) / bounds.size.height * _size.height);
}

- (CGRect) convertRectFromViewToSurface:(CGRect)rect
{
	CGRect bounds = [self bounds];
	return CGRectMake((rect.origin.x - bounds.origin.x) / bounds.size.width * _size.width, (rect.origin.y - bounds.origin.y) / bounds.size.height * _size.height, rect.size.width / bounds.size.width * _size.width, rect.size.height / bounds.size.height * _size.height);
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	CGRect bounds = [self bounds];
	CGPoint location;
	
	for(UITouch *touch in touches)
	{
		location = [touch locationInView:self];
		location.y = bounds.size.height - location.y;
		
		[(DefaultAppDelegate *)[[UIApplication sharedApplication] delegate] onTap:location State:TAP_START ID:touch];
	}	
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{  
	CGRect bounds = [self bounds];
	CGPoint location;
	
	for(UITouch *touch in touches)
	{
		location = [touch locationInView:self];
		location.y = bounds.size.height - location.y;
		
		[(DefaultAppDelegate *)[[UIApplication sharedApplication] delegate] onTap:location State:TAP_MOVE ID:touch];
	}	
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	CGRect bounds = [self bounds];
	CGPoint location;
	
	for(UITouch *touch in touches)
	{
		location = [touch locationInView:self];
		location.y = bounds.size.height - location.y;
		
		[(DefaultAppDelegate *)[[UIApplication sharedApplication] delegate] onTap:location State:TAP_END ID:touch];
	}	
}

@end
