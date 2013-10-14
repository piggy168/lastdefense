/* cocos2d for iPhone
 *
 * http://www.cocos2d-iphone.org
 *
 * Copyright (C) 2008,2009 Ricardo Quesada
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the 'cocos2d for iPhone' license.
 *
 * You will find a copy of this license within the cocos2d for iPhone
 * distribution inside the "LICENSE" file.
 *
 */

#import "Texture2D.h"

typedef struct TVertex3F
{
	float x;
	float y;
} TVertex3F;

typedef struct TColor4B
{
	unsigned char r;
	unsigned char g;
	unsigned char b;
	unsigned char a;
} TColor4B;

typedef struct TCoord2F
{
	float u;
	float v;
} TCoord2F;

//! a Point with a vertex point, a tex coord point and a color 4B
typedef struct TVertexInfo
{
	TVertex3F	vertices;			// 12 bytes
	TColor4B	colors;				// 4 bytes
	TCoord2F	coords;				// 8 bytes
} TVertexInfo;

typedef struct TQuadInfo
{
	TVertexInfo	tl;		//! top left
	TVertexInfo	bl;		//! bottom left
	TVertexInfo	tr;		//! top right
	TVertexInfo	br;		//! bottom right
} TQuadInfo;


@interface TextureAtlas : NSObject
{
	NSUInteger	totalQuads_;
	NSUInteger	capacity_;
	NSUInteger	blendType_;
	TQuadInfo	*quads_;			// quads to be rendered
	GLushort	*indices_;
	Texture2D	*texture_;
#if CC_TEXTURE_ATLAS_USES_VBO
	GLuint		buffersVBO_[2];		//0: vertex  1: indices
#endif // CC_TEXTURE_ATLAS_USES_VBO
}

/** quantity of quads that are going to be drawn */
@property (nonatomic,readwrite) NSUInteger totalQuads, blendType;
/** quantity of quads that can be stored with the current texture atlas size */
@property (nonatomic,readonly) NSUInteger capacity;
/** Texture of the texture atlas */
@property (nonatomic,retain) Texture2D *texture;
/** Quads that are going to be rendered */
@property (nonatomic,readwrite) TQuadInfo *quads;


+(id) textureAtlasWithTexture:(Texture2D *)tex capacity:(NSUInteger)capacity;
-(id) initWithTexture:(Texture2D *)tex capacity:(NSUInteger)capacity;

/** updates a Quad (texture, vertex and color) at a certain index
 * index must be between 0 and the atlas capacity - 1
 @since v0.8
 */
-(void) updateQuad:(TQuadInfo*)quad atIndex:(NSUInteger)index;

/** Inserts a Quad (texture, vertex and color) at a certain index
 index must be between 0 and the atlas capacity - 1
 @since v0.8
 */
-(void) insertQuad:(TQuadInfo*)quad atIndex:(NSUInteger)index;

/** Removes the quad that is located at a certain index and inserts it at a new index
 This operation is faster than removing and inserting in a quad in 2 different steps
 @since v0.7.2
*/
-(void) insertQuadFromIndex:(NSUInteger)fromIndex atIndex:(NSUInteger)newIndex;

/** removes a quad at a given index number.
 The capacity remains the same, but the total number of quads to be drawn is reduced in 1
 @since v0.7.2
 */
-(void) removeQuadAtIndex:(NSUInteger) index;

/** removes all Quads.
 The TextureAtlas capacity remains untouched. No memory is freed.
 The total number of quads to be drawn will be 0
 @since v0.7.2
 */
-(void) removeAllQuads;
 
/** resize the capacity of the Texture Atlas.
 * The new capacity can be lower or higher than the current one
 * It returns YES if the resize was successful.
 * If it fails to resize the capacity it will return NO with a new capacity of 0.
 */
-(BOOL) resizeCapacity: (NSUInteger) n;


/** draws n quads
 * n can't be greater than the capacity of the Atlas
 */
-(void) drawNumberOfQuads: (NSUInteger) n;

/** draws all the Atlas's Quads
 */
-(void) drawQuads;

@end
