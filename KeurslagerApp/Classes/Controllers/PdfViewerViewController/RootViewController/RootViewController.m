    //
//  RootViewController.m
//  Cafe2U
//
//  Created by mac-227 on 12.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RootViewController.h"

#import "WaitPanel.h"

#import "VLog.h"
#import "consts.h"


@interface RootViewController ()
@property (nonatomic, retain) UIViewController *activeController;

@end



@implementation RootViewController

@synthesize activeController;

- (void)dealloc {
	[activeController viewWillDisappear:NO];
	[activeController.view removeFromSuperview];
	[activeController viewDidDisappear:NO];
	
	self.activeController = nil;
	
	[super dealloc];
}

- (void)viewDidUnload {
	[super viewDidUnload];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

-(id)initWithController:(UIViewController *)aController {
	if(!(self = [super initWithNibName:nil bundle:nil])) return nil;
	self.activeController = aController;
	return self;
}

-(void)loadView {
	self.view = [[[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
	
	[activeController viewWillAppear:NO];
	[self.view addSubview:activeController.view];
	[activeController viewDidAppear:NO];
}

-(void)switchToController:(UIViewController *)aController
{
	if (activeController == aController) return;
	
	aController.view.frame = self.view.bounds;
	[aController retain]; //retain aController
	
	[aController viewWillAppear:YES];
	[activeController viewWillDisappear:YES];
	
	aController.view.alpha = 0.0f;
	[self.view addSubview:aController.view];
	
	[aController viewDidAppear:YES];
	
	[UIView beginAnimations:@"switchToControllerAnimation" context:(void*)aController];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
	[UIView setAnimationDuration:0.5];
	
	aController.view.alpha = 1.0f;
	activeController.view.alpha = 0.0f;
	
	[UIView commitAnimations];
}

- (void)animationDidStop:(NSString *)animationID
                finished:(NSNumber *)finished
                 context:(void *)context
{
	if ([animationID isEqualToString:@"switchToControllerAnimation"])
	{
		[activeController.view removeFromSuperview];
        [activeController viewDidDisappear:YES];
		
		UIViewController* aController = (UIViewController*)context;
		[activeController release]; // release activeController
		activeController = aController; // (aController already retained)
	}
}


@end
