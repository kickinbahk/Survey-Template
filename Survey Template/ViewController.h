//
//  ViewController.h
//  Philips Questionaire
//
//  Created by HAI on 5/8/15.
//  Copyright (c) 2015 HAI. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PQSReferenceManager.h"
#import "PQSQuestion.h"
#import "PQSQuestionView.h"
#import "PQSLocalSubmitSuccessView.h"

@interface ViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, PQSQuestionViewDelegate, PQSReferenceManagerDelegate, UIAlertViewDelegate>

/**
 *  The table View containing the questions for the survey.
 */
@property (nonatomic, strong) UITableView *questionTableView;

/**
 *  The company logo or brand image. Will reformat to 1/10 of the shorter screen dimension
 */
@property (nonatomic, strong) UIImageView *brandImageView;

/**
 *  The label displaying the show title.
 */
@property (nonatomic, strong) UILabel *showTitleLabel;

/**
 *  Image View behind all other views.
 */
@property (nonatomic, strong) UIImageView *backgroundImageView;

/**
 *  Button to submit survey results
 */
@property (nonatomic, strong) UIButton *submitButton;

/**
 *  The view to display once the user has successfully submitted their answers.
 */
@property (nonatomic, strong) PQSLocalSubmitSuccessView *localSuccessView;

/**
 *  i in a Circle to tap on to show the instructionsView
 */
@property (nonatomic, strong) UIButton *instructionButton;

/**
 *  A view overlaying the screen that offers clear instructions on what to do.
 */
@property (nonatomic, strong) UIView *instructionsView;

@end

