//
//  TweetsLoader.h
//  KeurslagerApp
//
//  Created by mac-227 on 04.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RequestManager.h"


@class TweetsLoader;

@protocol TweetsLoaderDelegate <NSObject>
- (void)tweetsLoader:(TweetsLoader *)aLoader didFinishWithNewsArray:(NSArray *)aTweetsArray;
- (void)tweetsLoader:(TweetsLoader *)aLoader didFailWithError:(NSError *)error;
@end


@interface TweetsLoader : NSObject <RequestManagerDelegate> {
@private
	// int helpers
	RequestManager	*loadTweetsRequest_;
	NSDateFormatter	*dateFormatter_;
	
	NSString* userName_;
}

+ (TweetsLoader *)sharedIntance;

@property (nonatomic, retain) NSString* userName;

- (BOOL)loadTweetsWithDelegate:(id<TweetsLoaderDelegate>)aDelegate;

@end