//
//  YoutubeVideo.m
//  KeurslagerApp
//
//  Created by mac-227 on 27.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "YoutubeVideo.h"

@implementation YoutubeVideo

@synthesize title;
@synthesize thumbURL;
@synthesize linkURL;
@synthesize desc;
@synthesize pubDate;
@synthesize author;

- (void)dealloc {
	self.title = nil;
	self.desc = nil;
	self.thumbURL = nil;
	self.linkURL = nil;
	self.pubDate = nil;
	self.author = nil;
	
	[super dealloc];
}

- (NSString *)description {
	NSString *descrStr =
	[NSString stringWithFormat:
	 @"title = \"%@\"\n thumbURL = \"%@\"\n linkURL = \"%@\"\n author = \"%@\"\n pubDate = \"%@\"",
	 title, [thumbURL absoluteString], [linkURL absoluteString], author, pubDate];
	return descrStr;
}


@end
