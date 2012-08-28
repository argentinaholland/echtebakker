//
//  TwitterViewController.m
//  KeurslagerApp
//
//  Created by mac-227 on 04.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TwitterViewController.h"

#import "DetailTwitterViewController.h"
#import "AppDelegate.h"

#import "TweetViewCell.h"
#import "WaitPanel.h"
#import "UIImageView+WebCache.h"
#import "SpinnerImageView.h"

#import "TweetMessage.h"

#import "VLog.h"
#import "helpers.h"
#import "consts.h"


static float kTextLabelHeight = 67;
//static float kLabelsVerticalGap = 5;


@interface TwitterViewController ()
@property (nonatomic, retain) NSArray* tweetsArray;
@property (nonatomic, retain) NSDate* lastUpdateDate;

@property (nonatomic, retain) EGORefreshTableHeaderView	*refreshHeaderView;
@property (nonatomic, retain) WaitPanel* waitPanel;
@property (nonatomic, retain) UIAlertView* errorAlertView;
@property (nonatomic, retain) NSDateFormatter* dateFormatter1;
@property (nonatomic, retain) NSDateFormatter* dateFormatter2;

- (void)updateData;

- (void)showWaitPanel;
- (void)hideWaitPanel;

-(NSString *)formatTime:(NSDate *)aDate;

@end



@implementation TwitterViewController

@synthesize channelNumber;

@synthesize tweetsArray, lastUpdateDate;

@synthesize tableView;
@synthesize waitPanel;
@synthesize errorAlertView;
@synthesize refreshHeaderView;
@synthesize dateFormatter1;
@synthesize dateFormatter2;


- (void)dealloc {
	self.tweetsArray = nil;
	self.lastUpdateDate = nil;
	
	self.tableView = nil;
	self.refreshHeaderView = nil;
	self.waitPanel = nil;
	self.errorAlertView = nil;
	self.dateFormatter1 = nil;
	self.dateFormatter2 = nil;
	[super dealloc];
}

- (void)viewDidUnload {
	self.tableView = nil;
	self.refreshHeaderView = nil;
	self.waitPanel = nil;
	self.errorAlertView = nil;
	self.dateFormatter1 = nil;
	self.dateFormatter2 = nil;
	[super viewDidUnload];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}


#pragma mark - View lifecycle

- (void)viewDidLoad {
	[super viewDidLoad];
	
	//self.navigationItem.title = @"";
	
	self.dateFormatter1	= [[NSDateFormatter new] autorelease];
	[self.dateFormatter1 setDateFormat:@"H"];
	//NSLocale *enLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
	[self.dateFormatter1 setLocale:[NSLocale currentLocale]];
	
	self.dateFormatter2	= [[NSDateFormatter new] autorelease];
	[self.dateFormatter2 setDateFormat:@"d MMM"];
	//NSLocale *enLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
	[self.dateFormatter1 setLocale:[NSLocale currentLocale]];
	
	
	CGSize selfSize = self.view.bounds.size;
	self.refreshHeaderView = [[[EGORefreshTableHeaderView alloc] initWithFrame:
							   CGRectMake(0, 0 - self.tableView.bounds.size.height,
										  selfSize.width, self.tableView.bounds.size.height)] autorelease];
	[self.tableView addSubview:refreshHeaderView];
	refreshHeaderView.delegate = self;
	
	
	[self updateData];
}

- (void)updateData {
	if ( ![[TweetsLoader sharedIntance] loadTweetsWithDelegate:self] )
	{
		isReloading = NO;
		VLog(@"Error to begin loading news");
		self.errorAlertView =
		[[[UIAlertView alloc] initWithTitle:kAppTitle
									message:@"Unable to update tweets.\nPlease try again later."
								   delegate:self
						  cancelButtonTitle:@"OK"
						  otherButtonTitles:nil] autorelease];
		
		[errorAlertView show];
	} else {
		isReloading = YES;
		[self showWaitPanel];
	}
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	AppDelegate* appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
	[appDelegate customizeNavigationController:self.navigationController withImage:@"KSL_Logo_navbar.png"];
	
	//self.navigationItem.title = @"";
	//[appDelegate customizeNavigationController:self.navigationController withImage:@"KSL_Twitter_navbar.png"];
	
	UIBarButtonItem *chooseTwitterChannelButton =
	[[UIBarButtonItem alloc] initWithTitle:@"Kies Echte Bakker"
									 style:UIBarButtonItemStylePlain
									target:self
									action:@selector(onChooseTwitterChannelButton)];
	self.navigationItem.rightBarButtonItem = chooseTwitterChannelButton;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}


#pragma mark -
#pragma mark <NewsLoaderDelegate> implementation

