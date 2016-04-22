//
//  PQSAnswerView.h
//  Philips Questionaire
//
//  Created by HAI on 5/8/15.
//  Copyright (c) 2015 HAI. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "PQSQuestion.h"
#import "PQSTextInputView.h"
#import "PQSSegmentedControl.h"

@protocol PQSAnswerViewDelegate <NSObject>

@required
- (void)answerSelected:(NSString *)answer question:(PQSQuestion *)question;
- (void)displayAlertController:(UIAlertController *)alertController;
- (void)presentTextInputView:(PQSTextInputView *)textInputView;
- (void)reloadQuestions;

@end

@interface PQSAnswerView : UIView <UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate>

/**
 *  Create the answer view. The only part of the frame that's absolutely essential is the width. The height will change after initialization.
 *
 *  @param frame    Frame of the answer view. Only the width is necessary and the height will change.
 *  @param question Question object to create the answer view based on
 *
 *  @return View containing answer UI elements.
 */
- (instancetype)initWithFrame:(CGRect)frame question:(PQSQuestion *)question;

/**
 *  The question this view is displaying the answers for
 */
@property (nonatomic, strong) PQSQuestion *question;

/**
 *  Removes all associated views from their respective superview
 */
- (void)clearSecondaryViews;

/**
 *  Delegate for Passing information from the answer view up to the view controller
 */
@property (weak) id <PQSAnswerViewDelegate> delegate;


/**
 *  The view that all answers are contained in
 */
@property (nonatomic, strong) 	UIView *containerView, *multiColumnContainerView;

/**
 *  Add a tap gesture for the entire view to activate the answer button function.
 */
@property (nonatomic) BOOL useTapGesture;


@property (nonatomic, strong) PQSSegmentedControl *segmentedControl;
@property (nonatomic, strong) UIButton *answerButton;
@property (nonatomic, strong) PQSTextInputView *textInputView;
@property (nonatomic, strong) UIDatePicker *datePicker;

+ (void)buttonTouched:(NSDictionary *)info;

@end
