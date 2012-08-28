//
//  TweetsLoader.m
//  KeurslagerApp
//
//  Created by mac-227 on 04.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TweetsLoader.h"

#import "TweetMessage.h"

#import "JSON.h"
#import "GTMNSString+HTML.h"

#import "VLog.h"
#import "consts.h"



static NSString *const kTwitterManagerErrorDomain	= @"TwitterManagerErrorDomain";
static NSString *const kTwitterManagerPasingError	= @"Failed parse incoming data from twitter";

static NSString	*const kTwitterUserIDString		= @"219045437";	// user_name = "keurzijlstra"
static NSString	*const kTwitterUser				= @"keurzijlstra";
static NSString *const kRecentTweetsJSONRequestURL	= @"http://search.twitter.com/search.json?result_type=recent&q=%@";


static NSString *const kNewsLoaderRequestDelegate		= @"RequestDelegate";



@interface TweetsLoader ()
@property (nonatomic, retain) RequestManager	*loadTweetsRequest;
@property (nonatomic, retain) NSDateFormatter	*dateFormatter;

- (NSArray *)parseTweetsResponce:(NSData *)aResponce error:(NSError **)pError;


@end


@implementation TweetsLoader

@synthesize loadTweetsRequest	= loadTweetsRequest_;
@synthesize dateFormatter	= dateFormatter_;
@synthesize userName = userName_;


- (void)dealloc {
	self.userName = nil;
	
	[self.loadTweetsRequest cancel];
	self.loadTweetsRequest	= nil;
	
	self.dateFormatter	= nil;
	
	[super dealloc];
}


#pragma mark -
#pragma mark Singleton methods

static TweetsLoader *tweetsLoaderSharedInstance__	 = nil;


+ (TweetsLoader *)sharedIntance {
	@synchronized(self) {
		if (nil == tweetsLoaderSharedInstance__) {
			tweetsLoaderSharedInstance__ = [[TweetsLoader alloc] init];
		}
	}
	return tweetsLoaderSharedInstance__;
}

+ (id)allocWithZone:(NSZone *)zone {
	@synchronized(self) {
		if (nil == tweetsLoaderSharedInstance__) {
			tweetsLoaderSharedInstance__ = [super allocWithZone:zone];
		}
	}
	return tweetsLoaderSharedInstance__;
}

