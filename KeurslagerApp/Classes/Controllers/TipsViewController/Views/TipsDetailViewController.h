//
//  TipsDetailViewController.h
//  KeurslagerApp
//
//  Created by mac-227 on 27.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>


@class YoutubeVideo;

@interface TipsDetailViewController : UIViewController {
	YoutubeVideo* video;
}

- (id)initWithVideo:(YoutubeVideo*)aVideo;

@property (nonatomic, retain) IBOutlet UIWebView* webView;

@property (nonatomic, retain) YoutubeVideo* video;

@end
