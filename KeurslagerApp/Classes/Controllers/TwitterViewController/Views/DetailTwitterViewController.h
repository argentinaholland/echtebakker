//
//  DetailTwitterViewController.h
//  KeurslagerApp
//
//  Created by mac-227 on 27.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@class TweetMessage;

@interface DetailTwitterViewController : UIViewController {
@private
	TweetMessage* tweet;
}

- (id)initWithTweet:(TweetMessage*)aTweet;

@property (nonatomic, retain) IBOutlet UIWebView* webView;

@property (nonatomic, retain) TweetMessage* tweet;

@end
