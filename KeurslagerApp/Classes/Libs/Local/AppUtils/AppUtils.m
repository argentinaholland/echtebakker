//
//  AppUtils.m
//  RTE
//
//  Created by mac-227 on 17.02.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AppUtils.h"

#import "consts.h"
#import "helpers.h"
#import "VLog.h"


int kSCNavBarImageTag	= 6183746;


@implementation AppUtils

+ (void)customizeNavigationController:(UINavigationController *)navController
							withImage:(UIImage *)bgImage
{
	UINavigationBar *navBar = [navController navigationBar];
	UIColor* navBarColor =
	[UIColor colorWithRed:kCustomNavigationBarColorValues[0]
					green:kCustomNavigationBarColorValues[1]
					 blue:kCustomNavigationBarColorValues[2]
					alpha:kCustomNavigationBarColorValues[3]];
	[navBar setTintColor:navBarColor];
	
	UIImageView *imageView = (UIImageView *)[navBar viewWithTag:kSCNavBarImageTag];
	if (nil == imageView)
	{
		imageView = [[UIImageView alloc] initWithImage: bgImage];
		[imageView setTag:kSCNavBarImageTag];
		[navBar insertSubview:imageView atIndex:0];
		[imageView release];
	} else {
		[imageView setImage: bgImage];
	}
}

@end


@implementation ClassUtils

+ (void)swizzleSelector:(SEL)orig ofClass:(Class)c withSelector:(SEL)new
{
	Method origMethod = class_getInstanceMethod(c, orig);
	Method newMethod = class_getInstanceMethod(c, new);
	
	if (class_addMethod(c, orig, method_getImplementation(newMethod), method_getTypeEncoding(newMethod)))
	{
		class_replaceMethod(c, new, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
	} else {
		method_exchangeImplementations(origMethod, newMethod);
	}
}

@end
