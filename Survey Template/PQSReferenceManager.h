//
//  PQSReferenceManager.h
//  Philips Questionaire
//
//  Created by HAI on 5/8/15.
//  Copyright (c) 2015 HAI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

#import "PQSQuestion.h"

typedef NS_ENUM(NSUInteger, PQSCompany) {
    PQSCompanyNone,
    PQSCompanyBSCI,
    PQSCompanyPHIL,
    PQSCompanyHAI
};

@protocol PQSReferenceManagerDelegate <NSObject>

@required
- (void)sentToServerSuccessfully;
- (void)sentToServerFailure;
- (void)noRequestsToSend;
- (void)noNetworkConnection;

@end

@interface PQSReferenceManager : NSObject <NSURLConnectionDelegate, CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (assign) id <PQSReferenceManagerDelegate> delegate;

/**
 *  Singleton to reference all of the data for the survey
 *
 *  @return PQSReferenceManager object
 */
+ (instancetype)sharedReferenceManager;

/**
 *  Immutable array of questions in the currently loaded survey.
 *
 *  @return Immutable array of questions in the currently loaded survey
 */
- (NSArray *)questions;

/**
 *  A collection of the headers in the list of questions
 *
 *  @return An array of headers
 */
- (NSArray *)headers;

/**
 *  Returns the question for a specific location in a table view, assuming that there is only one section to the table. This also works on UICollectionView.
 *
 *  @param indexPath The indexPath requesting the question. Meant to be a UITableView or UICollectionView location
 *
 *  @return the question object for the specific location
 */
- (PQSQuestion *)questionAtIndexPath:(NSIndexPath *)indexPath;

/**
 *  The image for the current brand or company.
 *
 *  @return Image of the current brand to display in the top left corner of the main view controller.
 */
- (UIImage *)brandImage;

/**
 *  The name of the current show
 *
 *  @return The name of the current show
 */
- (NSString *)currentShowTitle;

/**
 *  An array of the possible shows this survey can be shown at.
 *
 *  @return Immutable array of strings with names of shows this survey is for.
 */
- (NSArray *)possibleShowTitles;

/**
 *  Set the title of the current show.
 *
 *  @param showTitle The show title to change to. This should always be one of the possible show titles and will log and error if not.
 */
- (void)setShowTitle:(NSString *)showTitle;


/**
 *  Submitting answers for questions. Answers must always be in the form of a string.
 *
 *  @param answer         A string containing the answer.
 *  @param questionNumber The question this answer answers.
 */
- (void)submitAnswer:(NSString *)answer forQuestion:(PQSQuestion *)question;

/**
 *  Submitting answers for questions using keys instead of questions.
 *
 *  @param answer A string representing the answer.
 *  @param key    The key for URL encoding.
 */
- (void)submitAnswer:(NSString *)answer withKey:(NSString *)key;

/**
 *  This stores the answers locally on the device and does not attempt to send them to the server remotely.
 *
 *  @return If there is no answer to save or there is an error in the saving process then a NO is returned.
 */
- (BOOL)saveAnswerLocally;

/**
 *  Submit the answers that are still saved locally to the server.
 */
- (void)submitCurrentAnswers;

/**
 *  Coordinate of the user/device
 */
- (CLLocationCoordinate2D)currentLocationCoordinate;

/**
 *  List of countries with their full names as keys and three letter codes as the value.
 *
 *  @return Dictionary of KVP
 */
- (NSDictionary *)countryCodeList;

/**
 *  The ability to set the current question to be able to return to it quickly.
 *
 *  @param question The question you want to be made current.
 */
- (void)setCurrentQuestion:(PQSQuestion *)question;

/**
 *  The current question.
 *
 *  @return The current question.
 */
- (PQSQuestion *)currentQuestion;

/**
 *  Supply an answer to the current question.
 *
 *  @param answer The answer to the current question.
 */
- (void)answerCurrentQuestion:(NSString *)answer;

/**
 *  The current company the survey should be branded for
 */
+ (PQSCompany)company;

+ (NSString *)defaultCountry;
@end
