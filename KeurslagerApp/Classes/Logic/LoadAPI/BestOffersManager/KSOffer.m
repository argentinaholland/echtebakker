//
//  KSOffer.m
//  KeurslagerApp
//
//  Created by mac-227 on 06.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "KSOffer.h"


@implementation KSOffer

@synthesize title;
@synthesize thumbURL;
@synthesize desc;
@synthesize unit;
@synthesize date;

@synthesize priceCurrency;
@synthesize priceNumbers;
@synthesize priceSeparator;
@synthesize priceDecimals;

@synthesize url;

- (void)dealloc {
	self.title = nil;
	self.desc = nil;
	self.thumbURL = nil;
	self.unit = nil;
	self.date = nil;
	
	self.priceCurrency = nil;
	self.priceNumbers = nil;
	self.priceSeparator = nil;
	self.priceDecimals = nil;
	
	self.url = nil;
	
	[super dealloc];
}

- (NSString *)description {
	NSString* priceString =
	[NSString stringWithFormat:@"%@%@%@%@",
	 priceCurrency,
	 priceNumbers,
	 priceSeparator,
	 priceDecimals,
	 nil];
	
	NSString *descrStr =
	[NSString stringWithFormat:
	 @"title = %@\n thumbURL = %@\n desc = %@\n unit = %@\n price=%@\n date = %@\n url = %@",
	 title, [thumbURL absoluteString], desc, unit, priceString, date, [url absoluteString]];
	return descrStr;
}

@end
