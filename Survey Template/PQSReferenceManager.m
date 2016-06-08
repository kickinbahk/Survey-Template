//
//  PQSReferenceManager.m
//  Philips Questionaire
//
//  Created by HAI on 5/8/15.
//  Copyright (c) 2015 HAI. All rights reserved.
//

#import "PQSReferenceManager.h"

#import "UIFont+AppFonts.h"

#import "Reachability.h"

#define LAST_LOCATION_UPDATE_DATE_KEY @"LAST_LOCATION_UPDATE_DATE"
#define ONE_DAY_IN_SECOND 86400.0f
#define NUMERIC_KEY_FOR_INT(input) [NSString stringWithFormat:@"NumericKey%zd", input]
#define COMPLETED_REQUEST_KEY_FOR_INT(input) [NSString stringWithFormat:@"COMPLETED_REQUEST_KEY%zd", input]

static NSString * const submissionURLString = @"http://hyperactive.to/hyper_rest3/index.php/api/example/senders?";

/**
 *  The default show title to include in all lists and used when the app first launches.
 */
static NSString * const defaultShowTitle = @"APSS Sleep Survey";

/**
 *  This could use location or time zone to get the current country instead of being hard coded. This would also take care of localization.
 */
static NSString * const defaultCountry = @"United States";

/**
 *  Key for the default show
 */
static NSString * const defaultShowKey = @"APSS_2016"; // e.g. AUA_MR_2016


/**
 *  Key for the company who's owning this show
 */
static NSString * const companyKey = @"PHIL"; // e.g. BSCI <or> PHIL


/**
 *  The key for finding the number of pending request strings stored locally
 */
static NSString * const primaryKey = @"Primary List Key";

/**
 *  The key for finding the number of completed requests
 */
static NSString * const completedRequestKey = @"Completed Request Key";

/**
 *  The key for finding the most recent show name
 */
static NSString * const mostRecentShowNameKey = @"Most Recent Show Name K£y Key";


@interface PQSReferenceManager () <NSURLConnectionDataDelegate>

@end

@implementation PQSReferenceManager {
	NSMutableArray *_questions, *_headers;
	UIImage *_currentBrandImage;
	NSString *_currentShowTitle;
	NSMutableOrderedSet *_possibleShowTitles;
	NSMutableDictionary *_answers;
	Reachability *_reach;
	NSMutableData *_responseData;
	CLLocationCoordinate2D _currentLocationCoordinate;
	NSMutableArray *_answersArray;
	NSDate *_lastRemoteSubmissionDate;
	NSMutableSet *_requestStrings;
	NSMutableSet *_completedRequests;
	NSMutableDictionary *_countryCodeList;
	PQSQuestion *_currentQuestion;
	NSDateFormatter *_dateFormatter;
	UITextField *_specialTextField;
	NSMutableDictionary *_questionsAndKeys;
}

+ (instancetype)sharedReferenceManager {
	static PQSReferenceManager *sharedReferenceManager;
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedReferenceManager = [[PQSReferenceManager alloc] init];
	});
	
	return sharedReferenceManager;
}

