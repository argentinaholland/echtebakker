//
//  BestOffersViewController.h
//  KeurslagerApp
//
//  Created by mac-227 on 04.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BestOffersLoader.h"
#import "EGORefreshTableHeaderView.h"


@class WaitPanel;

@interface BestOffersViewController : UIViewController
<EGORefreshTableHeaderDelegate, BestOffersLoaderDelegate, UITableViewDataSource, UITableViewDelegate>
{
	NSArray* offersArray;
	
	WaitPanel* waitPanel;
	EGORefreshTableHeaderView	*refreshHeaderView;
	UIAlertView* errorAlertView;
	
	BOOL isReloading;
	NSDate* lastUpdateDate;
}


@property (nonatomic, retain) IBOutlet UITableView* tableView;

@end
