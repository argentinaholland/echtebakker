//
//  AppUtils.h
//  RTE
//
//  Created by mac-227 on 17.02.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

//#import </usr/include/objc/objc-class.h>
#import <objc/runtime.h>
#import <objc/message.h>
#import <Foundation/Foundation.h>


extern int kSCNavBarImageTag;


@interface AppUtils : UIView

+ (void)customizeNavigationController:(UINavigationController *)navController
							withImage:(UIImage *)bgImage;

@end



@interface ClassUtils : NSObject

+ (void)swizzleSelector:(SEL)orig ofClass:(Class)c withSelector:(SEL)new;

@end

