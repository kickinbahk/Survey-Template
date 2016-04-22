//
//  PQSTextInputView.h
//  Philips Questionaire
//
//  Created by Nathan Fennel on 11/29/15.
//  Copyright © 2015 HAI. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PQSTextInputViewDelegate <NSObject>

@required
- (void)textInputComplete:(NSString *)text;

@end

@interface PQSTextInputView : UIToolbar

@property (nonatomic, strong) UITextView *textView;

@property (nonatomic, strong) UIToolbar *headerToolbar;

@property (weak) id <PQSTextInputViewDelegate> delegateText;

@property (nonatomic, strong) UIView *blockingView;

- (UIBarButtonItem *)doneButton;
- (UIBarButtonItem *)titleBarButtonItem;

@end
