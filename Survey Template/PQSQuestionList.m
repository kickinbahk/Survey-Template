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
    
    
    
    
    
    PQSQuestion *header1 = PQSQuestion.plainHeader;
    header1.question = @"Typing Questions";
    [self addObject:header1];
    
    
    PQSQuestion *question0a = PQSQuestion.textFieldQuestion;
    question0a.question = @"Participant Name";
    question0a.placeholderText = @"Participant Name";
    [self addObject:question0a];
    
    PQSQuestion *question0b = PQSQuestion.textFieldQuestion;
    question0b.question = @"Questions can have different placeholder text.";;
    question0b.placeholderText = @"This is my alternate placeholder text";
    [self addObject:question0b];
    
    PQSQuestion *stickyQuestion = PQSQuestion.textFieldQuestion;
    stickyQuestion.question = @"This question will remember your preference between submissions";
    stickyQuestion.placeholderText = @"Useful for names that don't change";
    stickyQuestion.isSticky = YES;
    [self addObject:stickyQuestion];
    
    
    PQSQuestion *question1 = PQSQuestion.largeNumberQuestion;
    question1.question = @"This allows typing in any number. Usefull for Large Numbers";
    question1.attributedQuestion = [self boldText:@[@"10"]
                                         inString:question1.question];
    question1.scaleSuffix = @"Eggs";
    question1.placeholderText = @"Eggs";
    question1.minimumScale = 0;
    question1.maximumScale = 500;
    [self addObject:question1];
    
    
    PQSQuestion *question2 = PQSQuestion.largeNumberQuestion;
    question2.question = @"Bolding words in a sentence. Often times, the client will want to stylize the text of the question.";
    question2.attributedQuestion = [self boldText:@[@"Bold", @"sentence"]
                                         inString:question2.question];
    question2.scaleSuffix = @"Things";
    question2.scaleInterval = 5;
    question2.minimumScale = 0;
    question2.maximumScale = 100;
    question2.placeholderText = [NSString stringWithFormat:@"%g - %g", question2.minimumScale, question2.maximumScale];
    [self addObject:question2];
				
    
    
    
    
    
    PQSQuestion *header2 = PQSQuestion.plainHeader;
    header2.question = @"Header";
    [self addObject:header2];
    
    
    PQSQuestion *textViewQuestion = PQSQuestion.textViewQuestion;
    textViewQuestion.question = @"Text VIEW Question";
    textViewQuestion.placeholderText = @"Type something long in here";
    [self addObject:textViewQuestion];
    
    PQSQuestion *textFieldQuestion = PQSQuestion.textFieldQuestion;
    textFieldQuestion.question = @"Text Field Question";
    textFieldQuestion.placeholderText = @"Type something shorter in here";
    [self addObject:textFieldQuestion];
    
    
    
    PQSQuestion *header3 = PQSQuestion.subHeader;
    header3.question = @"The following question has a sub-question that only appears if the user selects \"Yes\" or \"No\" and does not those them if the user doesn't answer.";
    header3.fixedHeight = 52.0f;
    [self addObject:header3];
    
    PQSQuestion *trueFalseConditionalQuestion = PQSQuestion.trueFalseConditionalQuestion;
    trueFalseConditionalQuestion.question = @"Primary Question";
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
    yesNoConditionalQuestion.question = @"Primary Question";
    [self addObject:yesNoConditionalQuestion];
    
        PQSQuestion *yesNoConditionalQuestionTrue = PQSQuestion.textFieldQuestion;
        yesNoConditionalQuestionTrue.question = @"Yes Question";
        yesNoConditionalQuestionTrue.placeholderText = @"This only appears if the user selected \"Yes\"";
        yesNoConditionalQuestionTrue.preferredBackgroundTone = yesNoConditionalQuestion.preferredBackgroundTone;
        yesNoConditionalQuestion.trueConditionalQuestion     = yesNoConditionalQuestionTrue;
        
        PQSQuestion *yesNoConditionalQuestionFalse = PQSQuestion.textFieldQuestion;
        yesNoConditionalQuestionFalse.question = @"`No` Question";
        yesNoConditionalQuestionFalse.placeholderText = @"This only appears if the user selected \"No\"";
        yesNoConditionalQuestionFalse.preferredBackgroundTone   = yesNoConditionalQuestion.preferredBackgroundTone;
        yesNoConditionalQuestion.falseConditionalQuestion       = yesNoConditionalQuestionFalse;


    
    
    
    
    PQSQuestion *question6a = PQSQuestion.yesNoConditional2Question;
    question6a.question = @"Primary Question";
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
    [self addObject:question6d];
    
        PQSQuestion *question6e = PQSQuestion.textFieldQuestion;
        question6e.question = @"Secondary Question";
        question6e.preferredBackgroundTone = question6d.preferredBackgroundTone;
        question6d.falseConditionalQuestion	= question6e;
        
        PQSQuestion *question6f = PQSQuestion.trueFalseQuestion;
        question6f.question = @"Other Secondary Question";
        question6f.preferredBackgroundTone  = question6d.preferredBackgroundTone;
        question6d.falseConditionalQuestion2= question6f;
    
    
    
    
    PQSQuestion *sliderHeader = PQSQuestion.plainHeader;
    sliderHeader.question = @"Increments, Sliders, and Percentage";
    [self addObject:sliderHeader];
    
    PQSQuestion *incrementalQuestion = PQSQuestion.incrementalQuestion;
    incrementalQuestion.minimumScale = 0;
    incrementalQuestion.maximumScale = 5;
    incrementalQuestion.question = @"How many eggs in Huevos Rancheros?";
    incrementalQuestion.attributedQuestion = [self boldAndUnderlineText:@[@"Heuvos"]
                                                               inString:incrementalQuestion.question];
    [self addObject:incrementalQuestion];
    
    PQSQuestion *tacoQuestion = PQSQuestion.scaleQuestion;
    tacoQuestion.question = @"How many Tacos would you like?";
    tacoQuestion.minimumScale = 0;
    tacoQuestion.maximumScale = 10;
    tacoQuestion.showScaleValues = YES;
    tacoQuestion.scaleInterval = 1;
    tacoQuestion.scaleSuffix = @"Tacos";
    [self addObject:tacoQuestion];
    
    PQSQuestion *percentageQuestion = PQSQuestion.percentageQuestion;
    percentageQuestion.question = @"What percent of your meals would you like to be south of the border?";
    percentageQuestion.attributedQuestion = [self italicizeText:@[@"south"]
                                                       inString:percentageQuestion.question];
    percentageQuestion.startingPoint = 50.0f;
    [self addObject:percentageQuestion];
    
    PQSQuestion *splitPercentageQuestion = PQSQuestion.splitPercentageQuestion;
    splitPercentageQuestion.question = @"How many of your meals do you want to be of which type of the following foods?";
    [splitPercentageQuestion.possibleAnswers addObjectsFromArray:@[@"Tacos",
                                                                   @"Burritos",
                                                                   @"Other"]];
    [self addObject:splitPercentageQuestion];
    
    
    
    
    
    
    
    PQSQuestion *header3a = PQSQuestion.plainHeader;
    header3a.question = @"Main Header";
    [self addObject:header3a];
    
    PQSQuestion *question7 = PQSQuestion.yesNoQuestion;
    question7.question = @"This question is a fixed height. This is useful for layout adjustments.";
    question7.maximumHeight = 100.0f;
    [self addObject:question7];
    
    
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
                                                                  @"Corned beef landjaeger doner tail, meatloaf bacon prosciutto tongue pork chop meatball turkey ground round"]];
    [self addObject:multipleChoiceQuestion];
    
    
    PQSQuestion *oneToTenQuestion = PQSQuestion.oneToTenQuestion;
    oneToTenQuestion.leftLabelText = @"Minimum Label";
    oneToTenQuestion.rightLabelText = @"Maximum Label";
    oneToTenQuestion.question = @"Range";
    [self addObject:oneToTenQuestion];
    
    
    
    
    
    PQSQuestion *header3b = PQSQuestion.subHeader;
    header3b.question = @"Sometimes, there are a bunch of questions in a row that are really similar.";
    [self addObject:header3b];
    
    PQSQuestion *header3c = PQSQuestion.subHeader;
    header3c.question = @"If you select \"LoVe Worse\" then a follow up question is asked.";
    header3c.fixedHeight = 50.0f;
    [self addObject:header3c];
    
    NSArray *similarQuestions = @[@"Similar Question 1",
                                  @"Similar Question 2",
                                  @"Similar Question 3"];
    
    
    for (NSString *questionText in similarQuestions) {
        PQSQuestion *rootQuestion = PQSQuestion.multiColumnConditionalQuestion;
        rootQuestion.question = questionText;
        NSInteger locationOfColon = [questionText rangeOfString:@":"].location;
        if (locationOfColon == NSNotFound) {
            locationOfColon = questionText.length - 1;
        } else {
            locationOfColon++;
        }
        
        if (locationOfColon < questionText.length) {
            NSString *boldText = [questionText substringToIndex:locationOfColon];
            rootQuestion.attributedQuestion = [self boldText:@[boldText]
                                                    inString:questionText];
        }
        
        [self addObject:rootQuestion];
        
        PQSQuestion *questionA = PQSQuestion.yesNoQuestion;
        questionA.question = @"Clinically Acceptable*";
        
        PQSQuestion *radioButtonsQuestion = PQSQuestion.radioButtonsQuestion;
        radioButtonsQuestion.question = @"How does Love compare to hate?†";
        radioButtonsQuestion.attributedQuestion = [self appendItalicizedText:@"(Optional)"
                                                                    toString:[[NSAttributedString alloc] initWithString:radioButtonsQuestion.question]];
        [radioButtonsQuestion.possibleAnswers addObjectsFromArray:@[@"LoVe much better", @"LoVe better", @"Same", @"LoVe worse\n(Please describe)"]];
        rootQuestion.triggerAnswer = [radioButtonsQuestion.possibleAnswers lastObject];
        
        PQSQuestion *conditionalQuestion = PQSQuestion.textViewQuestion;
        conditionalQuestion.question = @"Please describe";
        conditionalQuestion.placeholderText = @"Please describe";
        rootQuestion.triggerQuestion = conditionalQuestion;
        
        [rootQuestion setMultipleColumnQuestions:@[questionA, radioButtonsQuestion]];
    }
    
    PQSQuestion *twoWayExclusivityQuestion = PQSQuestion.twoWayExclusivityQuestion;
    twoWayExclusivityQuestion.question = @"Rank the following as your first, second, and third choice.";
    [twoWayExclusivityQuestion.possibleAnswers addObjectsFromArray:@[@"Option 1",
                                                                     @"Option 2",
                                                                     @"Option 3",
                                                                     @"Option 4",
                                                                     @"Option 5"]];
    twoWayExclusivityQuestion.minimumScale = 1;
    twoWayExclusivityQuestion.maximumScale = 3;
    [self addObject:twoWayExclusivityQuestion];
    
    PQSQuestion *checkBoxQuestion = PQSQuestion.checkBoxesQuestion;
    checkBoxQuestion.question = @"Select your condiments";
    [checkBoxQuestion.possibleAnswers addObjectsFromArray:@[@"Cheese",
                                                            @"Lettuce",
                                                            @"Beef",
                                                            @"Salsa",
                                                            @"Sour Cream"]];
    [self addObject:checkBoxQuestion];
    
    
    
    
    PQSQuestion *question18 = PQSQuestion.textViewQuestion;
    question18.question = @"Additional Comments";
    question18.placeholderText = @"Comments";
    [self addObject:question18];
    
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

