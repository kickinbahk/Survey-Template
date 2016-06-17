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
 *  Subquestions for each column of a `PQSQuestionMultipleColumnConditional`.
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



/**
 *  Changes the font for the given input to be bold. Compounds with underlining but NOT italicizing.
 *
 *  @param text Text to be bolded.
 *
 *  @return Returns NO if text is not found in the question.
 */
- (BOOL)boldText:(NSString *)text;

/**
 *  Changes the font for the given inputs to bold. Compounds with underlining but NOT italicizing.
 *
 *  @param texts Array of strings to be bolded.
 *
 *  @return Returns YES iff all texts are found in the question.
 */
- (BOOL)boldTexts:(NSArray *)texts;

/**
 *  Changes the font to an italicized font.
 *
 *  @param text Text to be italicized.
 *
 *  @return Returns NO if text is not found in the question.
 */
- (BOOL)italicizeText:(NSString *)text;

/**
 *  Changes the font to an italicized font.
 *
 *  @param texts Array of strings to be italicized
 *
 *  @return Returns YES iff all texts are found in the question.
 */
- (BOOL)italicizeTexts:(NSArray *)texts;


/**
 *  Underlines the text for the given input. Compounds with other text attributes.
 *
 *  @param text Text to be underlined.
 *
 *  @return Returns NO if text is not found in the question.
 */
- (BOOL)underlineText:(NSString *)text;

/**
 *  Underlins the text for the given inputs
 *
 *  @param texts Array of texts to be underlined.
 *
 *  @return Returns YES iff all texts are found in the question.
 */
- (BOOL)underlineTexts:(NSArray *)texts;


/**
 *  Adds the given text to the end of the question in a slightly smaller and italicized font.
 *
 *  @discussion Useful or adding an "(Optional)" tag to the end of a question as well as for denoting that there is a relevant footnote.
 *
 *  @param text Text to be appended to the end of the question.
 */
- (void)appendAndItalicizedText:(NSString *)text;



/**
 *  Changes the font of the given input to a bold and italic font. Compounds with underlining.
 *
 *  @param text Text to be bolded and italicized.
 *
 *  @return Returns NO if text is not found in the question.
 */
- (BOOL)boldAndItalicizeText:(NSString *)text;

/**
 *  Changes the font of the given inputs to a bold and italic font. Compounds with underlining.
 *
 *  @param texts Array of texts to be bolded and italicized.
 *
 *  @return Returns YES iff all texts are found in the question.
 */
- (BOOL)boldAndItalicizeTexts:(NSArray *)texts;


/**
 *  Changes the font of the given input to a bold font and adds an underline. Overwrites italics.
 *
 *  @param text Text to be bolded and underlined.
 *
 *  @return Returns NO if the text is not found in the question.
 */
- (BOOL)boldAndUnderlineText:(NSString *)text;

/**
 *  Changes the font of the given inputs to a bold font and adds an underline. Overwrites italics.
 *
 *  @param texts Array of texts to be bolded and underlined.
 *
 *  @return Returns YES iff all texts are found in the question.
 */
- (BOOL)boldAndUnderlineTexts:(NSArray *)texts;


/**
 *  Changes the font of the given input to an italic font and adds an underline. Overwrites bold font.
 *
 *  @param text Text to be italicized and underlined.
 *
 *  @return Returns NO if the text is not found in the question.
 */
- (BOOL)underlineAndItalicizeText:(NSString *)text;

/**
 *  Changes the font of the given inputs to an italic font and adds an underline. Overwrites bold font.
 *
 *  @param texts Array of texts to be italicized and underlined.
 *
 *  @return Returns YES iff all texts are found in the question.
 */
- (BOOL)underlineAndItalicizeTexts:(NSArray *)texts;


/**
 *  Changes the font of the given input to a bold and italic font and adds an underline.
 *
 *  @param text Text to be bolded, underlined, and italicized.
 *
 *  @return Returns NO if the text is not found in the question.
 */
- (BOOL)boldUnderlineAndItalicizeText:(NSString *)text;

