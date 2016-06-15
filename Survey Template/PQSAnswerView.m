//
//  PQSAnswerView.m
//  Philips Questionaire
//
//  Created by HAI on 5/8/15.
//  Copyright (c) 2015 HAI. All rights reserved.
//

#import "PQSAnswerView.h"

#import "PQSReferenceManager.h"

#import "UIColor+AppColors.h"
#import "UIFont+AppFonts.h"

#import "APNumberPad.h"

#import "PQSAlertAction.h"

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kStatusBarHeight (([[UIApplication sharedApplication] statusBarFrame].size.height == 20.0f) ? 20.0f : (([[UIApplication sharedApplication] statusBarFrame].size.height == 40.0f) ? 20.0f : 0.0f))
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

#define SHORTER_SIDE ((kScreenWidth < kScreenHeight) ? kScreenWidth : kScreenHeight)
#define LONGER_SIDE ((kScreenWidth > kScreenHeight) ? kScreenWidth : kScreenHeight)


static CGFloat const cellHeight = 44.0f;

static NSInteger const maxMultipleChoiceCount = 8;

static int const percentageRoundingInterval = 5;

static CGFloat const leftSideBuffer = 44.0f;


static NSString * const questionKey = @"questionK£y";
static NSString * const answerKey = @"answerK£Y!";
static NSString * const senderKey = @"s£nD£rK£Y";

@interface PQSAnswerView () <APNumberPadDelegate, PQSTextInputViewDelegate>

@end

@implementation PQSAnswerView {
	UISlider *_slider;
	UITableView *_tableView;
	NSMutableArray *_additionalLabels;
	NSMutableArray *_additionalButtons;
	NSMutableArray *_additionalValueLabels;
	NSMutableArray *_numberLabels;
	UIAlertController *_optionsController;
	UIAlertView *_alertView;
	UIStepper *_stepper;
	UILabel *_leftLabel, *_rightLabel;
	UITextField *_textField;
	
	CGFloat _indentation;
	
	NSMutableDictionary *_countryCodeList;
	
	PQSAnswerView *_triggerAnswerView;
	
	NSDateFormatter *_dateFormatter;
	NSMutableDictionary *_conditionalAnswerViewsDictionary;
	NSMutableDictionary *_conditionalQuestionLabelsDictionary;
	BOOL checkForTimeUpdate;
	
	UITapGestureRecognizer *_tap;
    CGSize segmentedControlSize;
}

- (instancetype)init {
	self = [super init];
	
	if (self) {
		NSLog(@"There's a problem. You did not specify the question for this answer. That's going to make things hard. You should probably fix that.");
	}
	
	return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	
	if (self) {
		NSLog(@"There's a problem. You did not specify the question for this answer. That's going to make things hard. You should probably fix that.");
	}
	
	return self;
}

- (instancetype)initWithFrame:(CGRect)frame question:(PQSQuestion *)question {
	CGSize buffer = {10.0f, 28.0f};
	
	if (question.questionType == PQSQuestionType2WayExclusivityRadioButtons) {
		frame.size.height += question.possibleAnswers.count * buffer.height;
	}
	
	frame.origin.x += buffer.width;
	frame.size.width -= buffer.width * 2.0f;
	
	if (question.questionType == PQSQuestionTypeMultiColumnConditional) {
		frame.origin.x = 0.0f;
	}
	
	self = [super initWithFrame:frame];
	
	if (self) {
		[self addSubview:self.containerView];
		self.question = question;
		_additionalLabels = [[NSMutableArray alloc] init];
		_additionalButtons = [[NSMutableArray alloc] init];
		_additionalValueLabels = [[NSMutableArray alloc] init];
		_numberLabels = [[NSMutableArray alloc] init];
		_conditionalAnswerViewsDictionary = [NSMutableDictionary new];
		_conditionalQuestionLabelsDictionary = [NSMutableDictionary new];
		self.backgroundColor = [UIColor clearColor];
		_indentation = 0.0245f * kScreenWidth; // MAGIC
	}
	
	return self;
}

- (UIView *)containerView {
	if (!_containerView) {
		_containerView = [[UIView alloc] initWithFrame:[self containerViewFrame]];
	}
	
	return _containerView;
}

- (UIView *)multiColumnContainerView {
	if (!_multiColumnContainerView) {
		_multiColumnContainerView = [[UIView alloc] initWithFrame:[self containerViewFrame]];
	}
	
	return _multiColumnContainerView;
}

- (void)clearSecondaryViews {
	for (UIView *subview in _additionalLabels) {
		if (![subview.superview isEqual:self] && ![subview.superview isEqual:self.containerView]) {
//			[subview removeFromSuperview];
		}
	}
	for (UIView *subview in _additionalButtons) {
		if (![subview.superview isEqual:self] && ![subview.superview isEqual:self.containerView]) {
//			[subview removeFromSuperview];
		}
	}
}

- (void)layoutSubviews {
	[super layoutSubviews];
	
	[self clearSecondaryViews];
	
	self.containerView.frame = [self containerViewFrame];
	
	if (self.question.questionType == PQSQuestionTypeScale) {
		[self layoutScaleAnswers];
	} else if (self.question.questionType == PQSQuestionTypeMultipleChoice) {
		if (self.question.possibleAnswers.count > maxMultipleChoiceCount) {
			[self longListQuestion];
		} else {
			[self layoutpossibleAnswers];
		}
	} else if (self.question.questionType == PQSQuestionTypeTrueFalse) {
		if (!(([self.question.possibleAnswers containsObject:@"True"] || [self.question.possibleAnswers containsObject:@"Yes"]) &&
			([self.question.possibleAnswers containsObject:@"False"] || [self.question.possibleAnswers containsObject:@"No"]))) {
			if (self.question.useYesNoForTrueFalse) {
				[self.question.possibleAnswers addObjectsFromArray:@[@"Yes",
																	 @"No"]];
			} else {
				[self.question.possibleAnswers addObjectsFromArray:@[@"True",
																	 @"False"]];
			}
		}
		
		if (self.question.possibleAnswers.count < 2) {
			NSLog(@"This could be the problem: There should be at least two possible answers for a true false question.");
		}
		
		[self radioButtonLayout];
		
		_segmentedControl.apportionsSegmentWidthsByContent = YES;
		[self resizeSegmentsToFitTitles:_segmentedControl];
		for (int i = 0; i < _segmentedControl.numberOfSegments; i++) {
			[_segmentedControl setWidth:56.0f
					  forSegmentAtIndex:i];
		}
	} else if (self.question.questionType == PQSQuestionTypeRadioButtons) {
		[self radioButtonLayout];
	} else if (self.question.questionType == PQSQuestionType2WayExclusivityRadioButtons) {
		[self setUp2WayExclusivityRadioButtons];
	} else if (self.question.questionType == PQSQuestionTypeLongList) {
		[self longListQuestion];
	} else if (self.question.questionType == PQSQuestionTypeIncrementalValue) {
		[self incrementalValueLayout];
	} else if (self.question.questionType == PQSQuestionTypePercentage) {
		[self percentageLayout];
	} else if (self.question.questionType == PQSQuestionTypeSplitPercentage) {
		[self splitPercentageLayout];
	} else if (self.question.questionType == PQSQuestionTypeMultipleRadios) {
		[self layoutMultipleRadios];
	} else if (self.question.questionType == PQSQuestionTypeCheckBoxes) {
		[self layoutCheckboxes];
	} else if (self.question.questionType == PQSQuestionTypeTrueFalseConditional) {
		[self trueFalseConditionalLayout];
		
		for (int i = 0; i < _segmentedControl.numberOfSegments; i++) {
			[_segmentedControl setWidth:56.0f
					  forSegmentAtIndex:i];
		}
	} else if (self.question.questionType == PQSQuestionTypeTrueFalseConditional2) {
		[self trueFalseConditional2Layout];
		
		for (int i = 0; i < _segmentedControl.numberOfSegments; i++) {
			[_segmentedControl setWidth:56.0f
					  forSegmentAtIndex:i];
		}
} else if (self.question.questionType == PQSQuestionTypeTextField) {
		[self textFieldLayout];
	} else if (self.question.questionType == PQSQuestionTypeMultiColumnConditional) {
		[self multiColumnConditionalLayout];
	} else if (self.question.questionType == PQSQuestionTypeDate) {
		[self dateLayout];
	} else if (self.question.questionType == PQSQuestionTypeTime) {
		[self timeLayout];
	} else if (self.question.questionType == PQSQuestionTypeLargeNumber) {
		[self largeNumberLayout];
	} else if (self.question.questionType == PQSQuestionTypeTextView) {
		[self textFieldLayout];
    } else if (self.question.questionType == PQSQuestionType1to10) {
        if (self.question.possibleAnswers.count < self.question.maximumScale - self.question.minimumScale) {
            for (int i = self.question.minimumScale; i <= self.question.maximumScale; i++) {
                [self.question.possibleAnswers addObject:@(i).description];
            }
        }
        
        self.question.questionType = PQSQuestionTypeRadioButtons;
        [self radioButtonLayout];
	} else if (self.question.question.length > 0 && self.question.questionType != PQSQuestionTypeNone) {
		NSLog(@"Question type not recognized. %zd \n%@", self.question.questionType, self.question.question);
	}
	
	NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithArray:self.question.possibleAnswers];
	self.question.possibleAnswers = [NSMutableArray arrayWithArray:[orderedSet array]];
	
	[self setBackgroundColor:[UIColor clearColor]];
}

- (CGRect)containerViewFrame {
	CGRect frame = self.bounds;
	
	CGFloat buffer = 10.0f;
	
	if (self.question.leftLabelText) {
		[self layoutLeftLabel];
		frame.origin.x = _leftLabel.frame.size.width - buffer * 3.75;
	}
	
	if (self.question.rightLabelText) {
		[self layoutRightLabel];
		frame.size.width = self.bounds.size.width - _rightLabel.frame.size.width;
	}
	
	return frame;
}

#pragma mark - Left and Right Text Labels 

- (void)layoutLeftLabel {
	if (!_leftLabel) {
		_leftLabel = [[UILabel alloc] initWithFrame:[self leftLabelFrame]];
	} else {
		_leftLabel.frame = [self leftLabelFrame];
	}
	
	_leftLabel.text = self.question.leftLabelText;
	_leftLabel.textColor = [UIColor appColor];
	
	if (_tableView) {
		_leftLabel.center = CGPointMake(_leftLabel.center.x, _tableView.center.y);
	} else if (_segmentedControl) {
		_leftLabel.center = CGPointMake(_leftLabel.center.x, _segmentedControl.center.y);
	}
	
	[self addSubview:_leftLabel];
}

- (CGRect)leftLabelFrame {
	CGRect frame = self.bounds;
	
	frame.size.width = [self widthOfString:self.question.leftLabelText
                                  withFont:[UIFont appFont]];
	
	frame.origin.y += 2.5f;
	
	return frame;
}

- (void)layoutRightLabel {
	if (!_rightLabel) {
		_rightLabel = [[UILabel alloc] initWithFrame:[self rightLabelFrame]];
		_rightLabel.textAlignment = NSTextAlignmentLeft;
	} else {
		_rightLabel.frame = [self rightLabelFrame];
	}
	
	_rightLabel.text = self.question.rightLabelText;
	_rightLabel.textColor = [UIColor appColor];
	
	if (_tableView) {
		_rightLabel.center = CGPointMake(_rightLabel.center.x, _tableView.center.y);
	} else if (_segmentedControl) {
		_rightLabel.center = CGPointMake(_rightLabel.center.x, _segmentedControl.center.y);
	}
	
	[self addSubview:_rightLabel];
}

- (CGRect)rightLabelFrame {
	CGRect frame = self.bounds;
	
	frame.size.width = [self widthOfString:self.question.rightLabelText withFont:[UIFont appFont]];
	
	if (self.question.questionType == PQSQuestionTypeRadioButtons) {
		[self layoutMultipleRadios];
		frame.origin.x = _leftLabel.frame.size.width + _segmentedControl.frame.size.width + 20.0f;
	}
	
	frame.origin.y += 2.5f;
	
	return frame;
}

- (CGFloat)widthOfString:(NSString *)string withFont:(UIFont *)font {
	NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil];
	return [[[NSAttributedString alloc] initWithString:string
                                            attributes:attributes] size].width;
}




#pragma mark - Scale Question Layout