- (void)tweetsLoader:(TweetsLoader *)aManager didFinishWithNewsArray:(NSArray *)aTweetsArray {
	VLog(@"NewsManager::newsLoader:didFinishWithNewsArray:");
	
	self.tweetsArray = aTweetsArray;
	
	VLog(@"Loaded news:");
	int i = 0;
	for (TweetMessage *tweet in tweetsArray) {
		VLog(@"%d) %@", i++, [tweet description]);
	}
	
	[self.tableView reloadData];
	
	isReloading = NO;
	self.lastUpdateDate = [NSDate date];
	[refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
	[refreshHeaderView refreshLastUpdatedDate];
	
	[self hideWaitPanel];
}

- (void)tweetsLoader:(TweetsLoader *)aLoader didFailWithError:(NSError *)error {
	VLog(@"TweetsLoader::tweetsLoader:didFailWithError: %@, %d, %@",
		 [error domain], [error code], [error localizedDescription]);
	
//	if (kInternetConnecitonOfflineErrorCode != error.code) {
//		//
//	}
	
	self.errorAlertView =
	[[[UIAlertView alloc] initWithTitle:kAppTitle
								message:@"Unable to update tweets.\nPlease try again later."
							   delegate:self
					  cancelButtonTitle:@"OK"
					  otherButtonTitles:nil] autorelease];
	[errorAlertView show];
	
	[self hideWaitPanel];
}


#pragma mark -
#pragma mark <UITableViewDataSource> implementation

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return tweetsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"TweetViewCellID";
    
    TweetViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        NSArray *nibsArray = [[NSBundle mainBundle] loadNibNamed:@"TweetViewCell" owner:self options:nil];
		cell = (TweetViewCell *)[nibsArray objectAtIndex:0];
    }
	
	TweetMessage* tweet = [tweetsArray objectAtIndex:indexPath.row];
	
	cell.nameLabel.text = tweet.fromUserName;
	
	cell.dateLabel.text = [self formatTime:tweet.date];
		
	cell.textLabel.text = tweet.text;
	
	CGRect textLabelFrame = cell.textLabel.frame;
	CGSize textLabelSize = [cell.textLabel sizeThatFits:textLabelFrame.size];
	if (textLabelSize.height > kTextLabelHeight) {
		textLabelSize.height = kTextLabelHeight;
	}
	textLabelFrame.size.height = textLabelSize.height;
	cell.textLabel.frame = textLabelFrame;
	
	if (tweet.profileImageUrl) {
		[cell.profileImageView setImageWithURL:tweet.profileImageUrl
							  placeholderImage:nil];
	} else {
		//cell.profileImageView.image = [UIImage imageNamed:@""];
	} 
    
    return cell;
}


#pragma mark -
#pragma mark <UITableViewDelegate> implementation

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[aTableView deselectRowAtIndexPath:indexPath animated:YES];
	
	TweetMessage* tweet = [tweetsArray objectAtIndex:indexPath.row];
	DetailTwitterViewController* controller =
	[[DetailTwitterViewController alloc] initWithTweet:tweet];
	[self.navigationController pushViewController:controller animated:YES];
	[controller release];
}


#pragma mark -
#pragma mark Helpers

- (void)showWaitPanel {
	if (!self.waitPanel) {
		self.waitPanel = [[[WaitPanel alloc] initWithParentView:self.view] autorelease];
	}
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	[self.waitPanel showWithLabel:kAppLoadingMessage];
}

- (void)hideWaitPanel {
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	[self.waitPanel hide];
}

-(NSString *)formatTime:(NSDate *)aDate {
	NSTimeInterval interval = -[aDate timeIntervalSinceNow];
	if (interval < 60)
	{
		return @"less than minute ago";
	}
	else if (interval >= 60 && interval < 60 * 60)
	{
		int num_minutes = (int)(interval / 60);
		NSString *plural_tail = @"";
		if (num_minutes > 1) {
			plural_tail = @"s";
		}
		return [NSString stringWithFormat: @"%d minute%@ ago", num_minutes, plural_tail];
	}
	else if (interval >= 60 * 60 && interval < 24 * 60 * 60)
	{
		int num_hours = (int)(interval / (60 * 60));
		NSString *plural_tail = @"";
		if (num_hours > 1) {
			plural_tail = @"s";
		}
		return [NSString stringWithFormat: @"%d hour%@ ago", num_hours, plural_tail];
	}
	
	return [dateFormatter2 stringFromDate:aDate];
}


#pragma mark ----------------- UIScrollViewDelegate -----------------

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	[refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	[refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}


#pragma mark ----------------- EGORefreshTableHeaderDelegate -----------------

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view {
	[self updateData];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view {
	return isReloading; // should return if data source model is reloading
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view {
	return lastUpdateDate;
}


#pragma mark ----------------- UIAlertViewDelegate -----------------

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	// do nothing
}


- (IBAction)onChooseTwitterChannelButton {
	AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
	[appDelegate switchToSelectTwitterChannelController];
}


@end