- (NSMutableAttributedString *)boldText:(NSArray *)texts inString:(NSString *)source {
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:source
                                                                                         attributes:@{NSFontAttributeName : [UIFont appFont]}];
    for (NSString *textToBold in texts) {
        NSRange textRange = [source rangeOfString:textToBold];
        if (textRange.location != NSNotFound) {
            [attributedString addAttribute:NSFontAttributeName
                                     value:[UIFont boldAppFont]
                                     range:textRange];
        }
    }
    
    return attributedString;
}

- (NSMutableAttributedString *)underlineText:(NSArray *)texts inString:(NSString *)source {
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:source
                                                                                         attributes:@{NSFontAttributeName : [UIFont appFont]}];
    for (NSString *textToBold in texts) {
        NSRange textRange = [source rangeOfString:textToBold];
        if (textRange.location != NSNotFound) {
            [attributedString addAttribute:NSUnderlineStyleAttributeName
                                     value:@(1)
                                     range:textRange];
        }
    }
    
    return attributedString;
}


- (NSMutableAttributedString *)italicizeText:(NSArray *)texts inString:(NSString *)source {
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:source
                                                                                         attributes:@{NSFontAttributeName : [UIFont appFont]}];
    for (NSString *textToItalicize in texts) {
        NSRange textRange = [source rangeOfString:textToItalicize];
        if (textRange.location != NSNotFound) {
            [attributedString addAttribute:NSFontAttributeName
                                     value:[UIFont italicAppFont]
                                     range:textRange];
        }
    }
    
    return attributedString;
}