- (instancetype)init {
	self = [super init];
	
	if (self) {
//        NSString *jsonPath = [[NSBundle mainBundle] pathForResource:@"aua16" ofType:@"json"];
//        NSData *jsonData = [[NSData alloc] initWithContentsOfFile:jsonPath];
//        NSDictionary *survey = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
        // NSLog(@"Survey from JSON: %@", survey);
        
        _possibleShowTitles = [[NSMutableOrderedSet alloc] initWithObjects:@"APSS Sleep Survey", @"Testing", nil];
        
		_questions          = [[NSMutableArray alloc] init];
		_answers            = [[NSMutableDictionary alloc] initWithCapacity:_questions.count];
        _answersArray       = [[NSMutableArray alloc] init];
        _requestStrings     = [[NSMutableSet alloc] init];
        _completedRequests  = [[NSMutableSet alloc] init];
		_dateFormatter      = [[NSDateFormatter alloc] init];
        
		[_dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"]; // PHP Date format
		
        _reach = [Reachability reachabilityForInternetConnection];
        
        [self setupLocationManager];
        [self loadStringsFromDefaults];
        
//        for (NSDictionary *section in survey[@"sections"]) {
//            
//            NSArray *questionsData = section[@"questions"];
//            
//            [self addHeader:section[@"title"]];
//            
//            if (questionsData) {
//                
//                for (NSDictionary *questionData in questionsData) {
//                    [_questions addObject:[self questionForData:questionData]];
//                }
//            }
//        }
        
        
        PQSQuestion *primaryHeader = PQSQuestion.new;
        primaryHeader.questionType = PQSQuestionTypeNone;
        primaryHeader.headerType = PQSHeaderTypePlain;
        primaryHeader.question = @"";
        primaryHeader.fixedHeight = 1.0f;
        [_questions addObject:primaryHeader];
        
        PQSQuestion *subHeader = PQSQuestion.new;
        subHeader.questionType = PQSQuestionTypeNone;
        subHeader.headerType = PQSHeaderTypePlain;
        subHeader.question = @"Envisioning the future of healthy sleep";
        [_questions addObject:subHeader];
        
        PQSQuestion *question0 = PQSQuestion.new;
        question0.question = @"Are you a physician?";
        question0.questionType = PQSQuestionTypeTrueFalse;
        question0.useYesNoForTrueFalse = YES;
        question0.preferredBackgroundTone = PQSQuestionViewPreferredBackgroundToneLight;
        [_questions addObject:question0];
        
        PQSQuestion *question1 = PQSQuestion.new;
        question1.questionType = PQSQuestionType1to10;
        question1.minimumScale = 0;
        question1.maximumScale = 10;
        question1.preferredBackgroundTone = PQSQuestionViewPreferredBackgroundToneDark;
        question1.leftLabelText = @"Not at all clearly";
        question1.rightLabelText = @"                Extremely clearly";
        question1.question = @"Based upon your experience with us today, how clearly has Philips conveyed its vision for helping people to get better sleep?";
        [_questions addObject:question1];
        
        [_questions addObject:self.blankQuestion];
        
        PQSQuestion *question2 = PQSQuestion.new;
        question2.questionType = PQSQuestionType1to10;
        question2.minimumScale = 0;
        question2.maximumScale = 10;
        question2.preferredBackgroundTone = PQSQuestionViewPreferredBackgroundToneLight;
        question2.leftLabelText = @"Not at all innovative";
        question2.rightLabelText = @"                Extremely innovative";
        question2.question = @"How innovative have you found the concepts shown and discussed with you today in this Philips “Envisioning the future of healthy sleep” booth?";
        [_questions addObject:question2];
        
        [_questions addObject:self.blankQuestion];
        
        PQSQuestion *question3 = PQSQuestion.new;
        question3.questionType = PQSQuestionType1to10;
        question3.minimumScale = 0;
        question3.maximumScale = 10;
        question3.preferredBackgroundTone = PQSQuestionViewPreferredBackgroundToneDark;
        question3.leftLabelText = @"Not at all likely";
        question3.rightLabelText = @"                Extremely likely";
        question3.question = @"Based upon your experience with us today, how likely are you to recommend that a colleague visit this Philips “Envisioning the future of healthy sleep” booth?";
        [_questions addObject:question3];
        
        [_questions addObject:self.blankQuestion];
        
        PQSQuestion *question4 = PQSQuestion.new;
        question4.questionType = PQSQuestionTypeTextView;
        question4.preferredBackgroundTone = PQSQuestionViewPreferredBackgroundToneLight;
        question4.question = @"What questions or comments do you have after visiting this Philips “Envisioning the future of healthy sleep” booth?";
        question4.placeholderText = @"[Tap here to type your answer.]";
        [_questions addObject:question4];
        
        PQSQuestion *blankQuestion = PQSQuestion.new;
        blankQuestion.preferredBackgroundTone = PQSQuestionViewPreferredBackgroundToneLight;
        [_questions addObject:blankQuestion];
        
        question1.fixedHeight = 110.0f;
        question2.fixedHeight = question1.fixedHeight;
        question3.fixedHeight = question1.fixedHeight;
		
		[self createKeys];
		
		
		_headers = [[NSMutableArray alloc] init];
		for (int i = 0; i < _questions.count; i++) {
			PQSQuestion *question = [_questions objectAtIndex:i];
			
			if (question.headerType == PQSHeaderTypePlain) {
				[_headers addObject:question];
			} else {
				if (_headers.count == 0) {
					PQSQuestion *header = [PQSQuestion new];
					header.headerType = PQSHeaderTypePlain;
					[_headers addObject:header];
				}
				
				PQSQuestion *header = [_headers lastObject];
				[header.subQuestions addObject:question];
			}
		}
		
		_currentBrandImage = [UIImage imageNamed:@"questionaire_background.png"];
		
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		_currentShowTitle = [defaults objectForKey:mostRecentShowNameKey];
		
		if (!_currentShowTitle) {
			_currentShowTitle = defaultShowTitle;
			[_possibleShowTitles addObject:_currentShowTitle];
		}
		
		[self performSelector:@selector(uploadQuestionsInBackground)
				   withObject:nil
				   afterDelay:1.0f];
		
        // not used?
		/*NSTimer *submitTimer = [NSTimer scheduledTimerWithTimeInterval:5.0f
																target:self
															  selector:@selector(submitWithoutNotification)
															  userInfo:nil
															   repeats:YES];*/
	}
	
	return self;
}

- (PQSQuestion *)blankQuestion {
    PQSQuestion *blankQuestion = PQSQuestion.new;
    blankQuestion.fixedHeight = 10.0f;
    blankQuestion.preferredBackgroundTone = PQSQuestionViewPreferredBackgroundToneLight;
    return blankQuestion;
}

- (void)addHeader:(NSString *)title {
    PQSQuestion *header = [PQSQuestion new];
    header.questionType = PQSQuestionTypeNone;
    header.headerType = PQSHeaderTypePlain;
    header.question = title;
    [_questions addObject:header];
}

- (PQSQuestion *)questionForData:(NSDictionary *)question {
    NSString *type = question[@"type"];
    
    PQSQuestion *q = [PQSQuestion new];
    q.question = question[@"title"];
    q.attributedQuestion = [self boldText:question[@"title bold text"]
                                 inString:q.question];
    q.master = question[@"master"];
    q.observers = question[@"observers"];
    q.placeholderText = question[@"placeholderText"];
    q.scaleSuffix = q.placeholderText;
    
    if (q.scaleSuffix.length > 0) {
        NSLog(@"%@", q);
    } else {
        q.scaleSuffix = @"procedures monthly";
    }
    
    
    if ([type isEqualToString:@"PQSQuestionTypeCheckBoxes"]) {
        q.questionType = PQSQuestionTypeCheckBoxes;
        [q.possibleAnswers addObjectsFromArray:question[@"responses"]];
    }
    
    else if ([type isEqualToString:@"PQSQuestionTypeIncrementalValue"]) {
        q.questionType = PQSQuestionTypeIncrementalValue;
    }
    
    else if ([type isEqualToString:@"PQSQuestionTypeLargeNumber"]) {
        NSString *units = question[@"units"] ? question[@"units"] : @"";
        
        q.questionType = PQSQuestionTypeLargeNumber;
        q.scaleSuffix = units;
        q.placeholderText = units;
    }
    
    else if ([type isEqualToString:@"PQSQuestionTypeLongList"]) {
        q.questionType = PQSQuestionTypeLongList;
        q.placeholderText = defaultCountry;
        q.longListTitle = @"Select Country";
        q.hideBorder = NO;
        q.questionNumber = 1;
        [self countryCodeList];
        [q.possibleAnswers addObjectsFromArray:_countryCodeList.allKeys];
        [q.possibleAnswers sortUsingSelector:@selector(caseInsensitiveCompare:)];
        [q.urlKeys addEntriesFromDictionary:@{@"country" : @"In_what_country_do_you_practice"}];
    }
    
    else if ([type isEqualToString:@"PQSQuestionTypePercentage"]) {
        q.questionType = PQSQuestionTypePercentage;
    }
    
    else if ([type isEqualToString:@"PQSQuestionTypeRadioButtons"]) {
        NSArray *responses = question[@"responses"];
        NSDictionary *other = question[@"other"];
        
        q.questionType = PQSQuestionTypeRadioButtons;
        [q.possibleAnswers addObjectsFromArray:responses];
        
        if (other) {
            NSString *otherTitle = other[@"title"] ? other[@"title"] : @"Default Title";
            NSString *otherText = other[@"placeholder"] ? other[@"placeholder"] : @"Default Placeholder Text";
            
            [q.possibleAnswers addObject:otherTitle];
            
            PQSQuestion *otherQ = [PQSQuestion new];
            otherQ.questionType = PQSQuestionTypeTextView;
            otherQ.question = otherText;
            otherQ.placeholderText = otherText;
            
            q.triggerAnswer = [q.possibleAnswers lastObject];
            q.triggerQuestion = otherQ;
        }
    }
    
    else if ([type isEqualToString:@"PQSQuestionTypeScale"]) {
        float min = question[@"min"] ? [question[@"min"] floatValue] : 0;
        float max = question[@"max"] ? [question[@"max"] floatValue] : 10;
        float start = question[@"startingPoint"] ? [question[@"startingPoint"] floatValue] : roundf((q.minimumScale + q.maximumScale) / 2);
        float interval = question[@"interval"] ? [question[@"interval"] floatValue] : 1;
        
        NSString *units = question[@"units"] ? question[@"units"] : @"";
        NSString *label = question[@"label"] ? question[@"label"] : @"Default Label";
        
        q.questionType = PQSQuestionTypeScale;
        q.minimumScale = min;
        q.maximumScale = max;
        q.startingPoint = start;
        q.scaleInterval = interval;
        q.scaleSuffix = units;
        [q.scaleLabels addObject:label];
    }
    
    else if ([type isEqualToString:@"PQSQuestionTypeTextField"]) {
        q.questionType = PQSQuestionTypeTextField;
        q.placeholderText = question[@"placeholder"];
    }
    
    else if ([type isEqualToString:@"PQSQuestionTypeTextView"]) {
        q.questionType = PQSQuestionTypeTextView;
        q.placeholderText = question[@"placeholder"];
    }
    
    else if ([type isEqualToString:@"PQSQuestionTypeTrueFalse"]) {
        q.questionType = PQSQuestionTypeTrueFalse;
        q.useYesNoForTrueFalse = YES;
    }
    
    else if ([type isEqualToString:@"PQSQuestionType2WayExclusivityRadioButtons"]) {
        NSArray *answers = question[@"responses"];
        NSDictionary *other = question[@"other"];
        float min = [question[@"scale"][0] floatValue];
        float max = [question[@"scale"][1] floatValue];
        
        q.questionType = PQSQuestionType2WayExclusivityRadioButtons;
        [q.possibleAnswers addObjectsFromArray:answers];
        q.minimumScale = min;
        q.maximumScale = max;
        
        if (other) {
            NSString *otherTitle = other[@"title"] ? other[@"title"] : @"Default Title";
            NSString *otherText = other[@"placeholder"] ? other[@"placeholder"] : @"Default Placeholder Text";
            
            [q.possibleAnswers addObject:otherTitle];
            
            PQSQuestion *otherQ = [PQSQuestion new];
            otherQ.questionType = PQSQuestionTypeTextView;
            otherQ.question = otherText;
            otherQ.placeholderText = otherText;
            
            q.triggerAnswer = [q.possibleAnswers lastObject];
            q.triggerQuestion = otherQ;
        }
    }
    
    else if ([type isEqualToString:@"PQSQuestionTypeNone"]) {
        q.questionType = PQSQuestionTypeNone;
        NSString *ifRelevant = question[@"ifRelevant"];
        
        if (ifRelevant) {
            q.headerType = PQSHeaderTypeIfRelevant;
        } else {
            q.headerType = PQSHeaderTypeSub; // PQSHeaderTypePlain - to make sticky
        }
    }
    
    else if (type) {
        NSLog(@"*** Unknown type: %@", type);
        return nil;
    }
    
    else {
        NSLog(@"No question type provided");
        return nil;
    }
    
    return q;
}

- (void)uploadQuestionsInBackground {
	[self performSelectorInBackground:@selector(uploadQuestions)
						   withObject:nil];
}

- (void)uploadQuestions {
	NSMutableArray *questionsDescriptionArray = [[NSMutableArray alloc] initWithCapacity:_questions.count];
	
	
	int numberOfSubQuestions = 0;
	
	for (int i = 0; i < _questions.count; i++) {
		PQSQuestion *question = [_questions objectAtIndex:i];
		//NSLog(@"%@", question.question);
		[questionsDescriptionArray addObjectsFromArray:[self dictionariesForQuestion:question
																			  number:(i + numberOfSubQuestions)]];
	}
	
//	NSLog(@"Here's what I'm sending up: \n\n%@\n\n", @{@"question_set" : questionsDescriptionArray});
	
	NSError *error;
	NSData *jsondata = [NSJSONSerialization dataWithJSONObject:@{@"question_set" : questionsDescriptionArray}
													   options:NSJSONWritingPrettyPrinted
														 error:&error];
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://hyperactive.to/hyper_rest3/index.php/api/example/questions"]
														   cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
													   timeoutInterval:5.0];
	[request setValue:@"multipart/form-data" forHTTPHeaderField:@"Content-type"];
	[request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
	[request setHTTPMethod:@"POST"];
	[request setValue:[NSString stringWithFormat:@"%zd", [jsondata length]] forHTTPHeaderField:@"Content-Length"];
	[request setHTTPBody:jsondata];
	
	NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
	[configuration setHTTPAdditionalHeaders:@{ @"Accept": @"application/json",
											   @"Accept-Language": @"en_US",
											   @"Content-Type": @"multipart/form-data"}];
	NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
	
	
	NSURLSessionUploadTask *task = [session uploadTaskWithRequest:request
														 fromData:jsondata
												completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
													NSObject *responseObject;
													
													if (!error) {
														NSLog(@"Class: %@\t\tresponseObject:\n\n%@\n\n", [responseObject class], responseObject);
														responseObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
													} else if (error) {
														NSLog(@"Error:\n%@\n", error.localizedDescription);
													}
													
													if (response) {
														NSLog(@"Response: %@", response);
													}
													
													if (data) {
														NSLog(@"data: %@", [NSJSONSerialization JSONObjectWithData:data options:0 error:&error]);
													}
													
													if (responseObject) {
														NSDictionary *responseDictionary = [NSDictionary dictionaryWithDictionary:(NSDictionary *)responseObject];
														UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@""
																																 message:responseDictionary.allKeys.firstObject
																														  preferredStyle:UIAlertControllerStyleAlert];
														
														
														[alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
															textField.keyboardType = UIKeyboardTypeNumberPad;
															_specialTextField = textField;
														}];

														
														UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
																										   style:UIAlertActionStyleDefault
																										 handler:^(UIAlertAction *action) {
																											 
																										 }];
														[alertController addAction:okAction];
														
														UIAlertAction *showDetailAction = [UIAlertAction actionWithTitle:@"More..."
																												   style:UIAlertActionStyleDefault
																												 handler:^(UIAlertAction *action) {
																													 UIAlertController *secondController = [UIAlertController alertControllerWithTitle:responseDictionary.allKeys.firstObject
																																															   message:[responseDictionary objectForKey:responseDictionary.allKeys.firstObject] preferredStyle:UIAlertControllerStyleAlert];
																													 [secondController addAction:okAction];
																													 [self performSelectorOnMainThread:@selector(presentViewControllerInRootViewController:)
																																			withObject:secondController
																																		 waitUntilDone:YES];
																												 }];
														[alertController addAction:showDetailAction];
														
														
														
//														[self performSelectorOnMainThread:@selector(presentViewControllerInRootViewController:)
//																			   withObject:alertController
//																			waitUntilDone:YES];
													}
												}];
	
	[task resume];
}

