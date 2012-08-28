//
//  TwitterManager.m
//
//  Created by mac-227 on 11.03.11.
//  Copyright 2011 iTechArt. All rights reserved.
//

#import "TwitterManager.h"

#import "TweetMessage.h"

#import "JSON.h"
#import "GTMNSString+HTML.h"

#import "ReachabilityManager.h"

#import "VLog.h"
#import "consts.h"


NSString * const kTwitterUpdatedNotification		= @"TwitterUpdatedNotification";

static NSString *const kTwitterManagerErrorDomain	= @"TrafficAlertsManagerErrorDomain";
static NSString *const kTwitterManagerPasingError	= @"Failed parse incoming data from twitter";

static NSString	*const kTwitterUserIDString		= @"219045437";	// user_name = "keurzijlstra"
static NSString	*const kTwitterUser				= @"keurzijlstra";
static NSString *const kRecentTweetsJSONRequestURL	= @"http://search.twitter.com/search.json?result_type=recent&q=keurzijlstra";

const NSTimeInterval	kTwitterUpdateInterval	= 10 * 60; // 10 minutes



@interface TwitterManager ()
@property (nonatomic, retain) RequestManager	*recentTweetsRequest;
@property (nonatomic, retain) NSTimer			*sheduleTimer;
@property (nonatomic, retain) NSDateFormatter	*dateFormatter;
@property (nonatomic, retain) NSArray			*cutOffArray;


- (void)updateTrafficAlerts:(NSTimer *)theTimer;

- (NSArray *)recentTweetsFromResponseData:(NSData *)aResponce error:(NSError **)error;

- (NSString *)cuttOffBadURL:(NSString *)anURLString;

- (void)internetReachabilityChanged:(NSNotification *)notification;

@end



@implementation TwitterManager

@synthesize recentTweetsRequest	= recentTweetsRequest_;
@synthesize sheduleTimer		= sheduleTimer_;
@synthesize dateFormatter		= dateFormatter_;

@synthesize trafficAlertsArray	= trafficAlertsArray_;
@synthesize cutOffArray			= cutOffArray_;


#pragma mark -
#pragma mark Memory Stuff

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kNetworkReachabilityChangedNotification object:nil];
	
	[self.recentTweetsRequest cancel];
	self.recentTweetsRequest	= nil;
	self.sheduleTimer	= nil;
	self.dateFormatter	= nil;
	
	self.trafficAlertsArray	= nil;
	self.cutOffArray	= nil;
	
	[super dealloc];
}


#pragma mark -
#pragma mark Singleton methods

static TwitterManager *trafficAlertsManagerSharedInstance__	 = nil;

+ (TwitterManager *)sharedIntance {
	@synchronized(self) {
		if (nil == trafficAlertsManagerSharedInstance__) {
			trafficAlertsManagerSharedInstance__ = [[TwitterManager alloc] init];
		}
	}
	return trafficAlertsManagerSharedInstance__;
}

+ (id)allocWithZone:(NSZone *)zone {
	@synchronized(self) {
		if (trafficAlertsManagerSharedInstance__ == nil) {
			trafficAlertsManagerSharedInstance__ = [super allocWithZone:zone];
		}
	}
	return trafficAlertsManagerSharedInstance__;
}

- (id)init {
	if ((self = [super init])) {
		self.dateFormatter	= [[[NSDateFormatter alloc] init] autorelease];
		[self.dateFormatter setDateFormat: @"EEE, d MMM yyyy HH:mm:ss ZZZ"];	// "Fri, 11 Mar 2011 12:49:27 +0000"
		[self.dateFormatter setLocale: [[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] autorelease]];
	}
	return self;
}

- (id)copyWithZone:(NSZone *)zone {
	return self;
}

- (id)retain {
	return self;
}

- (void)release {
	//do nothing
}

- (id)autorelease {
	return self;
}


#pragma mark -
#pragma mark Car Parks Stuff

- (BOOL)startNotifier {
	VLog(@"TrafficAlertsManager::startNotifier");
	
	return [self startNotifierWithInterval:kTwitterUpdateInterval];
}

- (BOOL)startNotifierWithInterval:(NSTimeInterval)timeInterval {
	VLog(@"TrafficAlertsManager::startNotifierWithInterval:");
	
	[self stopNotifier];
	self.sheduleTimer =
	[NSTimer scheduledTimerWithTimeInterval:timeInterval
									 target:self
								   selector:@selector(updateTrafficAlerts:)
								   userInfo:nil
									repeats:YES];
	
	if (nil != self.sheduleTimer) {
		// timer is not starting immediatley, so start scroll manually
		[self updateTrafficAlerts:self.sheduleTimer];
		
		// internet reachability handler
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(internetReachabilityChanged:)
													 name:kNetworkReachabilityChangedNotification object:nil];
		
		return YES;
	}
	
	return NO;
}

