//
//  PQSQuestionList.m
//  Survey Template
//
//  Created by HAI on 6/15/16.
//  Copyright © 2016 Nathan Fennel. All rights reserved.
//

#import "PQSQuestionList.h"

#import "PQSReferenceManager.h"
#import "PQSQuestion.h"
#import "UIFont+Custom.h"
#import "UIFont+AppFonts.h"

@implementation PQSQuestionList {
    NSMutableDictionary *_countryCodeList;
    NSMutableArray *_questions;
}

- (void)setupQuestions {
    PQSQuestion *plainHeader = PQSQuestion.plainHeader;
    plainHeader.question = @"Plain Header";
    plainHeader.fixedHeight = 80.0f;
    [self addObject:plainHeader];
    
    PQSQuestion *detail0 = PQSQuestion.detailHeader;
    detail0.question = @"Header!";
    detail0.fixedHeight = 1.0f;
    detail0.clipsToBounds = YES;
    detail0.preferredBackgroundTone = PQSQuestionViewPreferredBackgroundToneLight;
    [self addObject:detail0];
    
    PQSQuestion *question3 = PQSQuestion.whichCountryQuestion;
    [self addObject:question3];
    
    
    PQSQuestion *dateQuestion = PQSQuestion.dateQuestion;
    dateQuestion.question = @"Date Question";
    [self addObject:dateQuestion];
    
    PQSQuestion *timeQuestion = PQSQuestion.timeQuestion;
    timeQuestion.question = @"Time scale question";
    timeQuestion.startingPoint = 0;
    timeQuestion.maximumScale = 180.0f;
    timeQuestion.minimumScale = 0.0f;
    timeQuestion.scaleInterval = 5.0f;
    [self addObject:timeQuestion];
    
    
    PQSQuestion *fixedHeightQuestion = PQSQuestion.yesNoQuestion;
    fixedHeightQuestion.question = @"This question is a fixed height. This is useful for layout adjustments.";
    fixedHeightQuestion.maximumHeight = 100.0f;
    [self addObject:fixedHeightQuestion];
    
    
    
    
    
    
    PQSQuestion *header1 = PQSQuestion.plainHeader;
    header1.question = @"Typing Questions";
    [self addObject:header1];
    
    
    
    PQSQuestion *textViewQuestion = PQSQuestion.textViewQuestion;
    textViewQuestion.question = @"Text VIEW Question";
    textViewQuestion.placeholderText = @"Type something long in here";
    [self addObject:textViewQuestion];
    
    PQSQuestion *textFieldQuestion = PQSQuestion.textFieldQuestion;
    textFieldQuestion.question = @"Text FIELD Question";
    textFieldQuestion.placeholderText = @"Type something shorter in here";
    [self addObject:textFieldQuestion];
    
    PQSQuestion *question0b = PQSQuestion.textFieldQuestion;
    question0b.question = @"Typing questions can have different placeholder text.";;
    question0b.placeholderText = @"This is placeholder text";
    [self addObject:question0b];
    
    PQSQuestion *stickyQuestion = PQSQuestion.textFieldQuestion;
    stickyQuestion.question = @"This question will remember your preference between submissions. This makes the question \"Sticky\"";
    stickyQuestion.placeholderText = @"Useful for names that don't change";
    stickyQuestion.isSticky = YES;
    [self addObject:stickyQuestion];
    
    
    PQSQuestion *question1 = PQSQuestion.largeNumberQuestion;
    question1.question = @"This allows typing in any number. Usefull for Large Numbers";
    [question1 boldText:@"Large Numbers"];
    question1.scaleSuffix = @"Things";
    question1.placeholderText = @"Things";
    question1.minimumScale = 0;
    question1.maximumScale = 500;
    [self addObject:question1];
    
    
    PQSQuestion *boldQuestion = PQSQuestion.incrementalQuestion;
    boldQuestion.question = @"Bolding words in a sentence. Often times, the client will want to stylize the text of the question.";
    [boldQuestion boldTexts:@[@"Bold", @"sentence"]];
    boldQuestion.scaleSuffix = @" Things";
    boldQuestion.scaleInterval = 5;
    boldQuestion.minimumScale = 0;
    boldQuestion.maximumScale = 100;
    boldQuestion.placeholderText = [NSString stringWithFormat:@"%g - %g", boldQuestion.minimumScale, boldQuestion.maximumScale];
    [self addObject:boldQuestion];
    
    PQSQuestion *attributedQuestion = PQSQuestion.textFieldQuestion;
    attributedQuestion.question = @"Text can be bold, underline, or italics. As well as any combination of them.";
    [attributedQuestion boldText:@"bold"];
    [attributedQuestion underlineText:@"underline"];
    [attributedQuestion italicizeText:@"italics"];
    [attributedQuestion boldAndUnderlineText:@"well"];
    [attributedQuestion boldAndItalicizeText:@"any"];
    [attributedQuestion underlineAndItalicizeText:@"as"];
    [attributedQuestion boldUnderlineAndItalicizeText:@"combination"];
    [attributedQuestion appendAndItalicizedText:@"†"];
    attributedQuestion.placeholderText = @"Placeholder text cannot be altered.";
    [self addObject:attributedQuestion];
    
    
    
    
    
    
    
    
    
    PQSQuestion *header3 = PQSQuestion.subHeader;
    header3.question = @"The following question has a sub-question that only appears if the user selects \"Yes\" or \"No\" and does not those them if the user doesn't answer.";
    header3.fixedHeight = 52.0f;
    [self addObject:header3];
    
    
    PQSQuestion *trueFalseConditionalQuestion = PQSQuestion.trueFalseConditionalQuestion;
    trueFalseConditionalQuestion.question = @"Primary True/False Question";
    [trueFalseConditionalQuestion appendAndItalicizedText:@" (True/False Conditional Question)"];
    [self addObject:trueFalseConditionalQuestion];
    
        PQSQuestion *trueFalseConditionalQuestionTrue = PQSQuestion.textFieldQuestion;
        trueFalseConditionalQuestionTrue.question = @"True Question";
        trueFalseConditionalQuestionTrue.placeholderText = @"This only appears if the user selected \"True\"";
        trueFalseConditionalQuestionTrue.preferredBackgroundTone = trueFalseConditionalQuestion.preferredBackgroundTone;
        trueFalseConditionalQuestion.trueConditionalQuestion	= trueFalseConditionalQuestionTrue;
        
        PQSQuestion *trueFalseConditionalQuestionFalse = PQSQuestion.textFieldQuestion;
        trueFalseConditionalQuestionFalse.question = @"False Question";
        trueFalseConditionalQuestionFalse.placeholderText = @"This only appears if the user selected \"False\"";
        trueFalseConditionalQuestionFalse.preferredBackgroundTone = trueFalseConditionalQuestion.preferredBackgroundTone;
        trueFalseConditionalQuestion.falseConditionalQuestion	= trueFalseConditionalQuestionFalse;
    
    
    
    PQSQuestion *yesNoConditionalQuestion = PQSQuestion.yesNoConditionalQuestion;
    yesNoConditionalQuestion.question = @"Primary Yes/No Question";
    [yesNoConditionalQuestion appendAndItalicizedText:@" (Yes/No Conditional Question)"];
    [self addObject:yesNoConditionalQuestion];
    
        PQSQuestion *yesNoConditionalQuestionTrue = PQSQuestion.textFieldQuestion;
        yesNoConditionalQuestionTrue.question = @"`Yes` Question";
        yesNoConditionalQuestionTrue.placeholderText = @"This only appears if the user selected \"Yes\"";
        yesNoConditionalQuestionTrue.preferredBackgroundTone = yesNoConditionalQuestion.preferredBackgroundTone;
        yesNoConditionalQuestion.trueConditionalQuestion     = yesNoConditionalQuestionTrue;
        
        PQSQuestion *yesNoConditionalQuestionFalse = PQSQuestion.textFieldQuestion;
        yesNoConditionalQuestionFalse.question = @"`No` Question";
        yesNoConditionalQuestionFalse.placeholderText = @"This only appears if the user selected \"No\"";
        yesNoConditionalQuestionFalse.preferredBackgroundTone   = yesNoConditionalQuestion.preferredBackgroundTone;
        yesNoConditionalQuestion.falseConditionalQuestion       = yesNoConditionalQuestionFalse;


    
    
    
    
    PQSQuestion *question6a = PQSQuestion.yesNoConditional2Question;
    question6a.question = @"Primary Yes or No Question";
    [question6a appendAndItalicizedText:@" (Yes/No Conditional 2 Question)"];
    [self addObject:question6a];
    
        PQSQuestion *question6b = PQSQuestion.textFieldQuestion;
        question6b.question = @"Secondary Question";
        question6b.preferredBackgroundTone  = question6a.preferredBackgroundTone;
        question6a.trueConditionalQuestion	= question6b;
        
        PQSQuestion *question6c = PQSQuestion.yesNoQuestion;
        question6c.question = @"Other Secondary Question";
        question6c.preferredBackgroundTone  = question6a.preferredBackgroundTone;
        question6a.trueConditionalQuestion2	= question6c;
    
    
    
    PQSQuestion *question6d = PQSQuestion.trueFalseConditional2Question;
    question6d.question = @"Primary True or False Question";
    [question6d appendAndItalicizedText:@" (True/False Conditional 2 Question)"];
    [self addObject:question6d];
    
        PQSQuestion *question6e = PQSQuestion.textFieldQuestion;
        question6e.question = @"Secondary Question";
        question6e.preferredBackgroundTone = question6d.preferredBackgroundTone;
        question6d.falseConditionalQuestion	= question6e;
        
        PQSQuestion *question6f = PQSQuestion.trueFalseQuestion;
        question6f.question = @"Other Secondary Question";
        question6f.preferredBackgroundTone  = question6d.preferredBackgroundTone;
        question6d.falseConditionalQuestion2= question6f;
    
        PQSQuestion *question6g = PQSQuestion.textFieldQuestion;
        question6g.question = @"0, 1, or 2 questions can be used conditionally a True/False or Yes/No question.";
        question6g.preferredBackgroundTone = question6d.preferredBackgroundTone;
        question6d.trueConditionalQuestion = question6g;
    
    
    
    
    PQSQuestion *sliderHeader = PQSQuestion.plainHeader;
    sliderHeader.question = @"Increments, Sliders, and Percentage";
    [self addObject:sliderHeader];
    
    PQSQuestion *incrementalQuestion = PQSQuestion.incrementalQuestion;
    incrementalQuestion.minimumScale = 0;
    incrementalQuestion.maximumScale = 5;
    incrementalQuestion.question = @"How many eggs in Huevos Rancheros?";
    [incrementalQuestion appendAndItalicizedText:@" (Incremental Question)"];
    [incrementalQuestion boldAndUnderlineText:@"Huevos"];
    incrementalQuestion.scaleSuffix = @" Eggs";
    [self addObject:incrementalQuestion];
    
    PQSQuestion *tacoQuestion = PQSQuestion.scaleQuestion;
    tacoQuestion.question = @"How many Tacos would you like?";
    tacoQuestion.minimumScale = 0;
    tacoQuestion.maximumScale = 10;
    tacoQuestion.showScaleValues = YES;
    tacoQuestion.scaleInterval = 1;
    tacoQuestion.scaleSuffix = @"Tacos";
    [tacoQuestion appendAndItalicizedText:@" (Scale Question)"];
    [self addObject:tacoQuestion];
    
    PQSQuestion *percentageQuestion = PQSQuestion.percentageQuestion;
    percentageQuestion.question = @"What percent of your meals would you like to be south of the border?";
    [percentageQuestion italicizeText:@"south"];
    percentageQuestion.startingPoint = 50.0f;
    [percentageQuestion appendAndItalicizedText:@" (Percentage Question)"];
    [self addObject:percentageQuestion];
    
    PQSQuestion *splitPercentageQuestion = PQSQuestion.splitPercentageQuestion;
    splitPercentageQuestion.question = @"How many of your meals do you want to be of which type of the following foods?";
    [splitPercentageQuestion.possibleAnswers addObjectsFromArray:@[@"Tacos",
                                                                   @"Burritos",
                                                                   @"Other"]];
    [splitPercentageQuestion appendAndItalicizedText:@" (Split Percentage Question)"];
    [self addObject:splitPercentageQuestion];
    
    
    
    
    
    
    
    PQSQuestion *multipleChoiceHeader = PQSQuestion.plainHeader;
    multipleChoiceHeader.question = @"Multiple Choice Options";
    [self addObject:multipleChoiceHeader];
    
    
    PQSQuestion *radioButtonQuestion = PQSQuestion.radioButtonsQuestion;
    radioButtonQuestion.question = @"Radio Button Question";
    [radioButtonQuestion.possibleAnswers addObjectsFromArray:@[@"Taco",
                                                               @"Hamburger",
                                                               @"Tangerine",
                                                               @"Poi"]];
    [self addObject:radioButtonQuestion];
    
    PQSQuestion *multipleChoiceQuestion = PQSQuestion.multipleChoiceQuestion;
    multipleChoiceQuestion.question = @"This is useful when each answer has longer text";
    [multipleChoiceQuestion.possibleAnswers addObjectsFromArray:@[@"Bacon ipsum dolor amet rump short loin beef meatloaf frankfurter jerky cow, hamburger t-bone kielbasa flank tenderloin",
                                                                  @"Ball tip sirloin flank swine porchetta ground round",
                                                                  @"Corned beef landjaeger doner"]];
    [multipleChoiceQuestion appendAndItalicizedText:@" (Multiple Choice Question)"];
    [self addObject:multipleChoiceQuestion];
    
    
    PQSQuestion *oneToTenQuestion = PQSQuestion.oneToTenQuestion;
    oneToTenQuestion.leftLabelText = @"Minimum Label";
    oneToTenQuestion.rightLabelText = @"Maximum Label";
    oneToTenQuestion.question = @"One to Ten";
    [self addObject:oneToTenQuestion];
    
    
    PQSQuestion *checkBoxQuestion = PQSQuestion.checkBoxesQuestion;
    checkBoxQuestion.question = @"Select your condiments";
    [checkBoxQuestion.possibleAnswers addObjectsFromArray:@[@"Cheese",
                                                            @"Lettuce",
                                                            @"Beef",
                                                            @"Salsa",
                                                            @"Sour Cream"]];
    [checkBoxQuestion appendAndItalicizedText:@" (Checkbox Question)"];
    [self addObject:checkBoxQuestion];
    
    
    
    
    
    
    PQSQuestion *specialHeader = PQSQuestion.plainHeader;
    specialHeader.question = @"Special Questions";
    [self addObject:specialHeader];
    
    PQSQuestion *specialHeaderSub = PQSQuestion.subHeader;
    specialHeaderSub.question = @"Sometimes, there are a bunch of questions in a row that are really similar.";
    [self addObject:specialHeaderSub];
    
    PQSQuestion *specialHeaderSub2 = PQSQuestion.subHeader;
    specialHeaderSub2.question = @"If you select \"Love Worse\" then a follow up question is asked.";
    specialHeaderSub2.fixedHeight = 50.0f;
    [self addObject:specialHeaderSub2];
    
    NSArray *similarQuestions = @[@"Question 1",
                                  @"Question 2",
                                  @"Question 3"];
    
    
    for (NSString *questionText in similarQuestions) {
        PQSQuestion *rootQuestion = PQSQuestion.multiColumnConditionalQuestion;
        rootQuestion.question = questionText;
        [rootQuestion boldTextAfterString:@" "];
        [rootQuestion appendAndItalicizedText:@" (Multi Column Conditional Question)"];
        
        [self addObject:rootQuestion];
        
        PQSQuestion *questionA = PQSQuestion.yesNoQuestion;
        questionA.question = @"Clinically Acceptable*";
        
        PQSQuestion *radioButtonSubQuestion = PQSQuestion.radioButtonsQuestion;
        radioButtonSubQuestion.question = @"How does Love compare to hate?†";
        [radioButtonSubQuestion appendAndItalicizedText:@"(Optional)"];
        [radioButtonSubQuestion.possibleAnswers addObjectsFromArray:@[@"Love much better", @"Love better", @"Same", @"Love worse\n(Please describe)"]];
        radioButtonSubQuestion.triggerAnswer = [radioButtonSubQuestion.possibleAnswers lastObject];
        
        PQSQuestion *conditionalQuestion = PQSQuestion.textViewQuestion;
        conditionalQuestion.question = @"Please describe";
        conditionalQuestion.placeholderText = @"Please describe";
        rootQuestion.triggerQuestion = conditionalQuestion;
        
        [rootQuestion setMultipleColumnQuestions:@[questionA, radioButtonSubQuestion]];
    }
    
    
    
    
    PQSQuestion *twoWayExclusivityQuestion = PQSQuestion.twoWayExclusivityQuestion;
    twoWayExclusivityQuestion.question = @"Rank the following as your first, second, and third choice.";
    [twoWayExclusivityQuestion appendAndItalicizedText:@" (Two Way Exclusivity Question)"];
    [twoWayExclusivityQuestion.possibleAnswers addObjectsFromArray:@[@"Option 1",
                                                                     @"Option 2",
                                                                     @"Option 3",
                                                                     @"Option 4",
                                                                     @"Option 5"]];
    twoWayExclusivityQuestion.minimumScale = 1;
    twoWayExclusivityQuestion.maximumScale = 3;
    [self addObject:twoWayExclusivityQuestion];
    
    
    
    PQSQuestion *finePrint = PQSQuestion.finePrintHeader;
    finePrint.question = @"*Fine Print\n†Other Fine Print";
    [self addObject:finePrint];
}

- (instancetype)init {
    self = [super init];
    
    if (self) {
        [self setupQuestions];
    }
    
    return self;
}





+ (instancetype)sharedQuestionsList {
    static PQSQuestionList *sharedQuestionsList;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedQuestionsList = [[PQSQuestionList alloc] init];
    });
    
    return sharedQuestionsList;
    
}

+ (NSMutableArray *)defaultQuestions {
    return PQSQuestionList.sharedQuestionsList.defaultQuestions;
}

- (NSMutableArray *)defaultQuestions {
    if (!_questions) {
        _questions = NSMutableArray.new;
        
        [self setupQuestions];
    }
    
    return _questions;
}

- (void)addObject:(NSObject *)object {
    if (object) {
        [_questions addObject:object];
    } else {
        NSLog(@"Cannot add nil object to _questions");
    }
}


@end
