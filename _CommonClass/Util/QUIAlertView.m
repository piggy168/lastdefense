//
//  MUIAlertView.m
//
//  Created by SUNG WOOK MOON on 09. 11. 10..
//  Copyright 2009 Arista. All rights reserved.
//

#import "QUIAlertView.h"
//- (id)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id /*<UIAlertViewDelegate>*/)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ...;


@implementation QUIAlertView
- (id)initWithTitle:(NSString *)title numberOfTextFields:(NSInteger)fields delegate:(id /*<UIAlertViewDelegate>*/)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitle:(NSString *)otherButtonTitle
{
	NSMutableString *s = [NSMutableString string];
	for (int i = 0; i < fields * 1.5; i++) [s appendString:@"\n"];
	
	self = [super initWithTitle:title message:s delegate:delegate cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitle,nil];
	if (self != nil)
	{
		_fields = [[NSMutableArray alloc] initWithCapacity:fields];
		for (int i = 0; i < fields; i++)
		{
			UITextField *f = [[[UITextField alloc] initWithFrame:CGRectMake(10.0, 50.0 + 35.0 * i, 263.0, 30.0)] autorelease];
			f.borderStyle = UITextBorderStyleRoundedRect;
			f.delegate = self;
			[self addSubview:f];
			[_fields addObject:f];
		}
	}
	return self;
}

- (void)show
{
	[super show];
}

- (void)dealloc
{
	[_fields release]; _fields = nil;
	[super dealloc];
}

- (UITextField *)fieldAtIndex:(NSInteger)index
{
	if ([_fields count] <= index) return nil;
	return [_fields objectAtIndex:index];
}

- (NSInteger)numberOfFields
{
	return [_fields count];	
}

#pragma mark -
#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.3];
	self.center = CGPointMake(self.center.x, 384.0);
	[UIView commitAnimations];
	return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{           // became first responder
	if ([self.delegate respondsToSelector:@selector(textFieldDidBeginEditing:)])
	{
		[self.delegate textFieldDidBeginEditing:textField];
	}
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{          // return YES to allow editing to stop and to resign first responder status. NO to disallow the editing session to end
	if ([self.delegate respondsToSelector:@selector(textFieldShouldEndEditing:)])
	{
		return [self.delegate textFieldShouldEndEditing:textField];
	} 
	return YES;
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{             // may be called if forced even if shouldEndEditing returns NO (e.g. view removed from window) or endEditing:YES called
	if ([self.delegate respondsToSelector:@selector(textFieldDidEndEditing:)])
	{
		[self.delegate textFieldDidEndEditing:textField];
	}
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{   // return NO to not change text
	if ([self.delegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)])
	{
		return [self.delegate textField:textField shouldChangeCharactersInRange:range replacementString:string];
	}
	return YES;
}
	
- (BOOL)textFieldShouldClear:(UITextField *)textField
{               // called when clear button pressed. return NO to ignore (no notifications)
	if ([self.delegate respondsToSelector:@selector(textFieldShouldClear:)])
	{
		return [self.delegate textFieldShouldClear:textField];
	}
	return NO;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{              // called when 'return' key pressed. return NO to ignore.
	if ([self.delegate respondsToSelector:@selector(textFieldShouldReturn:)])
	{
		return [self.delegate textFieldShouldReturn:textField];
	}
	return NO;
}

@end
