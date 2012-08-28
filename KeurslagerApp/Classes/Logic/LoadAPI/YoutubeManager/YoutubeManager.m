//
//  YoutubeManager.m
//  KeurslagerApp
//
//  Created by mac-227 on 27.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "YoutubeManager.h"

#import "DDXML.h"
#import "DDXMLElementAdditions.h"
#import "GTMNSString+HTML.h"

#import "helpers.h"
#import "VLog.h"
#import "consts.h"

#import "YoutubeVideo.h"



static NSString *const kYoutubeManagerErrorDomain	= @"YoutubeManagerErrorDomain";
static NSString *const kYoutubeManagerPasingError	= @"Failed parse incoming youtube rss data";
///static NSString *const kBaseURL = @"feed://www.youtube.com/rss/user/UCt_19IJYWrG7kJ4Kp7H-Z_w/video.rss "

static NSString *const kBaseURL = @"http://gdata.youtube.com/feeds/base/users/UCt_19IJYWrG7kJ4Kp7H-Z_w/uploads?orderby=updated&alt=rss&client=ytapi-youtube-rss-redirect&v=2";

static NSString *const kBaseURL2 = @"http://gdata.youtube.com/feeds/base/users/nypost/uploads?orderby=updated&alt=rss&client=ytapi-youtube-rss-redirect&v=2";

static NSStringEncoding	kResponceEncoding	= NSUTF8StringEncoding; // NSUTF8StringEncoding NSISOLatin1StringEncoding


static NSString *const kBestOffersLoaderRequestDelegate		= @"RequestDelegate";



@interface YoutubeManager ()
@property (nonatomic, retain) RequestManager	*loadRequest;
@property (nonatomic, retain) NSDateFormatter	*dateFormatter;

- (NSArray *)parseYoutubeRSS:(NSData *)aResponce error:(NSError **)pError;

- (NSError *)makeParseErrorWithCode:(NSInteger)anErrorCode;

- (YoutubeVideo *)parseItemXMLElement:(DDXMLElement *)itemElement;

- (NSString*)getHTMLContentFromString:(NSString*)htmlString
						 withBeginTag:(NSString*)beginTag
						   withEndTag:(NSString*)endTag
							withRange:(NSRange*)pSearchRange;

@end


@implementation YoutubeManager

@synthesize loadRequest	= loadRequest_;
@synthesize dateFormatter	= dateFormatter_;


- (void)dealloc {
	[self.loadRequest cancel];
	self.loadRequest	= nil;
	
	self.dateFormatter	= nil;
	
	[super dealloc];
}


#pragma mark -
#pragma mark Singleton methods

static YoutubeManager *youtubeManagerSharedInstance__	 = nil;


+ (YoutubeManager *)sharedIntance {
	@synchronized(self) {
		if (nil == youtubeManagerSharedInstance__) {
			youtubeManagerSharedInstance__ = [[YoutubeManager alloc] init];
		}
	}
	return youtubeManagerSharedInstance__;
}

+ (id)allocWithZone:(NSZone *)zone {
	@synchronized(self) {
		if (nil == youtubeManagerSharedInstance__) {
			youtubeManagerSharedInstance__ = [super allocWithZone:zone];
		}
	}
	return youtubeManagerSharedInstance__;
}

