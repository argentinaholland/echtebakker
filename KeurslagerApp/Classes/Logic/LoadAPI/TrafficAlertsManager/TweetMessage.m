//
//  TweetMessage.m
//  EasyTrip
//
//  Created by mac-227 on 11.03.11.
//  Copyright 2011 iTechArt. All rights reserved.
//

#import "TweetMessage.h"


@implementation TweetMessage

@synthesize date, fromUser, fromUserName, fromID, toID, toUserName, messageID, text, profileImageUrl;

- (void)dealloc {
	self.date	= nil;
	self.fromID	= nil;
	self.fromUser = nil;
	self.fromUserName = nil;
	self.toID	= nil;
	self.toUserName = nil;
	self.messageID	= nil;
	self.text	= nil;
	self.profileImageUrl = nil;
	[super dealloc];
}

- (NSString *)description {
	NSString *descrStr =
	[NSString stringWithFormat:
	 @"messageID = %@\n fromUser = %@\n fromUserName = %@\n fromID = %@\n toUserName = %@\n toID = %@\n date = %@\n text = %@\n profileImageUrl = %@",
	 messageID, fromUser, fromUserName, fromID, toUserName, toID, [date description], text, [profileImageUrl absoluteString]];
	return descrStr;
}

@end