- (NSMutableAttributedString *)boldAndUnderlineText:(NSArray *)texts inString:(NSString *)source {
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:source
                                                                                         attributes:@{NSFontAttributeName : [UIFont appFont]}];
    for (NSString *textToBold in texts) {
        NSRange textRange = [source rangeOfString:textToBold];
        if (textRange.location != NSNotFound) {
            [attributedString addAttribute:NSFontAttributeName
                                     value:[UIFont boldAppFont]
                                     range:textRange];
            [attributedString addAttribute:NSUnderlineStyleAttributeName
                                     value:@(1)
                                     range:textRange];
        }
    }
    
    return attributedString;
}

- (NSMutableAttributedString *)boldItalicAndUnderlineText:(NSArray *)texts inString:(NSString *)source {
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:source
                                                                                         attributes:@{NSFontAttributeName : [UIFont appFont]}];
    for (NSString *textToBold in texts) {
        NSRange textRange = [source rangeOfString:textToBold];
        if (textRange.location != NSNotFound) {
            [attributedString addAttribute:NSFontAttributeName
                                     value:[UIFont boldItalicAppFont]
                                     range:textRange];
            [attributedString addAttribute:NSUnderlineStyleAttributeName
                                     value:@(1)
                                     range:textRange];
        }
    }
    
    return attributedString;
}

