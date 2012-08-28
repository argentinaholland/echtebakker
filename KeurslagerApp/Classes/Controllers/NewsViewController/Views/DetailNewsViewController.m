//
//  DetailNewsViewController.m
//  KeurslagerApp
//
//  Created by mac-227 on 27.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DetailNewsViewController.h"

#import "AppDelegate.h"

#import "WaitPanel.h"
#import "UIImageView+WebCache.h"
#import "SpinnerImageView.h"

#import "VLog.h"
#import "helpers.h"
#import "consts.h"

#import "KSNews.h"


@interface DetailNewsViewController ()
- (void)showLocalNews;

@end


@implementation DetailNewsViewController

@synthesize news;

@synthesize webView;

- (void)dealloc {
	self.news = nil;
	
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

- (id)initWithNews:(KSNews*)aNews {
	if (!aNews) return nil;
	
	if ((self = [super init])) {
		self.news = aNews;
	}
	
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.navigationItem.title = news.title;
	AppDelegate* appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
	[appDelegate customizeNavigationController:self.navigationController withImage:@"KSL_Clear_navbar.png"];
	
	VLog(@"news.url = %@", news.url);
	NSURLRequest* request = [NSURLRequest requestWithURL:news.url];
	[self.webView loadRequest:request];
	
	//[self showLocalNews];
}

- (void)showLocalNews {
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
	<body bgcolor=\"Silver\">\
	<div><h3>%@</h3><h4>%@</h4></div>%@</body>\
	</html>";
	
	NSString* htmlContent = [NSString stringWithFormat:htmlString, news.title, news.date, news.introduction];
	
	[self.webView loadHTMLString:htmlContent baseURL:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
