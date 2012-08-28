//
//  MakeOrderViewController.m
//  KeurslagerApp
//
//  Created by mac-227 on 04.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MakeOrderViewController.h"

#import "AppDelegate.h"

#import "VLog.h"
#import "helpers.h"
#import "consts.h"

#define kWebPageURL @"http://www.unipage.nl/pages/eigen-afbeelding/company/9231AS-Bakkerij-De-Korenaar/"
#define kWebPageURL2 @"http://www.unipage.nl/pages/eigen-afbeelding/company/9231AS-Bakkerij-De-Korenaar/"

@interface MakeOrderViewController ()

- (void)embedOrderForm;

@end


@implementation MakeOrderViewController

@synthesize webView, address2;

- (void)dealloc {
	self.webView = nil;
	[super dealloc];
}

- (void)viewDidUnload {
	[super viewDidUnload];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
	[super viewDidLoad];
	
	//self.navigationItem.title = @"";
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	AppDelegate* appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
	[appDelegate customizeNavigationController:self.navigationController withImage:@"KSL_Logo_navbar.png"];
	
	//self.navigationItem.title = @"";
	//[appDelegate customizeNavigationController:self.navigationController withImage:@"KSL_Twitter_navbar.png"];
	
	// update form each time
	[self embedOrderForm];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark -
#pragma mark <UITextFieldDelegate>


- (void)embedOrderForm {
	/*NSString *embedHTML = @"<html><head></head>\
	<body>\
	<iframe allowtransparency=\"true\" src=\"http://form.jotformeu.com/form/22153126239346\" frameborder=\"0\" style=\"width:100%; height:1229px; border:none;\" scrolling=\"no\">\
	</body></html>";
	
	
	/*
     NSString *embedHTML = @"<html><head>\
     <meta name = \"viewport\" content = \"initial-scale = 1.0, user-scalable = no, width = %0.0f\"/></head>\
     <body style=\"background:#FFF; margin-top:0px; margin-left:0px\">\
     <iframe allowtransparency=\"true\" src=\"http://form.jotformeu.com/form/22153126239346\" frameborder=\"0\" style=\"width:100%; height:1200px; border:none;\" scrolling=\"no\">\
     </iframe>\
     <script type=\"text/javascript\">\
     </body></html>";
	 */
	
	//@"<script src=\"http://max.jotfor.ms/min/g=jotform?3.0.2691\" type=\"text/javascript\"></script>\"
	//@"<script type=\"text/javascript\" src=\"http://form.jotformeu.com/jsform/22153126239346\"></script>\"
	
	//NSURL* baseURL = [NSURL URLWithString:urlString];
	NSURL* baseURL = nil;
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.address2 ? kWebPageURL2 : kWebPageURL]];
    UIWebView *webView2 = [[UIWebView alloc] init];
    [webView2 setDelegate:self];
    [webView2 loadRequest:request];
    
    self.webView.scalesPageToFit = YES;
}


-(void)webViewDidFinishLoad:(UIWebView *)webView {
    if (![webView isEqual:self.webView]) {
        NSString *javascripts = [webView stringByEvaluatingJavaScriptFromString:@"document.getElementsByTagName('head')[0].outerHTML"];
        NSString *htmlElement = [webView stringByEvaluatingJavaScriptFromString:@"document.getElementsByClassName('c2')[0].outerHTML"];
        [self.webView loadHTMLString:[NSString stringWithFormat:@"%@ %@",javascripts,htmlElement] baseURL:nil];
    }
}



@end