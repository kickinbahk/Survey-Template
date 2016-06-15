//
//  PQSQuestion.m
//  Philips Questionaire
//
//  Created by HAI on 5/8/15.
//  Copyright (c) 2015 HAI. All rights reserved.
//

#import "PQSQuestion.h"
#import "UIFont+AppFonts.h"

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kStatusBarHeight (([[UIApplication sharedApplication] statusBarFrame].size.height == 20.0f) ? 20.0f : (([[UIApplication sharedApplication] statusBarFrame].size.height == 40.0f) ? 20.0f : 0.0f))
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#define SHORTER_SIDE ((kScreenWidth < kScreenHeight) ? kScreenWidth : kScreenHeight)
#define LONGER_SIDE ((kScreenWidth > kScreenHeight) ? kScreenWidth : kScreenHeight)

@implementation PQSQuestion {
	UISegmentedControl *_segmentedControl;
}

- (instancetype)init {
	self = [super init];
	
	if (self) {
		self.possibleAnswers = [[NSMutableArray alloc] init];
		self.attributedPossibleAnswers = [[NSMutableArray alloc] init];
		self.multipleRadioButtonQuestions = [[NSMutableArray alloc] init];
		self.scaleLabels = [[NSMutableArray alloc] init];
		self.urlKeys = [[NSMutableDictionary alloc] init];
		self.subQuestions = [NSMutableArray new];
	}
	
	return self;
}

- (CGFloat)estimatedHeightForQuestionView {
	CGFloat height = 0.0f;
	
	if (self.questionType == PQSQuestionTypeRadioButtons) {
		[self testMultipleRadioSize];
	}
	
	switch (self.questionType) {
		  case PQSQuestionTypeScale:
			if (self.scaleLabels.count > 0) {
				height += 44.0f; // magic number from Apple
			}
			
			if (self.showScaleValues) {
				height += 44.0f; // magic number from Apple
			}
			
			break;
			
		case PQSQuestionTypeMultipleChoice:
			height += self.possibleAnswers.count * 44.0f; // magic number from Apple
			break;
			
		case PQSQuestionTypeTrueFalse:
			height += 2.0f * 44.0f; // magic number from Apple
			break;
			
		case PQSQuestionType2WayExclusivityRadioButtons:
			height += 28.0f * self.possibleAnswers.count;
			break;
			
		case PQSQuestionTypeLongList:
			height -= 20.0f; // I don't know why, but this just looks right. magic
			break;
			
		case PQSQuestionTypeSplitPercentage:
			height += self.possibleAnswers.count * 70.0f; // magic number from Apple
			break;
			
		case PQSQuestionTypeCheckBoxes:
			height += 38.0f * self.possibleAnswers.count;
			break;
			
		case PQSQuestionTypeMultipleRadios:
			height += 39.0f * self.multipleRadioButtonQuestions.count;
			break;
			
		  default:
			break;
	}
	
	UIWindow *window = [UIApplication sharedApplication].keyWindow;
	UIViewController *rootViewController = window.rootViewController;

	CGRect frame = CGRectMake(0.0f, 0.0f, rootViewController.view.frame.size.width - 140.0f, 88.0f);
	
	if (self.attributedQuestion) {
		frame = [self.attributedQuestion boundingRectWithSize:frame.size
															   options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesDeviceMetrics|NSStringDrawingUsesFontLeading
															   context:nil];
	} else {
		frame = [self.question boundingRectWithSize:frame.size
											options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesDeviceMetrics|NSStringDrawingUsesFontLeading
										 attributes:@{ NSFontAttributeName:[UIFont appFont]}
											context:nil];
	}
	
	if (self.headerType != PQSHeaderTypeNone) {
		frame.size.height += 33.0f;
	}
	
	float addedBufferHeight = 0.0f;
	
	if (frame.size.height > 24.0f) {
		addedBufferHeight = 24.0f;
	}
	
	while ((int)frame.size.height % 11 != 0 || frame.size.height <= 44) {
		frame.size.height = (int)frame.size.height + 1;
	}
	
	if (self.trueFalseConditionalHasAnswer) {
		if (self.trueFalseConditionalAnswer) {
			height += self.trueConditionalQuestion.estimatedHeightForQuestionView;
			
			if (self.trueConditionalQuestion2) {
				height += 100.0f;
			}
		} else {
			height += self.falseConditionalQuestion.estimatedHeightForQuestionView;
			
			if (self.falseConditionalQuestion2) {
				height += 100.0f;
			}
		}
		
		addedBufferHeight += 10.0f;
	}
	
	if (self.multipleColumnShouldShowQuestion && self.triggerQuestion) {
		height += self.triggerQuestion.estimatedHeightForQuestionView;
	}
	
	if (self.triggerQuestion) {
		if (self.multipleColumnQuestions.count > 0) {
			NSLog(@"triggerQuestions: %@", self.multipleColumnQuestions);
		} else {
			NSLog(@"triggerQuestion: %@", self.question);
		}
	}
	
	if (kScreenHeight == 1024.0f && kScreenWidth == 768.0f) {
		PQSQuestion *question = self.multipleColumnQuestions.firstObject;
		height += question.estimatedHeightForQuestionView;
	}
	
	if (self.headerType != PQSHeaderTypeNone) {
		
	} else {
		NSInteger numberOfLines, index, stringLength = [self.question length];
		for (index = 0, numberOfLines = 0; index < stringLength; numberOfLines++) {
			index = NSMaxRange([self.question lineRangeForRange:NSMakeRange(index, 0)]);
		}
		
		if (numberOfLines > 2) {
			frame.size.height = 32.0f * numberOfLines;
		}
	}

	frame.size.height += addedBufferHeight;
	
	height += frame.size.height; // estimating the height of the question label, probably not accurate
	
	if (self.headerType == PQSHeaderTypePlain) {
		height += 24.0f;
	}
	
	/* this needs fixing because it's currently kind of useless
	if (self.fixedWidth > 0) {
		frame.size.width = self.fixedWidth;
	} else if (self.maximumWidth > 0 && self.maximumWidth < frame.size.width) {
		frame.size.width = self.maximumWidth;
	} else if (self.minimumWidth > 0 && self.minimumWidth > frame.size.width) {
		frame.size.width = self.minimumWidth;
	}
	 */
	
	if (self.fixedHeight > 0) {
		height = self.fixedHeight;
	} else if (self.maximumHeight > 0 && self.maximumHeight < height) {
		height = self.maximumHeight;
	} else if (self.minimumHeight > 0 && self.minimumHeight > height) {
		height = self.minimumHeight;
	}
	
	return height;
}

- (void)testMultipleRadioSize {
	if (!_segmentedControl) {
		_segmentedControl = [[UISegmentedControl alloc] initWithItems:self.possibleAnswers];
	}
	
	if (_segmentedControl.frame.size.width > LONGER_SIDE) {
		self.questionType = PQSQuestionTypeMultipleChoice;
		return;
	}
	
}






#pragma mark - Convenience initializers

+ (instancetype)multipleChoiceQuestion {
    PQSQuestion *question = PQSQuestion.new;
    
    question.questionType = PQSQuestionTypeMultipleChoice;
    
    return question;
}

@end
