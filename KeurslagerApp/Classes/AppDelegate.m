//
//  AppDelegate.m
//  KeurslagerApp
//
//  Created by mac-227 on 04.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"

#import "SelectTwitterChannelControllerViewController.h"
#import "RootViewController.h"

#import "NewsViewController.h"
#import "TwitterViewController.h"
#import "BestOffersViewController.h"
#import "LocationViewController.h"
#import "MakeOrderViewController.h"

#import "TipsViewController.h"
#import "FacebookViewController.h"

#import "AppUtils.h"
#import "UIDevice+Addittions.h"

#import "SHKFacebook.h"
#import "SHKConfiguration.h"
#import "KeurslagerSHKConfigurator.h"


@implementation AppDelegate

@synthesize window = _window;
@synthesize tabBarController = _tabBarController;
@synthesize navigationController = _navigationController;
@synthesize firstController = _firstController;
@synthesize rootViewController = _rootViewController;

- (void)dealloc
{
	[_rootViewController release];
	[_firstController release];
	[_window release];
	[_tabBarController release];
	[_navigationController release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
#ifndef DEBUG
	[NSThread sleepForTimeInterval:2.5];	// show splashscreen for 3 sec
#endif
	
	
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
	
	 //v.1
	_firstController = [SelectTwitterChannelControllerViewController new];
	[self.window addSubview:_firstController.view];
	
	// v.2
	//UIViewController* firstScreenController = [SelectTwitterChannelControllerViewController new];
	//_rootViewController = [[RootViewController alloc] initWithController:firstScreenController];
	//self.window.rootViewController = _rootViewController;
	
	[self.window makeKeyAndVisible];
	
	DefaultSHKConfigurator *configurator = [[KeurslagerSHKConfigurator alloc] init];
	[SHKConfiguration sharedInstanceWithConfigurator:configurator];
	[configurator release];
	
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
	/*
	 Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	 Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
	 */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	/*
	 Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
	 If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	 */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	/*
	 Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
	 */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	/*
	 Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	 */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	/*
	 Called when the application is about to terminate.
	 Save data if appropriate.
	 See also applicationDidEnterBackground:.
	 */
}

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
}
*/

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed
{
}
*/

- (void)customizeNavigationController:(UINavigationController*)aController withImage:(NSString*)imageName {
	if (!imageName || !aController) return;
	
	//UINavigationController *newsNavController = self.navigationController;
	UIImage *navBarImage = [UIImage imageNamed:imageName];
	if ([UIDevice isIOSVersionGreaterOrEqualTo:@"5.0"]) {
		[aController.navigationBar setBackgroundImage:navBarImage forBarMetrics:UIBarMetricsDefault];
    } else {
		[AppUtils customizeNavigationController:aController withImage:navBarImage];
	}
}

/*
- (void)setClearNavigationBar {
	UINavigationController *newsNavController = self.navigationController;
	UIImage *navBarImage = [UIImage imageNamed:kNavigationBarClearBackgroundImageName];
	if ([UIDevice isIOSVersionGreaterOrEqualTo:@"5.0"]) {
		[_navigationController.navigationBar setBackgroundImage:navBarImage forBarMetrics:UIBarMetricsDefault];
    } else {
		[AppUtils customizeNavigationController:newsNavController withImage:navBarImage];
	}
}
*/

- (BOOL)handleOpenURL:(NSURL*)url {
	NSString* scheme = [url scheme];
	if ([scheme hasPrefix:[NSString stringWithFormat:@"fb%@", SHKCONFIG(facebookAppId)]])
		return [SHKFacebook handleOpenURL:url];
	return YES;
}

