#import <UIKit/UIKit.h>
#import <OpenGLES/ES1/gl.h>

//CONSTANTS:
#define ENABLE_DEFAULT_GL_STATES() {				\
glEnableClientState(GL_VERTEX_ARRAY);			\
glEnableClientState(GL_COLOR_ARRAY);			\
glEnableClientState(GL_TEXTURE_COORD_ARRAY);	\
glEnable(GL_TEXTURE_2D);						\
}

#define DISABLE_DEFAULT_GL_STATES() {			\
glDisable(GL_TEXTURE_2D);						\
glDisableClientState(GL_COLOR_ARRAY);			\
glDisableClientState(GL_TEXTURE_COORD_ARRAY);	\
glDisableClientState(GL_VERTEX_ARRAY);			\
}

typedef enum {
	kTexture2DPixelFormat_Automatic = 0,
	//! 32-bit texture: RGBA8888
	kTexture2DPixelFormat_RGBA8888,
	//! 16-bit texture: used with images that have alpha pre-multiplied
	kTexture2DPixelFormat_RGB565,
	//! 8-bit textures used as masks
	kTexture2DPixelFormat_A8,
	//! 16-bit textures: RGBA4444
	kTexture2DPixelFormat_RGBA4444,
	//! 16-bit textures: RGB5A1
	kTexture2DPixelFormat_RGB5A1,
} Texture2DPixelFormat;

#define kTexture2DPixelFormat_Default kTexture2DPixelFormat_RGBA8888

//CLASS INTERFACES:

/*
This class allows to easily create OpenGL 2D textures from images, text or raw data.
The created Texture2D object will always have power-of-two dimensions.
Depending on how you create the Texture2D object, the actual image area of the texture might be smaller than the texture dimensions i.e. "contentSize" != (pixelsWide, pixelsHigh) and (maxS, maxT) != (1.0, 1.0).
Be aware that the content of the generated textures will be upside-down!
*/
@interface Texture2D : NSObject
{
@protected
	GLuint					_name;
	CGSize					_size;
	NSUInteger				_width, _height;
	Texture2DPixelFormat	_format;
	GLfloat					_maxS, _maxT;
	BOOL					_hasPremultipliedAlpha;
	BOOL					_forRetina;
}
- (id) initWithData:(const void*)data pixelFormat:(Texture2DPixelFormat)pixelFormat pixelsWide:(NSUInteger)width pixelsHigh:(NSUInteger)height contentSize:(CGSize)size;

@property(readonly) Texture2DPixelFormat pixelFormat;
@property(readonly) NSUInteger width;
@property(readonly) NSUInteger height;

@property(readonly) GLuint name;

@property(readonly, nonatomic) CGSize contentSize;
@property(readonly) GLfloat maxS;
@property(readonly) GLfloat maxT;
@property(readwrite) BOOL forRetina;
@end

/*
Drawing extensions to make it easy to draw basic quads using a Texture2D object.
These functions require GL_TEXTURE_2D and both GL_VERTEX_ARRAY and GL_TEXTURE_COORD_ARRAY client states to be enabled.
*/
@interface Texture2D (Drawing)
- (void) drawAtPoint:(CGPoint)point;
- (void) drawInRect:(CGRect)rect;
@end

/*
Extensions to make it easy to create a Texture2D object from an image file.
Note that RGBA type textures will have their alpha premultiplied - use the blending mode (GL_ONE, GL_ONE_MINUS_SRC_ALPHA).
*/
@interface Texture2D (Image)
- (id)initWithImage:(UIImage *)uiImage;
- (id)initAlphaWithImage:(UIImage *)uiImage;
@end

/*
Extensions to make it easy to create a Texture2D object from a string of text.
Note that the generated textures are of type A8 - use the blending mode (GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA).
*/
@interface Texture2D (Text)
- (id) initWithString:(NSString*)string dimensions:(CGSize)dimensions alignment:(UITextAlignment)alignment fontName:(NSString*)name fontSize:(CGFloat)size;
@end

typedef struct _ccTexParams
{
	GLuint	minFilter;
	GLuint	magFilter;
	GLuint	wrapS;
	GLuint	wrapT;
} ccTexParams;

@interface Texture2D (GLFilter)
- (void)setTexParameters: (ccTexParams*) texParams;
- (void)setAntiAliasTexParameters;
- (void)setAliasTexParameters;
- (void)generateMipmap;


@end
