//
//  SelectTwitterChannelControllerViewController.m
//  KeurslagerApp
//
//  Created by mac-214 on 5/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SelectTwitterChannelControllerViewController.h"

#import "TweetsLoader.h"
#import "AppDelegate.h"


@interface SelectTwitterChannelControllerViewController ()

- (void)showMainViewController;

@end


@implementation SelectTwitterChannelControllerViewController

- (void)dealloc {
	NSLog(@"SelectTwitterChannelControllerViewController::dealloc");
	[super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (IBAction)onSelectTwitterChannel1 {
	[TweetsLoader sharedIntance].userName = @"wdiertens";
	[self showMainViewController];
}

- (IBAction)onSelectTwitterChannel2 {
	[TweetsLoader sharedIntance].userName = @"BakerijLenes";
	[self showMainViewController];
}

- (IBAction)onSelectTwitterChannel3 {
	[TweetsLoader sharedIntance].userName = @"hoeksmaslager";
	[self showMainViewController];
}

- (IBAction)onSelectOrderForm {
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [appDelegate switchToOrderFormController];
}

- (void)showMainViewController
{
	AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
	
	// v.1
//	[appDelegate.window addSubview:appDelegate.tabBarController.view];
//	[self.view removeFromSuperview];
//	appDelegate.firstController = nil;
	
	// v.2
	[appDelegate switchToMainScreenController];
}


@end
