//
//  PQSTableViewCell.m
//  LithoVue Survey
//
//  Created by HAI on 11/30/15.
//  Copyright © 2015 HAI. All rights reserved.
//

#import "PQSTableViewCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation PQSTableViewCell

- (void)maskCellFromTop:(CGFloat)margin {
	self.layer.mask = [self visibilityMaskWithLocation:margin/self.frame.size.height];
	self.layer.masksToBounds = YES;
}

- (CAGradientLayer *)visibilityMaskWithLocation:(CGFloat)location {
	CAGradientLayer *mask = [CAGradientLayer layer];
	mask.frame = self.bounds;
	mask.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithWhite:1 alpha:0] CGColor], (id)[[UIColor colorWithWhite:1 alpha:1] CGColor], nil];
	mask.locations = [NSArray arrayWithObjects:[NSNumber numberWithFloat:location], [NSNumber numberWithFloat:location], nil];
	return mask;
}

@end
