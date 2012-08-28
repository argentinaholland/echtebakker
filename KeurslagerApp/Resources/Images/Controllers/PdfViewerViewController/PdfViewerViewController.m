//
//  PdfViewerViewController.m
//  KeurslagerApp
//
//  Created by mac-214 on 5/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "TweetsLoader.h"
#import "PdfViewerViewController.h"

#import "PDFViewerController.h"


#define ZOOM_VIEW_TAG 100500
#define ZOOM_STEP 1.5

#define THUMB_HEIGHT 150
#define THUMB_V_PADDING 10
#define THUMB_H_PADDING 10
#define CREDIT_LABEL_HEIGHT 20

#define AUTOSCROLL_THRESHOLD 30

static const float kHideBarsInterval = 5.f;
static const float kHideBarsIntervalAfterReset = 5.f;



@interface PdfViewerViewController ()
@property (nonatomic, retain) TapControllingView* contentView;

@property (nonatomic, retain) NSTimer*         hideBarsTimer;
@property (nonatomic, assign) AppDelegate*     appDelegate;


- (void)pickPDfNamed:(NSString *)name;
- (void)showPageNumber:(NSInteger)pageNumber;
- (void)showPdfPage;


- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center;

- (void)toggleThumbView;
- (void)hideNavigationBarAnimated:(BOOL)isAnimated;
- (void)showNavigationBarAnimated:(BOOL)isAnimated;
- (void)showTabBarAnimated:(BOOL)isAnimated;
- (void)hideTabBarAnimated:(BOOL)isAnimated;

- (void)runHideBarsTimer;
- (void)resetHideBarsTimer;
- (void)removeHideBarsTimer;

- (void)observeAppNotifications;
- (void)removeAppNotifications;

@end



@implementation PdfViewerViewController

@synthesize hideBarsTimer;
@synthesize appDelegate;

@synthesize contentView;

@synthesize scrollView;

- (void)dealloc {
	self.appDelegate = nil;
	
	[self removeAppNotifications];
	[self removeHideBarsTimer];
	
	CGPDFDocumentRelease(myDocumentRef), myDocumentRef = NULL;
    myPageRef = NULL;
	
	self.contentView = nil;
	self.scrollView = nil;
	
	[super dealloc];
}

- (void)viewDidUnload
{
	[self removeAppNotifications];
	[self removeHideBarsTimer];
	
	CGPDFDocumentRelease(myDocumentRef), myDocumentRef = NULL;
    myPageRef = NULL;
	
	self.contentView = nil;
	self.scrollView = nil;
	
	[super viewDidUnload];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
	
	scrollView.delegate = self;
	scrollView.maximumZoomScale = 1000;
	
    NSString* pdfName;//= @"ZijlstraHeerenveenbbq2012"; // default
    NSString* twitterUserName = [TweetsLoader sharedIntance].userName;
    if ([twitterUserName isEqualToString:@"hoeksmaslager"]) {
        pdfName = @"Proef Hoeksma - Wolvega - BBQ folder A4_400797";
    } else if ([twitterUserName isEqualToString:@"Sneekerpoort"]) {
        pdfName = @"Sneekerpoort_BBQ_2011";
    } else if ([twitterUserName isEqualToString:@"KeurZijlstra"]) {
        pdfName = @"ZijlstraHeerenveenbbq2012";
    } if ([twitterUserName isEqualToString:@"klaver_schagen"]) {
        pdfName = @"klaver_PDF";
    }	
	
	[self pickPDfNamed:pdfName];
	
	[self observeAppNotifications];
	
	
	
	// initialize arrows
	UIImage *leftImageOff = [UIImage imageNamed:@"left_off.png"];
	UIImage *leftImageOn = [UIImage imageNamed:@"left_on.png"];
	
	UIButton *leftButton = [UIButton buttonWithType: UIButtonTypeCustom];
	[leftButton setImage:leftImageOff forState:UIControlStateNormal];
	[leftButton setImage:leftImageOn forState:UIControlStateSelected];
	[leftButton addTarget:self action:@selector(leftClicked) forControlEvents:UIControlEventTouchUpInside];
	leftButton.frame = CGRectMake(0.0, 0.0, 33.0, 30.0);
	leftButton.accessibilityLabel = @"Previous article";
	leftButton.accessibilityTraits = UIAccessibilityTraitStaticText;
	
	UIImage *rightImageOff = [UIImage imageNamed:@"right_off.png"];
	UIImage *rightImageOn = [UIImage imageNamed:@"right_on.png"];
	
	UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[rightButton setImage:rightImageOff forState:UIControlStateNormal];
	[rightButton setImage:rightImageOn forState:UIControlStateSelected];
	[rightButton addTarget:self action:@selector(rightClicked) forControlEvents:UIControlEventTouchUpInside];
	rightButton.frame = CGRectMake(32.0, 0.0, 33.0, 30.0);
	rightButton.accessibilityLabel = @"Next article";
	rightButton.accessibilityTraits = UIAccessibilityTraitStaticText;
	
	UIView *arrowView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 66.0, 30.0)];
	[arrowView addSubview:leftButton];
	[arrowView addSubview:rightButton];
	
	UIBarButtonItem* arrowsBarButton = [[[UIBarButtonItem alloc] initWithCustomView:arrowView] autorelease];
	[arrowView release];
	
	self.navigationItem.rightBarButtonItem = arrowsBarButton;
}

