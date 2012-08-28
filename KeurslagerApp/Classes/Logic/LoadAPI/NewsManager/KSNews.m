//
//  KSNews.m
//  KeurslagerApp
//
//  Created by mac-227 on 04.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "KSNews.h"

@implementation KSNews

@synthesize title;
@synthesize url;
@synthesize introduction;
@synthesize thumbURL;
@synthesize date;

- (void)dealloc {
	self.title = nil;
	self.url = nil;
	self.introduction = nil;
	self.thumbURL = nil;
	self.date = nil;
	[super dealloc];
}

- (NSString *)description {
	NSString *descrStr =
	[NSString stringWithFormat:
	 @"title = %@\n date = %@\n url = %@\n introduction = %@\n thumbURL = %@",
	 title, date, [url absoluteString], introduction, [thumbURL absoluteString]];
	return descrStr;
}

@end