- (id)init {
	if ((self = [super init])) {
		// initialization
		self.dateFormatter	= [[[NSDateFormatter alloc] init] autorelease];
		[self.dateFormatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss ZZZ"];	// Thu, 02 Feb 2012 11:19:18 +0000
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

- (BOOL)loadYoutubeChannelWithDelegate:(id<YoutubeManagerDelegate>)aDelegate {
    
    
    NSString *theUrl = kBaseURL;
    if ([aDelegate respondsToSelector:@selector(firstChannel)])
        if (!(BOOL)[aDelegate performSelector:@selector(firstChannel)])
            theUrl = kBaseURL2;
    
	NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:aDelegate, kBestOffersLoaderRequestDelegate, nil];
	
	[self.loadRequest cancel];
	self.loadRequest =
	[RequestManager requestWithURL:[NSURL URLWithString:theUrl]
						  delegate:self
						  userInfo:userInfo];
	
	return (nil != self.loadRequest);
}


#pragma mark -
#pragma mark <RequestManagerDelegate> implementation

- (void)requestManager:(RequestManager *)aManager
 didFinishWithResponse:(NSData *)aResponce
{
	NSDictionary *userInfo = (NSDictionary *)aManager.userInfo;
	id<RequestManagerDelegate> delegate = [userInfo valueForKey:kBestOffersLoaderRequestDelegate];
	
	//if (self.loadRequest == aManager)
	{
		// parse xml data
		NSError *error = nil;
		NSArray *itemsArray = [self parseYoutubeRSS:aResponce error:&error];
		
		// free connection
		[self.loadRequest cancel];
		self.loadRequest = nil;
		
		if (!itemsArray || error)
		{
			if ([delegate respondsToSelector:@selector(youtubeLoader:didFailWithError:)]) {
				[delegate performSelector:@selector(youtubeLoader:didFailWithError:)
							   withObject:self withObject:error];
			}
		} else {
			// send parsed data back to delegate
			if ([delegate respondsToSelector:@selector(youtubeLoader:didFinishWithVideosArray:)]) {
				[delegate performSelector:@selector(youtubeLoader:didFinishWithVideosArray:)
							   withObject:self withObject:itemsArray];
			}
		}
	}
//	else
//	{
//		VLog(@"NewsLoader::RequestManager:didFinishWithResponse: uncknow Request");
//		
//		return;
//	}
}

- (void)requestManager:(RequestManager *)aManager
	  didFailWithError:(NSError *)error
{
	NSDictionary *userInfo = (NSDictionary *)aManager.userInfo;
	id<RequestManagerDelegate> delegate = [userInfo valueForKey:kBestOffersLoaderRequestDelegate];
	
	if (self.loadRequest == aManager)
	{
		[self.loadRequest cancel];
		self.loadRequest = nil;
	}
	else
	{
		VLog(@"NewsLoader::RequestManager:didFailWithError: uncknow Request");
		return;
	}
	
	if ([delegate respondsToSelector:@selector(youtubeLoader:didFailWithError:)]) {
		[delegate performSelector:@selector(youtubeLoader:didFailWithError:)
					   withObject:self withObject:error];
	}
}


#pragma mark -
#pragma mark Parser implementation

- (NSError *)makeParseErrorWithCode:(NSInteger)anErrorCode {
	NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:kYoutubeManagerPasingError, NSLocalizedDescriptionKey, nil];
	return [NSError errorWithDomain:kYoutubeManagerErrorDomain code:anErrorCode userInfo:errorDict];
}

- (NSArray *)parseYoutubeRSS:(NSData *)aResponce error:(NSError **)pError {
	if (!aResponce || [NSNull null] == (NSNull *)aResponce || !aResponce.length) return nil;
	
	NSString *responseString = [[NSString alloc] initWithData:aResponce encoding:kResponceEncoding];
	//NSString *responseString = [self stringFrom_ISO8859_15_Data:aResponce];
	if (!responseString || !responseString.length) {
		*pError	= [self makeParseErrorWithCode:0];
		VLog(@"Error parse response: response is empty");
		return nil;
	}
	
	// debug
	//VLog(@"responseString = \n%@", responseString);
	
	
	NSError *error = nil;
	DDXMLDocument *xml = [[DDXMLDocument alloc] initWithXMLString:responseString
														  options:0
															error:&error];
	if (!xml) {
		*pError = error;
		VLog(@"Error parsing response: %@", [error description]);
		[xml release];
		return nil;
	}
	
	
	// parse categories
	NSArray *itemElementsArray = [xml nodesForXPath:@"/rss/channel/item" error:&error];
	if (!itemElementsArray) {
		*pError = error;
		VLog(@"Error parsing response: %@", [error description]);
		[xml release];
		return nil;
	}
	if (!itemElementsArray.count) {
		VLog(@"Error parsing response: no \"item\" elements for path \"/rss/channel/item\"");
		[xml release];
		return nil;
	}
	
	NSMutableArray* fetchedItems = [NSMutableArray arrayWithCapacity:itemElementsArray.count];
	
	for (DDXMLElement *itemElement in itemElementsArray)
	{
		YoutubeVideo *video = [self parseItemXMLElement:itemElement];
		if (video) {
			[fetchedItems addObject:video];
		}
	}
	
	return fetchedItems;
}



- (YoutubeVideo *)parseItemXMLElement:(DDXMLElement *)itemElement {
	YoutubeVideo* videoItem = [[YoutubeVideo new] autorelease];
	
	DDXMLElement *titleElement = [itemElement elementForName:@"title"];
	if (!titleElement) return nil;
	videoItem.title = [titleElement stringValue];
	
	DDXMLElement *descriptionElement = [itemElement elementForName:@"description"];
	if (!descriptionElement) return nil;
	//videoItem.desc = [descriptionElement stringValue];
	NSString* descriptionString = [descriptionElement stringValue];
	NSString* descriptionHTMLString = [descriptionString gtm_stringByUnescapingFromHTML];
	videoItem.desc = descriptionHTMLString;
	//VLog(@"descriptionHTMLString  = %@", descriptionHTMLString);
	
	
	// get weeklyoffer-in-detail html
	NSRange searchRange = NSMakeRange(0, descriptionHTMLString.length);
	NSString* imageDescriptionHTMLString =
	[self getHTMLContentFromString:descriptionHTMLString
					  withBeginTag:@"<img "
						withEndTag:@">"
						 withRange:&searchRange];
	if (!imageDescriptionHTMLString || !imageDescriptionHTMLString.length) {
		VLog(@"Error parse response: no \"<img ");
		return nil;
	}
	
	NSRange localRange = NSMakeRange(0, imageDescriptionHTMLString.length);
	NSString* srcImageDescriptionHTMLString =
	[self getHTMLContentFromString:imageDescriptionHTMLString
					  withBeginTag:@"src=\""
						withEndTag:@"\""
						 withRange:&localRange];
	if (!srcImageDescriptionHTMLString || !srcImageDescriptionHTMLString.length) {
		srcImageDescriptionHTMLString =
		[self getHTMLContentFromString:imageDescriptionHTMLString
						  withBeginTag:@"src='"
							withEndTag:@"'"
							 withRange:&localRange];
		if (!srcImageDescriptionHTMLString || !srcImageDescriptionHTMLString.length) {
			return nil;
		}
	}
	NSURL* thumbURL = [NSURL URLWithString:srcImageDescriptionHTMLString];
	if (!thumbURL) {
		return nil;
	}
	videoItem.thumbURL = thumbURL;
	
	
	DDXMLElement *authorElement = [itemElement elementForName:@"author"];
	if (!authorElement) return nil;
	videoItem.author = [authorElement stringValue];
	
	DDXMLElement *pubDateElement = [itemElement elementForName:@"pubDate"];
	if (!pubDateElement) return nil;
	NSDate* pubDate = [dateFormatter_ dateFromString:[pubDateElement stringValue]];
	if (!pubDate) return nil;
	videoItem.pubDate = pubDate;
	
	DDXMLElement *linkElement = [itemElement elementForName:@"link"];
	if (!linkElement) return nil;
	NSString *linkString = [linkElement stringValue];
	NSURL* linkURL = [NSURL URLWithString:linkString];
	if (!linkURL) return nil;
	videoItem.linkURL = linkURL;
	
	return videoItem;
}


- (NSString*)getHTMLContentFromString:(NSString*)htmlString
						 withBeginTag:(NSString*)beginTag
						   withEndTag:(NSString*)endTag
							withRange:(NSRange*)pSearchRange
{
	NSAssert(htmlString, @"htmlString is nil");
	NSAssert(beginTag, @"beginTag is nil");
	NSAssert(endTag, @"endTag is nil");
	NSAssert(pSearchRange, @"pSearchRange is nil");
	
	NSRange tagBegin = [htmlString rangeOfString:beginTag
										 options:NSCaseInsensitiveSearch
										   range:*pSearchRange];
	if (NSNotFound == tagBegin.location) {
		VLog(@"Can't find news introduction begin tag: \"%@\": stop parsing.", beginTag);
		return nil;
	}
	pSearchRange->location = tagBegin.location + tagBegin.length;
	pSearchRange->length = htmlString.length - pSearchRange->location;
	
	
	NSRange tagEnd = [htmlString rangeOfString:endTag
									   options:NSCaseInsensitiveSearch
										 range:*pSearchRange];
	if (NSNotFound == tagEnd.location) {
		VLog(@"Can't find news introduction end tag: \"%@\": stop parsing.", endTag);
		return nil;
	}
	pSearchRange->location = tagEnd.location + tagEnd.length;
	pSearchRange->length = htmlString.length - pSearchRange->location;
	
	
	NSUInteger tagRangeBegin = tagBegin.location + tagBegin.length;
	NSUInteger tagRangeLength = tagEnd.location - tagRangeBegin;
	NSRange introductionRange = NSMakeRange(tagRangeBegin, tagRangeLength);
	NSString* contentString = [htmlString substringWithRange:introductionRange];
	
	return contentString;
}


@end
