//
//  UINavigationBar+BackgroundImage.m
//  NetworkRail
//
//  Created by James Hewitt on 17/07/2009.
//  Copyright 2009 Tenero Software Limited. All rights reserved.
//

#import "UINavigationBar+BackgroundImage.h"
#import "AppUtils.h"
#import "consts.h"
#import "VLog.h"


@implementation UINavigationBar (BackgroundImage)

- (void)subclassInsertSubview:(UIView *)view atIndex:(NSInteger)index
{
	[self subclassInsertSubview:view atIndex:index];
	
	UIView *backgroundImageView = [self viewWithTag:kSCNavBarImageTag];
	if (backgroundImageView != nil)
	{
		[self subclassSendSubviewToBack:backgroundImageView];
	}
}

- (void)subclassSendSubviewToBack:(UIView *)view
{
	[self subclassSendSubviewToBack:view];
	
	UIView *backgroundImageView = [self viewWithTag:kSCNavBarImageTag];
	if (backgroundImageView != nil)
	{
		[self subclassSendSubviewToBack:backgroundImageView];
	}
}

/*
- (void)drawRect:(CGRect)rect
{
	NSString *superViewClassName = NSStringFromClass([self.superview class]);
	//VLog(@"height : %f", rect.size.height);
	
	if(![superViewClassName isEqualToString:@"MPFullScreenVideoOverlay"] && (rect.size.height == 44.0 || rect.size.height == 32.0)) {
		UIImage *image = [UIImage imageNamed:@"nav_bar.png"];
		[image drawInRect:rect];
		self.topItem.title = @"";
	} else {
		if(rect.size.height == 74.0) {
			UIImage *image = [UIImage imageNamed:@"large_nav_bar.png"];
			[image drawInRect:rect];
			[super drawRect:rect];
		}
	}
}
*/

@end
