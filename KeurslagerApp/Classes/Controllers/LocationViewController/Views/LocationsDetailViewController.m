//
//  LocationsDetailViewController.m
//  KeurslagerApp
//
//  Created by mac-227 on 27.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LocationsDetailViewController.h"

#import "AppDelegate.h"
#import "AddressAnnotation.h"

#import "WaitPanel.h"
#import "UIImageView+WebCache.h"
#import "SpinnerImageView.h"

#import "VLog.h"
#import "helpers.h"
#import "consts.h"

#import "SHK.h"


@interface LocationsDetailViewController ()
- (void)makeTelephoneCall:(NSString *)aPhoneNumber;

@end


@implementation LocationsDetailViewController

@synthesize annotation;
@synthesize nameLabel, addressLabel, emailButton, phone1Button, phone2Button;


- (void)dealloc {
	self.annotation = nil;
	
	self.nameLabel = nil;
	self.addressLabel = nil;
	self.emailButton = nil;
	self.phone1Button = nil;
	self.phone2Button = nil;
	[super dealloc];
}

- (void)viewDidUnload {
	self.nameLabel = nil;
	self.addressLabel = nil;
	self.emailButton = nil;
	self.phone1Button = nil;
	self.phone2Button = nil;
	[super viewDidUnload];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}


#pragma mark - View lifecycle

- (id)initWithAnnotation:(AddressAnnotation*)anAnnotation {
	if (!anAnnotation) return nil;
	
	if ((self = [super init])) {
		self.annotation = anAnnotation;
	}
	
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.navigationItem.title = @"Informatie";
	//self.navigationItem.title = titles;
	
	UIButton* shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[shareButton addTarget:self 
					action:@selector(onShareButton)
		  forControlEvents:UIControlEventTouchUpInside];
	[shareButton setImage:[UIImage imageNamed:@"share_button.png"]
				 forState:UIControlStateNormal];
	shareButton.frame = CGRectMake(0, 0, 24, 24);
	
	UIBarButtonItem* rightButton = [[[UIBarButtonItem alloc] initWithCustomView:shareButton] autorelease];
	self.navigationItem.rightBarButtonItem = rightButton;
	
	
	AppDelegate* appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
	[appDelegate customizeNavigationController:self.navigationController withImage:@"KSL_Clear_navbar.png"];
	
	
	self.nameLabel.text = annotation.title;
	
	self.addressLabel.text = annotation.address;
	[self.addressLabel sizeToFit];
	
	[self.emailButton setTitle:annotation.email
					   forState:UIControlStateNormal];
	[self.emailButton sizeToFit];
	
	if (annotation.phone1 && annotation.phone1.length) {
		[self.phone1Button setTitle:annotation.phone1
						   forState:UIControlStateNormal];
	} else {
		[self.phone1Button removeFromSuperview];
	}
	
	if (annotation.phone2 && annotation.phone2.length) {
		[self.phone2Button setTitle:annotation.phone2
						   forState:UIControlStateNormal];
	} else {
		[self.phone2Button removeFromSuperview];
	}
	
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}


#pragma mark -
#pragma mark IBAction handlers

- (IBAction)onShareButton {
	SHKItem *item = [SHKItem URL:annotation.linkURL title:annotation.title];
    
    SHKActionSheet *actionSheet = [SHKActionSheet actionSheetForItem:item];
    [SHK setRootViewController:self];
	[actionSheet showFromToolbar:self.navigationController.toolbar];
}

- (IBAction)onSendEmail {
	if ([MFMailComposeViewController canSendMail]) {
		MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
		
		controller.mailComposeDelegate = self;
		[controller setSubject:@""]; // kAppMailSubject
		NSArray* mailRecipients = [NSArray arrayWithObjects:annotation.email, nil];
		[controller setToRecipients:mailRecipients];
		
		//NSString *messageBody = [NSString stringWithFormat:@""];
		[controller setMessageBody:@"" isHTML:NO];
		[self presentModalViewController:controller animated:YES];
		[controller release];
	} else {
		UIAlertView *alertView =
		[[UIAlertView alloc] initWithTitle:kAppErrorTitle
								   message:NSLocalizedString(@"You need to set up an email account to use this feature", @"")
								  delegate:nil
						 cancelButtonTitle:@"OK"
						 otherButtonTitles:nil];
		[alertView show];
		[alertView release];
	}
}

- (IBAction)onMakeCall1 {
	[self makeTelephoneCall:annotation.phone1];
}

- (IBAction)onMakeCall2 {
	[self makeTelephoneCall:annotation.phone2];
}


#pragma mark -
#pragma mark Helpers

- (void)makeTelephoneCall:(NSString *)aPhoneNumber {
	if (!aPhoneNumber || [NSNull null] == (NSNull *)aPhoneNumber || !aPhoneNumber.length) return;
	
	// trim spaces
	aPhoneNumber = [aPhoneNumber stringByReplacingOccurrencesOfString:@" "
														 withString:@""];
	NSString *phoneURLString = [NSString stringWithFormat:@"tel:%@", aPhoneNumber];
	NSURL *phoneURL = [NSURL URLWithString:phoneURLString];
	if (![[UIApplication sharedApplication] canOpenURL:phoneURL]) {
		UIAlertView *alertView =
		[[UIAlertView alloc] initWithTitle:kAppTitle
								   message:kDeviceDoesntSupportFeature
								  delegate:nil
						 cancelButtonTitle:@"OK"
						 otherButtonTitles:nil];
		[alertView show];
		[alertView release];
		return;
	}
	[[UIApplication sharedApplication] openURL:phoneURL];
}


#pragma mark -
#pragma mark <MFMailComposeViewControllerDelegate> implementation

- (void)mailComposeController:(MFMailComposeViewController*)controller
		  didFinishWithResult:(MFMailComposeResult)result
						error:(NSError*)error
{
	[self becomeFirstResponder];
	[self dismissModalViewControllerAnimated:YES];
}


@end
