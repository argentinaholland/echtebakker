//
//  NewsLoader.m
//  EasyTrip
//
//  Created by mac-227 on 15.03.11.
//  Copyright 2011 iTechArt. All rights reserved.
//

#import "NewsLoader.h"

#import "KSNews.h"

#import "DDXML.h"
#import "DDXMLElementAdditions.h"
#import "GTMNSString+HTML.h"

#import "VLog.h"
#import "consts.h"



static NSString *const kNewsLoaderErrorDomain	= @"NewsLoaderErrorDomain";
static NSString *const kNewsLoaderPasingError	= @"Failed parse incoming news data";

static NSString *const kBaseURL = @"http://www.zijlstraheerenveen.keurslager.nl";
static NSString *const kNewsHTMLRequestURL = @"http://www.zijlstraheerenveen.keurslager.nl/nieuws";
static NSStringEncoding	kNewsResponceEncoding	= NSISOLatin1StringEncoding; // NSUTF8StringEncoding NSISOLatin1StringEncoding


static NSString *const kNewsLoaderRequestDelegate		= @"RequestDelegate";



@interface NewsLoader ()
@property (nonatomic, retain) RequestManager	*loadNewsRequest;
@property (nonatomic, retain) NSDateFormatter	*dateFormatter;

- (NSArray *)parseNewsResponce:(NSData *)aResponce error:(NSError **)pError;

- (NSError *)makeParseErrorWithCode:(NSInteger)anErrorCode;

//- (NSString *)stringFrom_ISO8859_15_Data:(NSData *)aData;

- (NSString*)getHTMLContentFromString:(NSString*)htmlString
						 withBeginTag:(NSString*)beginTag
						   withEndTag:(NSString*)endTag
							withRange:(NSRange*)pSearchRange;

@end


@implementation NewsLoader

@synthesize loadNewsRequest	= loadNewsRequest_;
@synthesize dateFormatter	= dateFormatter_;


- (void)dealloc {
	[self.loadNewsRequest cancel];
	self.loadNewsRequest	= nil;
	
	self.dateFormatter	= nil;
	
	[super dealloc];
}


#pragma mark -
#pragma mark Singleton methods

static NewsLoader *newsLoaderSharedInstance__	 = nil;


+ (NewsLoader *)sharedIntance {
	@synchronized(self) {
		if (nil == newsLoaderSharedInstance__) {
			newsLoaderSharedInstance__ = [[NewsLoader alloc] init];
		}
	}
	return newsLoaderSharedInstance__;
}

+ (id)allocWithZone:(NSZone *)zone {
	@synchronized(self) {
		if (nil == newsLoaderSharedInstance__) {
			newsLoaderSharedInstance__ = [super allocWithZone:zone];
		}
	}
	return newsLoaderSharedInstance__;
}