- (void)layoutScaleAnswers {
	if (!_slider) {
		_slider = [[UISlider alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.frame.size.width, cellHeight)];
		_slider.minimumValue = self.question.minimumScale;
		_slider.maximumValue = self.question.maximumScale;
		_slider.minimumTrackTintColor = UIColor.appColor;
        [_slider setValue:self.question.startingPoint
                 animated:YES];
		_slider.tintColor = self.tintColor;
		
		if (self.question.minimumScale == self.question.maximumScale) {
			NSLog(@"The minimum value for this question is the same as the maximum. I'm changing the maximum value to be 1.0 greater than the minimum.");
			self.question.maximumScale = self.question.minimumScale + 1.0f;
		}
		
		if ((self.question.startingPoint <= self.question.maximumScale && self.question.startingPoint >= self.question.minimumScale) ||
			(self.question.startingPoint >= self.question.maximumScale && self.question.startingPoint <= self.question.minimumScale)){
			_slider.value = self.question.startingPoint;
		} else {
			NSLog(@"The recommended starting point is not in between the minimum (%f) and maximum (%f) values for this answer. Question: \"%@\"\n\t\tI'm going to set the starting value to the midpoint of the minimum and maximum values", self.question.minimumScale, self.question.maximumScale, self.question.question);
			self.question.startingPoint = (self.question.minimumScale * + self.question.maximumScale) * 0.5f;
		}
	}
	
	[self.containerView addSubview:_slider];
	
	
	
	
	// creates the description labels only if they haven't been created yet
	if (_additionalLabels.count != self.question.scaleLabels.count) {
		for (int i = 0; i < self.question.scaleLabels.count; i++) {
			UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f,
																	   cellHeight * 1.5f,
																	   self.frame.size.width / (self.question.scaleLabels.count + 1),
																	   cellHeight)];
			[label setFont:[UIFont appFont]];
			label.adjustsFontSizeToFitWidth = YES;
			label.textAlignment = NSTextAlignmentCenter;
			label.text = NSLocalizedString([self.question.scaleLabels objectAtIndex:i], nil);
			label.textColor = [UIColor appColor2];
			label.numberOfLines = 0;
			[_additionalLabels addObject:label];
		}
	}
	
	// centers and adds the scale description labels every time
	for (int i = 0; i < _additionalLabels.count; i++) {
		UILabel *label = [_additionalLabels objectAtIndex:i];
		float denominator = (float)self.question.scaleLabels.count - 0.3f;
		if (denominator < 1) {
			denominator = 1;
		}
		[label setCenter:CGPointMake(i * self.frame.size.width / denominator + label.frame.size.width/2.0f,
                                     label.center.y)];
		[self.containerView addSubview:label];
	}
	
	
	
	int startingValue = (self.question.minimumScale < self.question.maximumScale) ? self.question.minimumScale : self.question.maximumScale;
	int endingValue = (self.question.maximumScale > self.question.minimumScale) ? self.question.maximumScale : self.question.minimumScale;
	
	// creates the number labels only if they haven't been created yet
	if (_numberLabels.count != endingValue - startingValue + 1) {
	
	
		for (int i = startingValue; i <= endingValue; i++) {
			UILabel *numberLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f,
																			 cellHeight * 0.85f,
																			 self.frame.size.width / (abs(endingValue - startingValue) + 1),
																			 cellHeight)];
			[numberLabel setFont:[UIFont appFont]];
			[numberLabel setText:[NSString stringWithFormat:@"%d", i]];
			numberLabel.textColor = [UIColor appColor2];
			[_numberLabels addObject:numberLabel];
		}
	}
	
	// centers and adds the number labels to the view every time
	for (float i = 0; i < _numberLabels.count; i++) {
		UILabel *numberLabel = [_numberLabels objectAtIndex:i];
		float denominator = (float)_numberLabels.count - 0.43f; // once more, a magic number just to make things look right
		if (denominator < 1) {
			denominator = 1;
		}
		numberLabel.center = CGPointMake(((i + 0.25f) * self.frame.size.width - 0.5f) / denominator + _indentation,
                                         numberLabel.center.y);
		[self.containerView addSubview:numberLabel];
	}
}






#pragma mark - Radio Button Layout

- (void)radioButtonLayout {
	if (!_segmentedControl) {
		_segmentedControl = [[PQSSegmentedControl alloc] initWithItems:self.question.possibleAnswers];
		_segmentedControl.question = self.question;
		
		if (_segmentedControl.frame.size.width > LONGER_SIDE) {
			[self layoutpossibleAnswers];
			return;
		} else if (SHORTER_SIDE > 414.0f && _segmentedControl.frame.size.width > SHORTER_SIDE) {
			int i = 0;
			for (NSString *answer in self.question.possibleAnswers) {
				CGRect answerFrame = [answer boundingRectWithSize:self.bounds.size
														  options:NSStringDrawingUsesLineFragmentOrigin
													   attributes:@{NSFontAttributeName : [UIFont appFont]}
														  context:nil];
				if (answerFrame.size.width < 80.0f) {
					answerFrame.size.width = 80.0f;
				}
				
				[_segmentedControl setWidth:answerFrame.size.width forSegmentAtIndex:i];
				i++;
			}
		}
		
		_segmentedControl.tintColor = [UIColor appColor];
		_segmentedControl.center = CGPointMake(_segmentedControl.center.x + leftSideBuffer * 0.5f,
											   _segmentedControl.center.y + 10.0f);
		[_segmentedControl addTarget:self.superview
							  action:@selector(radioButtonTouched:)
					forControlEvents:UIControlEventTouchDragInside | UIControlEventTouchDragOutside | UIControlEventTouchDragEnter | UIControlEventTouchDragExit | UIControlEventTouchUpInside | UIControlEventTouchUpOutside | UIControlEventAllEvents];
		[_additionalButtons addObject:_segmentedControl];
	}
	
	if (_segmentedControl.frame.size.width > LONGER_SIDE) {
		[self layoutpossibleAnswers];
		return;
	}
	
	if (_segmentedControl.frame.size.width + 100.0f > self.frame.size.width) {
		_segmentedControl.center = CGPointMake(self.frame.size.width * 0.5f + leftSideBuffer,
											   _segmentedControl.center.y);
	} else {
		_segmentedControl.center = CGPointMake(_segmentedControl.frame.size.width  * 0.5f + leftSideBuffer,
											   _segmentedControl.frame.size.height * 0.5f + 10.0f);
	}
	
	[self.containerView addSubview:_segmentedControl];
	
	if (_additionalLabels.count != self.question.possibleAnswers.count) {
		
	}
}

-(void)resizeSegmentsToFitTitles:(PQSSegmentedControl *)segCtrl {
	CGFloat totalWidths = 0;    // total of all label text widths
	NSUInteger nSegments = segCtrl.subviews.count;
	UIView* aSegment = [segCtrl.subviews objectAtIndex:0];
	UIFont* theFont = nil;
	
	for (UILabel* aLabel in aSegment.subviews) {
		if ([aLabel isKindOfClass:[UILabel class]]) {
			theFont = aLabel.font;
			break;
		}
	}
	
	// calculate width that all the title text takes up
	for (NSUInteger i=0; i < nSegments; i++) {
		CGFloat textWidth = [[segCtrl titleForSegmentAtIndex:i] sizeWithFont:theFont].width;
		totalWidths += textWidth;
	}
	
	// width not used up by text, its the space between labels
	CGFloat spaceWidth = segCtrl.bounds.size.width - totalWidths;
	
	// now resize the segments to accomodate text size plus
	// give them each an equal part of the leftover space
	for (NSUInteger i=0; i < nSegments; i++) {
		// size for label width plus an equal share of the space
		CGFloat textWidth = [[segCtrl titleForSegmentAtIndex:i] sizeWithFont:theFont].width;
		// roundf??  the control leaves 1 pixel gap between segments if width
		// is not an integer value, the roundf fixes this
		CGFloat segWidth = roundf(textWidth + (spaceWidth / nSegments));
		[segCtrl setWidth:segWidth forSegmentAtIndex:i];
	}
}


- (void)radioButtonTouched:(PQSSegmentedControl *)segmentedControl {
	NSMutableString *answerString = [[NSMutableString alloc] init];
	
	PQSQuestion *question = self.question;
    
    _segmentedControl = segmentedControl;
	
	if ([segmentedControl respondsToSelector:@selector(question)] && segmentedControl.question) {
		question = segmentedControl.question;
	}
	
//	[answerString appendString:question.question];
	
	if (segmentedControl.selectedSegmentIndex < 0) { // make sure that this method is not just being called out of order
		return;
    }
	
	NSString *currentAnswerString;
	
	NSArray *possibleAnswers = question.possibleAnswers;
    
	
	if ([segmentedControl respondsToSelector:@selector(question)] && segmentedControl.question.possibleAnswers.count > 0) {
		possibleAnswers = segmentedControl.question.possibleAnswers;
	}
	
	if (segmentedControl.selectedSegmentIndex < possibleAnswers.count) {
		currentAnswerString = [NSString stringWithFormat:@"%@", [possibleAnswers objectAtIndex:segmentedControl.selectedSegmentIndex]];
	} else {
		currentAnswerString = [segmentedControl titleForSegmentAtIndex:segmentedControl.selectedSegmentIndex];
		
		if (!currentAnswerString) {
			NSLog(@"No current answer! This may cause a problem.");
			
			currentAnswerString = @"";
		}
	}
	
	NSLog(@"Possible Answers: %@\n\t\t\t\t\t\tQuestion: %@", possibleAnswers, segmentedControl.question.question);
	
	[answerString appendString:currentAnswerString];
	
	NSString *key = [self.question.urlKeys objectForKey:question.question];
	
	BOOL submitted = NO;
	
	for (NSString *tempKey in question.urlKeys) {
		if ([[question.question lowercaseString] rangeOfString:[tempKey lowercaseString]].location != NSNotFound) {
			key = [question.urlKeys objectForKey:tempKey];
			
			if (key) {
				[[PQSReferenceManager sharedReferenceManager] submitAnswer:currentAnswerString withKey:[question.urlKeys objectForKey:tempKey]];
				submitted = YES;
			}
		}
	}
	
	
	
	
	// find if the current segmented control contains a trigger
	BOOL selectedSegmentedControlContainsTrigger = NO;
	
	if (!question.triggerAnswer) {
		NSLog(@"What is going on here? %@", question.triggerAnswer);
		
		if (!self.question.triggerAnswer) {
			NSLog(@"You don't even have one?");
		} else {
			question.triggerAnswer = self.question.triggerAnswer;
		}
	}
	
	for (int i = 0; i < segmentedControl.numberOfSegments && !selectedSegmentedControlContainsTrigger && question.triggerAnswer; i++) {
		NSString *possibleAnswer = [segmentedControl titleForSegmentAtIndex:i];
		
		if (possibleAnswer && [possibleAnswer.lowercaseString containsString:question.triggerAnswer.lowercaseString]) {
			selectedSegmentedControlContainsTrigger = YES;
		}
	}
	
	// if the segemented control that was just selected contains the trigger and the trigger was not selected, then the trigger is deactivated
	if (selectedSegmentedControlContainsTrigger) {
		if ([currentAnswerString.lowercaseString containsString:question.triggerAnswer.lowercaseString]) {
			NSLog(@"Trigger!");
			question.multipleColumnShouldShowQuestion = YES;
			self.question.multipleColumnShouldShowQuestion = YES;
		} else {
			question.multipleColumnShouldShowQuestion = NO;
			self.question.multipleColumnShouldShowQuestion = NO;
		}
		
		if ([self.delegate respondsToSelector:@selector(reloadQuestions)]) {
			[self.delegate reloadQuestions];
		}
	}
	
	
	
	
	if (!submitted) {
		NSLog(@"Couldn't find a key to submit with, so we're going with submitting using the question itself");
		[[PQSReferenceManager sharedReferenceManager] submitAnswer:answerString forQuestion:question];
	}
}






#pragma mark - Multiple Choice Layout

- (void)layoutpossibleAnswers {
	if (!_tableView) {
		_tableView = [[UITableView alloc] initWithFrame:[self possibleAnswersFrame]];
		
		if (_tableView.frame.size.height > 0.0f) {
			_tableView.delegate = self;
			_tableView.dataSource = self;
			_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
			_tableView.backgroundColor = [UIColor clearColor];
		} else {
			NSLog(@"There are no answers for this multiple choice question. This will cause problems. I advise you fix that promptly.");
		}
		
		[_tableView reloadData];
	} else {
		_tableView.frame = [self possibleAnswersFrame];
	}
	
	[self.containerView addSubview:_tableView];
}

- (CGRect)possibleAnswersFrame {
	CGRect frame = CGRectMake(40.0f,
							  22.0f,
							  self.frame.size.width * 0.8f,
							  cellHeight * self.question.possibleAnswers.count);
	
	return frame;
}




