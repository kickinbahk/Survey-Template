//
//  ViewController.m
//  Philips Questionaire
//
//  Created by HAI on 5/8/15.
//  Copyright (c) 2015 HAI. All rights reserved.
//

#import "ViewController.h"
#import "PQSTableViewCell.h"

#import "UIColor+AppColors.h"
#import "UIFont+AppFonts.h"
#import "NGAParallaxMotion.h"

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kStatusBarHeight (([[UIApplication sharedApplication] statusBarFrame].size.height == 20.0f) ? 20.0f : (([[UIApplication sharedApplication] statusBarFrame].size.height == 40.0f) ? 20.0f : 0.0f))
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#define SHORTER_SIDE ((kScreenWidth < kScreenHeight) ? kScreenWidth : kScreenHeight)
#define LONGER_SIDE ((kScreenWidth > kScreenHeight) ? kScreenWidth : kScreenHeight)
#define tableViewMargin (32.0f/1024.0f * self.view.frame.size.width)


@interface ViewController () <UIAlertViewDelegate, PQSQuestionViewDelegate>

@end

@implementation ViewController {
	NSMutableDictionary *_questionViews;
	NSDate *_lastRemoteSubmissionDate;
	CGSize _lastFrameSize;
}

/**
 *  The buffer amount to add to all sides of the Question Table View. This does not include the buffer for the brand logo.
 */
//static float  const tableViewMargin = 50.0f;

/**
 *  The size of the square brand image.
 */
static float  const brandImageSideLength = 150.0f;

/**
 * Show the brand header at the top of the screen
 */
static BOOL const brandImageAboveQuestions = YES;

static NSString * const questionsTableViewCellIdentifier = @"questionsTableViewCellIdentifier";


- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	
	_questionViews = [[NSMutableDictionary alloc] init];
	
//	[self.view addSubview:self.backgroundImageView];
	[self.view addSubview:self.questionTableView];
	[self.view addSubview:self.brandImageView];
	[self.view addSubview:self.submitButton];
//	[self.view addSubview:self.instructionButton];
	
	[[PQSReferenceManager sharedReferenceManager] setDelegate:self];
	
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:self
		   selector:@selector(updateViewConstraints)
			   name:UIDeviceOrientationDidChangeNotification
			 object:nil];
	[nc addObserver:self.questionTableView
		   selector:@selector(reloadData)
			   name:UIDeviceOrientationDidChangeNotification
			 object:nil];
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		[self performSelector:@selector(checkForFrameChange) withObject:self afterDelay:0.36f];
	});
}

- (void)checkForFrameChange {
	if (_lastFrameSize.width != self.view.bounds.size.width || _lastFrameSize.height != self.view.bounds.size.height) {
		[self updateViewConstraints];
		[self.questionTableView reloadData];
	}
	
	_lastFrameSize = self.view.bounds.size;
	[self performSelector:@selector(checkForFrameChange) withObject:self afterDelay:0.25f];
}

- (void)updateViewConstraints {
	[super updateViewConstraints];
	[self setNeedsStatusBarAppearanceUpdate];
	
	self.questionTableView.frame = [self questionTableViewFrame];
	self.backgroundImageView.frame = self.view.bounds;
	[self.view sendSubviewToBack:self.backgroundImageView];
	self.submitButton.center = [self submitButtonCenter];
	self.instructionButton.center = CGPointMake(self.view.frame.size.width - 44.0f,
												self.view.frame.size.height - 44.0f);
	self.brandImageView.frame = [self brandImageViewFrame];
	self.brandImageView.frame = CGRectMake(0.0f, 0.0f, self.view.bounds.size.width, self.view.bounds.size.width * 0.17578f);
	self.showTitleLabel.frame = [self showTitleLabelFrame];
	self.questionTableView.scrollIndicatorInsets = [self questionTableViewScrollIndicatorInsets];
	self.questionTableView.contentInset = [self questionTableViewContentInsets];
	[self updateInstructionSubviews];
}


