//
//  PQSQuestionView.h
//  Philips Questionaire
//
//  Created by HAI on 5/8/15.
//  Copyright (c) 2015 HAI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PQSQuestion.h"
#import "PQSAnswerView.h"

@protocol PQSQuestionViewDelegate <NSObject>

@required
- (void)answerSelected:(NSString *)answer question:(PQSQuestion *)question;
- (void)displayAlertController:(UIAlertController *)alertController;
- (void)presentTextInputView:(PQSTextInputView *)textInputView;
- (void)reloadQuestions;

@end

@interface PQSQuestionView : UIView <PQSAnswerViewDelegate>

/**
 *  The question this view is based on.
 */
@property (nonatomic, strong) PQSQuestion *question;

/**
 *  The Question Number as presented in the view.
 */
@property (nonatomic, strong) UILabel *numberLabel;

/**
 *  The number the question is in the survey order.
 */
@property (nonatomic) NSInteger questionNumber;

/**
 *  The Question to be presented in the view.
 */
@property (nonatomic, strong) UILabel *questionLabel;

/**
 *  The view area where the answers are shown.
 */
@property (nonatomic, strong) PQSAnswerView *answerView;

/**
 *  Height of the view after adding in the question and answer. This may not match the initial height for the frame on initialization.
 */
@property (nonatomic) CGFloat height;

/**
 *  Conditional Answers
 */
@property (nonatomic, strong) NSMutableDictionary *conditionalAnswerViewDictionary;
@property (nonatomic, strong) NSMutableDictionary *conditionalQuestionViewDictionary;

/**
 *  Delegate for the answer view.
 */
@property id <PQSAnswerViewDelegate> delegate;

@property (nonatomic, strong) UIView *backgroundView;

@end
