//
//  PQSTextInputView.m
//  Philips Questionaire
//
//  Created by Nathan Fennel on 11/29/15.
//  Copyright © 2015 HAI. All rights reserved.
//

#import "PQSTextInputView.h"
#import "UIFont+AppFonts.h"
#import "UIColor+AppColors.h"
#import "NGAParallaxMotion.h"

@interface PQSTextInputView ()

@property (nonatomic, strong) UIBarButtonItem *doneButton, *flexibleSpace, *fixedSpace, *titleBarButtonItem;

@end

@implementation PQSTextInputView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        self.parallaxIntensity = 10.0f;
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self addSubview:self.textView];
    
    [self addSubview:self.headerToolbar];
    
    self.layer.cornerRadius = 5.0f;
    self.clipsToBounds = YES;
	
	if (self.titleBarButtonItem.title.length > 100) {
//		self.titleBarButtonItem.title = [NSString stringWithFormat:@"%@...", [self.titleBarButtonItem.title substringToIndex:90]];
		[self.titleBarButtonItem setTitleTextAttributes:@{NSFontAttributeName : [UIFont appFontOfSize:14.0f]} forState:UIControlStateNormal];
	}
	
	if (self.titleBarButtonItem.width > self.frame.size.width - self.doneButton.width) {
		self.titleBarButtonItem.width = self.frame.size.width - self.doneButton.width - self.fixedSpace.width * 2.0f;
	}
  
    UIWindow *rootWindow = [[UIApplication sharedApplication] windows].firstObject;
	self.blockingView.frame = rootWindow.rootViewController.view.bounds;
}

- (UITextView *)textView {
    if (!_textView) {
        _textView = [[UITextView alloc] initWithFrame:self.bounds];
        _textView.frame = CGRectInset(CGRectOffset(_textView.frame, 0.0f, self.headerToolbar.frame.size.height), 10.0f, 10.0f);
        _textView.autocapitalizationType = UITextAutocapitalizationTypeSentences;
        _textView.autocorrectionType = UITextAutocorrectionTypeDefault;
        _textView.textAlignment = NSTextAlignmentLeft;
        _textView.font = [UIFont appFontOfSize:24.0f];
        _textView.textColor = [[UIColor appColor] darkenColor];
        _textView.backgroundColor = [UIColor clearColor];
    }
    
    return _textView;
}

- (UIToolbar *)headerToolbar {
    if (!_headerToolbar) {
        _headerToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.bounds.size.width, 44.0f)];
        [_headerToolbar setItems:@[self.fixedSpace, self.titleBarButtonItem, self.flexibleSpace, self.doneButton, self.fixedSpace]];
        [_headerToolbar setBarTintColor:[UIColor white]];
    }
    
    return _headerToolbar;
}

- (UIBarButtonItem *)flexibleSpace {
    return [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                         target:self
                                                         action:nil];
}

- (UIBarButtonItem *)fixedSpace {
    return [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                         target:self
                                                         action:nil];
}

- (UIBarButtonItem *)doneButton {
    if (!_doneButton) {
        _doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                    target:self
                                                                    action:@selector(doneButtonTouched:)];
        _doneButton.tintColor = [UIColor appColor];
    }
    
    return _doneButton;
}

- (UIBarButtonItem *)titleBarButtonItem {
    if (!_titleBarButtonItem) {
        _titleBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:nil
                                                               style:UIBarButtonItemStylePlain
                                                              target:self
															  action:@selector(doneButtonTouched:)];
    }
	
    return _titleBarButtonItem;
}

- (UIView *)blockingView {
	if (!_blockingView) {
		_blockingView = [[UIView alloc] initWithFrame:self.bounds];
		_blockingView.backgroundColor = [[UIColor gray] colorWithAlphaComponent:0.5f];
	}
	
	return _blockingView;
}

#pragma mark - Button Actions

- (void)doneButtonTouched:(UIBarButtonItem *)doneButton {
    NSLog(@"Done button touched");
    
    if ([self.delegateText respondsToSelector:@selector(textInputComplete:)]) {
        [self.delegateText textInputComplete:self.textView.text];
    } else {
        NSLog(@"Delegate for PQSTextInputView does not respond to \"textInputComplete:\"");
    }
	
	[self.blockingView removeFromSuperview];
}




@end