- (NSMutableAttributedString *)boldAndUnderlineText:(NSArray *)boldAndUnderlineTexts italicizeText:(NSArray *)italicizeTexts inString:(NSString *)source {
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:source
                                                                                         attributes:@{NSFontAttributeName : [UIFont appFont]}];
    for (NSString *textToItalicize in italicizeTexts) {
        NSRange textRange = [source rangeOfString:textToItalicize];
        if (textRange.location != NSNotFound) {
            [attributedString addAttribute:NSFontAttributeName
                                     value:[UIFont italicAppFont]
                                     range:textRange];
        }
    }
    
    for (NSString *textToBoldAndUnderline in boldAndUnderlineTexts) {
        NSRange textRange = [source rangeOfString:textToBoldAndUnderline];
        if (textRange.location != NSNotFound) {
            [attributedString addAttribute:NSFontAttributeName
                                     value:[UIFont boldAppFont]
                                     range:textRange];
            [attributedString addAttribute:NSUnderlineStyleAttributeName
                                     value:@(1)
                                     range:textRange];
        }
    }
    
    return attributedString;
}

- (NSMutableAttributedString *)appendItalicizedText:(NSString *)textToItalicize toString:(NSAttributedString *)source {
    NSMutableAttributedString *mutableSource = [[NSMutableAttributedString alloc] initWithAttributedString:source];
    
    NSAttributedString *italicString = [[NSAttributedString alloc] initWithString:textToItalicize attributes:@{NSFontAttributeName : [UIFont italicAppFont]}];
    
    [mutableSource appendAttributedString:italicString];
    
    return mutableSource;
}

