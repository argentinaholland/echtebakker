//
//  ActivityIndicator.m
//
//  Created by Julius Sirait on 13/04/09.
//

#import "WaitPanel.h"
#import <QuartzCore/QuartzCore.h>


@interface WaitPanel ()
@property (nonatomic, retain) UIView			*parentView;
@property (nonatomic, retain) UIView			*bgView;
@property (nonatomic, retain) UIView			*tintView;
@property (nonatomic, retain) UIActivityIndicatorView	*indView;
@property (nonatomic, retain) UILabel			*label;
@end


@implementation WaitPanel

@synthesize parentView = parentView_;
@synthesize bgView = bgView_, label = label_, indView = indView_, tintView = tintView_;

- (void) dealloc {
	self.label = nil;
	self.indView = nil;
	self.bgView = nil;
	self.tintView = nil;
	self.parentView = nil;
	[super dealloc];
}

- (id) initWithParentView:(UIView *)parentView {
	if ( !(self = [super init]) ) return self;
	self.parentView = parentView;
	return self;
}

#pragma mark ----------------------- View Controller Stuff -----------------------

- (void) loadView {
	[super loadView];
	
	self.parentView.autoresizesSubviews = YES;
	
	//self.view = [[[UIView alloc] initWithFrame:self.parentView.bounds] autorelease];
	self.view.frame = self.parentView.bounds;
	self.view.autoresizesSubviews = YES;
	self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	
	self.tintView = [[[UIView alloc] initWithFrame:self.view.bounds] autorelease];
	self.tintView.backgroundColor = [UIColor blackColor];
	self.tintView.alpha = 0.5f;
	self.tintView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[self.view addSubview: self.tintView];
	
	self.bgView = [[[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, 200.f, 60.f)] autorelease];
	self.bgView.center = CGPointMake(round(self.view.bounds.size.width / 2.f), round(self.view.bounds.size.height / 2.f));
	self.bgView.alpha = 0.8f;
	self.bgView.backgroundColor = [UIColor blackColor];
	self.bgView.clipsToBounds = YES;
	self.bgView.autoresizingMask =
	UIViewAutoresizingFlexibleLeftMargin |
	UIViewAutoresizingFlexibleRightMargin |
	UIViewAutoresizingFlexibleTopMargin |
	UIViewAutoresizingFlexibleBottomMargin;
	[self.bgView.layer setCornerRadius:10.f];
	[self.view addSubview: self.bgView];
	
	self.indView = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite] autorelease];
	self.indView.center = CGPointMake(round(self.bgView.bounds.size.width / 2.f), round(self.bgView.bounds.size.height / 2.f + 10));
	[self.bgView addSubview:self.indView];
	[self.indView startAnimating];
	
	self.label = [[[UILabel alloc] initWithFrame:CGRectMake(0.f, 5.f, self.bgView.bounds.size.width, 15.f)] autorelease];
	self.label.text = NSLocalizedString(@"Please Wait…", nil);
	self.label.backgroundColor = [UIColor clearColor];
	self.label.textColor = [UIColor whiteColor];
	self.label.textAlignment = UITextAlignmentCenter;
	self.label.font = [UIFont systemFontOfSize: 14.f];
	[self.bgView addSubview:self.label];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark ----------------methods----------------
- (void) show {
	[self showWithLabel:nil];
}

- (void) showWithLabel:(NSString *)labelStr {
	[self.view removeFromSuperview]; // ?
//	UIWindow* keyWindow = [UIApplication sharedApplication].keyWindow;
//	[keyWindow addSubview:self.view];
//	self.view.frame = keyWindow.bounds;
	[self.parentView addSubview:self.view];
	self.view.frame = self.parentView.bounds;
	
	if (labelStr != nil) {
		self.label.text = labelStr;
		self.bgView.hidden = NO;
	} else {
		self.label.text = nil;
		self.bgView.hidden = YES;
	}
}

- (void)hide {
	[self.view removeFromSuperview];
}

@end