- (void)viewWillDisappear:(BOOL)animated {
	NSLog(@"PdfViewerViewController::viewWillDisappear");
	[super viewWillDisappear:animated];
	
	[self removeHideBarsTimer];
	[self showBarsAnimated:NO];
}

- (void)viewWillAppear:(BOOL)animated {
	NSLog(@"PdfViewerViewController::viewWillAppear");
	[super viewWillAppear:animated];
	
	[self removeHideBarsTimer];
}

- (void)viewDidAppear:(BOOL)animated {
	NSLog(@"PdfViewerViewController::viewDidAppear");
	[super viewDidAppear:animated];
	
	[self runHideBarsTimer];
}


#pragma mark -
#pragma mark IBAction handlers

-(void)rightClicked {
	[self showPageNumber:currentPage + 1];
}

-(void)leftClicked {
	[self showPageNumber:currentPage - 1];
}


#pragma mark -
#pragma mark Working staff

- (void)pickPDfNamed:(NSString *)name
{
	NSParameterAssert(name);
	NSParameterAssert(name.length);
	
	NSString* path = [[NSBundle mainBundle] pathForResource:name
													 ofType:@"pdf"];
	path = [path stringByExpandingTildeInPath];
	NSURL* pdfURL = [NSURL fileURLWithPath:path];
	
	myDocumentRef = CGPDFDocumentCreateWithURL((CFURLRef)pdfURL);
	numberOfPages = CGPDFDocumentGetNumberOfPages(myDocumentRef);
	currentPage = 1;
	
	[self showPdfPage];
}


- (void)showPdfPage
{
	myPageRef = CGPDFDocumentGetPage(myDocumentRef, currentPage);
	CGRect pageRect = CGRectIntegral(CGPDFPageGetBoxRect(myPageRef, kCGPDFCropBox));
	
	// first remove previous image view, if any
	[contentView removeFromSuperview];
	
	
	self.contentView = [[[TapControllingView alloc] initWithFrame:pageRect] autorelease];
	contentView.delegate = self;
	contentView.tag = ZOOM_VIEW_TAG;
	
	
	CATiledLayer *tiledLayer = [CATiledLayer layer];
	tiledLayer.delegate = self;
	tiledLayer.tileSize = CGSizeMake(1024.0, 1024.0);
	tiledLayer.levelsOfDetail = 1000;
	tiledLayer.levelsOfDetailBias = 1000;
	tiledLayer.frame = pageRect;
	
	[contentView.layer addSublayer:tiledLayer];
	
	[scrollView addSubview:contentView];
	[scrollView setContentSize:contentView.frame.size];
	
	
	// choose minimum scale so image height fits screen
	//CGRect scrollViewFrame = scrollView.frame;
	CGRect scrollViewFrame = CGRectMake(0, 0, 320, 480 - 20);
	
	//float minScale  = CGRectGetWidth(scrollViewFrame) / CGRectGetWidth(contentView.frame); // for width
	float minScale  = CGRectGetHeight(scrollViewFrame) / CGRectGetHeight(contentView.frame); // for height
	[scrollView setMinimumZoomScale:minScale];
	[scrollView setZoomScale:minScale];
	[scrollView setContentOffset:CGPointZero];
}

- (void)showPageNumber:(NSInteger)pageNumber {
	if (pageNumber < 1 || pageNumber > numberOfPages) return;
	currentPage = pageNumber;
	[self showPdfPage];
}


#pragma mark -
#pragma mark <UIScrollViewDelegate> implementation

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)aScrollView {
	NSLog(@"viewForZoomingInScrollView");
    return contentView;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)aScrollView {
	NSLog(@"scrollViewWillBeginDragging");
	[self resetHideBarsTimer];
}

