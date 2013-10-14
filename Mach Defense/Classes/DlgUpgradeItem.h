//
//  DlgUpgradeMach.h
//  MachDefense
//
//  Created by HaeJun Byun on 10. 11. 22..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//


@interface DlgUpgradeItem : QobBase
{

}

- (id)initWithBuildSet:(MachBuildSet *)buildSet;
- (id)initWithAttackSet:(SpAttackSet *)buildSet;

@end
