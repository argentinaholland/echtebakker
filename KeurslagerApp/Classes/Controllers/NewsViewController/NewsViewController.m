//
//  NewsViewController.m
//  KeurslagerApp
//
//  Created by mac-227 on 04.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NewsViewController.h"

#import "DetailNewsViewController.h"
#import "AppDelegate.h"
#import "NewsViewCell.h"
#import "WaitPanel.h"

#import "KSNews.h"

#import "VLog.h"
#import "helpers.h"
#import "consts.h"


//static float kIntroductionLabelHeight = 52;
static float kTitleLabelHeight = 52;
static float kLabelsVerticalGap = 5;

@interface NewsViewController ()
@property (nonatomic, retain) NSArray* newsArray;
@property (nonatomic, retain) WaitPanel* waitPanel;

- (void)showWaitPanel;
- (void)hideWaitPanel;

@end



@implementation NewsViewController

@synthesize newsArray;

@synthesize tableView;
@synthesize waitPanel;


- (void)dealloc {
	self.newsArray = nil;
	
	self.tableView = nil;
	self.waitPanel = nil;
	[super dealloc];
}

- (void)viewDidUnload {
	self.tableView = nil;
	self.waitPanel = nil;
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
	
	
	if ( ![[NewsLoader sharedIntance] loadNewsWithDelegate:self] ) {
		VLog(@"Error to begin loading news");
	} else {
		[self showWaitPanel];
	}
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	AppDelegate* appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
	[appDelegate customizeNavigationController:self.navigationController withImage:@"KSL_Logo_navbar.png"];
	
	//self.navigationItem.title = @"";
	//[appDelegate customizeNavigationController:self.navigationController withImage:@"KSL_News_navbar.png"];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}


#pragma mark -
#pragma mark <NewsLoaderDelegate> implementation

- (void)newsLoader:(NewsLoader *)aLoader didFinishWithNewsArray:(NSArray *)aNewsArray {
	VLog(@"NewsManager::newsLoader:didFinishWithNewsArray:");
	
	self.newsArray = aNewsArray;
	
	VLog(@"Loaded news:");
	int i = 0;
	for (KSNews *news in newsArray) {
		VLog(@"%d) %@", i++, [news description]);
	}
	
	[self.tableView reloadData];
	
	[self hideWaitPanel];
}

- (void)newsLoader:(NewsLoader *)aLoader didFailWithError:(NSError *)error {
	VLog(@"NewsManager::newsLoader:didFailWithError: %@, %d, %@",
		 [error domain], [error code], [error localizedDescription]);
	
	if (kInternetConnecitonOfflineErrorCode != error.code) {
		
	}
	
	[self hideWaitPanel];
}


#pragma mark -
#pragma mark IBAction handlers

- (IBAction)onShareButton {
	// TODO: implement
}


#pragma mark -
#pragma mark <UITableViewDataSource> implementation

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return newsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"NewsViewCellID";
    
    NewsViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        NSArray *nibsArray = [[NSBundle mainBundle] loadNibNamed:@"NewsViewCell" owner:self options:nil];
		cell = (NewsViewCell *)[nibsArray objectAtIndex:0];
    }
	
	KSNews* news = [newsArray objectAtIndex:indexPath.row];
	cell.titleLabel.text = news.title;
	
	CGRect titleLabelFrame = cell.titleLabel.frame;
	CGSize titleLabelSize = [cell.titleLabel sizeThatFits:titleLabelFrame.size];
	if (titleLabelSize.height > kTitleLabelHeight) {
		titleLabelSize.height = kTitleLabelHeight;
	}
	titleLabelFrame.size.height = titleLabelSize.height;
	cell.titleLabel.frame = titleLabelFrame;
	
	cell.dateLabel.text = news.date;
	CGRect dateLabelFrame = cell.dateLabel.frame;
	dateLabelFrame.origin.y = titleLabelFrame.origin.y + titleLabelFrame.size.height + kLabelsVerticalGap;
	cell.dateLabel.frame = dateLabelFrame;
	
	cell.introductionLabel.text = news.introduction;
	
	CGRect introductionLabelFrame = cell.introductionLabel.frame;
	introductionLabelFrame.origin.y = dateLabelFrame.origin.y + dateLabelFrame.size.height + kLabelsVerticalGap;
	CGSize introductionLabelSize = [cell.introductionLabel sizeThatFits:introductionLabelFrame.size];
	float maxIntroductionLabelHeight = cell.bounds.size.height - introductionLabelFrame.origin.y - kLabelsVerticalGap;
	if (introductionLabelSize.height > maxIntroductionLabelHeight) {
		introductionLabelSize.height = maxIntroductionLabelHeight;
	}
	introductionLabelFrame.size.height = introductionLabelSize.height;
	cell.introductionLabel.frame = introductionLabelFrame;
    
    return cell;
}


#pragma mark -
#pragma mark <UITableViewDelegate> implementation

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[aTableView deselectRowAtIndexPath:indexPath animated:YES];
	KSNews* news = [newsArray objectAtIndex:indexPath.row];
	DetailNewsViewController *detailViewController = [[DetailNewsViewController alloc] initWithNews:news];
	[self.navigationController pushViewController:detailViewController animated:YES];
	[detailViewController release];
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


@end
