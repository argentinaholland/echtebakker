//
//  NewsLoader.h
//  EasyTrip
//
//  Created by mac-227 on 15.03.11.
//  Copyright 2011 iTechArt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RequestManager.h"


@class NewsLoader;

@protocol NewsLoaderDelegate <NSObject>
- (void)newsLoader:(NewsLoader *)aLoader didFinishWithNewsArray:(NSArray *)aNewsArray;
- (void)newsLoader:(NewsLoader *)aLoader didFailWithError:(NSError *)error;
@end


@interface NewsLoader : NSObject <RequestManagerDelegate> {
@private
	// int helpers
	RequestManager	*loadNewsRequest_;
	NSDateFormatter	*dateFormatter_;
}

+ (NewsLoader *)sharedIntance;

- (BOOL)loadNewsWithDelegate:(id<NewsLoaderDelegate>)aDelegate;

@end
