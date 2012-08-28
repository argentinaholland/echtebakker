//
//  TwitterViewController.h
//  KeurslagerApp
//
//  Created by mac-227 on 04.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "EGORefreshTableHeaderView.h"
#import "TweetsLoader.h"


@class WaitPanel;

@interface TwitterViewController : UIViewController
<EGORefreshTableHeaderDelegate, TweetsLoaderDelegate, UITableViewDataSource, UITableViewDelegate>
{
	NSArray* tweetsArray;
	
	EGORefreshTableHeaderView	*refreshHeaderView;
	WaitPanel* waitPanel;
	UIAlertView* errorAlertView;
	NSDateFormatter* dateFormatter1;
	NSDateFormatter* dateFormatter2;
	
	// flags
	BOOL isReloading;
	NSDate* lastUpdateDate;
	
	NSInteger channelNumber;
}

@property (nonatomic, assign) NSInteger channelNumber;

@property (nonatomic, retain) IBOutlet UITableView* tableView;

//- (IBAction)onTwitterButton;
//- (IBAction)onFacebookButton;

- (IBAction)onChooseTwitterChannelButton;

@end
