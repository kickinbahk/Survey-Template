//
//  PQSQuestionView.m
//  Philips Questionaire
//
//  Created by HAI on 5/8/15.
//  Copyright (c) 2015 HAI. All rights reserved.
//

#import "PQSQuestionView.h"

#import "UIColor+AppColors.h"
#import "UIFont+AppFonts.h"

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kStatusBarHeight (([[UIApplication sharedApplication] statusBarFrame].size.height == 20.0f) ? 20.0f : (([[UIApplication sharedApplication] statusBarFrame].size.height == 40.0f) ? 20.0f : 0.0f))
#define kScreenHeight (([[UIApplication sharedApplication] statusBarFrame].size.height > 20.0f) ? [UIScreen mainScreen].bounds.size.height - 20.0f : [UIScreen mainScreen].bounds.size.height)

@implementation PQSQuestionView {
	float _indentation;
	CGRect _initialFrame;
}

- (instancetype)init {
	self = [super init];
	
	if (self) {
		
	}
	
	return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
	frame.size.width = kScreenWidth - 150.0f - frame.origin.x;
	self = [super initWithFrame:frame];
	
	if (self) {
		_indentation = 25.0f;
		self.backgroundColor = [UIColor clearColor];
	}
	
	return self;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	
	if (self.question.headerType == PQSHeaderTypePlain) {
		[self addSubview:self.backgroundView];
		CGRect frame = self.bounds;
		frame.origin.y -= 10.0f;
		frame.size.height += 10.0f;
		self.backgroundView.frame = frame;
	}
	
	[self addSubview:self.questionLabel];
	self.questionLabel.frame = [self questionLabelFrame];
	[self.superview addSubview:self.answerView];
	self.answerView.frame = [self answerViewFrame];
	[self.answerView layoutSubviews];
	[self addSubview:self.numberLabel];
	
	if (self.numberLabel.text.length == 0) {
		// comment out to remove question numbers entirely
//		self.numberLabel.text = [NSString stringWithFormat:@"%zd.", self.questionNumber];
	}
	
	for (NSObject *key in self.conditionalQuestionViewDictionary.allKeys) {
		UIView *conditionalQuestionView = [self.conditionalQuestionViewDictionary objectForKey:key];
		[conditionalQuestionView removeFromSuperview];
	}
	
	for (NSObject *key in self.conditionalAnswerViewDictionary.allKeys) {
		UIView *conditionalAnswerView = [self.conditionalAnswerViewDictionary objectForKey:key];
		[conditionalAnswerView removeFromSuperview];
	}
	
	if (self.question.trueFalseConditionalHasAnswer && self.question.questionType == PQSQuestionTypeTrueFalseConditional) {
		if (!self.conditionalQuestionViewDictionary) {
			self.conditionalQuestionViewDictionary	= [[NSMutableDictionary alloc] initWithCapacity:2];
			self.conditionalAnswerViewDictionary	= [[NSMutableDictionary alloc] initWithCapacity:2];
		}
		
		if (self.question.trueFalseConditionalAnswer) {
			if ([self.conditionalQuestionViewDictionary objectForKey:@"TRUE"]) {
				PQSAnswerView *conditionalAnswerView = [self.conditionalAnswerViewDictionary objectForKey:@"TRUE"];
				[self.superview insertSubview:conditionalAnswerView aboveSubview:self.answerView];
				conditionalAnswerView.frame = [self secondaryAnswerViewFrame];
				
				UILabel *conditionalQuestionLabel = [self.conditionalQuestionViewDictionary objectForKey:@"TRUE"];
				[self.superview insertSubview:conditionalQuestionLabel aboveSubview:self.answerView];
				conditionalQuestionLabel.frame = [self secondaryQuestionViewFrame];
			} else {
				PQSAnswerView *conditionalAnswerView = [[PQSAnswerView alloc] initWithFrame:[self secondaryAnswerViewFrame] question:self.question.trueConditionalQuestion];
				[conditionalAnswerView layoutSubviews];
				conditionalAnswerView.delegate = self;
				[self.conditionalAnswerViewDictionary setObject:conditionalAnswerView forKey:@"TRUE"];
				conditionalAnswerView.userInteractionEnabled = YES;
				[self.superview insertSubview:conditionalAnswerView aboveSubview:self.answerView];
				
				UILabel *conditionalQuestionLabel = [[UILabel alloc] initWithFrame:[self secondaryQuestionViewFrame]];
				conditionalQuestionLabel.numberOfLines = 0;
				conditionalQuestionLabel.lineBreakMode = NSLineBreakByWordWrapping;
				
				if (self.question.trueConditionalQuestion.attributedQuestion) {
					conditionalQuestionLabel.attributedText = self.question.trueConditionalQuestion.attributedQuestion;
				} else {
					conditionalQuestionLabel.text = self.question.trueConditionalQuestion.question;
				}
				
				[self.superview insertSubview:conditionalQuestionLabel aboveSubview:self.answerView];
				[self.conditionalQuestionViewDictionary setObject:conditionalQuestionLabel forKey:@"TRUE"];
			}
		} else {
			if ([self.conditionalQuestionViewDictionary objectForKey:@"FALSE"]) {
				PQSAnswerView *conditionalAnswerView = [self.conditionalAnswerViewDictionary objectForKey:@"FALSE"];
				[self.superview insertSubview:conditionalAnswerView aboveSubview:self.answerView];
				conditionalAnswerView.frame = [self secondaryAnswerViewFrame];
				
				UILabel *conditionalQuestionLabel = [self.conditionalQuestionViewDictionary objectForKey:@"FALSE"];
				[self.superview insertSubview:conditionalQuestionLabel aboveSubview:self.answerView];
				conditionalQuestionLabel.frame = [self secondaryQuestionViewFrame];
			} else {
				PQSAnswerView *conditionalAnswerView = [[PQSAnswerView alloc] initWithFrame:[self secondaryAnswerViewFrame] question:self.question.falseConditionalQuestion];
				[conditionalAnswerView layoutSubviews];
				conditionalAnswerView.delegate = self;
				[self.conditionalAnswerViewDictionary setObject:conditionalAnswerView forKey:@"FALSE"];
				conditionalAnswerView.userInteractionEnabled = YES;
				[self.superview insertSubview:conditionalAnswerView aboveSubview:self.answerView];
				
				UILabel *conditionalQuestionLabel = [[UILabel alloc] initWithFrame:[self secondaryQuestionViewFrame]];
				conditionalQuestionLabel.numberOfLines = 0;
				conditionalQuestionLabel.lineBreakMode = NSLineBreakByWordWrapping;
				if (self.question.falseConditionalQuestion.attributedQuestion) {
					conditionalQuestionLabel.attributedText = self.question.falseConditionalQuestion.attributedQuestion;
				} else {
					conditionalQuestionLabel.text = self.question.falseConditionalQuestion.question;
				}
				[self.superview insertSubview:conditionalQuestionLabel aboveSubview:self.answerView];
				[self.conditionalQuestionViewDictionary setObject:conditionalQuestionLabel forKey:@"FALSE"];
			}
		}
	}
	
	if (self.question.questionType == PQSQuestionTypeMultiColumnConditional) {
		self.answerView.frame = CGRectOffset(self.bounds, 0.0f, 22.0f);
	} else {
		self.answerView.frame = _initialFrame;
	}
}