- (PQSQuestion *)whichCountryQuestion {
    PQSQuestion *whichCountryQuestion = PQSQuestion.new;
    NSMutableAttributedString *whichCountryQuestionAttributedString = [[NSMutableAttributedString alloc]initWithString:
                                                                       @"In which country do you practice?"];
    UIFont *whichCountryQuestionAttributedStringFont1 = [UIFont appFont];
    UIFont *whichCountryQuestionAttributedStringFont2 = [UIFont boldAppFont];
    [whichCountryQuestionAttributedString addAttribute:NSFontAttributeName value:whichCountryQuestionAttributedStringFont1 range:NSMakeRange(0,9)];
    [whichCountryQuestionAttributedString addAttribute:NSUnderlineStyleAttributeName value:@(1) range:NSMakeRange(9,7)];
    [whichCountryQuestionAttributedString addAttribute:NSFontAttributeName value:whichCountryQuestionAttributedStringFont2 range:NSMakeRange(9,7)];
    [whichCountryQuestionAttributedString addAttribute:NSFontAttributeName value:whichCountryQuestionAttributedStringFont1 range:NSMakeRange(17,16)];
    whichCountryQuestion.attributedQuestion = whichCountryQuestionAttributedString;
    whichCountryQuestion.question = whichCountryQuestionAttributedString.string;
    whichCountryQuestion.questionType = PQSQuestionTypeLongList;
    whichCountryQuestion.placeholderText = PQSReferenceManager.defaultCountry;
    whichCountryQuestion.longListTitle = @"Select Country";
    whichCountryQuestion.hideBorder = NO;
    whichCountryQuestion.questionNumber = 1;
    [self countryCodeList];
    [whichCountryQuestion.possibleAnswers addObjectsFromArray:_countryCodeList.allKeys];
    [whichCountryQuestion.possibleAnswers sortUsingSelector:@selector(caseInsensitiveCompare:)];
    [whichCountryQuestion.urlKeys addEntriesFromDictionary:@{@"country" : @"In_what_country_do_you_practice"}];
    
    return whichCountryQuestion;
}

