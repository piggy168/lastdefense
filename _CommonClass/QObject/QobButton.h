//
//  QUiButton.h
//  Jumping!
//
//  Created by 엔비 on 08. 09. 26.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

@class Tile2D;

@interface QobButton : QobBase
{
	Tile2D *_tile;
	unsigned int _tileNo;
	unsigned int _releaseTileNo;
	unsigned int _deactiveTileNo;
	unsigned int _id;
	id _tapID;
	
	float _btnClickTime;
	float _btnReleaseTime;
	
	float _pushDepth;
	float _pushDelay;
	float _releaseHeight;
	float _releaseDelay;
	
	id _dataObject;
	int _intData;
	
	CGPoint _tapPos;
}

- (id)initWithTile:(Tile2D *)tile TileNo:(unsigned int)n;
- (id)initWithTile:(Tile2D *)tile TileNo:(unsigned int)n ID:(unsigned int)buttonId;

@property(readonly) Tile2D *tile;
@property(readwrite) unsigned int buttonId;
@property(readwrite) float pushDepth;
@property(readwrite) float pushDelay;
@property(readwrite) float releaseHeight;
@property(readwrite) float releaseDelay;
@property(readwrite, retain) id dataObject;
@property(readwrite) int intData;
@property(readonly) CGPoint tapPos;

- (void)setTile:(Tile2D *)tile;
- (void)setBoundWidth:(float)width Height:(float)height;
- (void)setDefaultTileNo:(unsigned int)n;
- (void)setReleaseTileNo:(unsigned int)n;
- (void)setDeactiveTileNo:(unsigned int)n;
- (void)setReleaseAction;

@end
