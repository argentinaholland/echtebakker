//
//  BestOffersViewController.m
//  KeurslagerApp
//
//  Created by mac-227 on 04.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BestOffersViewController.h"

#import "OfferViewCell.h"
#import "WaitPanel.h"
#import "UIImageView+WebCache.h"
#import "SpinnerImageView.h"

#import "KSOffer.h"

#import "VLog.h"
#import "helpers.h"
#import "consts.h"

#import "SHK.h"


static float kMaxDescLabelHeight = 63;
static float kLabelsVerticalGap = 5;

@interface BestOffersViewController ()
@property (nonatomic, retain) NSArray* offersArray;
@property (nonatomic, retain) NSDate* lastUpdateDate;

@property (nonatomic, retain) EGORefreshTableHeaderView	*refreshHeaderView;
@property (nonatomic, retain) WaitPanel* waitPanel;
@property (nonatomic, retain) UIAlertView* errorAlertView;

- (void)showWaitPanel;
- (void)hideWaitPanel;

- (void)updateData;

@end



@implementation BestOffersViewController

@synthesize offersArray, lastUpdateDate;

@synthesize tableView;
@synthesize waitPanel, errorAlertView, refreshHeaderView;


- (void)dealloc {
	self.offersArray = nil;
	self.lastUpdateDate = nil;
	
	self.tableView = nil;
	self.waitPanel = nil;
	self.errorAlertView = nil;
	self.refreshHeaderView = nil;
	[super dealloc];
}

- (void)viewDidUnload {
	self.tableView = nil;
	self.waitPanel = nil;
	self.errorAlertView = nil;
	self.refreshHeaderView = nil;
	[super viewDidUnload];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
	[super viewDidLoad];
	
	//self.navigationItem.title = @"";
	
	UIButton* shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[shareButton addTarget:self 
					action:@selector(onShareButton)
		  forControlEvents:UIControlEventTouchUpInside];
	[shareButton setImage:[UIImage imageNamed:@"share_button.png"]
				 forState:UIControlStateNormal];
	shareButton.frame = CGRectMake(0, 0, 24, 24);
	
	UIBarButtonItem* rightButton = [[[UIBarButtonItem alloc] initWithCustomView:shareButton] autorelease];
	self.navigationItem.rightBarButtonItem = rightButton;
	
	CGSize selfSize = self.view.bounds.size;
	self.refreshHeaderView = [[[EGORefreshTableHeaderView alloc] initWithFrame:
							   CGRectMake(0, 0 - self.tableView.bounds.size.height,
										  selfSize.width, self.tableView.bounds.size.height)] autorelease];
	[self.tableView addSubview:refreshHeaderView];
	refreshHeaderView.delegate = self;
	
	[self updateData];
}

- (void)updateData {
	if ( ![[BestOffersLoader sharedIntance] loadBestOffersWithDelegate:self] ) {
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}


#pragma mark -
#pragma mark <BestOffersLoaderDelegate> implementation

- (void)offersLoader:(BestOffersLoader *)aLoader didFinishWithOffersArray:(NSArray *)anOffersArray {
	self.offersArray = anOffersArray;
	
	VLog(@"Loaded news:");
	int i = 0;
	for (KSOffer *offer in offersArray) {
		VLog(@"%d) %@", i++, [offer description]);
	}
	
	[self.tableView reloadData];
	
	isReloading = NO;
	self.lastUpdateDate = [NSDate date];
	[refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
	[refreshHeaderView refreshLastUpdatedDate];
	
	[self hideWaitPanel];
}

- (void)offersLoader:(BestOffersLoader *)aLoader didFailWithError:(NSError *)error {
	VLog(@"BestOffersLoadr::offersLoader:didFailWithError: %@, %d, %@",
		 [error domain], [error code], [error localizedDescription]);
	
//	if (kInternetConnecitonOfflineErrorCode != error.code) {
//		//
//	}
	
	self.errorAlertView =
	[[[UIAlertView alloc] initWithTitle:kAppTitle
								message:@"Unable to update the best offers.\nPlease try again later."
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
    return offersArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"OfferViewCellID";
    
    OfferViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        NSArray *nibsArray = [[NSBundle mainBundle] loadNibNamed:@"OfferViewCell" owner:self options:nil];
		cell = (OfferViewCell *)[nibsArray objectAtIndex:0];
    }
	
	
	KSOffer* offer = [offersArray objectAtIndex:indexPath.row];
	
	
	cell.titleLabel.text = offer.title;
	
//	CGRect titleLabelFrame = cell.titleLabel.frame;
//	CGSize titleLabelSize = [cell.titleLabel sizeThatFits:titleLabelFrame.size];
//	if (titleLabelSize.height > kTitleLabelHeight) {
//		titleLabelSize.height = kTitleLabelHeight;
//	}
//	titleLabelFrame.size.height = titleLabelSize.height;
//	cell.titleLabel.frame = titleLabelFrame;
	
	cell.dateLabel.text = offer.date;
	
	
	cell.descLabel.text = offer.desc;
	
	CGRect descLabelFrame = cell.descLabel.frame;
	CGSize descLabelSize = [cell.descLabel sizeThatFits:descLabelFrame.size];
	if (descLabelSize.height > kMaxDescLabelHeight) {
		descLabelSize.height = kMaxDescLabelHeight;
	}
	descLabelFrame.size.height = descLabelSize.height;
	cell.descLabel.frame = descLabelFrame;
	
	
	cell.unitLabel.text = offer.unit;
	
	CGRect unitLabelFrame = cell.unitLabel.frame;
	unitLabelFrame.origin.y = descLabelFrame.origin.y + descLabelFrame.size.height + kLabelsVerticalGap;
	cell.unitLabel.frame = unitLabelFrame;
	
	
	NSString* priceString =
	[NSString stringWithFormat:@"%@%@%@%@",
	 offer.priceCurrency,
	 offer.priceNumbers,
	 offer.priceSeparator,
	 offer.priceDecimals,
	 nil];
	cell.priceLabel.text = priceString;
	
//	CGRect priceLabelFrame = cell.priceLabel.frame;
//	priceLabelFrame.origin.y = unitLabelFrame.origin.y + unitLabelFrame.size.height + kLabelsVerticalGap;
//	cell.priceLabel.frame = priceLabelFrame;
	
	
	if (offer.thumbURL) {
		[cell.thumImageView setImageWithURL:offer.thumbURL
						   placeholderImage:nil];
	} else {
		//cell.thumImageView.image = [UIImage imageNamed:@""];
	}
	
	
    return cell;
}


#pragma mark -
#pragma mark <UITableViewDelegate> implementation

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[aTableView deselectRowAtIndexPath:indexPath animated:YES];
	//	KSNews* news = [newsArray objectAtIndex:indexPath.row];
	//	NewsDetailViewController *detailViewController = [[NewsDetailViewController alloc] initWithNews:news];
	//	[self.navigationController pushViewController:detailViewController animated:YES];
	//	[detailViewController release];
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


#pragma mark -
#pragma mark IBAction handlers

- (IBAction)onShareButton {
	static NSString *const kBestOffersHTMLRequestURL = @"http://www.zijlstraheerenveen.keurslager.nl/aanbiedingen";
	NSURL* url = [NSURL URLWithString:kBestOffersHTMLRequestURL];
	SHKItem *item = [SHKItem URL:url title:@"Keurslager Actie's"];
    
    SHKActionSheet *actionSheet = [SHKActionSheet actionSheetForItem:item];
    [SHK setRootViewController:self];
	[actionSheet showFromToolbar:self.navigationController.toolbar];
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
