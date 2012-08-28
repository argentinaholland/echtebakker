//
//  TipsViewController.h
//  KeurslagerApp
//
//  Created by mac-227 on 27.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "YoutubeManager.h"
#import "EGORefreshTableHeaderView.h"


@interface TipsViewController : UIViewController
<UITableViewDelegate, UITableViewDataSource, YoutubeManagerDelegate, EGORefreshTableHeaderDelegate>
{
	NSArray* videosArray;
	NSDateFormatter	*dateFormatter;
	
	EGORefreshTableHeaderView *refreshHeaderView;
	UIAlertView* errorAlertView;
	
	BOOL isReloading;
	NSDate* lastUpdateDate;
}

@property (nonatomic, retain) IBOutlet UITableView* tableView;

@end