- (void)stopNotifier {
	VLog(@"TrafficAlertsManager::stopNotifier");
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kNetworkReachabilityChangedNotification object:nil];
	
	[self.sheduleTimer invalidate];
	self.sheduleTimer = nil;
	
	isOutOfDateNews	= YES;
}


- (void)updateTrafficAlerts:(NSTimer *)theTimer {
	VLog(@"TrafficAlertsManager::updateTrafficAlerts:");
	
	if (self.sheduleTimer != theTimer) return;
	
	[self.recentTweetsRequest cancel];
	self.recentTweetsRequest =
	[RequestManager requestWithURL:[NSURL URLWithString:kRecentTweetsJSONRequestURL]
						  delegate:self
						  userInfo:nil];
}


#pragma mark -
#pragma mark <RequestManagerDelegate> implementation

- (void)requestManager:(RequestManager *)aManager
 didFinishWithResponse:(NSData *)aResponce
{
	if (self.recentTweetsRequest == aManager)
	{
		VLog(@"TrafficAlertsManager::requestManager:didFinishWithResponse:");
		
		// parse data
		NSError *error = nil;
		NSArray *tweetsArray = [self recentTweetsFromResponseData:aResponce error:&error];
		
		// free connection
		[self.recentTweetsRequest cancel];
		self.recentTweetsRequest = nil;
		
		// save traffic alerts
		BOOL isShouldUpdate = NO;
		if (trafficAlertsArray_.count != tweetsArray.count) {
			isShouldUpdate = YES;
		} else {
			for (TweetMessage* newTweet in tweetsArray) {
				BOOL isNewTweetFound = NO;
				for (TweetMessage* oldTweet in trafficAlertsArray_) {
					if ([newTweet.messageID isEqualToString:oldTweet.messageID]) {
						isNewTweetFound = YES;
						break;
					}
				}
				if (!isNewTweetFound) {
					isShouldUpdate = YES;
					break;
				}
			}
		}
		if (isShouldUpdate) {
			@synchronized (self.trafficAlertsArray) {
				self.trafficAlertsArray = tweetsArray;
				isOutOfDateNews = NO;
			}
		}
		
		if (tweetsArray && tweetsArray.count) {
			// if parsed successfull - broadcast update message
			[[NSNotificationCenter defaultCenter] postNotificationName:kTwitterUpdatedNotification object:tweetsArray];
		}
	}
}

- (void)requestManager:(RequestManager *)aManager
	  didFailWithError:(NSError *)error
{
	if (self.recentTweetsRequest == aManager) {
		VLog(@"TrafficAlertsManager::requestManager:didFailWithError: code = %d, domain = %@, description = %@",
			 [error code], [error domain], [[error userInfo] description]);
		
		// free connection
		[self.recentTweetsRequest cancel];
		self.recentTweetsRequest = nil;
		
		isOutOfDateNews = YES;
	}
}


#pragma mark -
#pragma mark Twiter response parsers implemention