- (UILabel *)questionLabel {
	if (!_questionLabel) {
		CGRect frame = [self questionLabelFrame];
		if (self.question.questionType == PQSQuestionTypeMultipleChoice) {
			frame.origin.y += 22.0f;
		}
		
		_questionLabel = [[UILabel alloc] initWithFrame:frame];

		if (self.question.questionType == PQSQuestionTypeNone) {
			if (self.question.headerType == PQSHeaderTypePlain) {
				[_questionLabel setFont:[UIFont appFontOfSize:32.0f]];
				frame.origin.y = 22.0f;
				_questionLabel.frame = frame;
				_questionLabel.adjustsFontSizeToFitWidth = YES;
				_questionLabel.numberOfLines = 1;
			} else if (self.question.headerType == PQSHeaderTypeSub) {
				[_questionLabel setFont:[UIFont appFontOfSize:26.0f]];
				frame.origin.y = 24.0f;
				_questionLabel.frame = frame;
				_questionLabel.adjustsFontSizeToFitWidth = YES;
			} else if (self.question.headerType == PQSHeaderTypeDetail) {
				[_questionLabel setFont:[UIFont appFontOfSize:22.0f]];
				frame.origin.y = 100.0f;
				_questionLabel.frame = frame;
				_questionLabel.adjustsFontSizeToFitWidth = YES;
			} else if (self.question.headerType == PQSHeaderTypeFinePrint) {
				[_questionLabel setFont:[UIFont appFontOfSize:12.0f]];
				frame.origin.y = 25.0f;
				_questionLabel.frame = frame;
				_questionLabel.adjustsFontSizeToFitWidth = YES;
			}
		} else {
			[_questionLabel setFont:[UIFont appFont]];
		}
		
		_questionLabel.textAlignment = NSTextAlignmentLeft;
		_questionLabel.numberOfLines = 0; // unlimited number of lines
//		_questionLabel.adjustsFontSizeToFitWidth = YES;
		
		if (self.question.attributedQuestion) {
			NSMutableAttributedString *questionAttributedString = [[NSMutableAttributedString alloc] initWithAttributedString:self.question.attributedQuestion];
			
			[questionAttributedString addAttribute:NSForegroundColorAttributeName value:[UIColor appColor1] range:NSMakeRange(0, self.question.attributedQuestion.string.length)];
			
			_questionLabel.attributedText = questionAttributedString;
		} else {
			_questionLabel.textColor = [UIColor appColor1];
			_questionLabel.text = self.question.question;
		}
		
	}
	
	return _questionLabel;
}

