//
//  PQSQuestion.h
//  Philips Questionaire
//
//  Created by HAI on 5/8/15.
//  Copyright (c) 2015 HAI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, PQSQuestionType) {
	PQSQuestionTypeNone,
	PQSQuestionTypeMultipleChoice,
	PQSQuestionTypeScale,
	PQSQuestionTypeTrueFalse,
	PQSQuestionTypeRadioButtons,
	PQSQuestionTypeLongList,
	PQSQuestionType2WayExclusivityRadioButtons,
	PQSQuestionTypeIncrementalValue,
	PQSQuestionTypePercentage,
	PQSQuestionTypeSplitPercentage,
	PQSQuestionTypeMultipleRadios,
	PQSQuestionTypeCheckBoxes,
	PQSQuestionTypeTrueFalseConditional,
	PQSQuestionTypeTrueFalseConditional2,
	PQSQuestionTypeTextField,
	PQSQuestionTypeTextView,
	PQSQuestionTypeMultiColumnConditional,
	PQSQuestionTypeDate,
	PQSQuestionTypeTime,
	PQSQuestionTypeLargeNumber,
    PQSQuestionType1to10,
    PQSQuestionWhichCountry
};

typedef NS_ENUM(NSUInteger, PQSHeaderType) {
	PQSHeaderTypeNone,
	PQSHeaderTypePlain,
	PQSHeaderTypeSub,
	PQSHeaderTypeDetail,
	PQSHeaderTypeFinePrint
};

typedef NS_ENUM(NSUInteger, PQSQuestionViewPreferredBackgroundTone) {
	PQSQuestionViewPreferredBackgroundToneNone,
	PQSQuestionViewPreferredBackgroundToneLight,
	PQSQuestionViewPreferredBackgroundToneDark
};

@interface PQSQuestion : NSObject

/**
 *  The question Type. Current options are: Multiple Choice, Scale, True/False
 */
@property (nonatomic) PQSQuestionType questionType;

/**
 *  If the question type is set to PQSQuestionTypeNone then the header type can be set to simply add text without adding a question or user interaction at all
 */
@property (nonatomic) PQSHeaderType headerType;

/**
 *  The number this question is in the order of questions.
 */
@property (nonatomic) int questionNumber;


/**
 *  Text of question to present to user. Should be in English and rely on Localization for translating.
 */
@property (nonatomic, strong) NSAttributedString *attributedQuestion;
@property (nonatomic, strong) NSString *question;








// The following properties are for Interval and Scale Questions using UISlider or UIStepper (but not Percentage questions)
/**
 *  Minimum value for a Scale type question.
 */
@property (nonatomic) float minimumScale;

/**
 *  Minimum value for a Scale type question.
 */
@property (nonatomic) float maximumScale;

/**
 *  Starting value for a Scale type question.
 */
@property (nonatomic) float startingPoint;

/**
 *  The Interval at which a stepper changes values.
 */
@property (nonatomic) float scaleInterval;

/**
 *  A suffix added to the end of a stepper value for display
 *
 *  @discussion This could be improved by adding a singular and plural suffix
 */
@property (nonatomic) NSString *scaleSuffix;

/**
 *  Show or hide the scale values for a scale answer;
*/
@property (nonatomic) BOOL showScaleValues;

/**
 *  An array of strings describing the scale points. Labels will be evenly divided between minimum and maximum.
 */
@property (nonatomic, strong) NSMutableArray *scaleLabels;







// The following properties are only used for Long List Type Questions
/**
 *  The text for the top of the long list popover
 */
@property (nonatomic, strong) NSString *longListTitle;

/**
 *  The text for the long list popover message
 */
@property (nonatomic, strong) NSString *longListMessage;

/**
 *  Show border around button
 */
@property BOOL hideBorder;

/**
 *  Text to hold in the place of the selected answer on the button.
 *  Default is "Please Select One"
 */
@property (nonatomic, strong) NSString *placeholderText;

/**
 *  If sticky, then the answer for this question will be remembered
 */
@property (nonatomic) BOOL isSticky;








// The following properties will appear vertically centered and to the left of all answer possibilities.
// These are most useful for radio button and scale questions

/**
 *  Text to put in front of the answer view.
 */
@property (nonatomic, strong) NSString *leftLabelText;


/**
 *  Text to put after the answer view.
 */
@property (nonatomic, strong) NSString *rightLabelText;






/**
 *  An array of strings for the text of each possible answer to a Multiple Choice question. These are also used for
 */
@property (nonatomic, strong) NSMutableArray *possibleAnswers;

/**
 *  An array of attributed strings for the text of each possible answer
 */
@property (nonatomic, strong) NSMutableArray *attributedPossibleAnswers;

/**
 *  An array of strings representing the multiple questions that can be asked for a question that has multiple radio buttons.
 */
@property (nonatomic, strong) NSMutableArray *multipleRadioButtonQuestions;


/**
 *  Subquestions for each column of the question.
 */