- (NSArray *)recentTweetsFromResponseData:(NSData *)aResponce error:(NSError **)error {
	if (!aResponce || [NSNull null] == (NSNull *)aResponce || !aResponce.length) return nil;
	
	// parse json data
	NSString *jsonString = [[NSString alloc] initWithData:aResponce encoding:NSUTF8StringEncoding];
	SBJSON *jsonParser = [SBJSON new];
	NSError *localError = nil;
	NSMutableDictionary *parsedJSON = [jsonParser objectWithString:jsonString error:&localError];
	[jsonParser release];
	[jsonString release];
	
	if (!parsedJSON) {
		VLog(@"recentTweetsFromResponseData: Error parsing JSON: %@ %d %@", [localError domain], [localError code], [[localError userInfo] description]);
		
		NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:
								   kTwitterManagerPasingError, NSLocalizedDescriptionKey, nil];
		*error = [NSError errorWithDomain:kTwitterManagerErrorDomain
									 code:-1
								 userInfo:errorDict];
		return nil;
	}
	
	NSArray *results = [parsedJSON valueForKey:@"results"];
	if (!results || [NSNull null] == (NSNull *)results || !results.count) {
		VLog(@"recentTweetsFromResponseData: no results");
		
		NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:
								   kTwitterManagerPasingError, NSLocalizedDescriptionKey, nil];
		*error = [NSError errorWithDomain:kTwitterManagerErrorDomain
									 code:-1
								 userInfo:errorDict];
		return nil;
	}
	
	
	NSMutableArray *tweetsArray = [NSMutableArray arrayWithCapacity:results.count];
	for (NSDictionary *result in results) {
		// created_at
		NSString *createDateString = [result valueForKey:@"created_at"];
		if (!createDateString || [NSNull null] == (NSNull *)createDateString || !createDateString.length) {
			VLog(@"recentTweetsFromResponseData: no created_at at message");
			continue;
		}
		NSDate *createDate = [self.dateFormatter dateFromString:createDateString];
		
		// id_str
		NSString *messageIDString = [result valueForKey:@"id_str"];
		if (!messageIDString || [NSNull null] == (NSNull *)messageIDString || !messageIDString.length) {
			VLog(@"recentTweetsFromResponseData: no id_str at message");
			continue;
		}
		
		// from_user_id_str
		NSString *fromUserIDString = [result valueForKey:@"from_user_id_str"];
		if (!fromUserIDString || [NSNull null] == (NSNull *)fromUserIDString || !fromUserIDString.length) {
			VLog(@"recentTweetsFromResponseData: no from_user_id_str at message");
			continue;
		}
		
		if (![fromUserIDString isEqual:kTwitterUserIDString]) {
			VLog(@"recentTweetsFromResponseData: from_user is not %@", kTwitterUser);
			continue;
		}
		
		// to_user_id_str
		NSString *toUserIDString = [result valueForKey:@"to_user_id_str"];	// could be Null
		if (!toUserIDString || [NSNull null] == (NSNull *)toUserIDString || !toUserIDString.length) {
			VLog(@"recentTweetsFromResponseData: no to_user_id_str at message");
			//continue;
			toUserIDString = nil;
		}
		
		// text
		NSString *textString = [[result valueForKey:@"text"] gtm_stringByUnescapingFromHTML];
		if (!textString || [NSNull null] == (NSNull *)textString || !textString.length) {
			VLog(@"recentTweetsFromResponseData: no text at message");
			continue;
		}
		
		TweetMessage *tweetMessage = [[TweetMessage alloc] init];
		tweetMessage.date		= createDate;
		tweetMessage.messageID	= messageIDString;
		tweetMessage.fromID		= fromUserIDString;
		tweetMessage.toID		= toUserIDString;
		
		// cut off from message url "http://www.aaroadwatch.ie"
		//tweetMessage.text		= [self cuttOffBadURL:textString];
		
		[tweetsArray addObject:tweetMessage];
		[tweetMessage release];
	}
	
	return tweetsArray;
}

// cut off from message url "http://www.aaroadwatch.ie"
- (NSString *)cuttOffBadURL:(NSString *)anURLString
{
	NSMutableString *result = [[NSMutableString alloc] initWithCapacity:anURLString.length];
	NSCharacterSet *newLineAndWhitespaceCharacters = [NSCharacterSet characterSetWithCharactersInString:[NSString stringWithFormat:@" \t\n\r%C%C%C%C", 0x0085, 0x000C, 0x2028, 0x2029]];
	NSScanner *scanner = [[NSScanner alloc] initWithString:anURLString];
	[scanner setCharactersToBeSkipped:nil];
	[scanner setCaseSensitive:NO];
	NSString *str = nil;
	do {
		if ([scanner scanUpToString:@"http://" intoString:&str]) {
			//NSUInteger beginLinkPos = [scanner scanLocation];
			[result appendString:str];
			
			if ([scanner scanUpToCharactersFromSet:newLineAndWhitespaceCharacters intoString:NULL]) {
				//NSUInteger endLinkPos = [scanner scanLocation];
			}
		} else if ([scanner scanUpToString:@"See http://" intoString:&str]) {
			[result appendString:str];
			
			if ([scanner scanUpToCharactersFromSet:newLineAndWhitespaceCharacters intoString:NULL]) {
			}
		}

	} while (![scanner isAtEnd]);
	[scanner release];
	
	return result;
}


#pragma mark -
#pragma mark kReachabilityChangedNotification notification handler

//Called by Reachability whenever status changes.
- (void)internetReachabilityChanged:(NSNotification *)notification {
	VLog(@"TrafficAlertsManager::internetReachabilityChanged:");
	
	ReachabilityManager *currentReachability = [notification object];
	NSParameterAssert([currentReachability isKindOfClass:[ReachabilityManager class]]);
	
	if (NotReachable == [currentReachability currentReachabilityStatus]) {
		// do nothing
	} else {
		VLog(@"TrafficAlertsManager::internetReachabilityChanged: internet is reachable");
		
		// internet became rechable
		// if news are not availible or news are out of date
		if (!self.trafficAlertsArray || !self.trafficAlertsArray.count || isOutOfDateNews) {
			// update news
			if (self.sheduleTimer) {
				[self updateTrafficAlerts:self.sheduleTimer];
			}
		}
	}
}


@end