#pragma mark - Subviews

- (UITableView *)questionTableView {
	if (!_questionTableView) {
		_questionTableView = [[UITableView alloc] initWithFrame:[self questionTableViewFrame] style:UITableViewStylePlain];
		_questionTableView.scrollIndicatorInsets = [self questionTableViewContentInsets];
		_questionTableView.showsVerticalScrollIndicator = YES;
		_questionTableView.contentInset = UIEdgeInsetsMake(self.brandImageView.frame.origin.y + self.brandImageView.frame.size.height - 40.0f, 0.0f, tableViewMargin, 0.0f);
		_questionTableView.scrollIndicatorInsets = UIEdgeInsetsMake(self.brandImageView.frame.origin.y + self.brandImageView.frame.size.height, -tableViewMargin, 0.0f, -tableViewMargin);
		_questionTableView.delegate = self;
		_questionTableView.dataSource = self;
		_questionTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
		_questionTableView.allowsSelection = NO;
		_questionTableView.clipsToBounds = NO;
		_questionTableView.backgroundColor = [UIColor clearColor];
		_questionTableView.userInteractionEnabled = YES;
		
		[_questionTableView registerClass:[PQSTableViewCell class]
				   forCellReuseIdentifier:questionsTableViewCellIdentifier];
	}
	
	return _questionTableView;
}

- (CGRect)questionTableViewFrame {
	CGRect frame = self.view.bounds;
	
	if (brandImageAboveQuestions) {
		frame.origin.x		= tableViewMargin;
		frame.size.width = frame.size.width - tableViewMargin * 2.0f;
	} else {
		frame.origin.x		= tableViewMargin;
		frame.origin.y		= tableViewMargin;
		frame.size.width	= frame.size.width  - tableViewMargin;
		frame.size.height	= frame.size.height - tableViewMargin * 2.0f;
	}
	
	return frame;
}

- (UIEdgeInsets)questionTableViewScrollIndicatorInsets {
	UIEdgeInsets insets = UIEdgeInsetsZero;//self.questionTableView.contentInset;
	
	insets.top	= self.brandImageView.frame.size.height - 66.0f;
	insets.right= - tableViewMargin;
	
	return insets;
}

- (UIEdgeInsets)questionTableViewContentInsets {
	UIEdgeInsets insets = UIEdgeInsetsZero;//self.questionTableView.contentInset;
	
	if (LONGER_SIDE == 1024.0f && SHORTER_SIDE == 768.0f) {
		if (kScreenHeight == LONGER_SIDE) {
			insets.top	= self.brandImageView.frame.size.height - 60.0f;
		} else {
			insets.top	= self.brandImageView.frame.size.height - 100.0f;
		}
	} else if (LONGER_SIDE > 1024.0f) {
		insets.top	= self.brandImageView.frame.size.height - ((self.view.frame.size.height > 1530) ? 100.0f : ((self.view.frame.size.width > self.view.frame.size.height) ? 120.0f : 100.0f));
	}
	insets.right= - tableViewMargin;
	
	return insets;
}

- (UIImageView *)brandImageView {
	if (!_brandImageView) {
		_brandImageView = [[UIImageView alloc] initWithImage:[[PQSReferenceManager sharedReferenceManager] brandImage]];
		_brandImageView.frame = [self brandImageViewFrame];
		[_brandImageView addSubview:self.showTitleLabel];
		_brandImageView.userInteractionEnabled = YES;
		
		UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(brandImageLongPressed)];
		longPress.minimumPressDuration = 0.5f;
		[_brandImageView addGestureRecognizer:longPress];
	}
	
	return _brandImageView;
}

- (CGRect)brandImageViewFrame {
	CGRect frame = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, 0.25f * SHORTER_SIDE);
	
	return frame;
}