- (void)presentViewControllerInRootViewController:(UIViewController *)viewControllerToPresent {
  UIWindow *rootWindow = [[UIApplication sharedApplication] windows].firstObject;
	[rootWindow.rootViewController presentViewController:viewControllerToPresent
                                                animated:YES
                                                        completion:^{
                                                           
                                                        }];
}

- (NSArray *)dictionariesForQuestion:(PQSQuestion *)question number:(int)number {
	NSMutableArray *dictionaries = [NSMutableArray new];
	for (NSString *questionText in question.urlKeys.allKeys) {
		NSMutableDictionary *questionDescriptionDictionary = [[NSMutableDictionary alloc] init];
		
		[questionDescriptionDictionary setObject:@(number)
										  forKey:@"display_order"];
		[questionDescriptionDictionary setObject:[question.urlKeys objectForKey:questionText]
										  forKey:@"question_key"];
		[questionDescriptionDictionary setObject:defaultShowKey
										  forKey:@"event_key"];
		[questionDescriptionDictionary setObject:questionText
										  forKey:@"text"];
		
		[dictionaries addObject:questionDescriptionDictionary];
	}
	
	if (question.trueConditionalQuestion) {
		[dictionaries addObjectsFromArray:[self dictionariesForQuestion:question.trueConditionalQuestion
																 number:number]];
	}
	
	if (question.falseConditionalQuestion) {
		[dictionaries addObjectsFromArray:[self dictionariesForQuestion:question.falseConditionalQuestion
																 number:number]];
	}
	
	return dictionaries;
}

