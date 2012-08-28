//
//  SpinnerImageView.m
//  RTENews
//
//  Created by Alexander Belyavskiy on 10/15/10.
//  Copyright 2010 ITechArt Group. All rights reserved.
//

#pragma mark ----------------imports----------------
#import "SpinnerImageView.h"
#import <QuartzCore/QuartzCore.h>

const float kSpinnerBorderColorValues[4] = {238 / 255., 238 / 255., 238 / 255., 1.};

#pragma mark ----------------private----------------
@interface SpinnerImageView()
@property (nonatomic, retain) UIActivityIndicatorView	*spinner;
- (void) initSpinner;
- (void) centerSpinner;
- (void) initImageBorders;
@end


@implementation SpinnerImageView
#pragma mark ----------------properties----------------
@synthesize spinner			= spinner_;

- (id)initWithCoder:(NSCoder *)aDecoder {
	if ((self = [super initWithCoder:aDecoder])) {
        [self initSpinner];
		[self initImageBorders];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self initSpinner];
		[self initImageBorders];
		
    }
    return self;
}

- (void) initSpinner {
	UIActivityIndicatorView *activityInticatory = 
	[[UIActivityIndicatorView alloc]
	 initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray]; // UIActivityIndicatorViewStyleWhiteLarge
	self.spinner = activityInticatory;
	[activityInticatory release];
	
	//spinner_.frame = CGRectMake(0, 0, 37, 37);
	[self centerSpinner];
	[spinner_ setHidesWhenStopped:YES];
	[spinner_ stopAnimating];
	[self addSubview:spinner_];
}

- (void) centerSpinner {
	spinner_.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
}

- (void) initImageBorders {
	self.layer.borderColor =
	[UIColor colorWithRed:kSpinnerBorderColorValues[0]
					green:kSpinnerBorderColorValues[1]
					 blue:kSpinnerBorderColorValues[2]
					alpha:kSpinnerBorderColorValues[3]].CGColor;
	[self setBordersVisible:YES];
}

- (void)setImage:(UIImage *)newImage {
	if (newImage != NULL) {
		[super setImage:newImage];
		[self.spinner stopAnimating];
		[self setBordersVisible:NO];
	} else {
		[super setImage:nil];
		[self.spinner startAnimating];
		[self setBordersVisible:YES];
	}
}

- (void)setFrame:(CGRect)aFrame {
	[super setFrame:aFrame];
	[self centerSpinner];
}

- (void)dealloc {
	[self.spinner removeFromSuperview];
	self.spinner = nil;
	
    [super dealloc];
}

- (BOOL) bordersVisible
{
	return isBorderVisible_;
}

- (void) setBordersVisible: (BOOL) isBordersVisible
{
	isBorderVisible_ = isBordersVisible;
	if (isBordersVisible)
	{
		self.layer.borderWidth = 1.;
	} else {
		self.layer.borderWidth = 0.;
	}
}

- (void) setBordersColor: (UIColor *) bordersColor
{
	self.layer.borderColor = bordersColor.CGColor;
}

- (UIColor *) bordersColor
{
	return [UIColor colorWithCGColor: self.layer.borderColor];
}

@end