#pragma mark - Table View Data Source Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1; // assuming the table is only used for multiple choice type answers
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.question.possibleAnswers.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	CGRect frame = CGRectZero;
	
	if (self.question.attributedPossibleAnswers.count > indexPath.row) {
		NSAttributedString *string = [self.question.attributedPossibleAnswers objectAtIndex:indexPath.row];
		frame = [string boundingRectWithSize:_tableView.frame.size
									 options:NSStringDrawingUsesLineFragmentOrigin
									 context:nil];
	} else {
		[UIFont appFont];
		NSString *string = [self.question.possibleAnswers objectAtIndex:indexPath.row];
		frame = [string boundingRectWithSize:_tableView.frame.size
									 options:NSStringDrawingUsesLineFragmentOrigin
								  attributes:@{NSFontAttributeName : [UIFont appFont]}
									 context:nil];
	}
	
	if (frame.size.height > cellHeight) {
		return frame.size.height;
	}
	
	return cellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return cellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [[UITableViewCell alloc] initWithFrame:CGRectMake(0.0f,
																			  0.0f,
																			  self.frame.size.width,
																			  cellHeight)];
	cell.clipsToBounds = YES;
	
	if (self.question.attributedPossibleAnswers.count > indexPath.row) {
		cell.textLabel.attributedText = [self.question.attributedPossibleAnswers objectAtIndex:indexPath.row];
	} else {
		cell.textLabel.text = [NSString stringWithFormat:@"%@", NSLocalizedString([self.question.possibleAnswers objectAtIndex:indexPath.row], nil)];
		cell.textLabel.font = [UIFont appFont];
	}
	
	cell.textLabel.adjustsFontSizeToFitWidth = YES;
	cell.textLabel.numberOfLines = 0;
	cell.textLabel.minimumScaleFactor = 0.9f;;
	
	if (self.question.hideBorder) {
		cell.layer.borderWidth = 0.0f;
	} else {
		cell.layer.borderColor = [UIColor appColor].CGColor;
		cell.layer.borderWidth = 1.0f;
		cell.layer.cornerRadius = 5.0f;
	}
	
	
	cell.backgroundColor = [UIColor clearColor];
	
	return cell;
}





#pragma mark - Table View Delegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *answer = [self.question.possibleAnswers objectAtIndex:indexPath.row];
//	NSLog(@"Tapped: %@\t\tQuestion Number: %d", answer, self.question.questionNumber);
	
	if ([self.delegate respondsToSelector:@selector(answerSelected:question:)]) {
		[self.delegate answerSelected:answer question:self.question];
	} else {
		NSLog(@"Delegate not set or unresponsive for answer view. Nothing's happening when the user selects an answer without this delegate set.");
	}
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	if ([scrollView isEqual:_tableView]) {
		scrollView.contentOffset = CGPointZero;
	}
}




#pragma mark - APNumberPadDelegate

- (void)numberPad:(APNumberPad *)numberPad functionButtonAction:(UIButton *)functionButton textInput:(UIResponder<UITextInput> *)textInput {
	[textInput insertText:@"#"];
}





#pragma mark - 2 Way Exclusivity Radio Buttons

- (void)setUp2WayExclusivityRadioButtons {
	if (_additionalLabels.count != self.question.possibleAnswers.count) {
		// create the horizontal options
		NSMutableArray *options = [[NSMutableArray alloc] init];
		for (int i = self.question.minimumScale; i <= self.question.maximumScale; i++) {
			[options addObject:[NSString stringWithFormat:@"%d   ", i]];
		}
		
		for (int i = 0 ; i < self.question.possibleAnswers.count; i++) {
			PQSSegmentedControl *segmentedControl = [[PQSSegmentedControl alloc] initWithItems:options];
			segmentedControl.center = CGPointMake(segmentedControl.center.x + self.frame.origin.x,
												  segmentedControl.center.y + 28.0f * (i + 2.0f));
			[segmentedControl addTarget:self action:@selector(segmentedControlTouched:) forControlEvents:UIControlEventAllEvents];
			segmentedControl.tintColor = [UIColor appColor];
			segmentedControl.question = self.question;
			[self.superview addSubview:segmentedControl];
			
			[_additionalButtons addObject:segmentedControl];
			
			CGRect frame = segmentedControl.frame;
			frame.origin.x += segmentedControl.frame.size.width + 5.0f;
			frame.size.width = self.frame.size.width + 200.0f;
			UILabel *answerLabel = [[UILabel alloc] initWithFrame:frame];
			answerLabel.text = NSLocalizedString([self.question.possibleAnswers objectAtIndex:i], nil);
			answerLabel.textColor = [UIColor appColor2];
			answerLabel.font = [UIFont appFont];
			answerLabel.adjustsFontSizeToFitWidth = YES;
			answerLabel.numberOfLines = 0;
			[self.superview.superview addSubview:answerLabel];
			
			[_additionalLabels addObject:answerLabel];
		}
	}
	
	for (UIView *subview in _additionalLabels) {
		[self.superview addSubview:subview];
	}
	
	for (UIView *subview in _additionalButtons) {
		[self.superview addSubview:subview];
	}
}

- (void)segmentedControlTouched:(PQSSegmentedControl *)segmentedControl {
	for (PQSSegmentedControl *tempSegmentedControl in _additionalButtons) {
		if (![segmentedControl isEqual:tempSegmentedControl]) {
			if (segmentedControl.selectedSegmentIndex == tempSegmentedControl.selectedSegmentIndex && segmentedControl.selectedSegmentIndex != UISegmentedControlNoSegment) {
					tempSegmentedControl.selectedSegmentIndex = UISegmentedControlNoSegment;
			}
		}
	}
	
	NSMutableString *answerString = [[NSMutableString alloc] init];
	
	BOOL submitted = NO;
	
	for (int i = 0; i < self.question.possibleAnswers.count; i++) {
		NSString *multipleChoiceAnswer = [self.question.possibleAnswers objectAtIndex:i];
		
		[answerString appendString:[self.question.possibleAnswers objectAtIndex:i]];
		
		PQSSegmentedControl *segmentedControl = [_additionalButtons objectAtIndex:i];
		
		int position = (int)segmentedControl.selectedSegmentIndex + 1;
		if (position < 0) {
			position = 0;
		}
		
		NSString *currentAnswerString = [NSString stringWithFormat:@"%d", position];
		
		[answerString appendString:currentAnswerString];
		
		for (NSString *tempKey in self.question.urlKeys) {
			if ([multipleChoiceAnswer rangeOfString:tempKey].location != NSNotFound) {
				[[PQSReferenceManager sharedReferenceManager] submitAnswer:multipleChoiceAnswer withKey:[self.question.urlKeys objectForKey:tempKey]];
//				[[PQSReferenceManager sharedReferenceManager] submitAnswer:currentAnswerString withKey:[[self.question.urlKeys objectForKey:tempKey] stringByAppendingString:@"_int"]];
				submitted = YES;
			}
		}
	}
	
	if (!submitted) {
		NSLog(@"Couldn't find a key to submit with, so we're going with submitting using the question itself");
		[[PQSReferenceManager sharedReferenceManager] submitAnswer:answerString forQuestion:self.question];
	}
	
	NSLog(@"Answer string: \n\n%@\n\n", answerString);
}





#pragma mark - Long List Question

- (void)longListQuestion {
	if (_additionalLabels.count == 0) {
		_answerButton = [[UIButton alloc] initWithFrame:[self answerButtonFrame]];
		_answerButton.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
		if (self.question.placeholderText) {
			[_answerButton setTitle:NSLocalizedString(self.question.placeholderText, @"") forState:UIControlStateNormal];
		} else {
			[_answerButton setTitle:NSLocalizedString(@"Please Select One", nil) forState:UIControlStateNormal];
		}
		[_answerButton setTitle:[self paddedString:_answerButton.titleLabel.text] forState:UIControlStateNormal];
		_answerButton.titleLabel.font = [UIFont appFont];
		_answerButton.titleLabel.textAlignment = NSTextAlignmentLeft;
		_answerButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
		[_answerButton setTitleColor:[UIColor appColor] forState:UIControlStateNormal];
		[_answerButton addTarget:self action:@selector(longListLabelTapped) forControlEvents:UIControlEventTouchUpInside];
		_answerButton.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.0001f];
		if (!self.question.hideBorder) {
			_answerButton.titleLabel.layer.borderColor = [UIColor appColor].CGColor;
			_answerButton.titleLabel.layer.borderWidth = 1.0f;
			_answerButton.titleLabel.layer.cornerRadius = 5.0f;
		}
		[_additionalLabels addObject:_answerButton];
	} else {
		UIButton *answerButton = [_additionalLabels firstObject];
		answerButton.frame = [self answerButtonFrame];
	}
	
	if (self.useTapGesture && !_tap) {
		_tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(longListLabelTapped)];
		[self addGestureRecognizer:_tap];
	}
	
	for (UIButton *answerButton in _additionalLabels) {
		[self.containerView addSubview:answerButton];
	}
	
	if (!_optionsController && [UIAlertController class]) {
		_optionsController = [UIAlertController
							  alertControllerWithTitle:self.question.longListTitle
							  message:self.question.longListMessage
							  preferredStyle:UIAlertControllerStyleAlert];
		
		UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
			
		}];
		[_optionsController addAction:okAction];
		
		UIButton *answerButton = [_additionalLabels firstObject];
		
		
		for (NSString *optionName in self.question.possibleAnswers) {
			UIAlertAction *action = [UIAlertAction actionWithTitle:optionName
															 style:UIAlertActionStyleDefault
														   handler:^(UIAlertAction *action) {
															   [answerButton setTitle:[self paddedString:optionName] forState:UIControlStateNormal];
															   NSString *answer = [[[PQSReferenceManager sharedReferenceManager] countryCodeList] objectForKey:optionName];
															   if (!answer) {
																   answer = optionName;
															   }
															   [[PQSReferenceManager sharedReferenceManager] submitAnswer:answer
																												  withKey:[self.question.urlKeys objectForKey:[[self.question.urlKeys allKeys] firstObject]]];
														   }];
			[_optionsController addAction:action];
		}
	}
	
	if (!_alertView && ![UIAlertController class]) {
		_alertView = [[UIAlertView alloc] initWithTitle:self.question.longListTitle
															message:self.question.question
														   delegate:self
												  cancelButtonTitle:@"Cancel"
												  otherButtonTitles: nil];
		for (NSString *optionName in self.question.possibleAnswers) {
			[_alertView addButtonWithTitle:optionName];
		}
	}
}

- (CGRect)answerButtonFrame {
	CGRect frame = self.bounds;
	
	frame.size.height = cellHeight;
	frame.origin.x = cellHeight;
	
	return frame;
}

- (NSString *)paddedString:(NSString *)input {
	return [NSString stringWithFormat:@"  %@  ", input];
}

- (void)longListLabelTapped {
	if ([self.delegate respondsToSelector:@selector(displayAlertController:)]) {
		if (_optionsController) {
			[self.delegate displayAlertController:_optionsController];
		} else if (_alertView && ![UIAlertController class]) {
			[_alertView show];
		} else {
			NSLog(@"We're not even starting with a question. This can't even go downhill from here.");
		}
	}
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	NSString *buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];
	
	if ([[buttonTitle lowercaseString] rangeOfString:@"cancel"].location != NSNotFound) {
		return;
	} else if ([[[PQSReferenceManager sharedReferenceManager] countryCodeList] objectForKey:buttonTitle]) {
		NSString *answer = [[[PQSReferenceManager sharedReferenceManager] countryCodeList] objectForKey:buttonTitle];
		
		[[PQSReferenceManager sharedReferenceManager] submitAnswer:answer
														   withKey:[self.question.urlKeys objectForKey:[[self.question.urlKeys allKeys] firstObject]]];
	}
}








#pragma mark - Incremental Value

- (void)incrementalValueLayout {
	if (!_stepper) {
		_stepper = [[UIStepper alloc] init];
		_stepper.minimumValue = self.question.minimumScale;
		if (self.question.maximumScale > self.question.minimumScale) {
			_stepper.maximumValue = self.question.maximumScale;
		}
		_stepper.tintColor = [UIColor appColor];
		_stepper.value = self.question.startingPoint;
		_stepper.center = CGPointMake(_stepper.center.x, _stepper.center.y + 10.0f);
		[_stepper addTarget:self action:@selector(stepperTapped) forControlEvents:UIControlEventTouchUpInside];
		[_stepper addTarget:self action:@selector(stepperTapped) forControlEvents:UIControlEventAllTouchEvents];
		
		if (self.question.scaleInterval != 0) {
			_stepper.stepValue = self.question.scaleInterval;
		}
		
		UILabel *stepperValueLabel = [[UILabel alloc] initWithFrame:_stepper.frame];
		stepperValueLabel.text = [NSString stringWithFormat:@"%g%@", (float)_stepper.value, self.question.scaleSuffix ? self.question.scaleSuffix : @""];
		stepperValueLabel.textColor = [UIColor appColor2];
		stepperValueLabel.font = [UIFont appFont];
		stepperValueLabel.textAlignment = NSTextAlignmentCenter;
		stepperValueLabel.numberOfLines = 0;
		stepperValueLabel.adjustsFontSizeToFitWidth = YES;
		[_additionalLabels addObject:stepperValueLabel];
		
		CGRect frame = _stepper.frame;
		frame.origin.x += frame.size.width;
		_stepper.frame = frame;
	}
	
	[self.containerView addSubview:_stepper];
	
	for (UILabel *label in _additionalLabels) {
		[self.containerView addSubview:label];
	}
}

- (void)updateStepper {
	UILabel *stepperValueLabel = [_additionalLabels firstObject];
	stepperValueLabel.text = [NSString stringWithFormat:@"%g%@", (float)_stepper.value, self.question.scaleSuffix ? self.question.scaleSuffix : @""];
	[self.containerView addSubview:stepperValueLabel];
}

