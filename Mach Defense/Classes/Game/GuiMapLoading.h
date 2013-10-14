//
//  GuiStageClear.h
//  iFlying!
//
//  Created by 엔비 on 09. 04. 21.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

enum EStageClearStep
{
	SCS_FADEIN, 
	SCS_CLEAR_OBJECT, SCS_CLEAR_TILEMGR, SCS_READY, SCS_LOAD_NEXTMAP, SCS_FADEOUT, 
	SCS_COMPLETE
};


@interface GuiMapLoading : QobBase
{
	QobImage *_imgBG;
	
	int _step;
	int _nextStage;
}

@property(readwrite) int nextStage;

@end
