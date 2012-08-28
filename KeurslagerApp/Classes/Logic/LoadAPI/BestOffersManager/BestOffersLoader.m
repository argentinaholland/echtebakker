//
//  BestOffersLoader.m
//  KeurslagerApp
//
//  Created by mac-227 on 06.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BestOffersLoader.h"

#import "KSOffer.h"

#import "DDXML.h"
#import "DDXMLElementAdditions.h"
#import "GTMNSString+HTML.h"

#import "helpers.h"
#import "VLog.h"
#import "consts.h"



static NSString *const kBestOffersLoaderErrorDomain	= @"BestOffersLoaderErrorDomain";
static NSString *const kBestOffersLoaderPasingError	= @"Failed parse incoming news data";

static NSString *const kBaseURL = @"http://www.bakkerijdekorenaar.nl/ontbijtservice.html";
static NSString *const kBestOffersHTMLRequestURL = @"http://www.bakkerijdekorenaar.nl/ontbijtservice.html";
static NSStringEncoding	kResponceEncoding	= NSISOLatin1StringEncoding; // NSUTF8StringEncoding NSISOLatin1StringEncoding


static NSString *const kBestOffersLoaderRequestDelegate		= @"RequestDelegate";



@interface BestOffersLoader ()
@property (nonatomic, retain) RequestManager	*loadRequest;
@property (nonatomic, retain) NSDateFormatter	*dateFormatter;

- (NSArray *)parseBestOffersResponce:(NSData *)aResponce error:(NSError **)pError;

- (NSError *)makeParseErrorWithCode:(NSInteger)anErrorCode;

//- (NSString *)stringFrom_ISO8859_15_Data:(NSData *)aData;

- (NSString*)getHTMLContentFromString:(NSString*)htmlString
						 withBeginTag:(NSString*)beginTag
						   withEndTag:(NSString*)endTag
							withRange:(NSRange*)pSearchRange;

@end


@implementation BestOffersLoader

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

static BestOffersLoader *bestOffersLoaderSharedInstance__	 = nil;


+ (BestOffersLoader *)sharedIntance {
	@synchronized(self) {
		if (nil == bestOffersLoaderSharedInstance__) {
			bestOffersLoaderSharedInstance__ = [[BestOffersLoader alloc] init];
		}
	}
	return bestOffersLoaderSharedInstance__;
}