- (UILabel *)showTitleLabel {
	if (!_showTitleLabel) {
		_showTitleLabel = [[UILabel alloc] initWithFrame:[self showTitleLabelFrame]];
		_showTitleLabel.adjustsFontSizeToFitWidth = YES;
		_showTitleLabel.clipsToBounds = NO;
		_showTitleLabel.font = [UIFont fontWithName:@"OfficinaSerifLT-Bold" size:32.0f];
		_showTitleLabel.textColor = [UIColor white];
		_showTitleLabel.textAlignment = NSTextAlignmentLeft;
		_showTitleLabel.text = [[PQSReferenceManager sharedReferenceManager] currentShowTitle];
	}
	
	return _showTitleLabel;
}

- (CGRect)showTitleLabelFrame {
	// all sorts of magic numbers just for framing
	CGRect frame = CGRectMake(tableViewMargin,
							  0.0f,
							  self.submitButton.frame.origin.x - tableViewMargin,
							  self.brandImageView.frame.size.height * 0.5f);
	
//	while (frame.origin.x * 0.5f + frame.size.width > self.submitButton.frame.origin.x && frame.size.width > self.submitButton.frame.size.width) {
//		frame.size.width -= 1.0f;
//	}
//	
//	if (SHORTER_SIDE > 400.0f && LONGER_SIDE < 1000.0f) {
//		frame.origin.y += 7.0f;
//	}
	
	return frame;
}

- (UIImageView *)backgroundImageView {
	if (!_backgroundImageView) {
		_backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Background Image"]];
		CGRect frame = self.view.bounds;
		frame.size.height -= self.brandImageView.frame.size.height;
		frame.origin.y += self.brandImageView.frame.size.height;
		_backgroundImageView.frame = frame;
	}
	
	return _backgroundImageView;
}

- (UIButton *)submitButton {
	if (!_submitButton) {
		_submitButton = [[UIButton alloc] initWithFrame:[self submitButtonFrame]];
		_submitButton.center = [self submitButtonCenter];
		_submitButton.backgroundColor = [UIColor appColor];
		_submitButton.layer.cornerRadius = 5.0f; // Just a guess at what looks good...it's magic if it does
		_submitButton.clipsToBounds = YES;
		_submitButton.userInteractionEnabled = YES;
		_submitButton.parallaxIntensity = 10.0f;
		[_submitButton setTitle:@"Submit" forState:UIControlStateNormal];
		[_submitButton setTitle:@"" forState:UIControlStateDisabled];
		[_submitButton addTarget:self action:@selector(submitButtonTouched) forControlEvents:UIControlEventTouchUpInside];
		
		UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(submitButtonLongPressed:)];
		longPress.minimumPressDuration = 1.5f;
		[_submitButton addGestureRecognizer:longPress];
	}
	
	return _submitButton;
}

- (CGRect)submitButtonFrame {
	CGRect frame = CGRectMake(0.0f, 0.0f, 80.0f, 44.0f);
	
	return frame;
}

- (CGPoint)submitButtonCenter {
	CGPoint center = CGPointMake(self.view.frame.size.width - self.view.frame.size.width * 0.28f, self.brandImageView.center.y / 2.0f);
	
	return center;
}

- (PQSLocalSubmitSuccessView *)localSuccessView {
	if (!_localSuccessView) {
		_localSuccessView = [[PQSLocalSubmitSuccessView alloc] initWithFrame:self.view.bounds];
	}
	
	return _localSuccessView;
}

- (UIButton *)instructionButton {
	if (!_instructionButton) {
		_instructionButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 44.0f, 44.0f)];
		_instructionButton.clipsToBounds = YES;
		_instructionButton.layer.cornerRadius = 22.0f;
		_instructionButton.layer.borderColor = [UIColor white].CGColor;
		_instructionButton.layer.borderWidth = 1.0f;
		_instructionButton.titleLabel.font = [UIFont fontWithName:@"TimesNewRomanPS-BoldMT" size:36.0f];
		[_instructionButton setTitle:@"i" forState:UIControlStateNormal];
		[_instructionButton addTarget:self action:@selector(showInstructionsView) forControlEvents:UIControlEventTouchUpInside];
		[_instructionButton addTarget:self action:@selector(updateViewConstraints) forControlEvents:UIControlEventTouchUpInside];
	}
	
	return _instructionButton;
}