- (void)scrollViewDidScroll:(UIScrollView *)aScrollView {
//	float yOffset = aScrollView.contentOffset.y;
//	if (0 == yOffset) {
//        [self removeHideBarsTimer];
//        [self showBarsAnimated:YES];
//    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)aScrollView willDecelerate:(BOOL)decelerate {
	NSLog(@"scrollViewDidEndDragging");
	[self resetHideBarsTimer];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)aScrollView {
	NSLog(@"scrollViewDidEndDecelerating");
	[self resetHideBarsTimer];
}


#pragma mark -
#pragma mark ,CATiledLayerDelegate> implementation

- (void)drawLayer:(CALayer*)layer inContext:(CGContextRef)ctx
{
    CGContextSetRGBFillColor(ctx, 1.0, 1.0, 1.0, 1.0);
    CGContextFillRect(ctx, CGContextGetClipBoundingBox(ctx));
    CGContextTranslateCTM(ctx, 0.0, layer.bounds.size.height);
    CGContextScaleCTM(ctx, 1.0, -1.0);
    CGContextConcatCTM(ctx, CGPDFPageGetDrawingTransform(myPageRef, kCGPDFCropBox, layer.bounds, 0, true));
    CGContextDrawPDFPage(ctx, myPageRef);
}


#pragma mark TapDetectingImageViewDelegate methods

- (void)tapControllingImageView:(TapControllingView*)view gotSingleTapAtPoint:(CGPoint)tapPoint {
	// Single tap shows or hides drawer of thumbnails.
	[self toggleThumbView];
}

- (void)tapControllingImageView:(TapControllingView*)view gotDoubleTapAtPoint:(CGPoint)tapPoint {
	// double tap zooms in
	float newScale = scrollView.zoomScale * ZOOM_STEP;
	CGRect zoomRect = [self zoomRectForScale:newScale withCenter:tapPoint];
	[scrollView zoomToRect:zoomRect animated:YES];
}

- (void)tapControllingImageView:(TapControllingView*)view gotTwoFingerTapAtPoint:(CGPoint)tapPoint {
    // two-finger tap zooms out
    float newScale = scrollView.zoomScale / ZOOM_STEP;
    CGRect zoomRect = [self zoomRectForScale:newScale withCenter:tapPoint];
    [scrollView zoomToRect:zoomRect animated:YES];
}



#pragma mark -
#pragma mark Helper methods

- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center
{
	// the zoom rect is in the content view's coordinates. 
	// At a zoom scale of 1.0, it would be the size of the imageScrollView's bounds.
	// As the zoom scale decreases, so more content is visible, the size of the rect grows.
	CGRect zoomRect;
	zoomRect.size.height = CGRectGetHeight(scrollView.frame) / scale;
	zoomRect.size.width  = CGRectGetWidth(scrollView.frame)  / scale;
	
	// choose an origin so as to get the right center.
	zoomRect.origin.x    = center.x - CGRectGetWidth(zoomRect)  / 2.;
	zoomRect.origin.y    = center.y - CGRectGetHeight(zoomRect) / 2.;
	
	return zoomRect;
}

- (void)observeAppNotifications {
	// Detect iOS4.0+
	if (&UIApplicationDidEnterBackgroundNotification) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
	}
	if (&UIApplicationWillEnterForegroundNotification) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
	}
}

- (void)removeAppNotifications {
    // Detect iOS4.0+
    if (&UIApplicationDidEnterBackgroundNotification) {
        [[NSNotificationCenter defaultCenter] removeObserver:self
														name:UIApplicationDidEnterBackgroundNotification
													  object:nil];
    }
    if (&UIApplicationWillEnterForegroundNotification) {
        [[NSNotificationCenter defaultCenter] removeObserver:self
														name:UIApplicationWillEnterForegroundNotification
													  object:nil];
    }
}

- (void)appDidEnterBackground {
	NSLog(@"StoryViewController::appDidEnterBackground");
	
	[self removeHideBarsTimer];
}

- (void)appWillEnterForeground {
	NSLog(@"StoryViewController::appWillEnterForeground");
	
	[self runHideBarsTimer];
}


- (void)hideBarsTimerHandler:(NSTimer*)theTimer {
	NSLog(@"hideBarsTimerHandler");

    [self hideBarsAnimated:YES];
	
//    float yOffset = self.scrollView.contentOffset.y;
//    if (0.f != yOffset) {
//        [self hideBarsAnimated:YES];
//    } else {
//        [self resetHideBarsTimer];
//    }
}

- (void)runHideBarsTimer {
	NSLog(@"runHideBarsTimer");
	
	if (!hideBarsTimer) {
		self.hideBarsTimer =
		[NSTimer scheduledTimerWithTimeInterval:kHideBarsInterval
										 target:self
									   selector:@selector(hideBarsTimerHandler:)
									   userInfo:nil
										repeats:YES];
	} else {
		[self resetHideBarsTimer];
	}
}