/**
 *
 *  @return The frame for the question label.
 */
- (CGRect)questionLabelFrame {
	CGRect frame = CGRectZero;
	
	if (self.question.attributedQuestion) {
		frame = [self.question.attributedQuestion boundingRectWithSize:frame.size
															   options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesDeviceMetrics|NSStringDrawingUsesFontLeading
															   context:nil];
	} else {
		frame = [self.question.question boundingRectWithSize:frame.size
													 options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesDeviceMetrics|NSStringDrawingUsesFontLeading
												  attributes:@{ NSFontAttributeName:[UIFont appFont]}
													 context:nil];
	}
	
	if (self.question.headerType != PQSHeaderTypeNone) {
		frame.size.height += 33.0f;
		frame.origin.y += 12.0f;
	}
	
	float addedBufferHeight = 0.0f;
	
	if (frame.size.height > 24.0f) {
		addedBufferHeight = 24.0f;
	}
	
	while ((int)frame.size.height % 11 != 0 || frame.size.height <= 33) {
		frame.size.height = (int)frame.size.height + 1;
	}
	
	frame.size.height += addedBufferHeight;
	
	frame.size.width = self.frame.size.width;
	
	if (self.question.questionType == PQSQuestionTypeMultiColumnConditional) {
		frame.size.width *= 0.25f;
		frame.origin.y += 11.0f;
		
		CGRect textFrame =  [self.question.attributedQuestion boundingRectWithSize:CGSizeMake(frame.size.width, CGFLOAT_MAX)
																		   options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesDeviceMetrics|NSStringDrawingUsesFontLeading
																		   context:nil];
		frame.size.height = textFrame.size.height;
	}
	
	if (self.question.headerType == PQSHeaderTypeDetail) {
		frame.origin.y += 20.0f;
	}
	
	return frame;
}

- (UILabel *)numberLabel {
	if (!_numberLabel) {
		_numberLabel = [[UILabel alloc] initWithFrame:CGRectMake(-30.0f, 0.0f, 30.0f, 44.0f)];
		[_numberLabel setFont:[UIFont appFont]];
		_numberLabel.adjustsFontSizeToFitWidth = YES;
		_numberLabel.textAlignment = NSTextAlignmentLeft; // right alignment might look better but left alignment will look better if there are many questions with varying numbers of digits in the question numbers
	}
	
	return _numberLabel;
}

- (PQSAnswerView *)answerView {
	if (!_answerView) {
		_answerView = [[PQSAnswerView alloc] initWithFrame:[self answerViewFrame]
												  question:self.question];
		[_answerView layoutSubviews];
		_answerView.delegate = self;
	}
	
	return _answerView;
}

