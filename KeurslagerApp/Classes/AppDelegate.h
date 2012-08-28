//
//  AppDelegate.h
//  KeurslagerApp
//
//  Created by mac-227 on 04.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RootViewController.h"


@interface AppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate>

@property (nonatomic, retain) UIWindow* window;
@property (nonatomic, retain) UITabBarController* tabBarController;
@property (nonatomic, retain) UINavigationController* navigationController;
@property (nonatomic, retain) UIViewController* firstController;
@property (nonatomic, retain) RootViewController* rootViewController;


- (void)customizeNavigationController:(UINavigationController*)aController withImage:(NSString*)imageName;

- (void)switchToMainScreenController;
- (void)switchToSelectTwitterChannelController;
- (void)switchToOrderFormController;

@end