- (UIView *)instructionsView {
	if (!_instructionsView) {
		CGRect frame = self.view.bounds;
		frame.origin.y = - LONGER_SIDE;
		_instructionsView = [[UIView alloc] initWithFrame:frame];
		UIToolbar *blur = [[UIToolbar alloc] initWithFrame:_instructionsView.bounds];
		[_instructionsView addSubview:blur];
		
		UILabel *longPressInstruction = [[UILabel alloc] initWithFrame:CGRectMake(0.0f,
																				  0.0f,
																				  SHORTER_SIDE	* 0.75f,
																				  SHORTER_SIDE	* 0.25f)];
		longPressInstruction.adjustsFontSizeToFitWidth = YES;
		longPressInstruction.text = @"Long Press on the Company logo to change show name.";
		longPressInstruction.center = CGPointMake(self.view.frame.size.width  * 0.5f,
												  self.view.frame.size.height * 0.125);
		longPressInstruction.font = [UIFont appFontOfSize:20.0f];
		longPressInstruction.numberOfLines = 0;
		longPressInstruction.textAlignment = NSTextAlignmentLeft;
//		[_instructionsView addSubview:longPressInstruction];
		
		UILabel *submitInstruction = [[UILabel alloc] initWithFrame:longPressInstruction.frame];
		submitInstruction.adjustsFontSizeToFitWidth = YES;
		submitInstruction.text = @"Users will tap on an answer for each question and then tap \"Submit\" to save their answers on the device.";
		submitInstruction.center = CGPointMake(self.view.frame.size.width  * 0.5f,
											   self.view.frame.size.height * 0.333f);
		submitInstruction.font = [UIFont appFontOfSize:20.0f];
		submitInstruction.numberOfLines = 0;
		submitInstruction.textAlignment = longPressInstruction.textAlignment;
		[_instructionsView addSubview:submitInstruction];
		
		UILabel *submitToServerInstruction = [[UILabel alloc] initWithFrame:longPressInstruction.frame];
		submitToServerInstruction.adjustsFontSizeToFitWidth = YES;
		submitToServerInstruction.text = @"Long press for 2.5 seconds to submit locally stored survey results to the server. \nOnce survey results have been sent successfully to the server a \"success\" message will pop up.";
		submitToServerInstruction.center = CGPointMake(self.view.frame.size.width  * 0.5f,
													   self.view.frame.size.height * 0.667f);
		submitToServerInstruction.font = [UIFont appFontOfSize:20.0f];
		submitToServerInstruction.numberOfLines = 0;
		submitToServerInstruction.textAlignment = longPressInstruction.textAlignment;
		[_instructionsView addSubview:submitToServerInstruction];
		
		UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideInstructionsView)];
		[_instructionsView addGestureRecognizer:tap];
		
		UISwipeGestureRecognizer *swipeUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(hideInstructionsView)];
		swipeUp.direction = UISwipeGestureRecognizerDirectionUp;
		[_instructionsView addGestureRecognizer:swipeUp];
	}
	
	return _instructionsView;
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return [[PQSReferenceManager sharedReferenceManager] headers].count;
	return [[[PQSReferenceManager sharedReferenceManager] questions] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	PQSQuestion *header = [[[PQSReferenceManager sharedReferenceManager] headers] objectAtIndex:section];
	return header.subQuestions.count;
	return 1; // reference manager assumes that each section only has one row
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	PQSQuestion *header = [[[PQSReferenceManager sharedReferenceManager] headers] objectAtIndex:indexPath.section];
	PQSQuestion *question = [header.subQuestions objectAtIndex:indexPath.row];
	CGFloat height = [question estimatedHeightForQuestionView];
	
	CGFloat buffer = 50.0f; // magic number I totally pulled out of thin air
	height += buffer;
	
	return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	PQSTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:questionsTableViewCellIdentifier
															 forIndexPath:indexPath];
	
	if (!cell) {
		cell = [[PQSTableViewCell alloc] initWithFrame:CGRectMake(0.0f, 0.0f, tableView.frame.size.width, [self tableView:tableView heightForRowAtIndexPath:indexPath])];
	} else {
		for (PQSQuestionView *questionView in cell.subviews) {
			[questionView removeFromSuperview];
		}
	}
	
	cell.layer.cornerRadius = 8.0f;
	
	PQSQuestionView *questionView = [self questionViewForRow:indexPath];
	[cell addSubview:questionView];
	questionView.frame = [self frameForQuestion:questionView.question];
	[questionView layoutSubviews];
    
    cell.clipsToBounds = questionView.question.clipsToBounds;

	
	switch (questionView.question.preferredBackgroundTone) {
		case PQSQuestionViewPreferredBackgroundToneDark:
				cell.backgroundColor = [[UIColor appColor3] colorWithAlphaComponent:0.23f];
			break;
		case PQSQuestionViewPreferredBackgroundToneLight:
				cell.backgroundColor = [UIColor clearColor];
			break;
			
		default:
			if (indexPath.row %2 == 1) {
				cell.backgroundColor = [UIColor clearColor];
			} else {
				cell.backgroundColor = [[UIColor appColor3] colorWithAlphaComponent:0.23f];
			}
			break;
	}
	
	return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	PQSQuestionView *questionView = [self questionViewForRow:[NSIndexPath indexPathForRow:NSIntegerMax inSection:section]];
	return questionView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	PQSQuestion *header = [[[PQSReferenceManager sharedReferenceManager] headers] objectAtIndex:section];
    
    if (header.fixedHeight > 0) {
        return header.fixedHeight;
    }
	
	return header.estimatedHeightForQuestionView;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	for (UIView *subview in cell.subviews) {
		[subview layoutSubviews];
	}
}