- (id)init {
	if ((self = [super init])) {
		self.userName = kTwitterUser;
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
#pragma mark News Loading Stuff

- (BOOL)loadTweetsWithDelegate:(id<TweetsLoaderDelegate>)aDelegate {
	NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:aDelegate, kNewsLoaderRequestDelegate, nil];
	
	NSString* requestURLString = [NSString stringWithFormat:kRecentTweetsJSONRequestURL, userName_];
	
	[self.loadTweetsRequest cancel];
	self.loadTweetsRequest =
	[RequestManager requestWithURL:[NSURL URLWithString:requestURLString]
						  delegate:self
						  userInfo:userInfo];
	
	return (nil != self.loadTweetsRequest);
}


#pragma mark -
#pragma mark <RequestManagerDelegate> implementation

- (void)requestManager:(RequestManager *)aManager
 didFinishWithResponse:(NSData *)aResponce
{
	NSDictionary *userInfo = (NSDictionary *)aManager.userInfo;
	id<TweetsLoaderDelegate> delegate = [userInfo valueForKey:kNewsLoaderRequestDelegate];
	
	//if (self.loadTweetsRequest == aManager)
	{
		// parse xml data
		NSError *error = nil;
		NSArray *tweetsArray = [self parseTweetsResponce:aResponce error:&error];
		
		// free connection
		[loadTweetsRequest_ cancel];
		self.loadTweetsRequest = nil;
		
		if (!tweetsArray || error)
		{
			if ([delegate respondsToSelector:@selector(tweetsLoader:didFailWithError:)]) {
				[delegate performSelector:@selector(tweetsLoader:didFailWithError:)
							   withObject:self withObject:error];
			}
		} else {
			// send parsed data back to delegate
			if ([delegate respondsToSelector:@selector(tweetsLoader:didFinishWithNewsArray:)]) {
				[delegate performSelector:@selector(tweetsLoader:didFinishWithNewsArray:)
							   withObject:self withObject:tweetsArray];
			}
		}
	}
}

- (void)requestManager:(RequestManager *)aManager
	  didFailWithError:(NSError *)error
{
	NSDictionary *userInfo = (NSDictionary *)aManager.userInfo;
	id<TweetsLoaderDelegate> delegate = [userInfo valueForKey:kNewsLoaderRequestDelegate];
	
	//if (loadTweetsRequest_ == aManager)
	{
		[loadTweetsRequest_ cancel];
		self.loadTweetsRequest = nil;
	}
	
	if ([delegate respondsToSelector:@selector(tweetsLoader:didFailWithError:)]) {
		[delegate performSelector:@selector(tweetsLoader:didFailWithError:)
					   withObject:self withObject:error];
	}
}


- (NSArray *)parseTweetsResponce:(NSData *)aResponce error:(NSError **)pError {
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
		*pError = [NSError errorWithDomain:kTwitterManagerErrorDomain
									  code:-1
								  userInfo:errorDict];
		return nil;
	}
	
	NSArray *results = [parsedJSON valueForKey:@"results"];
	if (!results || [NSNull null] == (NSNull *)results || !results.count) {
		VLog(@"recentTweetsFromResponseData: no results");
		
		NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:
								   kTwitterManagerPasingError, NSLocalizedDescriptionKey, nil];
		*pError = [NSError errorWithDomain:kTwitterManagerErrorDomain
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
		
//		if (![fromUserIDString isEqual:kTwitterUserIDString]) {
//			VLog(@"recentTweetsFromResponseData: from_user is not %@", kTwitterUser);
//			continue;
//		}
		
		// from_user
		NSString *fromUserString = [result valueForKey:@"from_user"];
		if (!fromUserString || [NSNull null] == (NSNull *)fromUserString || !fromUserString.length) {
			VLog(@"recentTweetsFromResponseData: no from_user at message");
			continue;
		}
		
		// from_user_name
		NSString *fromUserNameString = [result valueForKey:@"from_user_name"];
		if (!fromUserNameString || [NSNull null] == (NSNull *)fromUserNameString || !fromUserNameString.length) {
			VLog(@"recentTweetsFromResponseData: no from_user_name at message");
			continue;
		}
		
		// to_user_id_str
		NSString *toUserIDString = [result valueForKey:@"to_user_id_str"];	// could be Null
		if (!toUserIDString || [NSNull null] == (NSNull *)toUserIDString || !toUserIDString.length) {
			VLog(@"recentTweetsFromResponseData: no to_user_id_str at message");
			//continue;
			toUserIDString = nil;
		}
		
		// to_user_name
		NSString *toUserNameString = [result valueForKey:@"to_user_name"];	// could be Null
		if (!toUserNameString || [NSNull null] == (NSNull *)toUserNameString || !toUserNameString.length) {
			VLog(@"recentTweetsFromResponseData: no to_user_name at message");
			//continue;
			toUserNameString = nil;
		}
		
		// profile_image_url
		NSString *profileImageUrlString = [result valueForKey:@"profile_image_url"];	// could be Null
		if (!profileImageUrlString || [NSNull null] == (NSNull *)profileImageUrlString || !profileImageUrlString.length) {
			VLog(@"profileImageUrlString: no to_user_id_str at message");
			//continue;
			profileImageUrlString = nil;
		}
		NSURL* profileImageUrl = [NSURL URLWithString:profileImageUrlString];
		
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
		tweetMessage.fromUser   = fromUserString;
		tweetMessage.fromUserName = fromUserNameString;
		tweetMessage.toID		= toUserIDString;
		tweetMessage.toUserName = toUserNameString;
		tweetMessage.profileImageUrl = profileImageUrl;
		
		// cut off from message url "http://www.aaroadwatch.ie"
		//tweetMessage.text		= [self cuttOffBadURL:textString];
		tweetMessage.text       = textString;
		
		[tweetsArray addObject:tweetMessage];
		[tweetMessage release];
	}
	
	return tweetsArray;
}


// cut off from message url "http://www.aaroadwatch.ie"
- (NSString *)cuttOffBadURL:(NSString *)anURLString {
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


@end
