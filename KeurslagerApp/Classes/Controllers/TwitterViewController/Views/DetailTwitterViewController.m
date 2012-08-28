//
//  DetailTwitterViewController.m
//  KeurslagerApp
//
//  Created by mac-227 on 27.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DetailTwitterViewController.h"

#import "AppDelegate.h"

#import "WaitPanel.h"
#import "UIImageView+WebCache.h"
#import "SpinnerImageView.h"

#import "VLog.h"
#import "helpers.h"
#import "consts.h"

#import "TweetMessage.h"

#import "SHK.h"



@implementation DetailTwitterViewController

@synthesize tweet;

@synthesize webView;

- (void)dealloc {
	self.tweet = nil;
	
	self.webView = nil;
	[super dealloc];
}

- (void)viewDidUnload {
	self.webView = nil;
	[super viewDidUnload];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}


#pragma mark - View lifecycle

- (id)initWithTweet:(TweetMessage*)aTweet {
	if (!aTweet) return nil;
	
	if ((self = [super init])) {
		self.tweet = aTweet;
	}
	
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.navigationItem.title = @"Tweet";
	
	AppDelegate* appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
	[appDelegate customizeNavigationController:self.navigationController withImage:@"KSL_Clear_navbar.png"];
	
	
	UIButton* shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[shareButton addTarget:self 
					action:@selector(onShareButton)
		  forControlEvents:UIControlEventTouchUpInside];
	[shareButton setImage:[UIImage imageNamed:@"share_button.png"]
				 forState:UIControlStateNormal];
	shareButton.frame = CGRectMake(0, 0, 24, 24);
	
	UIBarButtonItem* rightButton = [[[UIBarButtonItem alloc] initWithCustomView:shareButton] autorelease];
	self.navigationItem.rightBarButtonItem = rightButton;
	
	
	static NSString *htmlString = @"<html><head>\
	<meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\" />\
	<meta name=\"apple-mobile-web-app-capable\" content=\"yes\" />\
	<link rel=\"apple-touch-icon\" href=\"http://localhost/up/thumb/\"/>\
	<meta name=\"viewport\" content=\"width=device-width; initial-scale=1.0; maximum-scale=1.0; user-scalable=0;\" />\
	<meta name=\"apple-mobile-web-app-capable\" content=\"yes\" />\
	<meta names=\"apple-mobile-web-app-status-bar-style\" content=\"black-translucent\" />\
	<style type=\"text/css\">\
	h1, h2, h3 { color:#004185; font-weight:500; font-family:Georgia, \"Times New Roman\", Times serif; }\
	</style>\
	</head>\
	<body>\
	<div><h3>%@</h3></div>%@</body>\
	</html>";
	
	NSString* htmlContent = [NSString stringWithFormat:htmlString, tweet.fromUser, tweet.text];
	
	[self.webView loadHTMLString:htmlContent baseURL:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}


#pragma mark -
#pragma mark IBAction handlers

- (IBAction)onShareButton {
	NSString* detailPageURLString = [NSString stringWithFormat:@"https://twitter.com/#!/KeurZijlstra/status/%@", tweet.messageID];
	NSURL* detailPageURL = [NSURL URLWithString:detailPageURLString];
	SHKItem *item = [SHKItem URL:detailPageURL title:tweet.text];
    
    SHKActionSheet *actionSheet = [SHKActionSheet actionSheetForItem:item];
    [SHK setRootViewController:self];
	[actionSheet showFromToolbar:self.navigationController.toolbar];
}


@end
