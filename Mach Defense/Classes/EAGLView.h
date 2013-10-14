//
//  EAGLView.h
//  iFlying!
//
//  Created by 엔비 on 09. 02. 07.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

#import "Texture2D.h"
#import "EAGLViewController.h"

@class EAGLView;

@protocol EAGLViewDelegate <NSObject>
- (void) didResizeEAGLSurfaceForView:(EAGLView*)view; //Called whenever the EAGL surface has been resized
@end

@interface EAGLView : UIView
{
@private
	GLuint _deviceType;
	EAGLContext *_context;
	EAGLViewController *_viewController;
	
	NSString *_format;
	GLuint _viewRenderbuffer, _viewFramebuffer;
	GLuint _depthRenderbuffer;
	GLuint _depthFormat;
	GLuint _interfaceOrientation;
	CGSize _size;
	BOOL _autoresize;
	BOOL _hasBeenCurrent;
	
	id<EAGLViewDelegate> _delegate;
}

- (id)initWithCoder:(NSCoder*)coder; 

@property(readwrite) GLuint interfaceOrientation, deviceType;
@property(readonly) NSString* pixelFormat;
@property(readonly) GLuint depthFormat, framebuffer;
@property(readonly) EAGLContext *context;
@property(readonly) EAGLViewController *viewController;

@property BOOL autoresizesSurface; //NO by default - Set to YES to have the EAGL surface automatically resized when the view bounds change, otherwise the EAGL surface contents is rendered scaled
@property(readonly, nonatomic) CGSize surfaceSize;

@property(assign) id<EAGLViewDelegate> delegate;

- (void) createViewController:(CGSize)size;
- (BOOL) _createSurface;
- (void) _destroySurface;

- (void) setCurrentContext;
- (BOOL) isCurrentContext;
- (void) clearCurrentContext;

- (void) swapBuffers; //This also checks the current OpenGL error and logs an error if needed

- (CGPoint) convertPointFromViewToSurface:(CGPoint)point;
- (CGRect) convertRectFromViewToSurface:(CGRect)rect;

@end
