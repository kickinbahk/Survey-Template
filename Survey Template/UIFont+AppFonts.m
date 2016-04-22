//
//  UIFont+AppFonts.m
//  Philips Questionaire
//
//  Created by HAI on 5/8/15.
//  Copyright (c) 2015 HAI. All rights reserved.
//

#import "UIFont+AppFonts.h"
#import "UIFont+Custom.h"

@implementation UIFont (AppFonts)

+ (UIFont *)appFont {
	return [self appFontOfSize:18.0f];
}

+ (UIFont *)appFontOfSize:(float)fontSize {
	return [UIFont systemFontOfSize:fontSize];
}

+ (UIFont *)boldAppFont {
	return [self boldAppFontOfSize:18.0f];
}

+ (UIFont *)boldAppFontOfSize:(float)fontSize {
	return [UIFont boldSystemFontOfSize:fontSize];
}

+ (UIFont *)italicAppFont {
	return [self italicAppFontOfSize:18.0f];
}

+ (UIFont *)italicAppFontOfSize:(float)fontSize {
	return [UIFont italicSystemFontOfSize:fontSize];
}

+ (UIFont *)boldItalicAppFont {
	return [UIFont boldItalicAppFontOfSize:18.0f];
}

+ (UIFont *)italicBoldAppFont {
	return [self boldItalicAppFont];
}

+ (UIFont *)italicBoldAppFontOfSize:(float)fontSize {
	return [self boldItalicAppFontOfSize:fontSize];
}

+ (UIFont *)boldItalicAppFontOfSize:(float)fontSize {
	UIFontDescriptor *fontDescriptor = [[self appFontOfSize:fontSize].fontDescriptor fontDescriptorWithSymbolicTraits:	UIFontDescriptorTraitBold | UIFontDescriptorTraitItalic];
	return [UIFont fontWithDescriptor:fontDescriptor size:fontSize];
}

@end
