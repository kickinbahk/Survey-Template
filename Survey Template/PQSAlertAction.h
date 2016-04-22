//
//  PQSAlertAction.h
//  LithoVue Survey
//
//  Created by HAI on 12/8/15.
//  Copyright © 2015 HAI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PQSQuestion.h"

@interface PQSAlertAction : UIAlertAction

@property (nonatomic, strong) PQSQuestion *question;
@property (nonatomic, strong) NSString *key;

@end
