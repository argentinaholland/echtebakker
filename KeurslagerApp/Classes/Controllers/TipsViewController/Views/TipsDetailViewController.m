//
//  TipsDetailViewController.m
//  KeurslagerApp
//
//  Created by mac-227 on 27.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TipsDetailViewController.h"

#import "AppDelegate.h"

#import "WaitPanel.h"
#import "UIImageView+WebCache.h"
#import "SpinnerImageView.h"

#import "VLog.h"
#import "helpers.h"
#import "consts.h"

#import "SHK.h"

#import "YoutubeVideo.h"


@interface TipsDetailViewController ()

- (void)embedYouTube:(NSString *)urlString;
- (void)embedYouTube2:(NSString *)urlString;

@end


@implementation TipsDetailViewController

@synthesize video;
@synthesize webView;

- (void)dealloc {
	self.video = nil;
	
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

- (id)initWithVideo:(YoutubeVideo*)aVideo {
	if (!aVideo) return nil;
	
	if ((self = [super init])) {
		self.video = aVideo;
	}
	
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.navigationItem.title = video.title;
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
	
	
	[self embedYouTube2:[video.linkURL absoluteString]];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}


#pragma mark - Work Stuff

- (void)embedYouTube:(NSString *)urlString {
	NSString *embedHTML = @"\
	<html><head>\
	<style type=\"text/css\">\
	body {\
	background-color:white;\
	color:black;\
	}\
	</style>\
	</head><body style=\"margin:0\">\
	<h1>Title</h1>\
	<embed id=\"yt\" src=\"%@\" type=\"application/x-shockwave-flash\" \
	width=\"%0.0f\" height=\"%0.0f\"></embed>\
	</body></html>";
	
	/*
     NSString *embedHTML = @"<html><head>\
     <style type='text/css'>\
     body {\
     background-color:blue;\
     color:white;\
     }\
     </style>\
     </head>\
     <body style='margin:0'>\
     <iframe src='%@' width='%0.0f' height='%0.0f' frameborder='0' allowfullscreen></iframe>\
     </body></html>";
     */
	
	NSString *html = [NSString stringWithFormat:embedHTML, urlString, self.webView.frame.size.width, self.webView.frame.size.height];
	[self.webView loadHTMLString:html baseURL:nil];
}

- (void)embedYouTube2:(NSString *)urlString {
	NSString *embedHTML = @"<html><head>\
	<meta name = \"viewport\" content = \"initial-scale = 1.0, user-scalable = no, width = %0.0f\"/></head>\
	<body style=\"background:#000; margin-top:0px; margin-left:0px\">\
	<div><object width=\"%0.0f\" height=\"%0.0f\">\
	<param name=\"movie\" value=\"%@\"></param>\
	<param name=\"wmode\" value=\"transparent\"></param>\
	<embed src=\"%@\"\
	type=\"application/x-shockwave-flash\" wmode=\"transparent\" width=\"%0.0f\" height=\"%0.0f\"></embed>\
	</object></div></body></html>";
	
	float width = self.webView.frame.size.width;
	float height = self.webView.frame.size.height;
	NSString *html = [NSString stringWithFormat:embedHTML, width, width, height, urlString, urlString, width, height];
	//NSURL* baseURL = [NSURL URLWithString:urlString];
	NSURL* baseURL = nil;
	[self.webView loadHTMLString:html baseURL:baseURL];
}


#pragma mark -
#pragma mark IBAction handlers

- (IBAction)onShareButton {
	SHKItem *item = [SHKItem URL:video.linkURL title:video.title];
    
    SHKActionSheet *actionSheet = [SHKActionSheet actionSheetForItem:item];
    [SHK setRootViewController:self];
	[actionSheet showFromToolbar:self.navigationController.toolbar];
}


@end
