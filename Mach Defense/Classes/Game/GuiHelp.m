//
//  GuiHelp.m
//  HeavyMach2
//
//  Created by 엔비 on 10. 1. 12..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GuiHelp.h"
#import "GuiGame.h"

@implementation GuiHelp

- (id)initWithLocale:(NSString *)localeCode Page:(int)page
{
	[super init];
	[self setUiReceiver:true];
	[self setLayer:VLAYER_SYSTEM];
	
	_locale = [[NSString alloc] initWithString:localeCode];
	
	Tile2D *tile;
	_tileResMgr = [[ResMgr_Tile alloc] init];
	
	tile = [_tileResMgr getTile:@"Black.png"];
	[tile tileSplitX:1 splitY:1];
	QobImage *img = [[QobImage alloc] initWithTile:tile tileNo:0];
	[img setScaleX:_glView.surfaceSize.width / 16.f];
	[img setScaleY:_glView.surfaceSize.height / 16.f];
	[self addChild:img];
	
	_helpBG = [[QobImage alloc] initWithTile:nil tileNo:0];
	[self addChild:_helpBG];

	if(page == -1)
	{
		tile = [_tileResMgr getUniTile:[NSString stringWithFormat:@"HelpScrMain_%@.jpg", localeCode]];
		_helpHelp = [[QobImage alloc] initWithTile:tile tileNo:0];
		[self addChild:_helpHelp];
		
		page = 0;
		_chgPage = true;
	}
	else
	{
		[self setPage:page];
	}

	return self;
}

- (void)dealloc
{
	[_tileResMgr removeAllTiles];
	[_tileResMgr release];
	
	[_locale release];
	
	[super dealloc];
}

- (void)setPage:(int)page
{
	if(page < 0) page = 0;
	if(page > 6) page = 6;
	_page = page;
	
	Tile2D *tile = [_tileResMgr getUniTile:[NSString stringWithFormat:@"HelpScr%02d_%@.jpg", page + 1, _locale]];
	[_helpBG setTile:tile tileNo:0];
}

- (BOOL)onTap:(CGPoint)pt State:(int)state ID:(id)tapID
{
	if(state == TAP_END)
	{
		if([_helpHelp isShow])
		{
			if(pt.y < _glView.surfaceSize.height / 4)
			{
				[self remove];
				if(GWORLD != nil)
				{
					[GWORLD setPause:false];
					[GAMEUI turnOnButtons];
				}
			}
			else
			{
				[_helpHelp setShow:false];
				[self setPage:0];
			}
		}
		else
		{
			if(_chgPage)
			{
				if(pt.x < _glView.surfaceSize.width / 4) [self setPage:_page - 1];
				else if(pt.x > _glView.surfaceSize.width - _glView.surfaceSize.width / 4) [self setPage:_page + 1];
				else
				{
					if(pt.y < _glView.surfaceSize.height / 4)
					{
						[self remove];
						if(GWORLD != nil)
						{
							[GWORLD setPause:false];
							[GAMEUI turnOnButtons];
						}
					}
					else
					{
						[_helpHelp setShow:true];
					}
				}
			}
			else
			{
				[self remove];
				if(GWORLD != nil)
				{
					[GWORLD setPause:false];
					[GAMEUI turnOnButtons];
				}
			}
		}

	}
	
	return true;
}

@end