- (PQSQuestionView *)questionViewForRow:(NSIndexPath *)indexPath {
	PQSQuestionView *questionView = [_questionViews objectForKey:indexPath];
	
	if (!questionView) {
		PQSQuestion *question = [[PQSReferenceManager sharedReferenceManager] questionAtIndexPath:indexPath];
		CGRect frame = [self frameForQuestion:question];
		questionView = [[PQSQuestionView alloc] initWithFrame:frame];
		questionView.delegate = self;
		questionView.question = [[PQSReferenceManager sharedReferenceManager] questionAtIndexPath:indexPath];
		questionView.questionNumber = indexPath.row + 1;
		[_questionViews setObject:questionView forKey:indexPath];
		
		if (indexPath.section == 0 && indexPath.row == 0) {
			if (question.questionType) {
				questionView.answerView.useTapGesture = YES;
			}
		}
	}
	
	return questionView;
}

- (CGRect)frameForQuestion:(PQSQuestion *)question {
	CGRect frame = CGRectMake(10.0f, 0.0f, self.questionTableView.frame.size.width - 20.0f, [question estimatedHeightForQuestionView]);
	
	return frame;
}

#pragma mark - Scroll View Delegate

//- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//	for (PQSTableViewCell *cell in self.questionTableView.visibleCells) {
//		CGFloat hiddenFrameHeight = scrollView.contentOffset.y + 100.0f - cell.frame.origin.y;
//		if (hiddenFrameHeight >= 0 || hiddenFrameHeight <= cell.frame.size.height) {
//			[cell maskCellFromTop:hiddenFrameHeight];
//		}
//	}
//}


#pragma mark - Change Show Title Methods

