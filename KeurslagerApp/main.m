//
//  main.m
//  KeurslagerApp
//
//  Created by mac-227 on 04.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppDelegate.h"

#import "AppUtils.h"
#import "UIDevice+Addittions.h"


int main(int argc, char *argv[]) {
	if (![UIDevice isIOSVersionGreaterOrEqualTo:@"5.0"]) {
		// subclass UINavigationBar class
		[ClassUtils swizzleSelector:@selector(insertSubview:atIndex:)
							ofClass:[UINavigationBar class]
					   withSelector:@selector(subclassInsertSubview:atIndex:)];
		[ClassUtils swizzleSelector:@selector(sendSubviewToBack:)
							ofClass:[UINavigationBar class]
					   withSelector:@selector(subclassSendSubviewToBack:)];
	}
	
	
	@autoreleasepool {
#define IOS5_DEBUG_FIX
#ifdef IOS5_DEBUG_FIX
		int retVal = -1;
		@try {
			retVal = UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
		}
		@catch (NSException* exception) {
			NSLog(@"Uncaught exception: %@", exception.description);
			NSLog(@"Stack trace: %@", [exception callStackSymbols]);
		}
		return retVal;
#else
		return UIApplicationMain(argc, argv, nil, NSStringFromClass([CNAAppDelegate class]));
#endif
	}
}


/*
int main(int argc, char *argv[])
{
	if (![UIDevice isIOSVersionGreaterOrEqualTo:@"5.0"]) {
		// subclass UINavigationBar class
		[ClassUtils swizzleSelector:@selector(insertSubview:atIndex:)
							ofClass:[UINavigationBar class]
					   withSelector:@selector(subclassInsertSubview:atIndex:)];
		[ClassUtils swizzleSelector:@selector(sendSubviewToBack:)
							ofClass:[UINavigationBar class]
					   withSelector:@selector(subclassSendSubviewToBack:)];
	}
	
	@autoreleasepool {
	    return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
	}
}
*/
