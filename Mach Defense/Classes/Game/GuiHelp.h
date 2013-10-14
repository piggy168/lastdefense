//
//  GuiHelp.h
//  HeavyMach2
//
//  Created by 엔비 on 10. 1. 12..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//


@interface GuiHelp : QobBase
{
	ResMgr_Tile *_tileResMgr;

	QobImage *_helpBG, *_helpHelp;
	int _page;
	BOOL _chgPage;
	NSString *_locale;
}

- (id)initWithLocale:(NSString *)localeCode Page:(int)page;
- (void)setPage:(int)page;
@end
