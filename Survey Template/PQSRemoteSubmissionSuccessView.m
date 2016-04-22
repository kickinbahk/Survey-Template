//
//  PQSRemoteSubmissionSuccessView.m
//  Philips Questionaire
//
//  Created by HAI on 5/11/15.
//  Copyright (c) 2015 HAI. All rights reserved.
//

#import "PQSRemoteSubmissionSuccessView.h"

#import "UIFont+AppFonts.h"
#import "UIColor+AppColors.h"

/**
 *  Default duration of animations. Close approximation of Apple's animation duration.
 */
static NSTimeInterval  const animationDuration = 0.5f;

/**
 *  The y origin of the frame of the view while offscreen.
 */
static float const hiddenFrameYOffset = -2000.0f;

@implementation PQSRemoteSubmissionSuccessView {
	UISwipeGestureRecognizer *_swipeDown;
}

- (instancetype)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	
	if (self) {
		[self addSubview:self.blur];
		[self addSubview:self.successLabel];
		[self hide];
		
		_swipeDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(hide)];
		if (hiddenFrameYOffset < 0.0f) {
			_swipeDown.direction = UISwipeGestureRecognizerDirectionUp; // if the success view slides in from above then swipe up to dismiss
		} else {
			_swipeDown.direction = UISwipeGestureRecognizerDirectionDown;
		}
		[self addGestureRecognizer:_swipeDown];
	}
	
	return self;
}


#pragma mark - Subviews

- (UIToolbar *)blur {
	if (!_blur) {
		_blur = [[UIToolbar alloc] initWithFrame:self.bounds];
	}
	
	return _blur;
}

- (UILabel *)successLabel {
	if (!_successLabel) {
		_successLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f,
																  0.0f,
																  320.0f, // hard coded to be a consistent look across devices
																  160.0f)];
		_successLabel.font = [UIFont appFont];
		_successLabel.layer.cornerRadius = 10.0f;
		_successLabel.backgroundColor = [UIColor appColor];
		_successLabel.layer.borderColor = [UIColor white].CGColor;
		_successLabel.layer.borderWidth = 0.5f;
		_successLabel.textColor = [UIColor white];
		_successLabel.textAlignment = NSTextAlignmentCenter;
		_successLabel.text = NSLocalizedString(@"Thank you for your response.", @"Statement letting the user know that their submission was successful and their participation is appreciated.");
		_successLabel.center = CGPointMake(self.frame.size.width * 0.5f,
										   self.frame.size.height * 0.5f);
		_successLabel.clipsToBounds = YES;
		_successLabel.adjustsFontSizeToFitWidth = YES;
	}
	
	return _successLabel;
}

#pragma mark - Show and Hide

- (void)show {
	[self showWithMessage:nil];
}

- (void)showWithMessage:(NSString *)message {
	if (message) {
		self.successLabel.text = NSLocalizedString(message, nil);
	}
	
	CGRect finalFrame = self.superview.frame;
	finalFrame.origin.y = hiddenFrameYOffset;
	self.frame = finalFrame;
	
	finalFrame.origin = CGPointZero;
	[UIView animateWithDuration:animationDuration
						  delay:0.0f
						options:UIViewAnimationOptionCurveEaseOut
					 animations:^{
						 self.frame = finalFrame;
					 } completion:^(BOOL finished) {
						 
					 }];
}

- (void)hide {
	if (self.superview) {
		CGRect hiddenFrame = self.superview.frame;
		hiddenFrame.origin = CGPointMake(0.0f, hiddenFrameYOffset);
		
		[UIView animateWithDuration:animationDuration
						 animations:^{
							 self.frame = hiddenFrame;
						 }];
	}
}


@end