+ (id)allocWithZone:(NSZone *)zone {
	@synchronized(self) {
		if (nil == bestOffersLoaderSharedInstance__) {
			bestOffersLoaderSharedInstance__ = [super allocWithZone:zone];
		}
	}
	return bestOffersLoaderSharedInstance__;
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

- (BOOL)loadBestOffersWithDelegate:(id<BestOffersLoaderDelegate>)aDelegate {
	NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:aDelegate, kBestOffersLoaderRequestDelegate, nil];
	
	[self.loadRequest cancel];
	self.loadRequest =
	[RequestManager requestWithURL:[NSURL URLWithString:kBestOffersHTMLRequestURL]
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
		NSArray *newsArray = [self parseBestOffersResponce:aResponce error:&error];
		
		// free connection
		[self.loadRequest cancel];
		self.loadRequest = nil;
		
		if (!newsArray || error)
		{
			if ([delegate respondsToSelector:@selector(offersLoader:didFailWithError:)]) {
				[delegate performSelector:@selector(offersLoader:didFailWithError:)
							   withObject:self withObject:error];
			}
		} else {
			// send parsed data back to delegate
			if ([delegate respondsToSelector:@selector(offersLoader:didFinishWithOffersArray:)]) {
				[delegate performSelector:@selector(offersLoader:didFinishWithOffersArray:)
							   withObject:self withObject:newsArray];
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
	
	if ([delegate respondsToSelector:@selector(newsLoader:didFailWithError:)]) {
		[delegate performSelector:@selector(newsLoader:didFailWithError:)
					   withObject:self withObject:error];
	}
}


#pragma mark -
#pragma mark Parser implementation

- (NSError *)makeParseErrorWithCode:(NSInteger)anErrorCode {
	NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:kBestOffersLoaderPasingError, NSLocalizedDescriptionKey, nil];
	return [NSError errorWithDomain:kBestOffersLoaderErrorDomain code:anErrorCode userInfo:errorDict];
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


- (NSArray *)parseBestOffersResponce:(NSData *)aResponce error:(NSError **)pError {
	if (!aResponce || [NSNull null] == (NSNull *)aResponce || !aResponce.length) return nil;
	
	NSString *responseString = [[NSString alloc] initWithData:aResponce encoding:kResponceEncoding]; // NSISOLatin1StringEncoding
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
	
	NSUInteger searchRangeBegin = wraperDivRange.location + wraperDivRange.length;
	NSUInteger searchRangeEnd = responseString.length - searchRangeBegin;
	NSRange searchRange = NSMakeRange(searchRangeBegin, searchRangeEnd);
	
	NSMutableArray* offersArray = [NSMutableArray array];
	for (NSUInteger i = 0; ; i++)
	{
		KSOffer* offer = [[KSOffer new] autorelease];
		
		// get weeklyoffer-in-detail html
		NSString* weeklyOfferHTMLString =
		[self getHTMLContentFromString:responseString
						  withBeginTag:@"<div class='weeklyoffer-in-detail"
							withEndTag:@"</div>"
							 withRange:&searchRange];
		if (!weeklyOfferHTMLString || !weeklyOfferHTMLString.length) {
			VLog(@"Error parse response: no \"<div class='weeklyoffer-in-detail\"");
			break;
		}
		
		
		// get weeklyoffer-title
		NSRange localRange = NSMakeRange(0, weeklyOfferHTMLString.length);
		NSString* weeklyOfferItemTitleString =
		[self getHTMLContentFromString:weeklyOfferHTMLString
						  withBeginTag:@"<h3 class='weeklyoffer-title'>"
							withEndTag:@"</h3>"
							 withRange:&localRange];
		if (!weeklyOfferItemTitleString || !weeklyOfferItemTitleString.length) {
			VLog(@"Error parse response: no \"<h3 class='weeklyoffer-title'>\"");
			continue;
		}
		offer.title = [[weeklyOfferItemTitleString stringByTrimmingCharactersInSet:
					   [NSCharacterSet whitespaceAndNewlineCharacterSet]] gtm_stringByUnescapingFromHTML];
		
		
		// get dd 'weeklyoffer-picture' html
		NSString* weeklyOfferPictureHTMLString =
		[self getHTMLContentFromString:weeklyOfferHTMLString
						  withBeginTag:@"<dd class='weeklyoffer-picture'>"
							withEndTag:@"</dd>"
							 withRange:&localRange];
		if (!weeklyOfferPictureHTMLString || !weeklyOfferPictureHTMLString.length) {
			VLog(@"Error parse response: no \"<dd class='weeklyoffer-picture'>\"");
			continue;
		}
		
		
		// get img src content
		NSRange localRange2 = NSMakeRange(0, weeklyOfferPictureHTMLString.length);
		NSString* weeklyOfferPictureSrcString =
		[self getHTMLContentFromString:weeklyOfferPictureHTMLString
						  withBeginTag:@"src='"
							withEndTag:@"'"
							 withRange:&localRange2];
		if (!weeklyOfferPictureSrcString || !weeklyOfferPictureSrcString.length) {
			VLog(@"Error parse response: no src for 'weeklyoffer-picture' img");
			continue;
		}
		NSURL* thumbUrl = [NSURL URLWithString:[self createAbsoluteURLFromLocalURL:weeklyOfferPictureSrcString]];
		if (!thumbUrl) {
			VLog(@"Error parse response: bad 'weeklyoffer-picture' img src = \"%@\"", weeklyOfferPictureSrcString);
			continue;
		}
		offer.thumbURL = thumbUrl;
		
		
		// get dd 'weeklyoffer-description' html (text with <p>..</p> and </br> tags)
		NSString* weeklyOfferItemDescriptionString =
		[self getHTMLContentFromString:weeklyOfferHTMLString
						  withBeginTag:@"<dd class='weeklyoffer-description'>"
							withEndTag:@"</dd>"
							 withRange:&localRange];
		if (!weeklyOfferItemDescriptionString || !weeklyOfferItemDescriptionString.length) {
			VLog(@"Error parse response: no \"<dd class='weeklyoffer-description'>\"");
			continue;
		}
		weeklyOfferItemDescriptionString = replaceParagraphsWithNewLine(weeklyOfferItemDescriptionString);
		weeklyOfferItemDescriptionString = [weeklyOfferItemDescriptionString stringByStrippingHTML];
		offer.desc = [[weeklyOfferItemDescriptionString stringByTrimmingCharactersInSet:
					   [NSCharacterSet whitespaceAndNewlineCharacterSet]] gtm_stringByUnescapingFromHTML];
		
		
		// get dd 'weeklyoffer-unit' html (row text)
		NSString* weeklyOfferItemUnitHTMLString =
		[self getHTMLContentFromString:weeklyOfferHTMLString
						  withBeginTag:@"<dd class='weeklyoffer-unit'>"
							withEndTag:@"</dd>"
							 withRange:&localRange];
		if (!weeklyOfferItemUnitHTMLString || !weeklyOfferItemUnitHTMLString.length) {
			VLog(@"Error parse response: no \"<dd class='weeklyoffer-unit'>\"");
			continue;
		}
		offer.unit = [[weeklyOfferItemUnitHTMLString stringByTrimmingCharactersInSet:
					   [NSCharacterSet whitespaceAndNewlineCharacterSet]] gtm_stringByUnescapingFromHTML];
		
		
		// get dd 'weeklyoffer-price' html
		NSString* weeklyOfferItemPriceHTMLString =
		[self getHTMLContentFromString:weeklyOfferHTMLString
						  withBeginTag:@"<dd class='weeklyoffer-price'>"
							withEndTag:@"</dd>"
							 withRange:&localRange];
		if (!weeklyOfferItemPriceHTMLString || !weeklyOfferItemPriceHTMLString.length) {
			VLog(@"Error parse response: no \"<dd class='weeklyoffer-price'>\"");
			continue;
		}
		
		
		
		// get price text (numbers with currentcy) by concatinating spans
		
		// #0 get <span class='numbers'>...</span> text
		localRange2 = NSMakeRange(0, weeklyOfferItemPriceHTMLString.length);
		NSString* currencyString =
		[self getHTMLContentFromString:weeklyOfferItemPriceHTMLString
						  withBeginTag:@"<span class='currency'>"
							withEndTag:@"</span>"
							 withRange:&localRange2];
		currencyString = [[currencyString stringByTrimmingCharactersInSet:
						   [NSCharacterSet whitespaceAndNewlineCharacterSet]] gtm_stringByUnescapingFromHTML];
		
		if (!currencyString || !currencyString.length) {
			VLog(@"Error parse response: no text inside \"<span class='currency'>\"");
			continue;
		}
		offer.priceCurrency = currencyString;
		
		// #1 get <span class='numbers'>...</span> text
		NSString* numbersString =
		[self getHTMLContentFromString:weeklyOfferItemPriceHTMLString
						  withBeginTag:@"<span class='numbers'>"
							withEndTag:@"</span>"
							 withRange:&localRange2];
		numbersString = [[numbersString stringByTrimmingCharactersInSet:
						  [NSCharacterSet whitespaceAndNewlineCharacterSet]] gtm_stringByUnescapingFromHTML];

		if (!numbersString || !numbersString.length) {
			VLog(@"Error parse response: no text inside \"<span class='numbers'>\"");
			continue;
		}
		offer.priceNumbers = numbersString;
		
		// #2 get <span class='separator'>...</span> text
		NSString* separatorString =
		[self getHTMLContentFromString:weeklyOfferItemPriceHTMLString
						  withBeginTag:@"<span class='separator'>"
							withEndTag:@"</span>"
							 withRange:&localRange2];
		separatorString = [[separatorString stringByTrimmingCharactersInSet:
							[NSCharacterSet whitespaceAndNewlineCharacterSet]] gtm_stringByUnescapingFromHTML];
		
		if (!separatorString || !separatorString.length) {
			VLog(@"Error parse response: no text inside \"<span class='separator'>\"");
			continue;
		}
		offer.priceSeparator = separatorString;
		
		// #3 get <span class='decimals'>...</span> text
		NSString* decimalsString =
		[self getHTMLContentFromString:weeklyOfferItemPriceHTMLString
						  withBeginTag:@"<span class='decimals'>"
							withEndTag:@"</span>"
							 withRange:&localRange2];
		decimalsString = [[decimalsString stringByTrimmingCharactersInSet:
							[NSCharacterSet whitespaceAndNewlineCharacterSet]] gtm_stringByUnescapingFromHTML];
		
		if (!decimalsString || !decimalsString.length) {
			VLog(@"Error parse response: no text inside \"<span class='decimals'>\"");
			continue;
		}
		offer.priceDecimals = decimalsString;
		
		
		
		// get dd 'weeklyoffer-date' html
		NSString* weeklyOfferItemDateHTMLString =
		[self getHTMLContentFromString:weeklyOfferHTMLString
						  withBeginTag:@"<dd class='weeklyoffer-date'>"
							withEndTag:@"</dd>"
							 withRange:&localRange];
		if (!weeklyOfferItemDateHTMLString || !weeklyOfferItemDateHTMLString.length) {
			VLog(@"Error parse response: no \"<dd class='weeklyoffer-date'>\"");
			continue;
		}
		offer.date = [[weeklyOfferItemDateHTMLString stringByTrimmingCharactersInSet:
					   [NSCharacterSet whitespaceAndNewlineCharacterSet]] gtm_stringByUnescapingFromHTML];
		
		
		
		[offersArray addObject:offer];
	}
	
	return offersArray;
}



@end
