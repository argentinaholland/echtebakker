//
//  DetailNewsViewController.h
//  KeurslagerApp
//
//  Created by mac-227 on 27.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@class KSNews;

@interface DetailNewsViewController : UIViewController {
@private
	KSNews* news;
}

- (id)initWithNews:(KSNews*)aNews;

@property (nonatomic, retain) IBOutlet UIWebView* webView;

@property (nonatomic, retain) KSNews* news;

@end