- (BOOL)application:(UIApplication *)application 
            openURL:(NSURL *)url 
  sourceApplication:(NSString *)sourceApplication 
         annotation:(id)annotation 
{
	return [self handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application 
      handleOpenURL:(NSURL *)url 
{
	return [self handleOpenURL:url];  
}

- (void)switchToOrderFormController {
    
    MakeOrderViewController *makeOrderViewController = [[MakeOrderViewController new] autorelease];
    makeOrderViewController.address2 = YES;
	makeOrderViewController.title = @"Bestellen";
	makeOrderViewController.tabBarItem.image = [UIImage imageNamed:   @"80-shopping-cart.png"];
	UINavigationController *makeOrderNavController = [[[UINavigationController alloc] initWithRootViewController:makeOrderViewController] autorelease];
    //[makeOrderViewController.navigationController setNavigationBarHidden:YES];
	makeOrderNavController.navigationBar.backgroundColor = [UIColor brownColor];
	[self customizeNavigationController:makeOrderNavController withImage:@"KSL_Logo_navbar.png"];
    
    self.window.rootViewController = makeOrderNavController;
    
}

- (void)switchToMainScreenController {
	UIViewController *twitterViewController = [[TwitterViewController new] autorelease];
	twitterViewController.title = @"Twitter";
	twitterViewController.tabBarItem.image = [UIImage imageNamed:@"23-bird.png"];
	UINavigationController *twitterNavController = [[[UINavigationController alloc] initWithRootViewController:twitterViewController] autorelease];
	twitterNavController.navigationBar.backgroundColor = [UIColor brownColor];
	twitterNavController.navigationBar.tintColor = [UIColor brownColor];
	//[self customizeNavigationController:twitterNavController withImage:@"KSL_Tweets_navbar.png"];
	[self customizeNavigationController:twitterNavController withImage:@"KSL_Logo_navbar.png"];
	
	
	UIViewController *newsViewController = [[NewsViewController new] autorelease];
	newsViewController.title = @"Nieuws";
	newsViewController.tabBarItem.image = [UIImage imageNamed:@"56-feed.png"];
	UINavigationController *newsNavController = [[[UINavigationController alloc] initWithRootViewController:newsViewController] autorelease];
	newsNavController.navigationBar.backgroundColor = [UIColor brownColor];
	newsNavController.navigationBar.tintColor = [UIColor brownColor];
	//[self customizeNavigationController:newsNavController withImage:@"KSL_News_navbar.png"];
	[self customizeNavigationController:newsNavController withImage:@"KSL_Logo_navbar.png"];
	
	
	UIViewController *locationsViewController = [[LocationViewController new] autorelease];
	locationsViewController.title = @"Locatie";
	locationsViewController.tabBarItem.image = [UIImage imageNamed:@"103-map.png"];
	UINavigationController *locationsNavController = [[[UINavigationController alloc] initWithRootViewController:locationsViewController] autorelease];
	locationsNavController.navigationBar.backgroundColor = [UIColor brownColor];
	locationsNavController.navigationBar.tintColor = [UIColor brownColor];
	//[self customizeNavigationController:locationsNavController withImage:@"KSL_Locations_navbar.png"];
	[self customizeNavigationController:locationsNavController withImage:@"KSL_Logo_navbar.png"];
	
	
	UIViewController *bestOffersViewController = [[BestOffersViewController new] autorelease];
	bestOffersViewController.title = @"Actie's";
	bestOffersViewController.tabBarItem.image = [UIImage imageNamed:@"Brood2424.png"]; // @"58-todo.png"
	UINavigationController *bestOffersNavController = [[[UINavigationController alloc] initWithRootViewController:bestOffersViewController] autorelease];
	bestOffersNavController.navigationBar.backgroundColor = [UIColor brownColor];
	bestOffersNavController.navigationBar.tintColor = [UIColor brownColor];
	//[self customizeNavigationController:bestOffersNavController withImage:@"KSL_Offers_navbar.png"];
	[self customizeNavigationController:bestOffersNavController withImage:@"KSL_Logo_navbar.png"];
	
	
	UIViewController *makeOrderViewController = [[MakeOrderViewController new] autorelease];
	makeOrderViewController.title = @"Bestellen";
	makeOrderViewController.tabBarItem.image = [UIImage imageNamed:   @"80-shopping-cart.png"];
	UINavigationController *makeOrderNavController = [[[UINavigationController alloc] initWithRootViewController:makeOrderViewController] autorelease];
    //[makeOrderViewController.navigationController setNavigationBarHidden:YES];
	makeOrderNavController.navigationBar.backgroundColor = [UIColor brownColor];
	[self customizeNavigationController:makeOrderNavController withImage:@"KSL_Logo_navbar.png"];
	
	
	// UIViewController *MakeOrderViewController = [[MakeOrderViewController new] autorelease];
	// MakeOrderViewController.title = @"Bestellen";
	// MakeOrderViewController.tabBarItem.image = [UIImage imageNamed:@"80-shopping-cart.png"]; // @"80-shopping-cart.png"
	// UINavigationController *MakeOrderNavController = [[[UINavigationController alloc] initWithRootViewController:MakeOrderViewController] autorelease];
	// MakeOrderViewController.navigationBar.backgroundColor = [UIColor brownColor];
	// MakeOrderViewController.navigationBar.tintColor = [UIColor brownColor];
	// [self customizeNavigationController:MakeOrderViewController withImage:@"KSL_Logo_navbar.png"];
	
	
	UIViewController *tipsViewController = [[TipsViewController new] autorelease];
	tipsViewController.title = @"video";
	tipsViewController.tabBarItem.image = [UIImage imageNamed:@"tabbar_youtube.png"]; // @"tabbar_youtube.png"
	UINavigationController *tipsNavController = [[[UINavigationController alloc] initWithRootViewController:tipsViewController] autorelease];
	tipsNavController.navigationBar.backgroundColor = [UIColor brownColor];
	tipsNavController.navigationBar.tintColor = [UIColor brownColor];
	//[self customizeNavigationController:tipsNavController withImage:@"KSL_Tips_navbar.png"];
	[self customizeNavigationController:tipsNavController withImage:@"KSL_Logo_navbar.png"];
    
    
    UIViewController *facebookViewController = [[FacebookViewController new] autorelease];
	facebookViewController.title = @"facebook";
	facebookViewController.tabBarItem.image = [UIImage imageNamed:@"tabbar_facebook.png"];
	UINavigationController *facebookNavController = [[[UINavigationController alloc] initWithRootViewController:facebookViewController] autorelease];
	facebookNavController.navigationBar.backgroundColor = [UIColor brownColor];
	facebookNavController.navigationBar.tintColor = [UIColor brownColor];
	//[self customizeNavigationController:tipsNavController withImage:@"KSL_Tips_navbar.png"];
	[self customizeNavigationController:facebookNavController withImage:@"KSL_Logo_navbar.png"];
	
	self.tabBarController = [[[UITabBarController alloc] init] autorelease];
	self.tabBarController.viewControllers =
	[NSArray arrayWithObjects:
	 twitterNavController,
	 //newsNavController,
	
	 locationsNavController,
	 makeOrderNavController,
	 tipsNavController,
     facebookNavController,
	 nil];
	
	self.window.rootViewController = self.tabBarController;
	
	//[_rootViewController switchToController:_tabBarController];
}

- (void)switchToSelectTwitterChannelController {
	UIViewController* firstScreenController = [SelectTwitterChannelControllerViewController new];
	[_rootViewController switchToController:firstScreenController];
	self.tabBarController = nil;
}


@end
