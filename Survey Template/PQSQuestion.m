//
//  PQSQuestion.m
//  Philips Questionaire
//
//  Created by HAI on 5/8/15.
//  Copyright (c) 2015 HAI. All rights reserved.
//

#import "PQSQuestion.h"
#import "UIFont+AppFonts.h"
#import "PQSReferenceManager.h"

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kStatusBarHeight (([[UIApplication sharedApplication] statusBarFrame].size.height == 20.0f) ? 20.0f : (([[UIApplication sharedApplication] statusBarFrame].size.height == 40.0f) ? 20.0f : 0.0f))
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#define SHORTER_SIDE ((kScreenWidth < kScreenHeight) ? kScreenWidth : kScreenHeight)
#define LONGER_SIDE ((kScreenWidth > kScreenHeight) ? kScreenWidth : kScreenHeight)

@implementation PQSQuestion {
	UISegmentedControl *_segmentedControl;
    NSMutableDictionary *_countryCodeList;
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

+ (instancetype)blankQuestion {
    PQSQuestion *question = PQSQuestion.new;
    
    question.preferredBackgroundTone = PQSQuestionViewPreferredBackgroundToneLight;
    
    return question;
}

+ (instancetype)blankQuestionWithHeight:(CGFloat)height {
    PQSQuestion *question = PQSQuestion.blankQuestion;
    
    question.fixedHeight = height;
    
    return question;
}


+ (instancetype)checkBoxesQuestion {
    PQSQuestion *question = PQSQuestion.new;
    
    question.questionType = PQSQuestionTypeCheckBoxes;
    
    return question;
}

+ (instancetype)dateQuestion {
    PQSQuestion *question = PQSQuestion.new;
    
    question.questionType = PQSQuestionTypeDate;
    
    return question;
}

+ (instancetype)incrementalQuestion {
    PQSQuestion *question = PQSQuestion.new;
    
    question.questionType = PQSQuestionTypeIncrementalValue;
    
    return question;
}


+ (instancetype)largeNumberQuestion {
    PQSQuestion *question = PQSQuestion.new;
    
    question.questionType = PQSQuestionTypeLargeNumber;
    
    return question;
}

+ (instancetype)longListQuestion {
    PQSQuestion *question = PQSQuestion.new;
    
    question.questionType = PQSQuestionTypeLongList;
    
    return question;
}

+ (instancetype)multiColumnConditionalQuestion {
    PQSQuestion *question = PQSQuestion.new;
    
    question.questionType = PQSQuestionTypeMultiColumnConditional;
    
    return question;
}

+ (instancetype)multipleChoiceQuestion {
    PQSQuestion *question = PQSQuestion.new;
    
    question.questionType = PQSQuestionTypeMultipleChoice;
    
    return question;
}

+ (instancetype)oneToTenQuestion {
    PQSQuestion *question = PQSQuestion.new;
    
    question.questionType = PQSQuestionType1to10;
    question.minimumScale = 1;
    question.maximumScale = 10;
    
    return question;
}

+ (instancetype)percentageQuestion {
    PQSQuestion *question = PQSQuestion.new;
    
    question.questionType = PQSQuestionTypePercentage;
    
    return question;
}

+ (instancetype)radioButtonsQuestion {
    PQSQuestion *question = PQSQuestion.new;
    
    question.questionType = PQSQuestionTypeRadioButtons;
    
    return question;
}

+ (instancetype)scaleQuestion {
    PQSQuestion *question = PQSQuestion.new;
    
    question.questionType = PQSQuestionTypeScale;
    
    return question;
}

+ (instancetype)splitPercentageQuestion {
    PQSQuestion *question = PQSQuestion.new;
    
    question.questionType = PQSQuestionTypeSplitPercentage;
    
    return question;
}

+ (instancetype)textFieldQuestion {
    PQSQuestion *question = PQSQuestion.new;
    
    question.questionType = PQSQuestionTypeTextField;
    
    return question;
}

+ (instancetype)textViewQuestion {
    PQSQuestion *question = PQSQuestion.new;
    
    question.questionType = PQSQuestionTypeTextView;
    
    return question;
}

+ (instancetype)timeQuestion {
    PQSQuestion *timeQuestion = PQSQuestion.new;
    
    timeQuestion.questionType = PQSQuestionTypeTime;
    timeQuestion.scaleSuffix = @" Minutes  ";

    return timeQuestion;
}

+ (instancetype)trueFalseQuestion {
    PQSQuestion *question = PQSQuestion.new;
    
    question.questionType = PQSQuestionTypeTrueFalse;
    
    return question;
}

+ (instancetype)trueFalseConditionalQuestion {
    PQSQuestion *question = PQSQuestion.new;
    
    question.questionType = PQSQuestionTypeTrueFalseConditional;
    
    return question;
}

+ (instancetype)trueFalseConditional2Question {
    PQSQuestion *question = PQSQuestion.new;
    
    question.questionType = PQSQuestionTypeTrueFalseConditional2;
    
    return question;
}

+ (instancetype)twoWayExclusivityQuestion {
    PQSQuestion *question = PQSQuestion.new;
    
    question.questionType = PQSQuestionType2WayExclusivityRadioButtons;
    
    return question;
}

+ (instancetype)whichCountryQuestion {
    PQSQuestion *question = PQSQuestion.new;
    question = question.whichCountryQuestion; // this can be cleaned up and simplified
    
    return question;
}

+ (instancetype)yesNoQuestion {
    PQSQuestion *question = PQSQuestion.new;
    
    question.questionType = PQSQuestionTypeTrueFalse;
    
    question.useYesNoForTrueFalse = YES;
    
    return question;
}

+ (instancetype)yesNoConditionalQuestion {
    PQSQuestion *question = PQSQuestion.new;
    
    question.questionType = PQSQuestionTypeTrueFalseConditional;
    
    question.useYesNoForTrueFalse = YES;
    
    return question;
}

+ (instancetype)yesNoConditional2Question {
    PQSQuestion *question = PQSQuestion.new;
    
    question.questionType = PQSQuestionTypeTrueFalseConditional2;
    
    question.useYesNoForTrueFalse = YES;
    
    return question;
}


+ (instancetype)detailHeader {
    PQSQuestion *header = PQSQuestion.new;
    
    header.headerType = PQSHeaderTypeDetail;
    
    return header;
}

+ (instancetype)finePrintHeader {
    PQSQuestion *header = PQSQuestion.new;
    
    header.headerType = PQSHeaderTypeFinePrint;
    header.preferredBackgroundTone = PQSQuestionViewPreferredBackgroundToneLight;
    
    return header;
}

+ (instancetype)plainHeader {
    PQSQuestion *header = PQSQuestion.new;
    
    header.headerType = PQSHeaderTypePlain;
    
    return header;
}

+ (instancetype)subHeader {
    PQSQuestion *header = PQSQuestion.new;
    
    header.headerType = PQSHeaderTypeSub;
    
    return header;
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


@end