- (void)createKeys {
	if (!_questionsAndKeys) {
		_questionsAndKeys = [NSMutableDictionary new];
	} else {
		[_questionsAndKeys removeAllObjects];
	}
	
	NSMutableArray *questionsToCreateKeysFor = [[NSMutableArray alloc] initWithArray:_questions];
	for (PQSQuestion *question in _questions) {
		if (question.trueConditionalQuestion) {
			[questionsToCreateKeysFor addObject:question.trueConditionalQuestion];
		}
		
		if (question.falseConditionalQuestion) {
			[questionsToCreateKeysFor addObject:question.falseConditionalQuestion];
		}
		
		if (question.triggerQuestion) {
			[questionsToCreateKeysFor addObject:question.triggerQuestion];
		}
		
		for (PQSQuestion *subQuestion in question.multipleColumnQuestions) {
			[questionsToCreateKeysFor addObject:subQuestion];
		}
	}
	
	for (PQSQuestion *question in questionsToCreateKeysFor) {
		if (question.questionType != PQSQuestionTypeNone) {
			if (question.urlKeys.count == 0) {
				if (question.questionType == PQSQuestionTypeCheckBoxes) {
					NSLog(@"Figure out what to do here");
				} else {
					NSString *key = [self keyForQuestion:question];
					
					[question.urlKeys addEntriesFromDictionary:@{question.question : key}];
					
					if ([_questionsAndKeys objectForKey:key]) {
						NSLog(@"I can't use this key! key: %@", key);
					}  else {
						[_questionsAndKeys setObject:question.question forKey:key];
					}
				}
			}
		}
	}
	
	NSMutableString *ordered_questionsAndKeys = [NSMutableString new];
	for (PQSQuestion *question in _questions) {
		if (question.questionType != PQSQuestionTypeNone) {
			[ordered_questionsAndKeys appendFormat:@"%@\n", question.urlKeys];
		}
	}
	
	//NSLog(@"%@", [[ordered_questionsAndKeys stringByReplacingOccurrencesOfString:@"{" withString:@""] stringByReplacingOccurrencesOfString:@"}" withString:@""]);
}

- (NSString *)keyForQuestion:(PQSQuestion *)question {
	int maxKeyLength = 20;

    NSString *formattedKey = [self formatKey:question.question];
    NSString *formattedAndTrimmedKey = [self trimKey:formattedKey toLength:maxKeyLength];
    
//    NSLog(@"formattedKey is: %@", formattedAndTrimmedKey);
	
	if ([_questionsAndKeys objectForKey:formattedAndTrimmedKey]) {
		NSLog(@"The key already exists!");
	}
	
	return formattedAndTrimmedKey;
}

- (NSString *)trimKey:(NSString *)key toLength:(int)length {
    
    NSString *trimmedKey;
    
    if (key.length > length) {
        // trim to length
        trimmedKey = [key substringToIndex:length];
    } else {
        // not long enough, don't trim
        trimmedKey = key;
    }
    
    // if dictionary already contains key, add characters to key
    if ([_questionsAndKeys.allKeys containsObject:trimmedKey] || [_questionsAndKeys objectForKey:trimmedKey]) {
        length = length + 2;
        
        // while key is too short, append it to itself until it is long enough to trim
        while (key.length < length) {
            key = [key stringByAppendingString:key];
        }
        
        trimmedKey = [self trimKey:key toLength:length];
    }
    
    return trimmedKey;
}

