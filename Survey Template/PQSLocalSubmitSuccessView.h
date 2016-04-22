//
//  PQSLocalSubmitSucessView.h
//  Philips Questionaire
//
//  Created by HAI on 5/11/15.
//  Copyright (c) 2015 HAI. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PQSLocalSubmitSuccessView : UIView

/**
 *  Toolbar used as a blur effect.
 */
@property (nonatomic, strong) UIToolbar *blur;

/**
 *  The label containing the message informing the user that their submission was successful.
 */
@property (nonatomic, strong) UILabel *successLabel;

/**
 *  Amount of time for the success screen to remain on top of the view
 */
@property (nonatomic) NSTimeInterval remainOnScreenDuration;

/**
 *  Animate the display of the success view
 */
- (void)show;

/**
 *  Animate hiding the success view
 */
- (void)hide;

@end
