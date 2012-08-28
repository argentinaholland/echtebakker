//
//  PdfViewerViewController.h
//  KeurslagerApp
//
//  Created by mac-214 on 5/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppDelegate.h"
#import "TapControllingView.h"


@interface PdfViewerViewController : UIViewController
<TapControllingViewDelegate,
UIScrollViewDelegate>
{
	// int data
	CGPDFDocumentRef myDocumentRef;
	CGPDFPageRef myPageRef;
	NSUInteger numberOfPages;
	NSUInteger currentPage;
	
	// views
	TapControllingView* contentView;
	
	// helpers
	NSTimer*         hideBarsTimer;
	
	AppDelegate*     appDelegate;
	
	// flags
	BOOL isTabBarHidden;
}

@property (nonatomic, retain) IBOutlet UIScrollView* scrollView;

@end