- (NSDictionary *)countryCodeList {
    if (!_countryCodeList) {
        NSDictionary *backwardsList = @{@"AFG" : @"Afghanistan",
                                        @"ALA" : @"Åland Islands",
                                        @"ALB" : @"Albania",
                                        @"DZA" : @"Algeria",
                                        @"ASM" : @"American Samoa",
                                        @"AND" : @"Andorra",
                                        @"AGO" : @"Angola",
                                        @"AIA" : @"Anguilla",
                                        @"ATA" : @"Antarctica",
                                        @"ATG" : @"Antigua and Barbuda",
                                        @"ARG" : @"Argentina",
                                        @"ARM" : @"Armenia",
                                        @"ABW" : @"Aruba",
                                        @"AUS" : @"Australia",
                                        @"AUT" : @"Austria",
                                        @"AZE" : @"Azerbaijan",
                                        @"BHS" : @"Bahamas",
                                        @"BHR" : @"Bahrain",
                                        @"BGD" : @"Bangladesh",
                                        @"BRB" : @"Barbados",
                                        @"BLR" : @"Belarus",
                                        @"BEL" : @"Belgium",
                                        @"BLZ" : @"Belize",
                                        @"BEN" : @"Benin",
                                        @"BMU" : @"Bermuda",
                                        @"BTN" : @"Bhutan",
                                        @"BOL" : @"Bolivia, Plurinational State of",
                                        @"BES" : @"Bonaire, Sint Eustatius and Saba",
                                        @"BIH" : @"Bosnia and Herzegovina",
                                        @"BWA" : @"Botswana",
                                        @"BVT" : @"Bouvet Island",
                                        @"BRA" : @"Brazil",
                                        @"IOT" : @"British Indian Ocean Territory",
                                        @"BRN" : @"Brunei Darussalam",
                                        @"BGR" : @"Bulgaria",
                                        @"BFA" : @"Burkina Faso",
                                        @"BDI" : @"Burundi",
                                        @"KHM" : @"Cambodia",
                                        @"CMR" : @"Cameroon",
                                        @"CAN" : @"Canada",
                                        @"CPV" : @"Cape Verde",
                                        @"CYM" : @"Cayman Islands",
                                        @"CAF" : @"Central African Republic",
                                        @"TCD" : @"Chad",
                                        @"CHL" : @"Chile",
                                        @"CHN" : @"China",
                                        @"CXR" : @"Christmas Island",
                                        @"CCK" : @"Cocos (Keeling) Islands",
                                        @"COL" : @"Colombia",
                                        @"COM" : @"Comoros",
                                        @"COG" : @"Congo",
                                        @"COD" : @"Congo, the Democratic Republic of the",
                                        @"COK" : @"Cook Islands",
                                        @"CRI" : @"Costa Rica",
                                        @"CIV" : @"Côte d'Ivoire",
                                        @"HRV" : @"Croatia",
                                        @"CUB" : @"Cuba",
                                        @"CUW" : @"Curaçao",
                                        @"CYP" : @"Cyprus",
                                        @"CZE" : @"Czech Republic",
                                        @"DNK" : @"Denmark",
                                        @"DJI" : @"Djibouti",
                                        @"DMA" : @"Dominica",
                                        @"DOM" : @"Dominican Republic",
                                        @"ECU" : @"Ecuador",
                                        @"EGY" : @"Egypt",
                                        @"SLV" : @"El Salvador",
                                        @"GNQ" : @"Equatorial Guinea",
                                        @"ERI" : @"Eritrea",
                                        @"EST" : @"Estonia",
                                        @"ETH" : @"Ethiopia",
                                        @"FLK" : @"Falkland Islands (Malvinas)",
                                        @"FRO" : @"Faroe Islands",
                                        @"FJI" : @"Fiji",
                                        @"FIN" : @"Finland",
                                        @"FRA" : @"France",
                                        @"GUF" : @"French Guiana",
                                        @"PYF" : @"French Polynesia",
                                        @"ATF" : @"French Southern Territories",
                                        @"GAB" : @"Gabon",
                                        @"GMB" : @"Gambia",
                                        @"GEO" : @"Georgia",
                                        @"DEU" : @"Germany",
                                        @"GHA" : @"Ghana",
                                        @"GIB" : @"Gibraltar",
                                        @"GRC" : @"Greece",
                                        @"GRL" : @"Greenland",
                                        @"GRD" : @"Grenada",
                                        @"GLP" : @"Guadeloupe",
                                        @"GUM" : @"Guam",
                                        @"GTM" : @"Guatemala",
                                        @"GGY" : @"Guernsey",
                                        @"GIN" : @"Guinea",
                                        @"GNB" : @"Guinea-Bissau",
                                        @"GUY" : @"Guyana",
                                        @"HTI" : @"Haiti",
                                        @"HMD" : @"Heard Island and McDonald Islands",
                                        @"VAT" : @"Holy See (Vatican City State)",
                                        @"HND" : @"Honduras",
                                        @"HKG" : @"Hong Kong",
                                        @"HUN" : @"Hungary",
                                        @"ISL" : @"Iceland",
                                        @"IND" : @"India",
                                        @"IDN" : @"Indonesia",
                                        @"IRN" : @"Iran, Islamic Republic of",
                                        @"IRQ" : @"Iraq",
                                        @"IRL" : @"Ireland",
                                        @"IMN" : @"Isle of Man",
                                        @"ISR" : @"Israel",
                                        @"ITA" : @"Italy",
                                        @"JAM" : @"Jamaica",
                                        @"JPN" : @"Japan",
                                        @"JEY" : @"Jersey",
                                        @"JOR" : @"Jordan",
                                        @"KAZ" : @"Kazakhstan",
                                        @"KEN" : @"Kenya",
                                        @"KIR" : @"Kiribati",
                                        @"PRK" : @"Korea, Democratic People's Republic of",
                                        @"KOR" : @"Korea, Republic of",
                                        @"KWT" : @"Kuwait",
                                        @"KGZ" : @"Kyrgyzstan",
                                        @"LAO" : @"Lao People's Democratic Republic",
                                        @"LVA" : @"Latvia",
                                        @"LBN" : @"Lebanon",
                                        @"LSO" : @"Lesotho",
                                        @"LBR" : @"Liberia",
                                        @"LBY" : @"Libya",
                                        @"LIE" : @"Liechtenstein",
                                        @"LTU" : @"Lithuania",
                                        @"LUX" : @"Luxembourg",
                                        @"MAC" : @"Macao",
                                        @"MKD" : @"Macedonia, the former Yugoslav Republic of",
                                        @"MDG" : @"Madagascar",
                                        @"MWI" : @"Malawi",
                                        @"MYS" : @"Malaysia",
                                        @"MDV" : @"Maldives",
                                        @"MLI" : @"Mali",
                                        @"MLT" : @"Malta",
                                        @"MHL" : @"Marshall Islands",
                                        @"MTQ" : @"Martinique",
                                        @"MRT" : @"Mauritania",
                                        @"MUS" : @"Mauritius",
                                        @"MYT" : @"Mayotte",
                                        @"MEX" : @"Mexico",
                                        @"FSM" : @"Micronesia, Federated States of",
                                        @"MDA" : @"Moldova, Republic of",
                                        @"MCO" : @"Monaco",
                                        @"MNG" : @"Mongolia",
                                        @"MNE" : @"Montenegro",
                                        @"MSR" : @"Montserrat",
                                        @"MAR" : @"Morocco",
                                        @"MOZ" : @"Mozambique",
                                        @"MMR" : @"Myanmar",
                                        @"NAM" : @"Namibia",
                                        @"NRU" : @"Nauru",
                                        @"NPL" : @"Nepal",
                                        @"NLD" : @"Netherlands",
                                        @"NCL" : @"New Caledonia",
                                        @"NZL" : @"New Zealand",
                                        @"NIC" : @"Nicaragua",
                                        @"NER" : @"Niger",
                                        @"NGA" : @"Nigeria",
                                        @"NIU" : @"Niue",
                                        @"NFK" : @"Norfolk Island",
                                        @"MNP" : @"Northern Mariana Islands",
                                        @"NOR" : @"Norway",
                                        @"OMN" : @"Oman",
                                        @"PAK" : @"Pakistan",
                                        @"PLW" : @"Palau",
                                        @"PSE" : @"Palestinian Territory, Occupied",
                                        @"PAN" : @"Panama",
                                        @"PNG" : @"Papua New Guinea",
                                        @"PRY" : @"Paraguay",
                                        @"PER" : @"Peru",
                                        @"PHL" : @"Philippines",
                                        @"PCN" : @"Pitcairn",
                                        @"POL" : @"Poland",
                                        @"PRT" : @"Portugal",
                                        @"PRI" : @"Puerto Rico",
                                        @"QAT" : @"Qatar",
                                        @"REU" : @"Réunion",
                                        @"ROU" : @"Romania",
                                        @"RUS" : @"Russian Federation",
                                        @"RWA" : @"Rwanda",
                                        @"BLM" : @"Saint Barthélemy",
                                        @"SHN" : @"Saint Helena, Ascension and Tristan da Cunha",
                                        @"KNA" : @"Saint Kitts and Nevis",
                                        @"LCA" : @"Saint Lucia",
                                        @"MAF" : @"Saint Martin (French part)",
                                        @"SPM" : @"Saint Pierre and Miquelon",
                                        @"VCT" : @"Saint Vincent and the Grenadines",
                                        @"WSM" : @"Samoa",
                                        @"SMR" : @"San Marino",
                                        @"STP" : @"Sao Tome and Principe",
                                        @"SAU" : @"Saudi Arabia",
                                        @"SEN" : @"Senegal",
                                        @"SRB" : @"Serbia",
                                        @"SYC" : @"Seychelles",
                                        @"SLE" : @"Sierra Leone",
                                        @"SGP" : @"Singapore",
                                        @"SXM" : @"Sint Maarten (Dutch part)",
                                        @"SVK" : @"Slovakia",
                                        @"SVN" : @"Slovenia",
                                        @"SLB" : @"Solomon Islands",
                                        @"SOM" : @"Somalia",
                                        @"ZAF" : @"South Africa",
                                        @"SGS" : @"South Georgia and the South Sandwich Islands",
                                        @"SSD" : @"South Sudan",
                                        @"ESP" : @"Spain",
                                        @"LKA" : @"Sri Lanka",
                                        @"SDN" : @"Sudan",
                                        @"SUR" : @"Suriname",
                                        @"SJM" : @"Svalbard and Jan Mayen",
                                        @"SWZ" : @"Swaziland",
                                        @"SWE" : @"Sweden",
                                        @"CHE" : @"Switzerland",
                                        @"SYR" : @"Syrian Arab Republic",
                                        @"TWN" : @"Taiwan, Province of China",
                                        @"TJK" : @"Tajikistan",
                                        @"TZA" : @"Tanzania, United Republic of",
                                        @"THA" : @"Thailand",
                                        @"TLS" : @"Timor-Leste",
                                        @"TGO" : @"Togo",
                                        @"TKL" : @"Tokelau",
                                        @"TON" : @"Tonga",
                                        @"TTO" : @"Trinidad and Tobago",
                                        @"TUN" : @"Tunisia",
                                        @"TUR" : @"Turkey",
                                        @"TKM" : @"Turkmenistan",
                                        @"TCA" : @"Turks and Caicos Islands",
                                        @"TUV" : @"Tuvalu",
                                        @"UGA" : @"Uganda",
                                        @"UKR" : @"Ukraine",
                                        @"ARE" : @"United Arab Emirates",
                                        @"GBR" : @"United Kingdom",
                                        @"USA" : @"United States",
                                        @"UMI" : @"United States Minor Outlying Islands",
                                        @"URY" : @"Uruguay",
                                        @"UZB" : @"Uzbekistan",
                                        @"VUT" : @"Vanuatu",
                                        @"VEN" : @"Venezuela, Bolivarian Republic of",
                                        @"VNM" : @"Viet Nam",
                                        @"VGB" : @"Virgin Islands, British",
                                        @"VIR" : @"Virgin Islands, U.S.",
                                        @"WLF" : @"Wallis and Futuna",
                                        @"ESH" : @"Western Sahara",
                                        @"YEM" : @"Yemen",
                                        @"ZMB" : @"Zambia",
                                        @"ZWE" : @"Zimbabwe",
                                        };
        _countryCodeList = [[NSMutableDictionary alloc] initWithCapacity:backwardsList.count];
        for (NSString *key in backwardsList) {
            [_countryCodeList setObject:key forKey:[backwardsList objectForKey:key]];
        }
    }
    
    return _countryCodeList;
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