- (void)stepperTapped {
	UILabel *stepperValueLabel = [_additionalLabels firstObject];
	stepperValueLabel.text = [NSString stringWithFormat:@"%g%@", (float)_stepper.value, self.question.scaleSuffix ? self.question.scaleSuffix : @""];
	[self.containerView addSubview:stepperValueLabel];
	
	BOOL submitted = NO;
	
	for (NSString *tempKey in self.question.urlKeys) {
		if ([self.question.question rangeOfString:tempKey].location != NSNotFound) {
			[[PQSReferenceManager sharedReferenceManager] submitAnswer:stepperValueLabel.text withKey:[self.question.urlKeys objectForKey:tempKey]];
			submitted = YES;
		}
	}
	
	if (!submitted) {
		NSLog(@"Couldn't find a key to submit with, so we're going with submitting using the question itself");
		[[PQSReferenceManager sharedReferenceManager] submitAnswer:stepperValueLabel.text forQuestion:self.question];
	}
}





#pragma mark - Percentage

- (void)percentageLayout {
	if (!_slider) {
		_slider = [[UISlider alloc] initWithFrame:CGRectMake(60.0f, 0.0f, SHORTER_SIDE * 0.5f, 44.0f)];
		_slider.minimumTrackTintColor = [UIColor appColor];
		_slider.minimumValue = 0.0f;
		_slider.maximumValue = 100.0f;
		[_slider addTarget:self action:@selector(percentageSliderTouched) forControlEvents:UIControlEventAllEvents];
		[_additionalButtons addObject:_slider];
		
		UILabel *percentLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 60.0f, 44.0f)];
		percentLabel.font = [UIFont appFont];
		percentLabel.textAlignment = NSTextAlignmentCenter;
		percentLabel.text = [NSString stringWithFormat:@"%d%%", [self roundFloat:_slider.value interval:percentageRoundingInterval]];
		percentLabel.textColor = [UIColor appColor2];
		percentLabel.numberOfLines = 0;
		[_additionalLabels addObject:percentLabel];
	} else {
		_slider.frame = CGRectMake(60.0f, 0.0f, SHORTER_SIDE * 0.5f, 44.0f);
		UILabel *percentLabel = _additionalLabels.lastObject;
		percentLabel.frame = CGRectMake(0.0f, 0.0f, 60.0f, 44.0f);
	}
	
	[self.containerView addSubview:_slider];
	
	for (UILabel *label in _additionalLabels) {
		[self.containerView addSubview:label];
	}
}

- (void)percentageSliderTouched {
	UILabel *percentLabel = [_additionalLabels firstObject];
	percentLabel.text = [NSString stringWithFormat:@"%d%%", [self roundFloat:_slider.value interval:percentageRoundingInterval]];
	[self.containerView addSubview:percentLabel];
	
	BOOL submitted = NO;
	NSString *currentAnswerString = [NSString stringWithFormat:@"%d%%", [self roundFloat:_slider.value interval:percentageRoundingInterval]];
	
	for (NSString *tempKey in self.question.urlKeys) {
		if ([self.question.question rangeOfString:tempKey].location != NSNotFound) {
			[[PQSReferenceManager sharedReferenceManager] submitAnswer:currentAnswerString withKey:[self.question.urlKeys objectForKey:tempKey]];
			submitted = YES;
		}
	}
	
	if (!submitted) {
		NSLog(@"Couldn't find a key to submit with, so we're going with submitting using the question itself");
		[[PQSReferenceManager sharedReferenceManager] submitAnswer:currentAnswerString forQuestion:self.question];
	}
	
}

- (int)roundFloat:(float)value interval:(int)interval {
	return ((float)interval) * floor((value/((float)interval))+0.5f);
}





#pragma mark - Split Percentage

- (void)splitPercentageLayout {
	if (_additionalButtons.count != self.question.possibleAnswers.count) {
		for (int i = 0; i < self.question.possibleAnswers.count; i++) {
			UILabel *questionLabel = [[UILabel alloc] initWithFrame:[self splitPercentageQuestionLabelFrame:i]];
			
			if (self.question.attributedPossibleAnswers.count > i) {
				NSMutableAttributedString *questionAttributedString = [[NSMutableAttributedString alloc] initWithAttributedString:[self.question.attributedPossibleAnswers objectAtIndex:i]];
				
				[questionAttributedString addAttribute:NSForegroundColorAttributeName value:[UIColor appColor1] range:NSMakeRange(0, questionAttributedString.string.length)];
				
				questionLabel.attributedText = questionAttributedString;
			} else {
				questionLabel.text = [self.question.possibleAnswers objectAtIndex:i];
				questionLabel.textColor = [UIColor appColor2];
				questionLabel.font = [UIFont appFont];
			}
			
			questionLabel.textAlignment = NSTextAlignmentLeft;
			questionLabel.adjustsFontSizeToFitWidth = YES;
			questionLabel.numberOfLines = 0;
			[_additionalLabels addObject:questionLabel];
			
			UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(60.0f, i * 88.0f + 36.0f, SHORTER_SIDE * 0.5f, 56.0f)];
			slider.minimumValue = 0.0f;
			slider.maximumValue = 100.0f;
			slider.minimumTrackTintColor = [UIColor appColor];
			[slider addTarget:self action:@selector(splitPercentageSliderTouched:) forControlEvents:UIControlEventAllEvents];
			[slider addTarget:self action:@selector(splitPercentageSliderTouchEnded) forControlEvents:UIControlEventTouchUpInside];
			[_additionalButtons addObject:slider];
			
			UILabel *valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, i * 88.0f + 36.0f, 60.0f, 56.0f)];
			valueLabel.textAlignment = NSTextAlignmentCenter;
			valueLabel.text = [NSString stringWithFormat:@"%d%%", [self roundFloat:_slider.value interval:percentageRoundingInterval]];
			valueLabel.textColor = [UIColor appColor2];
			[_additionalValueLabels addObject:valueLabel];
		}
	} else {
		for (int i = 0; i < self.question.possibleAnswers.count; i++) {
			UILabel *questionLabel = [_additionalLabels objectAtIndex:i];
			questionLabel.frame = [self splitPercentageQuestionLabelFrame:i];
		}
	}
	
	for (UILabel *label in _additionalValueLabels) {
		[self.containerView addSubview:label];
	}
	
	for (UILabel *label in _additionalLabels) {
		[self.containerView addSubview:label];
	}
	
	for (UISlider *slider in _additionalButtons) {
		[self.containerView addSubview:slider];
	}
}

- (CGRect)splitPercentageQuestionLabelFrame:(int)questionNumber {
	CGRect frame = CGRectMake(0.0f, questionNumber * 88.0f, self.bounds.size.width, 44.0f);
	
	
	
	return frame;
}

- (void)splitPercentageSliderTouched:(UISlider *)slider {
	for (UISlider *slider in _additionalButtons) {
		slider.value = [self roundFloat:slider.value interval:percentageRoundingInterval];
	}
	
	while ([self currentSliderValues] > 101.0f) {
		if (slider.value > 100.0f) {
			slider.value = 100.0f;
		}
		
		for (UISlider *otherSlider in _additionalButtons) {
			if (![slider isEqual:otherSlider]) {
				[otherSlider setValue:otherSlider.value - percentageRoundingInterval];
				otherSlider.value = [self roundFloat:otherSlider.value interval:percentageRoundingInterval];
				if (otherSlider.value < 1.0f) {
					otherSlider.value = 0.0f;
				}
			}
		}
	}
	
	for (int i = 0; i < self.question.possibleAnswers.count; i++) {
		UISlider *slider = [_additionalButtons objectAtIndex:i];
		slider.minimumTrackTintColor = [UIColor appColor];
		
		UILabel *valueLabel = [_additionalValueLabels objectAtIndex:i];
		valueLabel.text = [NSString stringWithFormat:@"%d%%", (int)slider.value];
	}
}

- (void)splitPercentageSliderTouchEnded {
	NSMutableString *answerString = [[NSMutableString alloc] init];
	
	BOOL submitted = NO;
	
	for (int i = 0; i < self.question.possibleAnswers.count; i++) {
		NSString *multipleChoiceAnswer = [self.question.possibleAnswers objectAtIndex:i];
		
		[answerString appendString:[self.question.possibleAnswers objectAtIndex:i]];
		
		UISlider *slider = [_additionalButtons objectAtIndex:i];
		
		NSString *currentAnswerString = [NSString stringWithFormat:@"%d", (int)slider.value];
		
		[answerString appendString:currentAnswerString];
		
		for (NSString *tempKey in self.question.urlKeys) {
			if ([multipleChoiceAnswer rangeOfString:tempKey].location != NSNotFound) {
				[[PQSReferenceManager sharedReferenceManager] submitAnswer:currentAnswerString withKey:[self.question.urlKeys objectForKey:tempKey]];
				submitted = YES;
			}
		}
	}
	
	
	if (!submitted) {
		NSLog(@"Couldn't find a key to submit with, so we're going with submitting using the question itself");
		[[PQSReferenceManager sharedReferenceManager] submitAnswer:answerString forQuestion:self.question];
	}
}

- (float)currentSliderValues {
	float totalPercentage = 0.0f;
	for (UISlider *slider in _additionalButtons) {
		totalPercentage += slider.value;
	}
	
	return totalPercentage;
}





#pragma mark - Multiple Radios

- (void)layoutMultipleRadios {
	if (_additionalLabels.count != self.question.multipleRadioButtonQuestions.count) {
		float minimumLineHeight = 44.0f;
		float marginSize = 5.0f;
		
		for (int i = 0; i < self.question.multipleRadioButtonQuestions.count; i++) {
			PQSSegmentedControl *segmentedControl = [[PQSSegmentedControl alloc] initWithItems:self.question.possibleAnswers]; // UISegmentedControl's frame is automatically created
			segmentedControl.tintColor = [UIColor appColor];
			segmentedControl.center = CGPointMake(segmentedControl.center.x,
												  segmentedControl.center.y + i * minimumLineHeight + marginSize * 2.0f); // moves the view down
			[segmentedControl addTarget:self action:@selector(multipleRadiosTouched) forControlEvents:UIControlEventAllEvents];
			segmentedControl.question = self.question;
			[_additionalButtons addObject:segmentedControl];
			
			UILabel *questionLabel = [[UILabel alloc] initWithFrame:CGRectMake(segmentedControl.frame.size.width + marginSize,
																			   i * minimumLineHeight,
																			   self.frame.size.width - segmentedControl.frame.size.width - marginSize,
																			   minimumLineHeight)];
			questionLabel.text = [self.question.multipleRadioButtonQuestions objectAtIndex:i];
			questionLabel.textColor = [UIColor appColor2];
			questionLabel.textAlignment = NSTextAlignmentLeft;
			questionLabel.adjustsFontSizeToFitWidth = YES;
			questionLabel.numberOfLines = 0;
			[_additionalLabels addObject:questionLabel];
		}
	}
	
	for (UILabel *label in _additionalLabels) {
		[self.containerView addSubview:label];
	}
	
	for (PQSSegmentedControl *segmentedControl in _additionalButtons) {
		[self.containerView addSubview:segmentedControl];
	}
}

- (void)multipleRadiosTouched {
	NSMutableString *answerString = [[NSMutableString alloc] init];
	
	BOOL submitted = NO;

	for (int i = 0; i < self.question.multipleRadioButtonQuestions.count; i++) {
		NSString *multipleChoiceRadioButtonQuestion = [self.question.multipleRadioButtonQuestions objectAtIndex:i];

		[answerString appendString:[self.question.multipleRadioButtonQuestions objectAtIndex:i]];
		
		PQSSegmentedControl *segmentedControl = [_additionalButtons objectAtIndex:i];
		
		NSString *multipleChoiceOption = @"";
		
		if (segmentedControl.selectedSegmentIndex >= 0 && segmentedControl.selectedSegmentIndex < self.question.possibleAnswers.count) {
			multipleChoiceOption = [self.question.possibleAnswers objectAtIndex:segmentedControl.selectedSegmentIndex];
		} else if (segmentedControl.selectedSegmentIndex != UISegmentedControlNoSegment) {
			NSLog(@"Selected indez %zd but there are only %zd questions!", segmentedControl.selectedSegmentIndex, self.question.possibleAnswers.count);
		}
		
		int position = (int)segmentedControl.selectedSegmentIndex + 1;
		if (position < 0) {
			position = 0;
		}
		
		NSString *currentAnswerString = [NSString stringWithFormat:@"%d", position];
		
		[answerString appendString:currentAnswerString];
		
		
		for (NSString *tempKey in self.question.urlKeys) {
			if ([multipleChoiceRadioButtonQuestion rangeOfString:tempKey].location != NSNotFound) {
				[[PQSReferenceManager sharedReferenceManager] submitAnswer:multipleChoiceOption withKey:[self.question.urlKeys objectForKey:tempKey]];
//				[[PQSReferenceManager sharedReferenceManager] submitAnswer:currentAnswerString withKey:[[self.question.urlKeys objectForKey:tempKey] stringByAppendingString:@"_int"]];
				submitted = YES;
			}
		}
	}
	
	if (!submitted) {
		NSLog(@"Couldn't find a key to submit with, so we're going with submitting using the question itself");
		[[PQSReferenceManager sharedReferenceManager] submitAnswer:answerString forQuestion:self.question];
	}
}