- (NSString *)formatKey:(NSString *)key {
    // format string (remove all non alphanumeric characters)
    return [[key componentsSeparatedByCharactersInSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]] componentsJoinedByString:@""];
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


- (CLLocationManager *)locationManager {
	if (!_locationManager) {
		_locationManager = [[CLLocationManager alloc] init];
		_locationManager.delegate = self;
		_locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
		
		if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0 &&
			[CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedWhenInUse) {
			[_locationManager requestWhenInUseAuthorization];
		} else {
			[_locationManager startUpdatingLocation];
		}
		
		if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
			[self.locationManager requestWhenInUseAuthorization];
		}
		
		if([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]){
			NSUInteger code = [CLLocationManager authorizationStatus];
			if (code == kCLAuthorizationStatusNotDetermined && ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)] || [self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])) {
				// choose one request according to your business.
				if([[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationAlwaysUsageDescription"]){
					[self.locationManager requestAlwaysAuthorization];
				} else if([[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationWhenInUseUsageDescription"]) {
					[self.locationManager  requestWhenInUseAuthorization];
				} else {
					NSLog(@"Info.plist does not contain NSLocationAlwaysUsageDescription or NSLocationWhenInUseUsageDescription");
				}
			}
		}
		
		[self.locationManager startUpdatingLocation];
	}
	
	return _locationManager;
}

- (void)setupLocationManager {
	if (![CLLocationManager authorizationStatus]) {
		if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
			[self.locationManager requestWhenInUseAuthorization];
		}
	}
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSDate *lastLocationUpdateDate = [defaults objectForKey:LAST_LOCATION_UPDATE_DATE_KEY];
	if (!lastLocationUpdateDate || [lastLocationUpdateDate timeIntervalSinceNow] < -ONE_DAY_IN_SECOND) {
		[self.locationManager startUpdatingLocation];
	}
	
	if (lastLocationUpdateDate) {
		CLLocationDegrees latitude = [defaults doubleForKey:[NSString stringWithFormat:@"%@Latitude", lastLocationUpdateDate]];
		CLLocationDegrees longitude = [defaults doubleForKey:[NSString stringWithFormat:@"%@Longitude", lastLocationUpdateDate]];
		_currentLocationCoordinate = CLLocationCoordinate2DMake(latitude, longitude);
	} else {
		[self.locationManager startUpdatingLocation];
	}
	
	NSLog(@"%g", _currentLocationCoordinate.longitude);
	
	[self checkForLocationManager];
}

- (void)checkForLocationManager {
	if (!self.locationManager) {
		NSLog(@"Well, this is awkward...there's no Location Manager");
	}
	
	[self performSelector:@selector(checkForLocationManager) withObject:self afterDelay:1.0f];
}

#pragma mark - Public Methods

- (NSArray *)questions {
	return _questions;
}

- (NSArray *)headers {
	return _headers;
}

- (PQSQuestion *)questionAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section < _headers.count) {
		PQSQuestion *header = [_headers objectAtIndex:indexPath.section];
		
		if (indexPath.row < header.subQuestions.count && indexPath.row >= 0) {
			return [header.subQuestions objectAtIndex:indexPath.row];
		} else {
			return header;
		}
	}
	
	NSLog(@"I couldn't find a question for you!");
	
	if (indexPath.section < _questions.count) {
		return [_questions objectAtIndex:indexPath.section];
	}
	
	return nil;
}

- (UIImage *)brandImage {
	return _currentBrandImage;
}

- (NSString *)currentShowTitle {
	return _currentShowTitle;
}

- (NSArray *)possibleShowTitles {
	if (_possibleShowTitles.count == 0) {
		[_possibleShowTitles addObjectsFromArray:@[defaultShowTitle]];
	}
	
	NSMutableArray *possibleShowTitles = [[NSMutableArray alloc] initWithCapacity:_possibleShowTitles.count];
	for (NSObject *object in _possibleShowTitles) {
		[possibleShowTitles addObject:object];
	}
	
	return [NSArray arrayWithArray:possibleShowTitles];
}

- (void)setShowTitle:(NSString *)showTitle {
	if (showTitle && [_possibleShowTitles containsObject:showTitle]) {
		_currentShowTitle = showTitle;
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		[defaults setObject:showTitle forKey:mostRecentShowNameKey];
	} else {
		NSLog(@"Non-Fatal Error: showTitle is not an element of _possibleShowTitles. Resolve this error or the server may not be as forgiving.");
	}
}

- (CLLocationCoordinate2D)currentLocationCoordinate {
	return _currentLocationCoordinate;
}

- (NSString *)currentLocationString {
	return [NSString stringWithFormat:@"%f, %f", _currentLocationCoordinate.latitude, _currentLocationCoordinate.longitude];
}

- (void)setCurrentQuestion:(PQSQuestion *)question {
	_currentQuestion = question;
}

- (PQSQuestion *)currentQuestion {
	return _currentQuestion;
}

- (void)answerCurrentQuestion:(NSString *)answer {
	if (_currentQuestion) {
		[self submitAnswer:answer forQuestion:_currentQuestion];
	} else {
		NSLog(@"Answer submitted for current question, but the current question was never set.");
	}
}

#pragma mark - Submitting Answers

- (void)layoutObserversOfCondition:(NSDictionary *)condition hidden:(BOOL)hidden {
 
    if (!hidden) {
        for (PQSQuestion *q in self.questions) {
            
            if (q.observers) {
                NSLog(@"************** Q: %@", q.question);
            }
        }
    }
}

- (void)checkConditionsForQuestion:(PQSQuestion *)question withAnswer:(NSString *)answer {
    
    /*
     * If there are conditions set for question, verify them
     * If conditions are met, check for observers of this condition
     * For these observers, show/hide as appropriate
     */
    
    NSDictionary *condition = question.master;
    
    if (condition) {
        
        
        NSString *operator = condition[@"condition"][@"operator"];
        float conditionVal = [condition[@"condition"][@"comparison"] floatValue];
        float val = [answer floatValue];
        
        BOOL meetsCondition;
        
        if ([operator isEqualToString:@"=="]) meetsCondition = val == conditionVal;
        else if ([operator isEqualToString:@">"]) meetsCondition = val > conditionVal;
        else if ([operator isEqualToString:@"<"]) meetsCondition = val < conditionVal;
        
        
        NSLog(@"meetsCondition: %d", meetsCondition);
        
        // layout view for observers
        [self layoutObserversOfCondition:condition hidden:!meetsCondition];
    }
    
}