- (void)brandImageLongPressed {
	if ([UIAlertController class]) {
		UIAlertController *changeShowNameAlertController = [UIAlertController alertControllerWithTitle:@"Select Show"
																							   message:nil
																						preferredStyle:UIAlertControllerStyleAlert];
		
		for (NSString *showTitle in [[PQSReferenceManager sharedReferenceManager] possibleShowTitles]) {
			UIAlertAction *changeShowTitleAction = [UIAlertAction actionWithTitle:showTitle
																			style:(([[[PQSReferenceManager sharedReferenceManager] currentShowTitle] isEqualToString:showTitle]) ? UIAlertActionStyleCancel : UIAlertActionStyleDefault)
																		  handler:^(UIAlertAction *action) {
																			  [[PQSReferenceManager sharedReferenceManager] setShowTitle:showTitle];
																			  self.showTitleLabel.text = showTitle;
																		  }];
			[changeShowNameAlertController addAction:changeShowTitleAction];
		}
		
		[self presentViewController:changeShowNameAlertController
						   animated:YES
						 completion:^{
							 
						 }];
	} else {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Select Show"
															message:nil
														   delegate:self
												  cancelButtonTitle:nil
												  otherButtonTitles:nil];
		for (NSString *showTitle in [[PQSReferenceManager sharedReferenceManager] possibleShowTitles]) {
			[alertView addButtonWithTitle:showTitle];
		}
		
		[alertView show];
	}
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	NSString *showTitle = [alertView buttonTitleAtIndex:buttonIndex];
	[[PQSReferenceManager sharedReferenceManager] setShowTitle:showTitle];
	self.showTitleLabel.text = showTitle;
}

#pragma mark - Submit Button Actions

- (void)submitButtonTouched {
	// animating the button touch itself
	[UIView animateWithDuration:0.15f
					 animations:^{
						 self.submitButton.backgroundColor = [self.submitButton.backgroundColor darkenColor];
	} completion:^(BOOL finished) {
		[UIView animateWithDuration:0.15f
						 animations:^{
							 self.submitButton.backgroundColor = [UIColor appColor];
		}];
	}];
	
	// reset questions
	if ([[PQSReferenceManager sharedReferenceManager] saveAnswerLocally]) {	// successful save
		[self.view addSubview:self.localSuccessView]; // make sure the success view is on top of all other views
		[self.view addSubview:self.brandImageView]; // except for the brand logo
		[self.view addSubview:self.submitButton]; // ...and the submit button
		[self.localSuccessView show];
		for (NSObject *key in _questionViews.allKeys) {
			PQSQuestionView *questionView = [_questionViews objectForKey:key];
			[questionView.answerView clearSecondaryViews];
		}
		[_questionViews removeAllObjects];
		for (PQSQuestion *question in [[PQSReferenceManager sharedReferenceManager] questions]) {
			question.trueFalseConditionalHasAnswer = NO;
			question.multipleColumnShouldShowQuestion = NO;
		}
		[self.questionTableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.5f];
		[self performSelector:@selector(scrollToTopOfQuestionTableView) withObject:self afterDelay:1.0f];
		
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		NSCalendar *cal = [NSCalendar currentCalendar];
		
		NSDate *date = [NSDate date];
		NSDateComponents *comps = [cal components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay)
										 fromDate:date];
		NSDate *today = [cal dateFromComponents:comps];
		NSInteger dailyCount = [defaults integerForKey:today.description];
		dailyCount++;
		[defaults setInteger:dailyCount forKey:today.description];
	} else { // save was not possible
		NSLog(@"Missing information and cannot save answer locally");
	}
}