#pragma mark - Check boxes

- (void)layoutCheckboxes {
	if (_additionalLabels.count != self.question.possibleAnswers.count) {
		for (int i = 0; i < self.question.possibleAnswers.count; i++) {
			UISwitch *checkboxSwitch = [[UISwitch alloc] init];
			checkboxSwitch.tintColor = [UIColor appColor];
			checkboxSwitch.onTintColor = [UIColor appColor];
			checkboxSwitch.center = CGPointMake(checkboxSwitch.center.x, checkboxSwitch.center.y + i * 44.0f + 10.0f);
			[checkboxSwitch addTarget:self action:@selector(switchTouched) forControlEvents:UIControlEventTouchUpInside];
			[_additionalButtons addObject:checkboxSwitch];

			UILabel *optionLabel = [[UILabel alloc] initWithFrame:CGRectMake(checkboxSwitch.frame.size.width + 5.0f, i * 44.0f, self.frame.size.width - checkboxSwitch.frame.size.width - 5.0f, 44.0f)];
			optionLabel.text = [self.question.possibleAnswers objectAtIndex:i];
			optionLabel.textColor = [UIColor appColor2];
			optionLabel.textAlignment = NSTextAlignmentLeft;
			optionLabel.adjustsFontSizeToFitWidth = YES;
			[_additionalLabels addObject:optionLabel];
		}
	} else {
		for (int i = 0; i < _additionalLabels.count && i < _additionalButtons.count; i++) {
			UILabel *optionLabel = [_additionalLabels objectAtIndex:i];
			UISwitch *checkboxSwitch = [_additionalButtons objectAtIndex:i];
			CGRect frame = CGRectMake(checkboxSwitch.frame.size.width + 5.0f, i * 44.0f, self.frame.size.width - checkboxSwitch.frame.size.width - 5.0f, 44.0f);
			optionLabel.frame = frame;
		}
	}
	
	for (UILabel *label in _additionalLabels) {
		[self.containerView addSubview:label];
	}
	
	for (PQSSegmentedControl *segmentedControl in _additionalButtons) {
		[self.containerView addSubview:segmentedControl];
	}
}

- (void)switchTouched {
	NSMutableString *answerString = [[NSMutableString alloc] init];
	
	BOOL submitted = NO;
	
	for (int i = 0; i < self.question.possibleAnswers.count; i++) {
		NSString *multipleChoiceAnswer = [self.question.possibleAnswers objectAtIndex:i];
		
		[answerString appendString:multipleChoiceAnswer];
		
		UISwitch *checkboxSwitch = [_additionalButtons objectAtIndex:i];
		
		NSString *currentAnswerString = checkboxSwitch.isOn ? multipleChoiceAnswer : @"";
		
		[answerString appendString:currentAnswerString];
		
		
		for (NSString *tempKey in self.question.urlKeys) {
			if ([multipleChoiceAnswer rangeOfString:tempKey].location != NSNotFound) {
				[[PQSReferenceManager sharedReferenceManager] submitAnswer:currentAnswerString withKey:[self.question.urlKeys objectForKey:tempKey]];
				submitted = YES;
			}
		}
	}
	
	
	if (!submitted) {
		NSLog(@"Couldn't find a key to submit with, so we're going with submitting using the question itself");
		[[PQSReferenceManager sharedReferenceManager] submitAnswer:answerString forQuestion:self.question];
	}
}



#pragma mark - True False Conditional

- (void)trueFalseConditionalLayout {
	if (!_segmentedControl) {
		if (self.question.useYesNoForTrueFalse) {
			if (![self.question.possibleAnswers containsObject:@"Yes"]) {
				[self.question.possibleAnswers addObjectsFromArray:@[@"Yes"]];
			}
			if (![self.question.possibleAnswers containsObject:@"No"]) {
				[self.question.possibleAnswers addObjectsFromArray:@[@"No"]];
			}
		} else {
			if (![self.question.possibleAnswers containsObject:@"True"]) {
				[self.question.possibleAnswers addObjectsFromArray:@[@"True"]];
			}
			if (![self.question.possibleAnswers containsObject:@"False"]) {
				[self.question.possibleAnswers addObjectsFromArray:@[@"False"]];
			}
		}
		
		_segmentedControl = [[PQSSegmentedControl alloc] initWithItems:self.question.possibleAnswers];
		_segmentedControl.question = self.question;
		
		if (_segmentedControl.frame.size.width > LONGER_SIDE) {
			[self layoutpossibleAnswers];
			return;
		}
		
		_segmentedControl.tintColor = [UIColor appColor];
		_segmentedControl.center = CGPointMake(_segmentedControl.center.x + leftSideBuffer * 0.5f,
											   _segmentedControl.center.y + 10.0f);
		[_segmentedControl addTarget:self action:@selector(trueFalseConditionalTouched:)
					forControlEvents:UIControlEventAllEvents];
		[_additionalButtons addObject:_segmentedControl];
	}
	
	if (_segmentedControl.frame.size.width > LONGER_SIDE) {
		[self layoutpossibleAnswers];
		return;
	}
	
	if (_segmentedControl.frame.size.width + 100.0f > self.frame.size.width) {
		_segmentedControl.center = CGPointMake(self.frame.size.width * 0.5f + 10.0f + leftSideBuffer,
											   _segmentedControl.center.y);
	} else {
		_segmentedControl.center = CGPointMake(_segmentedControl.frame.size.width  * 0.5f + leftSideBuffer,
											   _segmentedControl.frame.size.height * 0.5f + 10.0f);
	}
	
	[self.containerView addSubview:_segmentedControl];
}

- (void)trueFalseConditionalTouched:(PQSSegmentedControl *)segmentedControl {
	if (self.question.questionType != PQSQuestionTypeRadioButtons) {
		self.question.trueFalseConditionalHasAnswer = YES;
		
		if (segmentedControl.selectedSegmentIndex < self.question.possibleAnswers.count) {
			NSString *selectedAnswer = [[self.question.possibleAnswers objectAtIndex:segmentedControl.selectedSegmentIndex] lowercaseString];
			
			if ([selectedAnswer rangeOfString:@"yes"].location != NSNotFound || [selectedAnswer rangeOfString:@"true"].location != NSNotFound) {
				self.question.trueFalseConditionalAnswer = YES;
			} else if ([selectedAnswer rangeOfString:@"no"].location != NSNotFound || [selectedAnswer rangeOfString:@"false"].location != NSNotFound) {
				self.question.trueFalseConditionalAnswer = NO;
			} else {
				NSLog(@"Selected answer is neither True, False, Yes, or No. Answer is: %@", [self.question.possibleAnswers objectAtIndex:segmentedControl.selectedSegmentIndex]);
			}
		} else {
			NSLog(@"The selected answer for \"%@\" is out of index. Selected: %zd out of %zd option%@", self.question.question, segmentedControl.selectedSegmentIndex, self.question.possibleAnswers.count, self.question.possibleAnswers.count != 1 ? @"" : @"s");
		}
		
		if ([self.delegate respondsToSelector:@selector(reloadQuestions)]) {
			[self.delegate reloadQuestions];
		} else {
			NSLog(@"Answer View delegate does not respond to \"reloadQuestions\".");
		}
	}
	
	[self radioButtonTouched:_segmentedControl];
}

- (void)trueFalseConditional2Layout {
	if (!_segmentedControl) {
		if (self.question.useYesNoForTrueFalse) {
			if (![self.question.possibleAnswers containsObject:@"Yes"]) {
				[self.question.possibleAnswers addObjectsFromArray:@[@"Yes"]];
			}
			if (![self.question.possibleAnswers containsObject:@"No"]) {
				[self.question.possibleAnswers addObjectsFromArray:@[@"No"]];
			}
		} else {
			if (![self.question.possibleAnswers containsObject:@"True"]) {
				[self.question.possibleAnswers addObjectsFromArray:@[@"True"]];
			}
			if (![self.question.possibleAnswers containsObject:@"False"]) {
				[self.question.possibleAnswers addObjectsFromArray:@[@"False"]];
			}
		}
		
		_segmentedControl = [[PQSSegmentedControl alloc] initWithItems:self.question.possibleAnswers];
		_segmentedControl.question = self.question;
		
		if (_segmentedControl.frame.size.width > LONGER_SIDE) {
			[self layoutpossibleAnswers];
			return;
		}
		
		_segmentedControl.tintColor = [UIColor appColor];
		_segmentedControl.center = CGPointMake(_segmentedControl.center.x + leftSideBuffer * 0.5f,
											   _segmentedControl.center.y + 10.0f);
		[_segmentedControl addTarget:self
							  action:@selector(trueFalseConditionalTouched:)
					forControlEvents:UIControlEventAllEvents];
		[_additionalButtons addObject:_segmentedControl];
	}
	
	if (_segmentedControl.frame.size.width > LONGER_SIDE) {
		[self layoutpossibleAnswers];
		return;
	}
	
	if (_segmentedControl.frame.size.width + 100.0f > self.frame.size.width) {
		_segmentedControl.center = CGPointMake(self.frame.size.width * 0.5f + leftSideBuffer,
											   _segmentedControl.center.y);
	} else {
		_segmentedControl.center = CGPointMake(_segmentedControl.frame.size.width  * 0.5f + leftSideBuffer,
											   _segmentedControl.frame.size.height * 0.5f + 10.0f);
	}
	
	[self.containerView addSubview:_segmentedControl];
	
	NSMutableArray *trueAnswers = [_conditionalAnswerViewsDictionary objectForKey:@"true"];
	NSMutableArray *trueQuestionLabels = [_conditionalQuestionLabelsDictionary objectForKey:@"true"];
	
	NSMutableArray *falseAnswers = [_conditionalAnswerViewsDictionary objectForKey:@"false"];
	NSMutableArray *falseQuestionLabels = [_conditionalQuestionLabelsDictionary objectForKey:@"false"];
	
	NSMutableSet *allAdditionalViews = [[NSMutableSet alloc] init];
	if (trueAnswers) {
		[allAdditionalViews addObjectsFromArray:trueAnswers];
	}
	
	if (trueQuestionLabels) {
		[allAdditionalViews addObjectsFromArray:trueQuestionLabels];
	}
	
	if (falseAnswers) {
		[allAdditionalViews addObjectsFromArray:falseAnswers];
	}
	
	if (falseQuestionLabels) {
		[allAdditionalViews addObjectsFromArray:falseQuestionLabels];
	}
	
	for (UIView *view in allAdditionalViews) {
		[view removeFromSuperview];
	}
	
	if (self.question.trueFalseConditionalHasAnswer) {
		if (self.question.trueFalseConditionalAnswer) {
			NSMutableArray *trueAnswers = [_conditionalAnswerViewsDictionary objectForKey:@"true"];
			
			if (!trueAnswers) {
				trueAnswers = [NSMutableArray new];
				if (self.question.trueConditionalQuestion) {
					PQSAnswerView *conditionalAnswerView = [[PQSAnswerView alloc] initWithFrame:self.frame question:self.question.trueConditionalQuestion];
					[conditionalAnswerView layoutSubviews];
					conditionalAnswerView.delegate = self.delegate;
					
					UIView *answerView;
					if (conditionalAnswerView.segmentedControl) {
						answerView = conditionalAnswerView.segmentedControl;
					} else if (conditionalAnswerView.answerButton) {
						answerView = conditionalAnswerView.answerButton;
					} else {
						NSLog(@"There's no button! %zd", self.question.trueConditionalQuestion.questionType);
					}
					
					[trueAnswers addObject:answerView];
				}
				
				if (self.question.trueConditionalQuestion2) {
					PQSAnswerView *conditionalAnswerView = [[PQSAnswerView alloc] initWithFrame:self.frame question:self.question.trueConditionalQuestion2];
					[conditionalAnswerView layoutSubviews];
					conditionalAnswerView.delegate = self.delegate;
					
					UIView *answerView;
					if (conditionalAnswerView.segmentedControl) {
						answerView = conditionalAnswerView.segmentedControl;
					} else if (conditionalAnswerView.answerButton) {
						answerView = conditionalAnswerView.answerButton;
					}
					
					[trueAnswers addObject:answerView];
				}
				
				[_conditionalAnswerViewsDictionary setObject:trueAnswers
													  forKey:@"true"];
			}
			
			NSMutableArray *trueQuestionLabels = [_conditionalQuestionLabelsDictionary objectForKey:@"true"];
			
			if (!trueQuestionLabels) {
				trueQuestionLabels = [NSMutableArray new];
				
				if (self.question.trueConditionalQuestion) {
					UILabel *answerLabel = [self labelForQuestion:self.question.trueConditionalQuestion];
					[answerLabel sizeToFit];
					[trueQuestionLabels addObject:answerLabel];
				}
				
				if (self.question.trueConditionalQuestion2) {
					UILabel *answerLabel = [self labelForQuestion:self.question.trueConditionalQuestion2];
					[answerLabel sizeToFit];
					[trueQuestionLabels addObject:answerLabel];
				}
				
				[_conditionalQuestionLabelsDictionary setObject:trueQuestionLabels
														 forKey:@"true"];
			}
			
			for (int i = 0; i < trueAnswers.count && i < trueQuestionLabels.count; i++) {
				UILabel *questionLabel = [trueQuestionLabels objectAtIndex:i];
				
				CGRect questionLabelFrame = questionLabel.frame;
				questionLabelFrame.origin.y = 88.0f * i + _segmentedControl.frame.origin.y + _segmentedControl.frame.size.height + 44.0f;
				
				questionLabel.frame = questionLabelFrame;
				
				[self.containerView addSubview:questionLabel];
				
				UIView *answerView = [trueAnswers objectAtIndex:i];
				
				CGRect answerViewFrame = answerView.frame;
				answerViewFrame.origin.y = 88.0f * i + 22.0f + _segmentedControl.frame.origin.y + _segmentedControl.frame.size.height + 44.0f;
				
				answerView.frame = answerViewFrame;
				
				[self.containerView addSubview:answerView];
			}
		} else {
			NSMutableArray *falseAnswers = [_conditionalAnswerViewsDictionary objectForKey:@"false"];
			
			if (!falseAnswers) {
				falseAnswers = [NSMutableArray new];
				if (self.question.falseConditionalQuestion) {
					PQSAnswerView *conditionalAnswerView = [[PQSAnswerView alloc] initWithFrame:self.frame question:self.question.falseConditionalQuestion];
					[conditionalAnswerView layoutSubviews];
					conditionalAnswerView.delegate = self.delegate;
					
					UIView *answerView;
					if (conditionalAnswerView.segmentedControl) {
						answerView = conditionalAnswerView.segmentedControl;
					} else if (conditionalAnswerView.answerButton) {
						answerView = conditionalAnswerView.answerButton;
					}
					
					[falseAnswers addObject:answerView];
				}
				
				if (self.question.falseConditionalQuestion2) {
					PQSAnswerView *conditionalAnswerView = [[PQSAnswerView alloc] initWithFrame:self.frame question:self.question.falseConditionalQuestion2];
					[conditionalAnswerView layoutSubviews];
					conditionalAnswerView.delegate = self.delegate;
					
					UIView *answerView;
					if (conditionalAnswerView.segmentedControl) {
						answerView = conditionalAnswerView.segmentedControl;
					} else if (conditionalAnswerView.answerButton) {
						answerView = conditionalAnswerView.answerButton;
					}
					
					[falseAnswers addObject:answerView];
				}
				
				[_conditionalAnswerViewsDictionary setObject:falseAnswers
													  forKey:@"false"];
			}

			NSMutableArray *falseQuestionLabels = [_conditionalQuestionLabelsDictionary objectForKey:@"false"];
			
			if (!falseQuestionLabels) {
				falseQuestionLabels = [NSMutableArray new];
				
				if (self.question.falseConditionalQuestion) {
					UILabel *answerLabel = [self labelForQuestion:self.question.falseConditionalQuestion];
					[answerLabel sizeToFit];
					[falseQuestionLabels addObject:answerLabel];
				}
				
				if (self.question.falseConditionalQuestion2) {
					UILabel *answerLabel = [self labelForQuestion:self.question.falseConditionalQuestion2];
					[answerLabel sizeToFit];
					[falseQuestionLabels addObject:answerLabel];
				}
				
				[_conditionalQuestionLabelsDictionary setObject:falseQuestionLabels
														 forKey:@"false"];
			}
			
			
			for (int i = 0; i < falseAnswers.count && i < falseQuestionLabels.count; i++) {
				UILabel *questionLabel = [falseQuestionLabels objectAtIndex:i];
				
				CGRect questionLabelFrame = questionLabel.frame;
				questionLabelFrame.origin.y = 88.0f * i + _segmentedControl.frame.origin.y + _segmentedControl.frame.size.height + 44.0f;
				
				questionLabel.frame = questionLabelFrame;
				
				[self.containerView addSubview:questionLabel];
				
				UIView *answerView = [falseAnswers objectAtIndex:i];
				
				CGRect answerViewFrame = answerView.frame;
				answerViewFrame.origin.y = 88.0f * i + 22.0f + _segmentedControl.frame.origin.y + _segmentedControl.frame.size.height + 44.0f;
				
				answerView.frame = answerViewFrame;
				
				[self.containerView addSubview:answerView];
			}
		}
	}
}