- (void)submitAnswer:(NSString *)answer forQuestion:(PQSQuestion *)question {
    question.currentAnswerString = answer;
    NSLog(@"Question answer: %@", question.currentAnswerString);
	BOOL submitted = NO;
	if (answer && question) {
        
        [self checkConditionsForQuestion:question withAnswer:answer];
        
		for (NSString *tempKey in question.urlKeys.allKeys) {
			if ([question.question rangeOfString:tempKey].location != NSNotFound) {
				[self submitAnswer:answer withKey:[question.urlKeys objectForKey:tempKey]];
				submitted = YES;
			}
		}
		
		if (!submitted) {
//			[_answers setObject:answer forKey:question.question];
			[self submitAnswer:answer withKey:question.question];
			NSLog(@"Couldn't find a key to submit with, so we're going with submitting using the question itself");
		}
	} else {
		NSLog(@"Both answer and question are requred for submission.");
	}
}

- (void)submitAnswer:(NSString *)answer withKey:(NSString *)key {
	if (answer && key) {
		NSString *formattedAnswer = [answer stringByReplacingOccurrencesOfString:@" " withString:@"_"];
		NSString *formattedKey = [self formatKey:key];
		NSLog(@"\tSubmitting:\t%@\n\t\t\t\t\t\t\t\tWithKey:\t%@", formattedAnswer, formattedKey);
		[_answers setObject:formattedAnswer forKey:formattedKey];
	} else {
		NSLog(@"Both answer and key are requred for submission.\t\tAnswer: \t%@\tKey: \t%@", answer, key);
	}
}

- (BOOL)saveAnswerLocally {
	NSDictionary *localTempCopyAnswer = [self dictionaryForAnswers:_answers];
	
	// store the answer locally
	
	_answers = [[NSMutableDictionary alloc] initWithCapacity:_questions.count];
	
//	NSLog(@"%@", [self formatAnswersForServer]);
	
//	[self submitAnswersToServer:[NSDictionary dictionaryWithDictionary:_answers]];
	
	if (localTempCopyAnswer && localTempCopyAnswer.count > 4) {
		[_answersArray addObject:localTempCopyAnswer];
		NSString *urlString = [self urlStringFromDictionary:localTempCopyAnswer];
		[self saveStringLocally:urlString];
		[_requestStrings addObject:urlString];
		return YES;
	} else if (!localTempCopyAnswer) {
		NSLog(@"No dictionary of answers. Can't do much with nothing.");
	} else if (localTempCopyAnswer.count <= 3) {
		NSLog(@"Dictionary of answers only has %zd answer%@, and that makes it pretty much unusable.\n\nKeys included:\n%@\n", localTempCopyAnswer.count, localTempCopyAnswer.count == 1 ? @"" : @"s", localTempCopyAnswer);
	}
	
	return NO;
}

/**
 *  Takes in a Dictionary with answers and formats the keys and answers to match up for the server to format
 *
 *  @param answerDictionary Answers in a human readable KVP format
 *
 *  @return dictionary ready to be turned into a URL
 */
- (NSDictionary *)dictionaryForAnswers:(NSDictionary *)answerDictionary {
	NSMutableDictionary *localTempCopyAnswer = [NSMutableDictionary new];
	
	BOOL canSave = YES; // created a separate flag to allow for more tests to check for question validity later on
	for (int i = 0; i < _questions.count; i++) {
		PQSQuestion *question = [_questions objectAtIndex:i];

		if ((![answerDictionary objectForKey:question.question] && question.isRequired) || (i + 1 == _questions.count && localTempCopyAnswer.count > 0)) {
			canSave = NO;
			return nil;
		}
	}
	
	[localTempCopyAnswer addEntriesFromDictionary:_answers]; // this is temporary and should be fixed
    
    // if today's date field has not been altered, send current date value to server (should match default value)
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMMM_dd,_yyyy"];
    
    // get today
    NSString *today = [dateFormatter stringFromDate:[NSDate date]];
    
    // get tomorrow - no default value for expiration date, so this isn't needed, but I'm leaving it here in case this changes.
//    NSCalendar *theCalendar = [NSCalendar currentCalendar];
//    NSDateComponents *dayComponent = [[NSDateComponents alloc] init];
//    dayComponent.day = 1;
//    NSString *tomorrow = [dateFormatter stringFromDate:[theCalendar dateByAddingComponents:dayComponent toDate:[NSDate date] options:0]];
    
    // create questions dictionaries for questions that need default responses
    // I don't think this is the best place to do this, but it works and ..deadline
    NSArray *questionsWithDefaultValues = @[
                                            //@{@"key": @"SingleUseScopeExpira", @"date": tomorrow},
                                            @{@"key": @"TodaysDate", @"date": today}
                                          ];
    
    for (NSDictionary *question in questionsWithDefaultValues) {
        NSString *key = question[@"key"];
        NSString *date = question[@"date"];
        
        if (![localTempCopyAnswer objectForKey:key]) {
            // add default value
            [localTempCopyAnswer setObject:date forKey:key];
        }
    }
	
	[localTempCopyAnswer setObject:[self currentLocationString] forKey:@"geolocation"];
	
	[localTempCopyAnswer setObject:[defaultShowKey stringByReplacingOccurrencesOfString:@" " withString:@"_"] forKey:@"event_key"];
	
	NSString *dateString = [_dateFormatter stringFromDate:[NSDate date]];
	[localTempCopyAnswer setObject:dateString forKey:@"created_datetime"];
	
	//NSLog(@"%@", localTempCopyAnswer);
	
	return localTempCopyAnswer;
}

