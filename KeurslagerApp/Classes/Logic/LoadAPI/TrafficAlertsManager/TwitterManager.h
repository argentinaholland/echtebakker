//
//  TwitterManager.h
//  EasyTrip
//
//  Created by mac-227 on 11.03.11.
//  Copyright 2011 iTechArt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RequestManager.h"


extern NSString * const kTwitterUpdatedNotification;


@interface TwitterManager : NSObject <RequestManagerDelegate> {
	// int helpers
	RequestManager	*recentTweetsRequest_;
	NSTimer			*sheduleTimer_;
	NSDateFormatter	*dateFormatter_;
	
	// int data
	NSArray			*trafficAlertsArray_;
	
	// flags
	BOOL	isOutOfDateNews;
}

@property (nonatomic, retain) NSArray	*trafficAlertsArray;

+ (TwitterManager *)sharedIntance;

- (BOOL)startNotifier;
- (BOOL)startNotifierWithInterval:(NSTimeInterval)timeInterval;
- (void)stopNotifier;

@end
