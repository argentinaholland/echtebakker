//
//  LocationsDetailViewController.h
//  KeurslagerApp
//
//  Created by mac-227 on 27.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>


@class AddressAnnotation;

@interface LocationsDetailViewController : UIViewController <MFMailComposeViewControllerDelegate>
{
@private
	AddressAnnotation* annotation;
}

- (id)initWithAnnotation:(AddressAnnotation*)anAnnotation;

@property (nonatomic, retain) AddressAnnotation* annotation;


@property (nonatomic, retain) IBOutlet UILabel* nameLabel;
@property (nonatomic, retain) IBOutlet UILabel* addressLabel;
@property (nonatomic, retain) IBOutlet UIButton* emailButton;
@property (nonatomic, retain) IBOutlet UIButton* phone1Button;
@property (nonatomic, retain) IBOutlet UIButton* phone2Button;

- (IBAction)onSendEmail;
- (IBAction)onMakeCall1;
- (IBAction)onMakeCall2;

@end