- (CGRect)answerViewFrame {
	CGRect frame = self.bounds;
	
	frame.origin = CGPointMake(_indentation, [self questionLabelFrame].size.height);
	frame.size.width = frame.size.width - _indentation * 2.0f;
	
	if (frame.size.height < 44.0f && self.question.questionType != PQSQuestionTypeLongList && self.question.questionType != PQSQuestionTypeNone) {
		frame.size.height = 44.0f;
	}
	
	_initialFrame = frame;
	
	if (self.question.trueFalseConditionalHasAnswer) {
		if (self.question.trueFalseConditionalAnswer) {
			frame.size.height += self.question.trueConditionalQuestion.estimatedHeightForQuestionView;
		} else {
			frame.size.height += self.question.falseConditionalQuestion.estimatedHeightForQuestionView;
		}
	}
	
	if (self.question.questionType == PQSQuestionTypeMultiColumnConditional && self.question.multipleColumnShouldShowQuestion) {
		frame.size.height += 66.0f;
	}
	
	
	return frame;
}

- (CGRect)secondaryQuestionViewFrame {
	CGRect frame = self.bounds;
	
	frame.size.width -= 40.0f;
	frame.origin.x += 20.0f;
	
	frame.origin.y = self.answerView.frame.origin.y;
	frame = CGRectStandardize(frame);

	if (self.question.trueFalseConditionalHasAnswer) {
		PQSQuestion *secondaryQuestion;
		if (self.question.trueFalseConditionalAnswer) {
			secondaryQuestion = self.question.trueConditionalQuestion;
		} else {
			secondaryQuestion = self.question.falseConditionalQuestion;
		}
		
		CGRect questionFrame = CGRectZero;
		if (secondaryQuestion.attributedQuestion) {
			questionFrame = [secondaryQuestion.attributedQuestion boundingRectWithSize:frame.size
																			   options:NSStringDrawingUsesLineFragmentOrigin
																			   context:nil];
		} else if (secondaryQuestion.question) {
			questionFrame = [secondaryQuestion.question boundingRectWithSize:frame.size
																	 options:NSStringDrawingUsesLineFragmentOrigin
																  attributes:@{NSFontAttributeName : [UIFont appFont]}
																	 context:nil];
		}
		
		frame.size.height = questionFrame.size.height;
	}
	
	frame.origin.y += 44.0f;
	
	return frame;
}

- (CGRect)secondaryAnswerViewFrame {
	CGRect frame = self.bounds;
	
	frame.size.width -= 40.0f;
	frame.origin.x += 20.0f;
	
	self.answerView.frame = CGRectStandardize(self.answerView.frame);
	self.questionLabel.frame = CGRectStandardize(self.questionLabel.frame);
	
	CGRect secondaryFrame = [self secondaryQuestionViewFrame];
	frame.origin.y = secondaryFrame.origin.y + secondaryFrame.size.height;
	
	return frame;
}

- (UIView *)backgroundView {
	if (!_backgroundView) {
		if (self.question.headerType == PQSHeaderTypePlain) {
			_backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"headerBackground"]];
			_backgroundView.contentMode = UIViewContentModeScaleToFill;
		}
	}
	
	return _backgroundView;
}

#pragma mark - Answer View Delegate

- (void)answerSelected:(NSString *)answer question:(PQSQuestion *)question {
	if ([self.delegate respondsToSelector:@selector(answerSelected:question:)]) {
		[self.delegate answerSelected:answer question:question];
	}
}

- (void)displayAlertController:(UIAlertController *)alertController {
	if ([self.delegate respondsToSelector:@selector(displayAlertController:)]) {
		if (alertController) {
			[self.delegate displayAlertController:alertController];
		} else {
			NSLog(@"We're somewhere in the middle and missing the question.");
		}
	}
}

- (void)presentTextInputView:(PQSTextInputView *)textInputView {
	if ([self.delegate respondsToSelector:@selector(presentTextInputView:)]) {
		[self.delegate presentTextInputView:textInputView];
	} else {
		NSLog(@"PQSQuestionView responds to presentTextInputView but ViewController does not");
	}
}

- (void)reloadQuestions {
	if ([self.delegate respondsToSelector:@selector(reloadQuestions)]) {
		[self.delegate reloadQuestions];
	}
}

@end
