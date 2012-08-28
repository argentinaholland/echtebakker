//
//  TipsViewController.m
//  KeurslagerApp
//
//  Created by mac-227 on 27.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TipsViewController.h"

#import "TipsViewCell.h"
#import "TipsDetailViewController.h"

#import "AppDelegate.h"
#import "WaitPanel.h"
#import "UIImageView+WebCache.h"
#import "SpinnerImageView.h"

#import "YoutubeVideo.h"

#import "VLog.h"
#import "helpers.h"
#import "consts.h"


@interface TipsViewController ()
@property (nonatomic, retain) WaitPanel* waitPanel;
@property (nonatomic, retain) EGORefreshTableHeaderView *refreshHeaderView;
@property (nonatomic, retain) UIAlertView* errorAlertView;
@property (nonatomic, retain) NSDateFormatter *dateFormatter;

@property (nonatomic, retain) NSArray* videosArray;
@property (nonatomic, retain) NSDate* lastUpdateDate;

@property(nonatomic, assign) BOOL firstChannel;

- (void)showWaitPanel;
- (void)hideWaitPanel;

- (void)updateData;

@end


@implementation TipsViewController

@synthesize videosArray, lastUpdateDate;

@synthesize tableView;

@synthesize waitPanel = _waitPanel;
@synthesize refreshHeaderView;
@synthesize errorAlertView;
@synthesize dateFormatter;

- (void)dealloc {
	self.videosArray = nil;
	self.lastUpdateDate = nil;
	
	self.dateFormatter = nil;
	self.waitPanel = nil;
	self.tableView = nil;
	self.refreshHeaderView = nil;
	self.errorAlertView= nil;
	[super dealloc];
}

- (void)viewDidUnload {
	self.dateFormatter = nil;
	self.waitPanel = nil;
	self.tableView = nil;
	self.refreshHeaderView = nil;
	self.errorAlertView= nil;
	[super viewDidUnload];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
	[super viewDidLoad];
	
	//self.navigationItem.title = @"";
    self.firstChannel = YES;
	
	dateFormatter	= [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss"];
	[dateFormatter setLocale:[NSLocale systemLocale]];
	[dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
	
	CGSize selfSize = self.view.bounds.size;
	self.refreshHeaderView = [[[EGORefreshTableHeaderView alloc] initWithFrame:
							   CGRectMake(0, 0 - self.tableView.bounds.size.height,
										  selfSize.width, self.tableView.bounds.size.height)] autorelease];
	[self.tableView addSubview:refreshHeaderView];
	refreshHeaderView.delegate = self;
	
	[self updateData];
}

- (void)updateData {
	if ( ![[YoutubeManager sharedIntance] loadYoutubeChannelWithDelegate:self] ) {
		VLog(@"Error to begin loading news");
		isReloading = NO;
		
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
	
//	self.navigationItem.title = @"";
//	[appDelegate customizeNavigationController:self.navigationController withImage:@"KSL_Tips_navbar.png"];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}


#pragma mark - Work Stuff


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


#pragma mark -
#pragma mark <BestOffersLoaderDelegate> implementation

- (void)youtubeLoader:(YoutubeManager*)aLoader didFinishWithVideosArray:(NSArray*)anVedeosArray {
	self.videosArray = anVedeosArray;
	
	VLog(@"Loaded news:");
	int i = 0;
	for (YoutubeVideo *video in videosArray) {
		VLog(@"%d) %@", i++, [video description]);
	}
	
	[self.tableView reloadData];
	
	isReloading = NO;
	self.lastUpdateDate = [NSDate date];
	[refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
	[refreshHeaderView refreshLastUpdatedDate];
	
	[self hideWaitPanel];
}

- (void)youtubeLoader:(YoutubeManager*)aLoader didFailWithError:(NSError*)error {
	VLog(@"BestOffersLoadr::offersLoader:didFailWithError: %@, %d, %@",
		 [error domain], [error code], [error localizedDescription]);
	
//	if (kInternetConnecitonOfflineErrorCode != error.code) {
//		//
//	}
	
	self.errorAlertView =
	[[[UIAlertView alloc] initWithTitle:kAppTitle
								message:@"Unable to update tips.\nPlease try again later."
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
    return videosArray.count + 1;
}

- (IBAction)segmentedDidChange:(UISegmentedControl *)sender {
    self.firstChannel = (sender.selectedSegmentIndex == 0);
    [self updateData];
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    // segmented control
    if (indexPath.row == 0) {
        
        UISegmentedControl *segmented = [[[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"first", @"second", nil]] autorelease];
        segmented.selectedSegmentIndex = self.firstChannel ? 0 : 1;
        UITableViewCell *cell = [[[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 60)] autorelease];
        segmented.center = CGPointMake(0.5 * cell.bounds.size.width, 0.5 * cell.bounds.size.height + 7);
        [cell addSubview:segmented];
        [segmented addTarget:self action:@selector(segmentedDidChange:) forControlEvents:UIControlEventValueChanged];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    
    static NSString *cellID = @"TipsViewCellID";
    
    TipsViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        NSArray *nibsArray = [[NSBundle mainBundle] loadNibNamed:@"TipsViewCell" owner:self options:nil];
		cell = (TipsViewCell *)[nibsArray objectAtIndex:0];
    }
	
	
	YoutubeVideo* video = [videosArray objectAtIndex:indexPath.row - 1];
	
	
	cell.titleLabel.text = video.title;
	
	CGRect titleLabelFrame = cell.titleLabel.frame;
	float titleLableWidth = titleLabelFrame.size.width;
	[cell.titleLabel sizeToFit];
	titleLabelFrame = cell.titleLabel.frame;
	titleLabelFrame.size.width = titleLableWidth;
	cell.titleLabel.frame = titleLabelFrame;

	cell.dateLabel.text = [dateFormatter stringFromDate:video.pubDate];
	
	
	if (video.thumbURL) {
		[cell.thumImageView setImageWithURL:video.thumbURL
						   placeholderImage:nil];
	} else {
		//cell.thumImageView.image = [UIImage imageNamed:@""];
	}
	
    return cell;
}

-(CGFloat )tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.row == 0 ? 60 : 180;
}


#pragma mark -
#pragma mark <UITableViewDelegate> implementation

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0)
        return;
    
	[aTableView deselectRowAtIndexPath:indexPath animated:YES];
	YoutubeVideo* video = [videosArray objectAtIndex:indexPath.row - 1];
	TipsDetailViewController *detailViewController = [[TipsDetailViewController alloc] initWithVideo:video];
	[self.navigationController pushViewController:detailViewController animated:YES];
	[detailViewController release];
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


@end