- (NSString *)urlStringFromDictionary:(NSDictionary *)answerDictionary {
	NSString *sessionKey = [[NSString stringWithFormat:@"%@_%@", [NSDate date], [[UIDevice currentDevice] name]] stringByReplacingOccurrencesOfString:@"’" withString:@""];
	
	[answerDictionary setValue:sessionKey forKey:@"session_key"];
	
	[answerDictionary setValue:companyKey forKey:@"company_key"];
	
	NSMutableString *requestString = [NSMutableString stringWithString:submissionURLString];
	
	for (int i = 0; i < answerDictionary.allKeys.count; i++) {
		NSString *key = [[[answerDictionary.allKeys objectAtIndex:i] stringByReplacingOccurrencesOfString:@"?" withString:@""] stringByReplacingOccurrencesOfString:@"'" withString:@"_"];
		NSString *value = [[[answerDictionary objectForKey:key] stringByReplacingOccurrencesOfString:@"?" withString:@""] stringByReplacingOccurrencesOfString:@"’" withString:@"_"];
		[requestString appendFormat:@"%@=%@", key, value];
		
		if (i + 1 < answerDictionary.allKeys.count) {
			[requestString appendString:@"&"];
		}
	}
	
	
	NSString *finalString = [[requestString stringByReplacingOccurrencesOfString:@"’" withString:@"_"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	
	NSLog(@"finalString: \"\n%@\n\"", finalString);
	
	return finalString;
}

/**
 *  Transforms a specific type of answer to an int string for responding with JSON
 *
 *  @discussion I like tacos even though I eat them in a funny way.
 *
 *  @param likeliness "More Likely" or "Less Likely" or anything else.
 *
 *  @return 1,2, or 3 corresponding to the likeliness of someone to agree with the original answer
 */
- (NSString *)likelinessToIntString:(NSString *)likeliness {
	if ([[likeliness lowercaseString] isEqualToString:[@"More Likely" lowercaseString]]) {
		return @"3";
	} else if ([[likeliness lowercaseString] isEqualToString:[@"Less Likely" lowercaseString]]) {
		return @"1";
	}
	
	return @"2";
}

- (void)submitCurrentAnswers {
	[self submitAnswersToServer:_answers notifyUser:YES];
}

- (void)submitCurrentAnswers:(BOOL)notifyUser {
	[self submitAnswersToServer:_answers notifyUser:notifyUser];
}

- (void)submitAnswersToServer:(NSDictionary *)answers notifyUser:(BOOL)notifyUsers {
	[self submitAnswersToServer:notifyUsers];
}

- (void)submitWithoutNotification {
	[self submitAnswersToServer:NO];
}

- (void)submitWithNotification {
	[self submitAnswersToServer:YES];
}

- (void)submitAnswersToServer:(BOOL)notifyUser {
	if (![_reach currentReachabilityStatus]) {
		if ([self.delegate respondsToSelector:@selector(noNetworkConnection)]) {
			[self.delegate noNetworkConnection];
		}
		
		[self saveRequests];
	} else if ([_reach currentReachabilityStatus]
			   && _requestStrings.count > 0
			   && ([_lastRemoteSubmissionDate timeIntervalSinceNow] < -5.0f
				   || !_lastRemoteSubmissionDate)) {
		_lastRemoteSubmissionDate = [NSDate date];
		
		for (NSString *completedRequestString in _completedRequests) {
			[_requestStrings removeObject:completedRequestString];
		}
		
		for (NSString *urlString in _requestStrings) {
			NSString *requestString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
			//NSLog(@"%@", requestString);

			NSURL *url = [NSURL URLWithString:requestString];
			NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
			request.HTTPMethod = @"GET";
//			[request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
//			[request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
//			[request setValue:[NSString stringWithFormat:@"%d", data.length] forHTTPHeaderField:@"Content-Length"];
//			[request setHTTPBody:data];
			
			NSURLResponse *response = nil;
			NSError *error = nil;
			
			NSData *result = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
			
			NSString *resultString = [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
			
			if ([[resultString lowercaseString] rangeOfString:@"fail"].location != NSNotFound) {
				NSLog(@"Fail returned:\n%@\n", resultString);
				if ([self.delegate respondsToSelector:@selector(sentToServerFailure)] && notifyUser) {
					[self.delegate sentToServerFailure];
				}
				
				[self saveStringLocally:urlString];
			} else if ([resultString rangeOfString:@"success"].location != NSNotFound){
				NSLog(@"Yay, it worked!\n\"\n%@\n\"\n\n", resultString);
				if ([self.delegate respondsToSelector:@selector(sentToServerSuccessfully)] && notifyUser) {
					[self.delegate sentToServerSuccessfully];
				}
				
				[_completedRequests addObject:urlString];
				[self saveCompletedRequest:urlString];
			} else {
				NSLog(@"Unknown Response: %@", resultString);
			}
		}
	} else if (_requestStrings.count == 0) {
		if ([self.delegate respondsToSelector:@selector(noRequestsToSend)] && notifyUser) {
			[self.delegate noRequestsToSend];
		}
	} else {
		[self performSelector:@selector(submitWithNotification) withObject:nil afterDelay:60.0f]; // try again in a minute
		[self saveRequests];
	}
}

- (void)makeServerRequestWithString:(NSString *)requestString {
	requestString = [requestString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:requestString]];
	
	// Create url connection and fire request
	NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	NSLog(@"Current request: \"\n%@\n\"", conn.currentRequest.URL);
}

/**
 *  Creates a JSON **string** using the current _answersArray
 *
 *  @return JSON string.
 */
- (NSString *)formatAnswersForServer {
	NSMutableString *formattedString = [[NSMutableString alloc] initWithString:@"{\n\t\"questionnaire\":{"];
	
	if (_answersArray.count > 0) {
		[formattedString appendFormat:@"\n\"results\":[\n%@", _answersArray.firstObject];
	}
	
	for (int i = 1; i < _answersArray.count; i++) {
		[formattedString appendFormat:@",\n%@", [[_answersArray objectAtIndex:i] description]];
	}
	
	[formattedString appendFormat:@"\n\t]\n\t}\n}"];
	
	return formattedString;
}

- (void)saveRequests {
	for (NSString *requestString in _requestStrings) {
		if (![_completedRequests containsObject:requestString]) {
			[self saveStringLocally:requestString];
		}
	}
}

- (void)saveStringLocally:(NSString *)input {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSInteger numberOfStringsSaved = [defaults integerForKey:primaryKey];
	numberOfStringsSaved++;
	[defaults setObject:input forKey:NUMERIC_KEY_FOR_INT(numberOfStringsSaved)];
	[defaults setInteger:numberOfStringsSaved forKey:primaryKey];
	
	NSString *completedKey = [self completedDateStringForURLString:input];
	if (completedKey) {
		[defaults setBool:NO forKey:completedKey];
	}
}

- (void)saveCompletedRequest:(NSString *)completedRequest {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSInteger numberOfCompletedRequestsSaved = [defaults integerForKey:completedRequestKey];
	numberOfCompletedRequestsSaved++;
	[defaults setObject:completedRequest forKey:COMPLETED_REQUEST_KEY_FOR_INT(numberOfCompletedRequestsSaved)];
	[defaults setInteger:numberOfCompletedRequestsSaved forKey:completedRequestKey];
	NSString *completedKey = [self completedDateStringForURLString:completedRequest];
	if (completedKey) {
		[defaults setBool:YES forKey:completedKey];
	}
}

- (void)loadStringsFromDefaults {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSInteger numberOfStringsSaved = [defaults integerForKey:primaryKey];

	for (NSInteger i = numberOfStringsSaved; i >= 0; i--) {
		NSString *currentString = [defaults objectForKey:NUMERIC_KEY_FOR_INT(i)];
		if (currentString) {
			NSString *completedKey = [self completedDateStringForURLString:currentString];
			if (!(completedKey && [defaults boolForKey:completedKey])) {
				[_requestStrings addObject:currentString];
				[defaults removeObjectForKey:NUMERIC_KEY_FOR_INT(i)];
				[defaults setInteger:i forKey:primaryKey];
			}
		}
	}
}

- (NSString *)completedDateStringForURLString:(NSString *)urlString {
	NSRange dateTimeRange = [urlString rangeOfString:@"created_datetime="];
	int lengthOfDateString = 21;
	if (dateTimeRange.location != NSNotFound && dateTimeRange.location + dateTimeRange.length + lengthOfDateString <= urlString.length) {
		NSString *dateString = [[urlString substringWithRange:NSMakeRange(dateTimeRange.location + dateTimeRange.length, lengthOfDateString)] stringByReplacingOccurrencesOfString:@"%20" withString:@" "];
		NSString *completedKey = [NSString stringWithFormat:@"%@Completed", dateString];
		return completedKey;
	}
	
	return nil;
}

#pragma mark - NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	// A response has been received, this is where we initialize the instance var you created
	// so that we can append data to it in the didReceiveData method
	// Furthermore, this method is called each time there is a redirect so reinitializing it
	// also serves to clear it
	_responseData = [[NSMutableData alloc] init];
	
	NSLog(@"- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response");
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	NSLog(@"didReceiveData %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
	
	// Append the new data to the instance variable you declared
	[_responseData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
				  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
	// Return nil to indicate not necessary to store a cached response for this connection
	return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	// The request is complete and data has been received
	// You can parse the stuff in your instance variable now
	
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	// The request has failed for some reason!
	// Check the error var
}

#pragma mark - Location Manager Delegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
	if (locations.count > 0) {
		CLLocation *currentLocation = [locations firstObject];
		_currentLocationCoordinate = currentLocation.coordinate;
		
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		NSDate *lastLocationUpdateDate = [NSDate date];
		[defaults setDouble:_currentLocationCoordinate.latitude forKey:[NSString stringWithFormat:@"%@Latitude", lastLocationUpdateDate]];
		[defaults setDouble:_currentLocationCoordinate.longitude forKey:[NSString stringWithFormat:@"%@Longitude", lastLocationUpdateDate]];
		[defaults setObject:lastLocationUpdateDate forKey:LAST_LOCATION_UPDATE_DATE_KEY];
		
		if (_currentLocationCoordinate.longitude != 0 && _currentLocationCoordinate.latitude != 0) {
			NSLog(@"%g, %g", _currentLocationCoordinate.longitude, _currentLocationCoordinate.latitude);
			[_locationManager stopUpdatingLocation];
		}
	} else {
		NSLog(@"Location Manager updated with new \"locations\" but there weren't any locations in the array that it returned.");
	}
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
	NSLog(@"Failed %@", error);
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
	switch (status) {
		case kCLAuthorizationStatusNotDetermined: {
			NSLog(@"User has neither granted nor denied location permission");
		} break;
		
		case kCLAuthorizationStatusDenied: {
			NSLog(@"User denies location access. Consider implementing a preset list of locations the user can hceck out.");
		} break;
		
		case kCLAuthorizationStatusAuthorizedWhenInUse:
		case kCLAuthorizationStatusAuthorizedAlways: {
			[self.locationManager startUpdatingLocation];
		} break;
			
		default: {
		} break;
	}
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

- (PQSQuestion *)whichCountryQuestion {
	PQSQuestion *whichCountryQuestion = [[PQSQuestion alloc] init];
	NSMutableAttributedString *whichCountryQuestionAttributedString = [[NSMutableAttributedString alloc]initWithString:@"In which country do you practice?"];
	UIFont *whichCountryQuestionAttributedStringFont1 = [UIFont appFont];
	UIFont *whichCountryQuestionAttributedStringFont2 = [UIFont boldAppFont];
	[whichCountryQuestionAttributedString addAttribute:NSFontAttributeName value:whichCountryQuestionAttributedStringFont1 range:NSMakeRange(0,9)];
	[whichCountryQuestionAttributedString addAttribute:NSUnderlineStyleAttributeName value:@(1) range:NSMakeRange(9,7)];
	[whichCountryQuestionAttributedString addAttribute:NSFontAttributeName value:whichCountryQuestionAttributedStringFont2 range:NSMakeRange(9,7)];
	[whichCountryQuestionAttributedString addAttribute:NSFontAttributeName value:whichCountryQuestionAttributedStringFont1 range:NSMakeRange(17,16)];
	whichCountryQuestion.attributedQuestion = whichCountryQuestionAttributedString;
	whichCountryQuestion.question = whichCountryQuestionAttributedString.string;
	whichCountryQuestion.questionType = PQSQuestionTypeLongList;
	whichCountryQuestion.placeholderText = defaultCountry;
	whichCountryQuestion.longListTitle = @"Select Country";
	whichCountryQuestion.hideBorder = NO;
	whichCountryQuestion.questionNumber = 1;
	[self countryCodeList];
	[whichCountryQuestion.possibleAnswers addObjectsFromArray:_countryCodeList.allKeys];
	[whichCountryQuestion.possibleAnswers sortUsingSelector:@selector(caseInsensitiveCompare:)];
	[whichCountryQuestion.urlKeys addEntriesFromDictionary:@{@"country" : @"In_what_country_do_you_practice"}];

	return whichCountryQuestion;
}

@end