/**
 *  Changes the font of the given inputs to a bold and italic font and adds an underline.
 *
 *  @param texts Array of texts to be bolded, underlined, and italicized.
 *
 *  @return Returns YES iff all texts are found in the question.
 */
- (BOOL)boldUnderlineAndItalicizeTexts:(NSArray *)texts;


/**
 *  Changes the font of the string up to (but not including) the first location of the given text to a bold font.
 *
 *  @param demarcationString The string that will not be bolded but all text prior to it will be bolded. If the string is not found, the entire question will be bolded.
 *
 *  @return Returns NO if the text is not found in the question.
 */
- (BOOL)boldTextUntilString:(NSString *)demarcationString;

/**
 *  Changes the font of the string after (not including) the first location of the given text to a bold font.
 *
 *  @param demarcationString The string that will not be bolded but all text after it will be bolded. If the string is not found, the question is left alone.
 *
 *  @return Returns NO if the text is not found in the question.
 */
- (BOOL)boldTextAfterString:(NSString *)demarcationString;




/**
 *  Question with a clear background.
 *  
 *  Useful for spacing out questions.
 */
+ (instancetype)blankQuestion;

/**
 *  Question with a clear background and the given, fixed height.
 *
 *  @param height The fixed height of the question in points. This is not dynamically set for different size devices. (though it could easily be added as a feature)
 *
 *  @return Initialized question with a clear background and a fixed height.
 */
+ (instancetype)blankQuestionWithHeight:(CGFloat)height;

/**
 *  Question with a list of UISwitches to select multiple options.
 *
 *  Multiple possibleAnswers must be added to make use of this question type.
 *
 *  @return Initialized question with question type set.
 */
+ (instancetype)checkBoxesQuestion;

/**
 *  Question with a UIPicker (as an input view) to select the date.
 *
 *  @return Initialized question with question type set.
 */
+ (instancetype)dateQuestion;

/**
 *  Question with a UIStepper.
 *
 *  Useful for precise but small numbers. Can use negative values as well as positive. Responds to starting value.
 *
 *  @return Initialized question with question type set. 
 */
+ (instancetype)incrementalQuestion;

/**
 *  Question with a text input that pulls up a number pad to input large numbers. 
 *
 *  Useful for precise inputs when the numbers would be out of a reasonable range for incrementing or for when a slider is not precise enough.
 *
 *  @return Initizlied question with question type set.
 */
+ (instancetype)largeNumberQuestion;

/**
 *  Question that pops up a `UIAlertController` `AlertView` with the possible answers (plus `Cancel`) as buttons.
 *
 *  Useful when a multiple choice question will fill up the entire screen.
 *  
 *  Requires `possibleAnswers` to be populated with options.
 *
 *  @return Initizlied question with question type set.
 */
+ (instancetype)longListQuestion;

/**
 *  Question that allows for multiple questions to be positioned horizontally within one cell. The conditional nature allows for an additional question to be shown beneath any of the questions. Refer to the example question for how to setup.
 *
 *  @return Initialized question with question type set.
 */
+ (instancetype)multiColumnConditionalQuestion;

/**
 *  Question that allows for displaying several options with longer text.
 *
 *  @discussion Displayed in a `UITableView`, a user trying to scroll by touching on the multiple choice options will be met with no interaction. This isn't a good user experience. Ideally, this question could use a normal `UIView` instead of a table to display the possible answers.
 *
 *  @return Initialized question with question type set.
 */
+ (instancetype)multipleChoiceQuestion;

/**
 *  Question that shows a `UISegmentedControl` with numbers from `minimumScale` to `maximumScale` in `scaleInterval` steps.
 *
 *  Useful for hedonic scales.
 *
 *  @return Initialized question with question type, minimum scale, maximum scale, and scale interval set.
 */
+ (instancetype)oneToTenQuestion;

/**
 *  Question that shows a `UISlider` for selecting a percentage from 0-100.
 *
 *  Default `scaleInterval` is 5%. While not incredibly precise, this drastically speeds up the speed at which a user can complete the survey.
 *
 *  @return Initialized question with question type and `scaleInterval` set.
 */
+ (instancetype)percentageQuestion;

