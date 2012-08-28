//
//  RootViewController.h
//  Cafe2U
//
//  Created by mac-227 on 12.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@class WaitPanel;

@interface RootViewController : UIViewController {
	UIViewController *activeController;
}

-(id)initWithController:(UIViewController *)aController;
-(void)loadView;

-(void)switchToController:(UIViewController *)aController;

@end
