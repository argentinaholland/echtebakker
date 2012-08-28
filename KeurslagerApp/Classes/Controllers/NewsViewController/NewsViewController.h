//
//  NewsViewController.h
//  KeurslagerApp
//
//  Created by mac-227 on 04.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NewsLoader.h"


@class WaitPanel;

@interface NewsViewController : UIViewController
<NewsLoaderDelegate, UITableViewDataSource, UITableViewDelegate>
{
	NSArray* newsArray;
	
	WaitPanel* waitPanel;
}


@property (nonatomic, retain) IBOutlet UITableView* tableView;

- (IBAction)onShareButton;

@end
