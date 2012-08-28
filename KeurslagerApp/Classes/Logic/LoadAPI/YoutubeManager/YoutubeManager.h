//
//  YoutubeManager.h
//  KeurslagerApp
//
//  Created by mac-227 on 27.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RequestManager.h"


@class YoutubeManager;

@protocol YoutubeManagerDelegate <NSObject>
- (void)youtubeLoader:(YoutubeManager*)aLoader didFinishWithVideosArray:(NSArray *)anVedeosArray;
- (void)youtubeLoader:(YoutubeManager*)aLoader didFailWithError:(NSError *)error;
@end


@interface YoutubeManager : NSObject <RequestManagerDelegate> {
@private
	// int helpers
	RequestManager	*loadRequest_;
	NSDateFormatter	*dateFormatter_;
}

+ (YoutubeManager *)sharedIntance;

- (BOOL)loadYoutubeChannelWithDelegate:(id<YoutubeManagerDelegate>)aDelegate;

@end