/**
 *  Question that shows a `UISegmentedControl` to show several options to the user. Similar to a multiple choice question, this option is useful for short texts.
 *
 *  Dynamically changes to multiple choice question when the `UISegmentedControl` would be too wide for the screen.
 *
 *  @return Initialized question with question type set.
 */
+ (instancetype)radioButtonsQuestion;

/**
 *  Question that shows a `UISlider` (with labels) for selecting a number in a range.
 *
 *  @return Initialized question with question type set.
 */
+ (instancetype)scaleQuestion;

/**
 *  Question with multiple `UISlider`s that never add up to more than 100%. SLider totals can add up to <100%, but *never* more.
 *
 *  Must add to `possibleAnswers` to show sliders.
 *
 *  @return Initialized question with question type set.
 */
+ (instancetype)splitPercentageQuestion;

/**
 *  Question that displays a `UIAlertController` `AlertView` with a `UITextField` inside for short answers. Pressing `return` will dismiss the view.
 *
 *  While the textField will allow for an unlimited amount of text, there is no dynamic resizing. Anything longer than a tweet will seem unnecessarily difficult.
 *
 *  @return Initialized question with question type set.
 */
+ (instancetype)textFieldQuestion;

/**
 *  Question that displays a popup with a `UITextView` inside for longer text answers. Pressing `return` will NOT dismiss the view.
 *
 *  @return Initialized question with question type set.
 */
+ (instancetype)textViewQuestion;

/**
 *  Question with a UIPicker (as an input view) to select a time.
 *
 *  @discussion A time of 0 minutes is not a possible answer. Changing the `scaleInterval` (default is 5) helps clarify when this type of question is unanswered.
 *
 *  @return Initialized question with question type, `scaleInterval`, and `scaleSuffix` set.
 */
+ (instancetype)timeQuestion;

/**
 *  Question with a `UISegmentedControl` for a simple True/False answer.
 *
 *  @return Initialized question with question type set.
 */
+ (instancetype)trueFalseQuestion;

/**
 *  Question with a `UISegmentedControl` for a True/False answer. Once answered, this question will allow for up to one follow up question for each answer that is dynamically displayed.
 *
 *  @return Initialized question with question type set.
 */
+ (instancetype)trueFalseConditionalQuestion;

/**
 *  Question with a `UISegmentedControl` for a True/False answer. Once answered, this question will allow for up to two follow up questions for each answer that are dynamically displayed.
 *
 *  @return Initialized question with question type set.
 */
+ (instancetype)trueFalseConditional2Question;

/**
 *  Question with a grid of `UISegmentedControl`s to allow for selecting a ranking of the given inputs.
 *
 *  Must add to `possibleAnswers` to show multiple rows.
 *
 *  Default range is 1, 2, 3
 *
 *  @return Initialized question with question type, `minimumScale`, and `maximumScale` set.
 */
+ (instancetype)twoWayExclusivityQuestion;

/**
 *  Question with a list of countries for the user to select from.
 *
 *  @discussion Because this list contains a superset of all countries (as of 6/2016), "Which" is correct and "What" is incorrect.
 *
 *  @return Fully initialized question.
 */
+ (instancetype)whichCountryQuestion;

/**
 *  Question with a `UISegmentedControl` for a simple Yes/No answer.
 *
 *  @return Initialized question with question type and `useYesNoForTrueFalse` set.
 */
+ (instancetype)yesNoQuestion;

/**
 *  Question with a `UISegmentedControl` for a simple Yes/No answer. Once answered, this question will allow for up to one follow up question for each answer that is dynamically displayed.
 *
 *  @return Initialized question with question type and `useYesNoForTrueFalse` set.
 */
+ (instancetype)yesNoConditionalQuestion;

/**
 *  Question with a `UISegmentedControl` for a simple Yes/No answer. Once answered, this question will allow for up to two follow up questions for each answer that are dynamically displayed.
 *
 *  @return Initialized question with question type and `useYesNoForTrueFalse` set.
 */
+ (instancetype)yesNoConditional2Question;

+ (instancetype)detailHeader;
+ (instancetype)finePrintHeader;
+ (instancetype)plainHeader;
+ (instancetype)subHeader;

@end