- (UILabel *)labelForQuestion:(PQSQuestion *)question {
	UILabel *answerLabel = [[UILabel alloc] initWithFrame:self.bounds];
	
	if (question.attributedQuestion) {
		answerLabel.attributedText = question.attributedQuestion;
	} else {
		answerLabel.text = question.question;
	}
	
	answerLabel.textAlignment = NSTextAlignmentLeft;
	answerLabel.textColor = [UIColor appColor];
	answerLabel.font = [UIFont appFont];
	
	return answerLabel;
}



#pragma mark - Text Field Layout

- (void)textFieldLayout {
	if (_additionalLabels.count == 0) {
		_answerButton = [[UIButton alloc] initWithFrame:[self textFieldAnswerButtonFrame]];
		_answerButton.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
		if (!self.question.placeholderText) {
			self.question.placeholderText = NSLocalizedString(@"Please Type Your Answer", nil);
		}
		[_answerButton setTitle:NSLocalizedString(self.question.placeholderText, @"") forState:UIControlStateNormal];
		[_answerButton setTitle:[self paddedString:_answerButton.titleLabel.text] forState:UIControlStateNormal];
		_answerButton.titleLabel.font = [UIFont appFont];
		_answerButton.titleLabel.textAlignment = NSTextAlignmentLeft;
		_answerButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
		[_answerButton setTitleColor:[UIColor appColor] forState:UIControlStateNormal];
		[_answerButton addTarget:self action:@selector(textFieldLabelTapped) forControlEvents:UIControlEventTouchUpInside];
		_answerButton.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.0001f];
		if (!self.question.hideBorder) {
			_answerButton.titleLabel.layer.borderColor = [UIColor appColor].CGColor;
			_answerButton.titleLabel.layer.borderWidth = 1.0f;
			_answerButton.titleLabel.layer.cornerRadius = 5.0f;
		}
		[_additionalLabels addObject:_answerButton];
		
		if (self.question.isSticky) {
			NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
			NSString *stickyValue = [defaults objectForKey:self.question.question];
			
			if (stickyValue) {
				[_answerButton setTitle:[self paddedString:stickyValue] forState:UIControlStateNormal];
				
				[[PQSReferenceManager sharedReferenceManager] submitAnswer:stickyValue
																   withKey:[self.question.urlKeys objectForKey:[[self.question.urlKeys allKeys] firstObject]]];
			}
		}
	} else {
		UIButton *answerButton = [_additionalLabels firstObject];
		answerButton.frame = [self textFieldAnswerButtonFrame];
	}
	
	if (self.useTapGesture && !_tap) {
		_tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(textFieldLabelTapped)];
		[self addGestureRecognizer:_tap];
	}
	
	for (UIButton *answerButton in _additionalLabels) {
		[self.containerView addSubview:answerButton];
	}
	
	if (!_optionsController && [UIAlertController class]) {
		_optionsController = [UIAlertController
							  alertControllerWithTitle:self.question.question
							  message:self.question.longListMessage
							  preferredStyle:UIAlertControllerStyleAlert];
		
		NSString *placeHolderText = self.question.placeholderText;
		[_optionsController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
			_textField = textField;
			textField.placeholder = placeHolderText;
			textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
			textField.autocorrectionType = UITextAutocorrectionTypeNo;
			textField.delegate = self;
		}];
		
		__weak NSString *key = [self.question.urlKeys objectForKey:[[self.question.urlKeys allKeys] firstObject]];
		__weak NSString *placeholderText = self.question.placeholderText;
		__weak NSString *questionText = self.question.question.copy;
		
		if (!key) {
			NSLog(@"There's no key! This won't work! %@", self.question.question);
			key = [[self.question.question componentsSeparatedByCharactersInSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]] componentsJoinedByString:@""];
		}
		
		NSLog(@"Weak Key: %@", key);
		
		UIButton *answerButton = [_additionalLabels firstObject];
		PQSAlertAction *okAction = [PQSAlertAction actionWithTitle:@"OK"
															 style:UIAlertActionStyleDefault
														   handler:^(UIAlertAction *action) {
															 if (_textField.text.length > 0) {
																 [answerButton setTitle:[self paddedString:_textField.text] forState:UIControlStateNormal];
															 } else {
																 [answerButton setTitle:[self paddedString:placeholderText] forState:UIControlStateNormal];
															 }
															 [[PQSReferenceManager sharedReferenceManager] submitAnswer:_textField.text
																												withKey:key];
															 if (self.question.isSticky) {
																 NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
																 [defaults setObject:_textField.text forKey:questionText];
															 }
														 }];
		okAction.key = key;
		[_optionsController addAction:okAction];
		
		UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
															   style:UIAlertActionStyleCancel
															 handler:^(UIAlertAction *action) {
																 
															 }];
		[_optionsController addAction:cancelAction];
		
		
	}
	
	if (!_alertView && ![UIAlertController class]) {
		_alertView = [[UIAlertView alloc] initWithTitle:self.question.longListTitle
												message:self.question.question
											   delegate:self
									  cancelButtonTitle:@"Cancel"
									  otherButtonTitles: nil];
		for (NSString *optionName in self.question.possibleAnswers) {
			[_alertView addButtonWithTitle:optionName];
		}
	}
}

- (CGRect)textFieldAnswerButtonFrame {
	CGRect frame = self.bounds;
	
	frame.size.height = cellHeight;
	frame.origin.x = leftSideBuffer;
	
	return frame;
}

- (void)textFieldLabelTapped {
	if (self.question.questionType == PQSQuestionTypeTextView) {
		[self textViewLabelTapped];
	} else if ([self.delegate respondsToSelector:@selector(displayAlertController:)]) {
		if (_optionsController) {
			[self.delegate displayAlertController:_optionsController];
		} else if (_alertView && ![UIAlertController class]) {
			[_alertView show];
		} else {
			NSLog(@"We're not even starting with a question. This can't even go downhill from here.");
		}
	} else {
		NSLog(@"Delegate does not respond. %@", self.delegate);
	}
}


#pragma mark - Text View Layout

- (void)textViewLayout {
	if (_additionalLabels.count == 0) {
		_answerButton = [[UIButton alloc] initWithFrame:[self textFieldAnswerButtonFrame]];
		_answerButton.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
		
		if (!self.question.placeholderText) {
			self.question.placeholderText = NSLocalizedString(@"Please Type Your Answer", nil);
		}
		
		[_answerButton setTitle:self.question.placeholderText
					   forState:UIControlStateNormal];
		[_answerButton setTitle:[self paddedString:_answerButton.titleLabel.text]
					   forState:UIControlStateNormal];
		_answerButton.titleLabel.font = [UIFont appFont];
		_answerButton.titleLabel.textAlignment = NSTextAlignmentLeft;
		_answerButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
		[_answerButton setTitleColor:[UIColor appColor]
							forState:UIControlStateNormal];
		[_answerButton addTarget:self
						  action:@selector(description)
				forControlEvents:UIControlEventTouchUpInside];
		_answerButton.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.0001f];
		if (!self.question.hideBorder) {
			_answerButton.titleLabel.layer.borderColor = [UIColor appColor].CGColor;
			_answerButton.titleLabel.layer.borderWidth = 1.0f;
			_answerButton.titleLabel.layer.cornerRadius = 5.0f;
		}
		[_additionalLabels addObject:_answerButton];
		
		if (self.question.isSticky) {
			NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
			NSString *stickyValue = [defaults objectForKey:self.question.question];
			
			if (stickyValue) {
				[_answerButton setTitle:[self paddedString:stickyValue] forState:UIControlStateNormal];
				
				[[PQSReferenceManager sharedReferenceManager] submitAnswer:stickyValue
																   withKey:[self.question.urlKeys objectForKey:[[self.question.urlKeys allKeys] firstObject]]];
			}
		}
	} else {
		UIButton *answerButton = [_additionalLabels firstObject];
		answerButton.frame = [self textFieldAnswerButtonFrame];
	}
	
	if (self.useTapGesture && !_tap) {
		_tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(description)];
		[self addGestureRecognizer:_tap];
	}
	
	for (UIButton *answerButton in _additionalLabels) {
		[self.containerView addSubview:answerButton];
	}
}

- (NSString *)description {
	NSLog(@"Is this going to be stupid too?");
	
	return [super description];
}