- (void)resetHideBarsTimer {
	NSLog(@"resetHideBarsTimer");
	[hideBarsTimer setFireDate:[NSDate dateWithTimeIntervalSinceNow:kHideBarsIntervalAfterReset]];
}

- (void)removeHideBarsTimer {
	NSLog(@"removeHideBarsTimer");
	[hideBarsTimer invalidate];
	self.hideBarsTimer = nil;
}

- (void)showBarsAnimated:(BOOL)isAnimated {
	NSLog(@"showBars");
	[self showTabBarAnimated:isAnimated];
	[self showNavigationBarAnimated:isAnimated];
	isTabBarHidden = NO;
	//[self informAccessibilityAboutBarsWereShowed];
}

- (void)hideBarsAnimated:(BOOL)isAnimated {
	NSLog(@"hideBars");
	if (!UIAccessibilityIsVoiceOverRunning()) {
		[self removeHideBarsTimer];
		[self hideTabBarAnimated:YES];
		[self hideNavigationBarAnimated:YES];
		isTabBarHidden = YES;
		//[self informAccessibilityAboutBarsWereHided];
	}
}

- (void)toggleThumbView {
	NSLog(@"toggleThumbView");
	
	if (!UIAccessibilityIsVoiceOverRunning())
	{
		if (isTabBarHidden)
		{
			[self showTabBarAnimated:YES];
			[self showNavigationBarAnimated:YES];
			[self runHideBarsTimer];
			//[self informAccessibilityAboutBarsWereShowed];
		} else {
			[self removeHideBarsTimer];
			[self hideTabBarAnimated:YES];
			[self hideNavigationBarAnimated:YES];
			//[self informAccessibilityAboutBarsWereHided];
		}
		
		isTabBarHidden = !isTabBarHidden;
	}
}

- (void)hideNavigationBarAnimated:(BOOL)isAnimated {
	[[self navigationController] setNavigationBarHidden:YES animated:isAnimated];
}

- (void)showNavigationBarAnimated:(BOOL)isAnimated {
	[[self navigationController] setNavigationBarHidden:NO animated:isAnimated];
}

- (void)hideTabBarAnimated:(BOOL)isAnimated
{
	UITabBarController* aTabbarcontroller = self.appDelegate.tabBarController;
	
	if (isAnimated) {
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.2f];
		[UIView setAnimationCurve:UIViewAnimationCurveLinear];
	}
	
	float selfHeight = 0.f;
	for (UIView *view in aTabbarcontroller.view.subviews)
	{
		if ([view isKindOfClass:[UITabBar class]])
		{
			NSLog(@"UITabBar frame = %@", NSStringFromCGRect(view.frame));
			
			float yOffset = view.frame.origin.y;
			if (431.f == yOffset) {
				selfHeight = 480.f;
			} else if (411 == yOffset) {
				selfHeight = 460.f;
			}
			
			if (0.f != selfHeight) {
				[view setFrame:CGRectMake(view.frame.origin.x, selfHeight, view.frame.size.width, view.frame.size.height)];
			}
			
			break;
		}
	}
	
	if (0.f != selfHeight)
	{
		for (UIView *view in aTabbarcontroller.view.subviews)
		{
			if (![view isKindOfClass:[UITabBar class]]) {
				[view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, selfHeight)];
			}
		}
	}
	
	if (isAnimated) {
		[UIView commitAnimations];
	}
}

- (void)showTabBarAnimated:(BOOL)isAnimated
{
	UITabBarController* aTabbarcontroller = self.appDelegate.tabBarController;
	
	if (isAnimated) {
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.2f];
		[UIView setAnimationCurve:UIViewAnimationCurveLinear];
	}
	
	float selfHeight = 0.f;
	for (UIView *view in aTabbarcontroller.view.subviews)
	{
		if ([view isKindOfClass:[UITabBar class]])
		{
			NSLog(@"UITabBar frame = %@", NSStringFromCGRect(view.frame));
			
			float yOffset = view.frame.origin.y;
			if (480.f == yOffset) {
				selfHeight = 431.f;
			} else if (460.f == yOffset) {
				selfHeight = 411.f;
			}
			
			if (0.f != selfHeight) {
				[view setFrame:CGRectMake(view.frame.origin.x, selfHeight, view.frame.size.width, view.frame.size.height)];
			}
			
			break;
		}
	}
	
	if (0 != selfHeight)
	{
		for (UIView *view in aTabbarcontroller.view.subviews)
		{
			if (![view isKindOfClass:[UITabBar class]]) {
				[view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, selfHeight)];
			}
		}
	}
	
	if (isAnimated) {
		[UIView commitAnimations];
	}
}


@end
