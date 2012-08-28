//
//  TweetMessage.h
//  EasyTrip
//
//  Created by mac-227 on 11.03.11.
//  Copyright 2011 iTechArt. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface TweetMessage : NSObject {
	NSDate		*date;
	NSString	*fromID;
	NSString	*fromUser;
	NSString	*fromUserName;
	NSString	*toID;
	NSString	*toUserName;
	NSString	*messageID;
	NSString	*text;
	NSURL		*profileImageUrl;
}

@property (nonatomic, retain) NSDate	*date;
@property (nonatomic, retain) NSString	*fromID;
@property (nonatomic, retain) NSString	*fromUser;
@property (nonatomic, retain) NSString	*fromUserName;
@property (nonatomic, retain) NSString	*toID;
@property (nonatomic, retain) NSString	*toUserName;
@property (nonatomic, retain) NSString	*messageID;
@property (nonatomic, retain) NSString	*text;
@property (nonatomic, retain) NSURL		*profileImageUrl;

@end