- (id)init {
	if ((self = [super init])) {
		// initialization
		self.dateFormatter	= [[[NSDateFormatter alloc] init] autorelease];
		[self.dateFormatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss ZZZZ"];	// Tue, 15 Mar 2011 14:46:17 GMT
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

- (BOOL)loadNewsWithDelegate:(id<NewsLoaderDelegate>)aDelegate {
	NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:aDelegate, kNewsLoaderRequestDelegate, nil];
	
	[self.loadNewsRequest cancel];
	self.loadNewsRequest =
	[RequestManager requestWithURL:[NSURL URLWithString:kNewsHTMLRequestURL]
						  delegate:self
						  userInfo:userInfo];
	
	return (nil != self.loadNewsRequest);
}


#pragma mark -
#pragma mark <RequestManagerDelegate> implementation

- (void)requestManager:(RequestManager *)aManager
 didFinishWithResponse:(NSData *)aResponce
{
	NSDictionary *userInfo = (NSDictionary *)aManager.userInfo;
	id<NewsLoaderDelegate> delegate = [userInfo valueForKey:kNewsLoaderRequestDelegate];
	
	if (self.loadNewsRequest == aManager)
	{
		// parse xml data
		NSError *error = nil;
		NSArray *newsArray = [self parseNewsResponce:aResponce error:&error];
		
		// free connection
		[self.loadNewsRequest cancel];
		self.loadNewsRequest = nil;
		
		if (!newsArray || error)
		{
			if ([delegate respondsToSelector:@selector(newsLoader:didFailWithError:)]) {
				[delegate performSelector:@selector(newsLoader:didFailWithError:)
							   withObject:self withObject:error];
			}
		} else {
			// send parsed data back to delegate
			if ([delegate respondsToSelector:@selector(newsLoader:didFinishWithNewsArray:)]) {
				[delegate performSelector:@selector(newsLoader:didFinishWithNewsArray:)
							   withObject:self withObject:newsArray];
			}
		}
	}
	else
	{
		VLog(@"NewsLoader::RequestManager:didFinishWithResponse: uncknow Request");
		
		return;
	}
}

- (void)requestManager:(RequestManager *)aManager
	  didFailWithError:(NSError *)error
{
	NSDictionary *userInfo = (NSDictionary *)aManager.userInfo;
	id<NewsLoaderDelegate> delegate = [userInfo valueForKey:kNewsLoaderRequestDelegate];
	
	if (self.loadNewsRequest == aManager) {
		[self.loadNewsRequest cancel];
		self.loadNewsRequest = nil;
	} else {
		VLog(@"NewsLoader::RequestManager:didFailWithError: uncknow Request");
		return;
	}
	
	if ([delegate respondsToSelector:@selector(newsLoader:didFailWithError:)]) {
		[delegate performSelector:@selector(newsLoader:didFailWithError:)
					   withObject:self withObject:error];
	}
}


#pragma mark -
#pragma mark Parser implementation

- (NSError *)makeParseErrorWithCode:(NSInteger)anErrorCode {
	NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:kNewsLoaderPasingError, NSLocalizedDescriptionKey, nil];
	return [NSError errorWithDomain:kNewsLoaderErrorDomain code:anErrorCode userInfo:errorDict];
}

- (NSString*)createAbsoluteURLFromLocalURL:(NSString*)aLocalURL {
	if ([[aLocalURL lowercaseString] hasPrefix:@"http"]) {
		return aLocalURL;
	}
	return [NSString stringWithFormat:@"%@%@", kBaseURL, aLocalURL];
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


- (NSArray *)parseNewsResponce:(NSData *)aResponce error:(NSError **)pError {
	if (!aResponce || [NSNull null] == (NSNull *)aResponce || !aResponce.length) return nil;
	
	NSString *responseString = [[NSString alloc] initWithData:aResponce encoding:kNewsResponceEncoding]; // NSISOLatin1StringEncoding
	//NSString *responseString = [self stringFrom_ISO8859_15_Data:aResponce];
	if (!responseString || !responseString.length) {
		*pError	= [self makeParseErrorWithCode:0];
		VLog(@"Error parse response: response is empty");
		return nil;
	}
	
	NSString* wraperDivString = @"<div class='article_content article_dynamic'>";
	NSRange wraperDivRange = [responseString rangeOfString:wraperDivString
												   options:NSCaseInsensitiveSearch];
	if (NSNotFound == wraperDivRange.location) {
		*pError	= [self makeParseErrorWithCode:1];
		VLog(@"Error parse response: unable to find: \"%@\"", wraperDivString);
		return nil;
	}
	
	NSMutableArray* newsArray = [NSMutableArray array];
	NSUInteger searchRangeBegin = wraperDivRange.location + wraperDivRange.length;
	NSUInteger searchRangeEnd = responseString.length - searchRangeBegin;
	NSRange searchRange = NSMakeRange(searchRangeBegin, searchRangeEnd);
	for (NSUInteger i = 0; ; i++)
	{
		KSNews* news = [[KSNews new] autorelease];
		
		// get newsitemtitle html
		NSString* newsItemTitleHTMLString =
		[self getHTMLContentFromString:responseString
						  withBeginTag:@"<h3 class='newsitemtitle'>"
							withEndTag:@"</h3>"
							 withRange:&searchRange];
		if (!newsItemTitleHTMLString) {
			VLog(@"Can't find news item title tag: stop parsing.");
			break;
		}
		
		
		// get newsitemtitle link
		NSRange localRange = NSMakeRange(0, newsItemTitleHTMLString.length);
		NSString* newsItemLinkString =
		[self getHTMLContentFromString:newsItemTitleHTMLString
						  withBeginTag:@"href='"
							withEndTag:@"'"
							 withRange:&localRange];
		if (!newsItemLinkString) {
			VLog(@"Error parse response: bad news item url");
			break;
		}
		NSURL* newsUrl = [NSURL URLWithString:[self createAbsoluteURLFromLocalURL:newsItemLinkString]];
		if (!newsUrl) {
			VLog(@"Error parse response: bad news item url \"%@\"", newsItemLinkString);
			continue;
		}
		news.url = newsUrl;
		
		
		// get newsitemtitle text
		NSString* newsItemTitleString =
		[self getHTMLContentFromString:newsItemTitleHTMLString
						  withBeginTag:@">"
							withEndTag:@"</"
							 withRange:&localRange];
		if (!newsItemTitleString || !newsItemTitleString.length) {
			VLog(@"Error parse response: bad title");
			continue;
		}
		news.title = [[newsItemTitleString stringByTrimmingCharactersInSet:
					   [NSCharacterSet whitespaceAndNewlineCharacterSet]] gtm_stringByUnescapingFromHTML];
		
		
		
		// get introduction html
		NSString* introductionHTMLString =
		[self getHTMLContentFromString:responseString
						  withBeginTag:@"<div class='introduction'>"
							withEndTag:@"</div>"
							 withRange:&searchRange];
		if (!introductionHTMLString) {
			VLog(@"Can't find news introduction tag: stop parsing.");
			break;
		}
		
		
		// get thumb url
		localRange = NSMakeRange(0, introductionHTMLString.length);
		NSString* thumbSrcString =
		[self getHTMLContentFromString:introductionHTMLString
						  withBeginTag:@"src='"
							withEndTag:@"'"
							 withRange:&localRange];
		if (!thumbSrcString) {
			VLog(@"Error parse response: bad img src url");
			break;
		}
		NSURL* thumbUrl = [NSURL URLWithString:[self createAbsoluteURLFromLocalURL:thumbSrcString]];
		if (!thumbUrl) {
			VLog(@"Error parse response: bad img src url \"%@\"", thumbSrcString);
			continue;
		}
		news.thumbURL = thumbUrl;
		
		
		// get date string
		NSString* dateString =
		[self getHTMLContentFromString:introductionHTMLString
						  withBeginTag:@"<span class='date'>"
							withEndTag:@"</span"
							 withRange:&localRange];
		if (!dateString) {
			VLog(@"Error parse response: can't get date");
			break;
		}
		news.date = dateString;
		
		
		// get introduction text
		NSString* introductionString =
		[self getHTMLContentFromString:introductionHTMLString
						  withBeginTag:@">"
							withEndTag:@"<a"
							 withRange:&localRange];
		if (!introductionString) {
			VLog(@"Error parse response: can't introduction text");
			break;
		}
		news.introduction = [[introductionString stringByTrimmingCharactersInSet:
							  [NSCharacterSet whitespaceAndNewlineCharacterSet]] gtm_stringByUnescapingFromHTML];
		
		
		
		[newsArray addObject:news];
	}
	
	return newsArray;
}


/*
- (NSString *)stringFrom_ISO8859_15_Data:(NSData *)aData {
	NSUInteger dataLength = [aData length];
	const unsigned char *dataBytes = [aData bytes];
	NSUInteger utf16DataLength = dataLength * 2;
	unichar *utf16Buffer = (unichar *) malloc (utf16DataLength);
	if (!utf16Buffer) {
		VLog(@"Unable to alloc memory for from_ISO8859_15_to_UTF8_decoder:");
		return nil;
	}
	
	for (NSUInteger i = 0; i < dataLength; i++) {
		unsigned char isoSymbol = (unsigned char)dataBytes[i];
		unichar utf16Symbol = 0;
		switch (isoSymbol) {
			case 164: utf16Symbol = 0x20AC; break;	// euro sign
			case 166: utf16Symbol = 0x0160; break;
			case 168: utf16Symbol = 0x0161; break;
			case 180: utf16Symbol = 0x017D; break;
			case 184: utf16Symbol = 0x017E; break;
			case 188: utf16Symbol = 0x0152; break;
			case 189: utf16Symbol = 0x0153; break;
			case 190: utf16Symbol = 0x0178; break;
			default: utf16Symbol = isoSymbol; break;
		}
		utf16Buffer[i] = utf16Symbol;
	}
	
	NSString *output = [[NSString alloc] initWithBytes:utf16Buffer
												length:utf16DataLength
											  encoding:NSUTF16LittleEndianStringEncoding];	// NSUTF16LittleEndianStringEncoding NSUTF16BigEndianStringEncoding NSUTF16StringEncoding
	
	return [output autorelease];
}
*/

@end