- (void)scrollToTopOfQuestionTableView {
	[self.questionTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

- (void)submitButtonLongPressed:(UILongPressGestureRecognizer *)longPress {
	if (longPress.state != UIGestureRecognizerStateBegan) {
		return;
	}
	
	if (_lastRemoteSubmissionDate) {
		if ([_lastRemoteSubmissionDate timeIntervalSinceNow] > -5) {
			return;
		}
	}
	
	_lastRemoteSubmissionDate = [NSDate date];
	
	[UIView animateWithDuration:0.15f
					 animations:^{
						 self.submitButton.backgroundColor = [self.submitButton.backgroundColor darkenColor];
					 } completion:^(BOOL finished) {
						 self.submitButton.backgroundColor = [UIColor appColor];
					 }];
	[[PQSReferenceManager sharedReferenceManager] submitCurrentAnswers];
}

#pragma mark - Answer View Delegate

- (void)answerSelected:(NSString *)answer question:(PQSQuestion *)question {
	NSString *key = [question.urlKeys objectForKey:question.question];
	
	if (key) {
		[[PQSReferenceManager sharedReferenceManager] submitAnswer:answer withKey:key];
		return;
	}
	
	for (NSString *tempKey in question.possibleAnswers) {
		key = [question.urlKeys objectForKey:tempKey];
		
		if (key) {
			[[PQSReferenceManager sharedReferenceManager] submitAnswer:answer withKey:key];
			return;
		}
	}
	
	[[PQSReferenceManager sharedReferenceManager] submitAnswer:answer forQuestion:question];
}

- (void)displayAlertController:(UIAlertController *)alertController {
	if (alertController) {
		[self presentViewController:alertController animated:YES completion:^{
			
		}];
	} else {
		NSLog(@"The alert controller doesn't even exist, and that's a problem.");
	}
}

- (void)presentTextInputView:(PQSTextInputView *)textInputView {
	textInputView.blockingView.frame = self.view.bounds;
	[self.view addSubview:textInputView.blockingView];
	[self.view addSubview:textInputView];
	
	textInputView.center = CGPointMake(self.view.frame.size.width      * 0.5f,
									   textInputView.frame.size.height * 0.5 + 44.0f);
	
	NSLog(@"%@", textInputView.description);
}

- (void)reloadQuestions {
	[self.questionTableView reloadData];
	[self updateViewConstraints];
	
	for (UITableViewCell *cell in self.questionTableView.visibleCells) {
		for (UIView *subview in cell.subviews) {
			[subview layoutSubviews];
		}
	}
}

#pragma mark - Reference Manager Delegate

- (void)sentToServerFailure {
	UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error"
																			 message:@"Survey Results were not sent successfully. Please try again."
																	  preferredStyle:UIAlertControllerStyleAlert];
	UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
													   style:UIAlertActionStyleDefault
													 handler:^(UIAlertAction *action) {
														 
													 }];
	[alertController addAction:okAction];
	[self presentViewController:alertController animated:YES completion:^{
		
	}];
}

- (void)sentToServerSuccessfully {
	if ([UIAlertController class]) {
		UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Success"
																				 message:@"Survey Results were sent successfully."
																		  preferredStyle:UIAlertControllerStyleAlert];
		UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
														   style:UIAlertActionStyleDefault
														 handler:^(UIAlertAction *action) {
															 
														 }];
		[alertController addAction:okAction];
		[self presentViewController:alertController animated:YES completion:^{
			
		}];
	} else {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Success"
															message:@"Survey results were sent successffully."
														   delegate:self
												  cancelButtonTitle:nil
												  otherButtonTitles:@"OK", nil];
		[alertView show];
	}
}

- (void)noRequestsToSend {
	if ([UIAlertController class]) {
		UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Submission Completed"
																				 message:@"All locally saved survey results have been sent successfully to the server!"
																		  preferredStyle:UIAlertControllerStyleAlert];
		UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
														   style:UIAlertActionStyleDefault
														 handler:^(UIAlertAction *action) {
															 
														 }];
		[alertController addAction:okAction];
		[self presentViewController:alertController animated:YES completion:^{
			
		}];
	} else {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Submission Completed"
															message:@"All locally saved survey results have been sent successfully to the server!"
														   delegate:self
												  cancelButtonTitle:nil
												  otherButtonTitles:@"OK", nil];
		[alertView show];
	}
}

