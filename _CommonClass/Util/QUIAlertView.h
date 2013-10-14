//
//  MUIAlertView.h
//
//  Created by SUNG WOOK MOON on 09. 11. 10..
//  Copyright 2009 Arista. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface QUIAlertView : UIAlertView <UITextFieldDelegate>
{
	NSMutableArray *_fields;
}
- (id)initWithTitle:(NSString *)title numberOfTextFields:(NSInteger)fields delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitle:(NSString *)otherButtonTitle;
- (UITextField *)fieldAtIndex:(NSInteger)index;
- (NSInteger)numberOfFields;
@end
