//
//  RequestManager.m
//  EasyTrip
//
//  Created by mac-227 on 23.02.11.
//  Copyright 2011 iTechArt. All rights reserved.
//

#import "RequestManager.h"
#import "SDNetworkActivityIndicator.h"
#import "VLog.h"


static NSString *const kRequestManagerErrorDomain	= @"RequestManagerErrorDomain";

static NSString *const kRequestManagerStartNotification	= @"RequestManagerStartNotification";
static NSString *const kRequestManagerStopNotification	= @"RequestManagerStopNotification";

// const
static NSTimeInterval kLoadRequestTimeout	= 15.f;



@interface RequestManager ()
@property (nonatomic, assign) id<RequestManagerDelegate> delegate;
@property (nonatomic, retain) NSURL	*url;

@property (nonatomic, retain) NSURLConnection	*connection;
//@property (nonatomic, retain) NSMutableData			*responce;
@end



@implementation RequestManager

@synthesize delegate	= delegate_;
@synthesize url			= url_;
@synthesize userInfo	= userInfo_;

@synthesize connection	= connection_;
@synthesize responce	= responce_;


- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver: self];
	
	self.delegate	= nil;
	self.url		= nil;
	self.userInfo	= nil;
	
	self.connection	= nil;
	self.responce	= nil;
	
	[super dealloc];
}

#pragma mark Public Methods

+ (id) requestWithURL: (NSURL *) anURL
			 delegate: (id<RequestManagerDelegate>) aDelegate
			 userInfo: (id) anUserInfo
{
	if (NSClassFromString(@"SDNetworkActivityIndicator"))
	{
		id activityIndicator = [NSClassFromString(@"SDNetworkActivityIndicator") performSelector:NSSelectorFromString(@"sharedActivityIndicator")];
		[[NSNotificationCenter defaultCenter] addObserver:activityIndicator
												 selector:NSSelectorFromString(@"startActivity")
													 name:kRequestManagerStartNotification
												   object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:activityIndicator
												 selector:NSSelectorFromString(@"stopActivity")
													 name:kRequestManagerStopNotification
												   object:nil];
	}
	
	RequestManager *loader = [[[RequestManager alloc] init] autorelease];
	loader.url		= anURL;
	loader.delegate	= aDelegate;
	loader.userInfo	= anUserInfo;
	
	[loader performSelectorOnMainThread:@selector(start) withObject:nil waitUntilDone:YES];
	
	return loader;
}

- (void)start
{
	// create request & connection
	NSURLRequest *httpRequest = [[NSURLRequest alloc] initWithURL:self.url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval: kLoadRequestTimeout];
	self.connection = [[[NSURLConnection alloc] initWithRequest:httpRequest delegate:self startImmediately:NO] autorelease];
	// Ensure we aren't blocked by UI manipulations (default runloop mode for NSURLConnection is NSEventTrackingRunLoopMode)
	[self.connection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
	[self.connection start];
	[httpRequest release];
	
	if (self.connection)
	{
		self.responce = [NSMutableData data];
		[[NSNotificationCenter defaultCenter] postNotificationName:kRequestManagerStartNotification object:nil];
	}
	else
	{
		if ([self.delegate respondsToSelector:@selector(requestManager:didFailWithError:)])
		{
			NSError *error = [NSError errorWithDomain:kRequestManagerErrorDomain
												 code:-1
											 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
													   @"Failed to create connection", NSLocalizedDescriptionKey, nil]];
			[self.delegate performSelector:@selector(requestManager:didFailWithError:)
								withObject:self withObject:error];
		}
	}
}

- (void)cancel {
	if (self.connection) {
		[self.connection cancel];
		self.connection = nil;
	}
	
	self.delegate = nil;
	self.userInfo = nil;
	self.url = nil;
	
	[[NSNotificationCenter defaultCenter] postNotificationName:kRequestManagerStopNotification object:nil];
}

#pragma mark NSURLConnection (delegate)

- (void)connection:(NSURLConnection *)aConnection didReceiveData:(NSData *)data {
	[self.responce appendData:data];
}

#pragma GCC diagnostic ignored "-Wundeclared-selector"

- (void)connectionDidFinishLoading:(NSURLConnection *)aConnection {
	self.connection = nil;
	
	[[NSNotificationCenter defaultCenter] postNotificationName:kRequestManagerStopNotification object:nil];
	
	if ([self.delegate respondsToSelector:@selector(requestManager:didFinishWithResponse:)]) {
		[self.delegate performSelector:@selector(requestManager:didFinishWithResponse:)
							withObject:self withObject:self.responce];
	}
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	[[NSNotificationCenter defaultCenter] postNotificationName:kRequestManagerStopNotification object:nil];
	
	if ([self.delegate respondsToSelector:@selector(requestManager:didFailWithError:)]) {
		[self.delegate performSelector:@selector(requestManager:didFailWithError:)
							withObject:self withObject:error];
	}
	
	self.connection	= nil;
	self.responce	= nil;
}


@end