- (void)textViewLabelTapped {
	if (!_textInputView) {
		_textInputView = [[PQSTextInputView alloc] initWithFrame:CGRectMake(0.0f,
																			0.0f,
																			kScreenWidth * 0.8f,
																			kScreenHeight * 0.4f)];
		_textInputView.delegateText = self;
	}
	
	[_textInputView.titleBarButtonItem setTitle:self.question.question];
	[_textInputView layoutSubviews];
	
	if ([self.delegate respondsToSelector:@selector(presentTextInputView:)]) {
		[self.delegate presentTextInputView:_textInputView];
		
		[_textInputView.textView becomeFirstResponder];
	} else {
		if ([self.superview respondsToSelector:@selector(delegate)]) {
			PQSAnswerView *superAnswerView = (PQSAnswerView *)self.superview;
			
			if ([superAnswerView.delegate respondsToSelector:@selector(presentTextInputView:)]) {
				[superAnswerView.delegate presentTextInputView:_textInputView];
				
				[_textInputView.textView becomeFirstResponder];
			}
		} else {
			NSLog(@"Delegate does not respond to \"presentTextInputView:\"");
		}
	}
}

- (void)textInputComplete:(NSString *)text {
	if (text.length > 0) {
		[_answerButton setTitle:[self paddedString:text] forState:UIControlStateNormal];
	} else {
		[_answerButton setTitle:[self paddedString:self.question.placeholderText] forState:UIControlStateNormal];
	}
	[[PQSReferenceManager sharedReferenceManager] submitAnswer:text
													   withKey:[self.question.urlKeys objectForKey:[[self.question.urlKeys allKeys] firstObject]]];
	if (self.question.isSticky) {
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		[defaults setObject:_textField.text forKey:self.question.question];
	}
	
	
	if (_textInputView) {
		[_textInputView.textView resignFirstResponder];
		[_textInputView removeFromSuperview];
	} else {
		NSLog(@"How do I keep losing you?");
	}
	
	// this line only applies if there IS an answer button on the trigger Answer View
	if ([self.delegate respondsToSelector:@selector(reloadQuestions)]) {
		[self.delegate reloadQuestions];
	}
}

#pragma mark - Multi Column Conditional Layout

- (void)multiColumnConditionalLayout {
	if (_additionalLabels.count < self.question.multipleColumnQuestions.count) {
		for (PQSQuestion *question in self.question.multipleColumnQuestions) {
			PQSAnswerView *extraAnswerView = [[PQSAnswerView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.frame.size.width / self.question.multipleColumnQuestions.count, self.frame.size.height) question:question];
			[extraAnswerView layoutSubviews];
			
			if (extraAnswerView.segmentedControl) {
				[_additionalButtons addObject:extraAnswerView.segmentedControl];
			}
			
			UILabel *extraLabel = [[UILabel alloc] initWithFrame:self.bounds];
			extraLabel.textAlignment = NSTextAlignmentCenter;
			
			if (question.attributedQuestion.string.length > 0) {
				extraLabel.attributedText = question.attributedQuestion;
			} else {
				extraLabel.text = question.question;
			}
			
			[_additionalLabels addObject:extraLabel];
		}
		
		for (UIView *subview in _additionalButtons) {
			subview.center = CGPointMake(subview.center.x, 44.0f);
		}
	}
	
	CGFloat totalButtonWidth = 0.0f;
	
	for (UIView *subview in _additionalButtons) {
		totalButtonWidth += subview.frame.size.width;
	}
	
	CGFloat divisions = 1 + _additionalButtons.count;
	CGFloat buffer = (self.frame.size.width - totalButtonWidth) / divisions;
	buffer /= 2;
	
	if (kScreenWidth >= 1024.0f) {
		CGFloat runningXOffset = self.frame.size.width * 0.25f + buffer;
		
		for (int i = 0; i < _additionalButtons.count; i++) {
			UIView *subview = [_additionalButtons objectAtIndex:i];
			UILabel *label = [_additionalLabels objectAtIndex:i];
			CGRect subviewFrame = subview.frame;
			
			subviewFrame.origin.x = runningXOffset;
			subview.frame = subviewFrame;
			
			runningXOffset += subviewFrame.size.width;
			runningXOffset += buffer;
			
			[self addSubview:subview];
			[self addSubview:label];
			
			label.center = CGPointMake(subview.center.x, subview.center.y - 44.0f);
		}
	} else {
		CGFloat runningXOffset = buffer;
		
		for (int i = 0; i < _additionalButtons.count; i++) {
			UIView *subview = [_additionalButtons objectAtIndex:i];
			UILabel *label = [_additionalLabels objectAtIndex:i];
			CGRect subviewFrame = subview.frame;
			
			subviewFrame.origin.y += 60.0f;
			subviewFrame.origin.x = runningXOffset;
			subview.frame = subviewFrame;
			
			runningXOffset += subviewFrame.size.width;
			runningXOffset += buffer;
			
			[self addSubview:subview];
			[self addSubview:label];
			
			label.center = CGPointMake(subview.center.x, subview.center.y - 44.0f);
		}

	}
	
	if (self.question.triggerQuestion && self.question.multipleColumnShouldShowQuestion && !_triggerAnswerView) {
		_triggerAnswerView = [[PQSAnswerView alloc] initWithFrame:self.bounds
														 question:self.question.triggerQuestion];
		_triggerAnswerView.delegate = self.delegate;
		[_triggerAnswerView layoutSubviews];
	} else {
		//NSLog(@"Trigger Question: %@", self.question.triggerQuestion.question);
		//NSLog(@"Trigger Answer:   %@", self.question.triggerAnswer);
	}
	
	if (_triggerAnswerView.answerButton) {
		_triggerAnswerView.answerButton.frame = [self triggerViewFrame];
		
		if (self.question.multipleColumnShouldShowQuestion) {
			[self.containerView addSubview:_triggerAnswerView.answerButton];
			_triggerAnswerView.answerButton.frame = CGRectMake(_triggerAnswerView.answerButton.superview.frame.size.width - _triggerAnswerView.answerButton.titleLabel.frame.size.width, _triggerAnswerView.answerButton.frame.origin.y, _triggerAnswerView.answerButton.frame.size.width, _triggerAnswerView.answerButton.frame.size.height);
		} else {
			[_triggerAnswerView.answerButton removeFromSuperview];
		}
	}
}

- (CGRect)triggerViewFrame {
	CGRect frame = self.bounds;
	frame.origin.y = 66.0f;
	frame.size.height -= frame.origin.y;
	frame.origin.x += leftSideBuffer;
	
	return frame;
}




#pragma mark - Date Layout

- (void)dateLayout {
	if (_additionalLabels.count == 0) {
		_answerButton = [[UIButton alloc] initWithFrame:[self textFieldAnswerButtonFrame]];
		_answerButton.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
		if (self.question.placeholderText) {
			[_answerButton setTitle:NSLocalizedString(self.question.placeholderText, @"") forState:UIControlStateNormal];
		} else {
			[_answerButton setTitle:NSLocalizedString(@"Please Type", nil) forState:UIControlStateNormal];
		}
		
		if (!_dateFormatter) {
			_dateFormatter = [[NSDateFormatter alloc] init];
			_dateFormatter.dateStyle = NSDateFormatterLongStyle;
		}
		
		if (self.question.startingDate) {
			[_answerButton setTitle:[self paddedString:[_dateFormatter stringFromDate:self.question.startingDate]] forState:UIControlStateNormal];
		} else {
			[_answerButton setTitle:[self paddedString:[_dateFormatter stringFromDate:[NSDate date]]] forState:UIControlStateNormal];
		}
		
		_answerButton.titleLabel.font = [UIFont appFont];
		_answerButton.titleLabel.textAlignment = NSTextAlignmentLeft;
		_answerButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
		[_answerButton setTitleColor:[UIColor appColor] forState:UIControlStateNormal];
		[_answerButton addTarget:self action:@selector(dateLabelTapped) forControlEvents:UIControlEventTouchUpInside];
		_answerButton.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.0001f];
		if (!self.question.hideBorder) {
			_answerButton.titleLabel.layer.borderColor = [UIColor appColor].CGColor;
			_answerButton.titleLabel.layer.borderWidth = 1.0f;
			_answerButton.titleLabel.layer.cornerRadius = 5.0f;
		}
		[_additionalLabels addObject:_answerButton];
	} else {
		UIButton *answerButton = [_additionalLabels firstObject];
		answerButton.frame = [self textFieldAnswerButtonFrame];
	}
	
	if (self.useTapGesture && !_tap) {
		_tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dateLabelTapped)];
		[self.containerView addGestureRecognizer:_tap];
	}
	
	for (UIButton *answerButton in _additionalLabels) {
		[self.containerView addSubview:answerButton];
	}
	
	if (!_optionsController && [UIAlertController class]) {
		_optionsController = [UIAlertController
							  alertControllerWithTitle:self.question.question
							  message:self.question.longListMessage
							  preferredStyle:UIAlertControllerStyleAlert];
		
		NSString *placeHolderText = self.question.placeholderText;
		
		UIDatePicker *datePicker = [[UIDatePicker alloc]initWithFrame:CGRectMake(0, 600, 320, 216)];
		datePicker.datePickerMode = UIDatePickerModeDate;
		[datePicker addTarget:self
					   action:@selector(dateSelected:)
			 forControlEvents:UIControlEventValueChanged];
		NSString *dateString = [_dateFormatter stringFromDate:datePicker.date];
		
		if (self.question.startingDate) {
			[datePicker setDate:self.question.startingDate
					   animated:NO];
			dateString = [_dateFormatter stringFromDate:self.question.startingDate];
		}
		
		
		[_optionsController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
			_textField = textField;
			textField.text = dateString;
			textField.placeholder = placeHolderText;
			textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
			textField.autocorrectionType = UITextAutocorrectionTypeNo;
			textField.inputView = datePicker;
		}];
		
		UIButton *answerButton = [_additionalLabels firstObject];
		UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
														   style:UIAlertActionStyleDefault
														 handler:^(UIAlertAction *action) {
															 [answerButton setTitle:[self paddedString:_textField.text] forState:UIControlStateNormal];
															 [[PQSReferenceManager sharedReferenceManager] submitAnswer:_textField.text
																												withKey:[self.question.urlKeys objectForKey:[[self.question.urlKeys allKeys] firstObject]]];
														 }];
		
		[_optionsController addAction:okAction];
		
		UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
															   style:UIAlertActionStyleCancel
															 handler:^(UIAlertAction *action) {
																 
															 }];
		[_optionsController addAction:cancelAction];
		
		
	}
	
	if (!_alertView && ![UIAlertController class]) {
		_alertView = [[UIAlertView alloc] initWithTitle:self.question.longListTitle
												message:self.question.question
											   delegate:self
									  cancelButtonTitle:@"Cancel"
									  otherButtonTitles: nil];
		for (NSString *optionName in self.question.possibleAnswers) {
			[_alertView addButtonWithTitle:optionName];
		}
	}
}

- (void)hey {
	NSLog(@"Hey");
}

- (void)dateSelected:(UIDatePicker *)datePicker {
	if (!_dateFormatter) {
		_dateFormatter = [[NSDateFormatter alloc] init];
		_dateFormatter.dateStyle = NSDateFormatterLongStyle;
	}
	
	if (datePicker.date) {
		_textField.text = [_dateFormatter stringFromDate:datePicker.date];
	}
}

- (void)dateLabelTapped {
	if ([self.delegate respondsToSelector:@selector(displayAlertController:)]) {
		if (_optionsController) {
			[self.delegate displayAlertController:_optionsController];
		} else if (_alertView && ![UIAlertController class]) {
			[_alertView show];
		} else {
			NSLog(@"We're not even starting with a question. This can't even go downhill from here.");
		}
	}
}


#pragma mark - Time Layout