- (void)noNetworkConnection {
	if ([UIAlertController class]) {
		UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error"
																				 message:@"No Network Connection. \nSurvey Results were not sent. Please try again."
																		  preferredStyle:UIAlertControllerStyleAlert];
		UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
														   style:UIAlertActionStyleDefault
														 handler:^(UIAlertAction *action) {
															 
														 }];
		[alertController addAction:okAction];
		[self presentViewController:alertController animated:YES completion:^{
			
		}];
	} else {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
															message:@"No Network Connection. \nSurvey Results were not sent. Please try again."
														   delegate:self
												  cancelButtonTitle:nil
												  otherButtonTitles:@"OK", nil];
		[alertView show];
	}
}

#pragma mark - Instructions View Actions

- (void)showInstructionsView {
	if (self.instructionsView.frame.origin.y == 0.0f) {
		[self hideInstructionsView];
		return;
	} else {
		self.instructionsView.alpha = 1.0f;
		CGRect startingFrame = self.view.bounds;
		startingFrame.origin.y = -LONGER_SIDE * 1.25f;
		self.instructionsView.frame = startingFrame;
	}
	
	for (UIToolbar *blur in self.instructionsView.subviews) {
		if ([blur respondsToSelector:@selector(setBarTintColor:)]) {
			blur.frame = self.instructionsView.bounds;
		}
	}
	
	CGRect finalFrame = self.view.bounds;
	[self.view addSubview:self.instructionsView];
	[self.view addSubview:self.instructionButton];
	[self changeInstructionButtonTitleToDailyCount];
	[UIView animateWithDuration:0.35f
					 animations:^{
						 self.instructionsView.frame = finalFrame;
						 self.instructionButton.layer.borderColor = [UIColor appColor].CGColor;
						 [self.instructionButton setTitleColor:[UIColor appColor] forState:UIControlStateNormal];
					 } completion:^(BOOL finished) {
						 [self setNeedsStatusBarAppearanceUpdate];
					 }];
}

- (void)updateInstructionSubviews {
	for (UILabel *subview in self.instructionsView.subviews) {
		CGRect frame = subview.frame;
		frame.size.width = self.view.bounds.size.width - frame.origin.x * 2.0f;
		subview.frame = frame;
	}
	
	if (_instructionsView.frame.origin.y == 0) {
		_instructionsView.frame = self.view.bounds;
	}
}

- (void)hideInstructionsView {
	CGRect startingFrame = self.view.frame;
	startingFrame.origin.y = -2000.0f;
	
	[UIView animateWithDuration:0.35f
					 animations:^{
						 self.instructionsView.frame = startingFrame;
						 [self setNeedsStatusBarAppearanceUpdate];
						 self.instructionButton.layer.borderColor = [UIColor white].CGColor;
						 [self.instructionButton setTitleColor:[UIColor white] forState:UIControlStateNormal];
					 } completion:^(BOOL finished) {
						 [self setNeedsStatusBarAppearanceUpdate];
					 }];
	[self resetInstructionButtonTitle];
}

- (void)changeInstructionButtonTitleToDailyCount {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSCalendar *cal = [NSCalendar currentCalendar];
	
	NSDate *date = [NSDate date];
	NSDateComponents *comps = [cal components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay)
									 fromDate:date];
	NSDate *today = [cal dateFromComponents:comps];
	NSInteger dailyCount = [defaults integerForKey:today.description];
	[self.instructionButton setTitle:[NSString stringWithFormat:@"%zd", dailyCount] forState:UIControlStateNormal];
}

- (void)resetInstructionButtonTitle {
	[self.instructionButton setTitle:@"i" forState:UIControlStateNormal];
}




#pragma mark - Status Bar

- (UIStatusBarStyle)preferredStatusBarStyle {
	if (self.instructionsView.frame.origin.y == 0.0f) {
		return UIStatusBarStyleDefault;
	}
	
	return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden {
	if (self.instructionsView.frame.origin.y == 0.0f) {
		return NO;
	}
	return self.view.frame.size.height > self.view.frame.size.width ^ self.view.frame.size.height < 400.0f;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
	return UIStatusBarAnimationSlide;
}

#pragma mark - Memory Warning

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

@end