@property (nonatomic, strong) NSArray *multipleColumnQuestions;
@property (nonatomic) BOOL multipleColumnShouldShowQuestion;
@property (nonatomic, strong) NSString *triggerAnswer;

/**
 *  The question triggered for a multiple column conditional question when the right answer is selected
 */
@property (nonatomic, strong) PQSQuestion *triggerQuestion;

/**
 *  Whether the true/false question has been answered and should show the detail answer
 */
@property (nonatomic) BOOL trueFalseConditionalHasAnswer;

/**
 *  The answer to the true/false conditional answer
 */
@property (nonatomic) BOOL trueFalseConditionalAnswer;

/**
 *  Instead of using "True" and "False" use "Yes" and "No"
 */
@property (nonatomic) BOOL useYesNoForTrueFalse;

/**
 *  The secondary questions used for a true/false conditional question
 */
@property (nonatomic, strong) PQSQuestion *trueConditionalQuestion, *falseConditionalQuestion;
@property (nonatomic, strong) PQSQuestion *trueConditionalQuestion2, *falseConditionalQuestion2;

/**
 *  An approximation of how tall the question will be when displayed on the current screen
 *
 *  @return Estimated height of the question view
 */
- (CGFloat)estimatedHeightForQuestionView;

/**
 *  Is the question required to complete the survey.
 */
@property (nonatomic) BOOL isRequired;


/**
 *  KVP with a segment of the question text as the key and the value being what should be part of the URL (or JSON).
 *
 * @discussion The question text itself will be checked first. If that's not found in the urlKeys then the multiple choice answers will be checked and finally the multiple radio button questions. If no result is found then an error will be logged.
 */
@property (nonatomic, strong) NSMutableDictionary *urlKeys;



/**
 *  The preferred lightness of the background for the question view.
 *  Default is None
 */
@property (nonatomic) PQSQuestionViewPreferredBackgroundTone preferredBackgroundTone;


/**
 *  The date to start a date type question on
 */
@property (nonatomic, strong) NSDate *startingDate;


/**
 *  The questions that are in the header section
 */
@property (nonatomic, strong) NSMutableArray *subQuestions;


/**
 *  Fixed width and height constraints
 */
@property (nonatomic) CGFloat fixedWidth, fixedHeight;
@property (nonatomic) CGFloat minimumWidth, minimumHeight;
@property (nonatomic) CGFloat maximumWidth, maximumHeight;

/**
 *  Does the cell need to clip everything not inside of itself?
 *  Default value is NO
 */
@property BOOL clipsToBounds;




- (BOOL)boldText:(NSString *)text;
- (BOOL)boldTexts:(NSArray *)texts;

- (BOOL)italicizeText:(NSString *)text;
- (BOOL)italicizeTexts:(NSArray *)texts;

- (BOOL)underlineText:(NSString *)text;
- (BOOL)underlineTexts:(NSArray *)texts;

- (void)appendAndItalicizedText:(NSString *)text;



- (BOOL)boldAndItalicizeText:(NSString *)text;
- (BOOL)boldAndItalicizeTexts:(NSArray *)texts;

- (BOOL)boldAndUnderlineText:(NSString *)text;
- (BOOL)boldAndUnderlineTexts:(NSArray *)texts;

- (BOOL)underlineAndItalicizeText:(NSString *)text;
- (BOOL)underlineAndItalicizeTexts:(NSArray *)texts;

- (BOOL)boldUnderlineAndItalicizeText:(NSString *)text;
- (BOOL)boldUnderlineAndItalicizeTexts:(NSArray *)texts;




/**
 *  Convenience initializers
 */
+ (instancetype)blankQuestion;
+ (instancetype)blankQuestionWithHeight:(CGFloat)height;

+ (instancetype)checkBoxesQuestion;
+ (instancetype)dateQuestion;
+ (instancetype)incrementalQuestion;
+ (instancetype)largeNumberQuestion;
+ (instancetype)longListQuestion;
+ (instancetype)multiColumnConditionalQuestion;
+ (instancetype)multipleChoiceQuestion;
+ (instancetype)oneToTenQuestion;
+ (instancetype)percentageQuestion;
+ (instancetype)radioButtonsQuestion;
+ (instancetype)scaleQuestion;
+ (instancetype)splitPercentageQuestion;
+ (instancetype)textFieldQuestion;
+ (instancetype)textViewQuestion;
+ (instancetype)timeQuestion;
+ (instancetype)trueFalseQuestion;
+ (instancetype)trueFalseConditionalQuestion;
+ (instancetype)trueFalseConditional2Question;
+ (instancetype)twoWayExclusivityQuestion;
+ (instancetype)whichCountryQuestion;
+ (instancetype)yesNoQuestion;
+ (instancetype)yesNoConditionalQuestion;
+ (instancetype)yesNoConditional2Question;

+ (instancetype)detailHeader;
+ (instancetype)finePrintHeader;
+ (instancetype)plainHeader;
+ (instancetype)subHeader;

@end