- (void)timeLayout {
	if (_additionalLabels.count == 0) {
		_answerButton = [[UIButton alloc] initWithFrame:[self textFieldAnswerButtonFrame]];
		_answerButton.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
		if (self.question.placeholderText) {
			[_answerButton setTitle:NSLocalizedString(self.question.placeholderText, @"") forState:UIControlStateNormal];
		} else {
			[_answerButton setTitle:NSLocalizedString(@"Please Type", nil) forState:UIControlStateNormal];
		}
		
		if (self.question.startingDate) {
			[_answerButton setTitle:[self paddedString:[_dateFormatter stringFromDate:self.question.startingDate]] forState:UIControlStateNormal];
		} else {
			[_answerButton setTitle:[self paddedString:[_dateFormatter stringFromDate:[NSDate date]]] forState:UIControlStateNormal];
		}
		
		_answerButton.titleLabel.font = [UIFont appFont];
		_answerButton.titleLabel.textAlignment = NSTextAlignmentLeft;
		_answerButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
		[_answerButton setTitleColor:[UIColor appColor] forState:UIControlStateNormal];
		[_answerButton addTarget:self action:@selector(timeLabelTapped) forControlEvents:UIControlEventTouchUpInside];
		_answerButton.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.0001f];
		if (!self.question.hideBorder) {
			_answerButton.titleLabel.layer.borderColor = [UIColor appColor].CGColor;
			_answerButton.titleLabel.layer.borderWidth = 1.0f;
			_answerButton.titleLabel.layer.cornerRadius = 5.0f;
		}
		[_additionalLabels addObject:_answerButton];
	} else {
		UIButton *answerButton = [_additionalLabels firstObject];
		answerButton.frame = [self textFieldAnswerButtonFrame];
	}
	
	if (self.useTapGesture && !_tap) {
		_tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(timeLabelTapped)];
		[self addGestureRecognizer:_tap];
	}
	
	for (UIButton *answerButton in _additionalLabels) {
		[self.containerView addSubview:answerButton];
	}
	
	if (!_optionsController && [UIAlertController class]) {
		_optionsController = [UIAlertController
							  alertControllerWithTitle:self.question.question
							  message:self.question.longListMessage
							  preferredStyle:UIAlertControllerStyleAlert];
		
		NSString *placeHolderText = self.question.placeholderText;
		
		_datePicker = [[UIDatePicker alloc]initWithFrame:CGRectMake(0, 600, 320, 216)];
		_datePicker.datePickerMode = UIDatePickerModeCountDownTimer;
        
        if (self.question.scaleInterval > 0) {
            _datePicker.minuteInterval = self.question.scaleInterval;
        }
        
		[_datePicker addTarget:self
					   action:@selector(timeSelected:)
			 forControlEvents:UIControlEventValueChanged];
		
		NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
		NSDateComponents *components = [cal components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay
											  fromDate:_datePicker.date];
		[components setHour:0];
		[components setMinute:0];
		[components setSecond:0];
		NSDate * date = [cal dateFromComponents:components];
		[_datePicker setDate:date
				   animated:NO];

		
		NSTimeInterval duration = _datePicker.countDownDuration;
		int hours = (int)(duration/3600.0f);
		int minutes = ((int)duration - (hours * 3600))/60;
		
		NSString *dateString = [_dateFormatter stringFromDate:_datePicker.date];

		if (hours > 0) {
			if (minutes > 0) {
				dateString = [NSString stringWithFormat:@"%d hour%@ %d minute%@", hours, hours != 1 ? @"s" : @"", minutes, minutes != 1 ? @"s" : @""];
			} else {
				dateString = [NSString stringWithFormat:@"%d hour%@", hours, hours != 1 ? @"s" : @""];
			}
		} else {
			dateString = [NSString stringWithFormat:@"%d minute%@", minutes, minutes != 1 ? @"s" : @""];
		}
		
		[_optionsController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
			_textField = textField;
			textField.text = dateString;
			textField.placeholder = placeHolderText;
			textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
			textField.autocorrectionType = UITextAutocorrectionTypeNo;
		}];
		
		_textField.inputView = _datePicker;
		
		[_answerButton setTitle:[self paddedString:dateString]
					   forState:UIControlStateNormal];
		
		UIButton *answerButton = [_additionalLabels firstObject];
		UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
														   style:UIAlertActionStyleDefault
														 handler:^(UIAlertAction *action) {
															 [answerButton setTitle:[self paddedString:_textField.text] forState:UIControlStateNormal];
															 [[PQSReferenceManager sharedReferenceManager] submitAnswer:_textField.text
																												withKey:[self.question.urlKeys objectForKey:[[self.question.urlKeys allKeys] firstObject]]];
															 checkForTimeUpdate = NO;
														 }];
		
		[_optionsController addAction:okAction];
		
		UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
															   style:UIAlertActionStyleCancel
															 handler:^(UIAlertAction *action) {
																 
															 }];
		[_optionsController addAction:cancelAction];
		
		
	}
	
	if (!_alertView && ![UIAlertController class]) {
		_alertView = [[UIAlertView alloc] initWithTitle:self.question.longListTitle
												message:self.question.question
											   delegate:self
									  cancelButtonTitle:@"Cancel"
									  otherButtonTitles: nil];
		for (NSString *optionName in self.question.possibleAnswers) {
			[_alertView addButtonWithTitle:optionName];
		}
	}
}

- (void)listenForDatePicker {
	if (!checkForTimeUpdate) {
		return;
	}
	
	if ([[_answerButton.titleLabel.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:[self timeFromDatePicker:_datePicker]]) {
		[self performSelector:@selector(listenForDatePicker)
				   withObject:nil
				   afterDelay:0.5f];
	} else {
		_textField.text = [self timeFromDatePicker:_datePicker];
		checkForTimeUpdate = NO;
	}
}

- (void)timeSelected:(UIDatePicker *)datePicker {
	_textField.text = [self timeFromDatePicker:datePicker];
}

- (NSString *)timeFromDatePicker:(UIDatePicker *)datePicker {
	NSString *timeString = @"";
	
	NSTimeInterval duration = datePicker.countDownDuration;
	int hours = (int)(duration/3600.0f);
	int minutes = ((int)duration - (hours * 3600))/60;
	
	if (datePicker.date) {
		if (hours > 0) {
			if (minutes > 0) {
				timeString = [NSString stringWithFormat:@"%d hour%@ %d minute%@", hours, hours != 1 ? @"s" : @"", minutes, minutes != 1 ? @"s" : @""];
			} else {
				timeString = [NSString stringWithFormat:@"%d hour%@", hours, hours != 1 ? @"s" : @""];
			}
		} else {
			timeString = [NSString stringWithFormat:@"%d minute%@", minutes, minutes != 1 ? @"s" : @""];
		}
	}
	
	return timeString;
}

- (void)timeLabelTapped {
	checkForTimeUpdate = YES;
	[self performSelector:@selector(listenForDatePicker)
			   withObject:nil
			   afterDelay:0.5f];
	
	if ([self.delegate respondsToSelector:@selector(displayAlertController:)]) {
		if (_optionsController) {
			[self.delegate displayAlertController:_optionsController];
		} else if (_alertView && ![UIAlertController class]) {
			[_alertView show];
		} else {
			NSLog(@"We're not even starting with a question. This can't even go downhill from here.");
		}
	}
}




#pragma mark - Large Number Layout

- (void)largeNumberLayout {
	if (_additionalLabels.count == 0) {
		_answerButton = [[UIButton alloc] initWithFrame:[self textFieldAnswerButtonFrame]];
		_answerButton.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
		
		if (self.question.placeholderText.length == 0) {
			self.question.placeholderText = [NSString stringWithFormat:@"%zd", (NSInteger)self.question.startingPoint];;
		}
		
		[_answerButton setTitle:[self paddedString:self.question.placeholderText]
					   forState:UIControlStateNormal];
		_answerButton.titleLabel.font = [UIFont appFont];
		_answerButton.titleLabel.textAlignment = NSTextAlignmentLeft;
		_answerButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
		[_answerButton setTitleColor:[UIColor appColor] forState:UIControlStateNormal];
		[_answerButton addTarget:self action:@selector(dateLabelTapped) forControlEvents:UIControlEventTouchUpInside];
		_answerButton.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.0001f];
		if (!self.question.hideBorder) {
			_answerButton.titleLabel.layer.borderColor = [UIColor appColor].CGColor;
			_answerButton.titleLabel.layer.borderWidth = 1.0f;
			_answerButton.titleLabel.layer.cornerRadius = 5.0f;
		}
		[_additionalLabels addObject:_answerButton];
	} else {
		UIButton *answerButton = [_additionalLabels firstObject];
		answerButton.frame = [self textFieldAnswerButtonFrame];
	}
	
	if (self.useTapGesture && !_tap) {
		_tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dateLabelTapped)];
		[self addGestureRecognizer:_tap];
	}
	
	for (UIButton *answerButton in _additionalLabels) {
		[self.containerView addSubview:answerButton];
	}
	
	if (!_optionsController && [UIAlertController class]) {
		_optionsController = [UIAlertController
							  alertControllerWithTitle:self.question.question
							  message:self.question.longListMessage
							  preferredStyle:UIAlertControllerStyleAlert];
		
		NSString *placeHolderText = self.question.placeholderText;
		
		APNumberPad *numberPad = [APNumberPad numberPadWithDelegate:self];
		
		[_optionsController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
			_textField = textField;
			textField.placeholder = placeHolderText;
			textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
			textField.autocorrectionType = UITextAutocorrectionTypeNo;
			textField.inputView = numberPad;
		}];
		
		UIButton *answerButton = [_additionalLabels firstObject];
		UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
														   style:UIAlertActionStyleDefault
														 handler:^(UIAlertAction *action) {
															 [_textField setText:[_textField.text stringByReplacingOccurrencesOfString:@"#" withString:@""]];
															 
															 [_textField setText:[_textField.text stringByReplacingOccurrencesOfString:@"#" withString:@""]];
															 if (_textField.text.length > 1) {
																 while ([[_textField.text substringToIndex:1] intValue] == 0 && _textField.text.length > 1) {
																	 _textField.text = [_textField.text substringFromIndex:1];
																 }
															 }
															 
															 if (_textField.text.length > 0) {
																 [answerButton setTitle:[self paddedString:[NSString stringWithFormat:@"%@ %@", _textField.text, self.question.scaleSuffix]] forState:UIControlStateNormal];
															 } else {
																 [answerButton setTitle:[self paddedString:self.question.placeholderText] forState:UIControlStateNormal];
															 }
															 [[PQSReferenceManager sharedReferenceManager] submitAnswer:_textField.text
																												withKey:[self.question.urlKeys objectForKey:[[self.question.urlKeys allKeys] firstObject]]];
														 }];
		
		[_optionsController addAction:okAction];
		
		UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
															   style:UIAlertActionStyleCancel
															 handler:^(UIAlertAction *action) {
																 
															 }];
		[_optionsController addAction:cancelAction];
		
		
	}
	
	if (!_alertView && ![UIAlertController class]) {
		_alertView = [[UIAlertView alloc] initWithTitle:self.question.longListTitle
												message:self.question.question
											   delegate:self
									  cancelButtonTitle:@"Cancel"
									  otherButtonTitles: nil];
		for (NSString *optionName in self.question.possibleAnswers) {
			[_alertView addButtonWithTitle:optionName];
		}
	}
}


#pragma mark - My attempt at fixing a pervasive problem

+ (void)buttonTouched:(NSDictionary *)info {
	PQSQuestion *question = [info objectForKey:questionKey];
	NSObject *sender = [info objectForKey:senderKey];
	
	if ([sender isKindOfClass:[PQSSegmentedControl class]]) {
		PQSSegmentedControl *segmentedControl = (PQSSegmentedControl *)sender;
		
		NSMutableString *answerString = [[NSMutableString alloc] init];
		
		[answerString appendString:question.question];
		
		if (segmentedControl.selectedSegmentIndex < 0) { // make sure that this method is not just being called out of order
			return;
		}
		
		NSString *currentAnswerString;
		
		if (segmentedControl.selectedSegmentIndex < question.possibleAnswers.count) {
			currentAnswerString = [NSString stringWithFormat:@"%@", [question.possibleAnswers objectAtIndex:segmentedControl.selectedSegmentIndex]];
		} else {
			currentAnswerString = [segmentedControl titleForSegmentAtIndex:segmentedControl.selectedSegmentIndex];
			
			if (!currentAnswerString) {
				NSLog(@"No current answer! This may cause a problem.");
				
				currentAnswerString = @"";
			}
		}
		
		[answerString appendString:currentAnswerString];
		
		NSString *key = [question.urlKeys objectForKey:question.question];
		
		BOOL submitted = NO;
		
		for (NSString *tempKey in question.urlKeys) {
			if ([[question.question lowercaseString] rangeOfString:[tempKey lowercaseString]].location != NSNotFound) {
				key = [question.urlKeys objectForKey:tempKey];
				
				if (key) {
					[[PQSReferenceManager sharedReferenceManager] submitAnswer:currentAnswerString withKey:[question.urlKeys objectForKey:tempKey]];
					submitted = YES;
				}
			}
		}
		
		
		
		
		// find if the current segmented control contains a trigger
		BOOL selectedSegmentedControlContainsTrigger = NO;
		
		if (!(!selectedSegmentedControlContainsTrigger && question.triggerAnswer)) {
			NSLog(@"This will cause a problem: %@", question.triggerAnswer);
		}
		
		for (int i = 0; i < segmentedControl.numberOfSegments && !selectedSegmentedControlContainsTrigger && question.triggerAnswer; i++) {
			NSString *possibleAnswer = [segmentedControl titleForSegmentAtIndex:i];
			
			if (possibleAnswer && [possibleAnswer.lowercaseString containsString:question.triggerAnswer.lowercaseString]) {
				selectedSegmentedControlContainsTrigger = YES;
			}
		}
		
		// if the segemented control that was just selected contains the trigger and the trigger was not selected, then the trigger is deactivated
		if (selectedSegmentedControlContainsTrigger) {
			if ([currentAnswerString.lowercaseString containsString:question.triggerAnswer.lowercaseString]) {
				NSLog(@"Trigger!");
				question.multipleColumnShouldShowQuestion = YES;
			} else {
				question.multipleColumnShouldShowQuestion = NO;
			}
			
//			if ([self.delegate respondsToSelector:@selector(reloadQuestions)]) {
//				[self.delegate reloadQuestions];
//			}
		}
		
		
		
		
		if (!submitted) {
			NSLog(@"Couldn't find a key to submit with, so we're going with submitting using the question itself");
			[[PQSReferenceManager sharedReferenceManager] submitAnswer:answerString forQuestion:question];
		}
	} else if ([sender isKindOfClass:[UISwitch class]]) {
		
	} else if ([sender isKindOfClass:[UIButton class]]) {
		
	}
	
}




@end
