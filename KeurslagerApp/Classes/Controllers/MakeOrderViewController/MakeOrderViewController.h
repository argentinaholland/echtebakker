//
//  MakeOrderViewController.h
//  KeurslagerApp
//
//  Created by mac-227 on 04.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MakeOrderViewController : UIViewController<UIWebViewDelegate> {
	
}

@property (nonatomic, retain) IBOutlet UIWebView* webView;
@property (nonatomic, assign) BOOL address2;

@end
