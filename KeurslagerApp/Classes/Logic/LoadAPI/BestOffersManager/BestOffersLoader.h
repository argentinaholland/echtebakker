//
//  BestOffersLoader.h
//  KeurslagerApp
//
//  Created by mac-227 on 06.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RequestManager.h"


@class BestOffersLoader;

@protocol BestOffersLoaderDelegate <NSObject>
- (void)offersLoader:(BestOffersLoader *)aLoader didFinishWithOffersArray:(NSArray *)aNewsArray;
- (void)offersLoader:(BestOffersLoader *)aLoader didFailWithError:(NSError *)error;
@end


@interface BestOffersLoader : NSObject <RequestManagerDelegate> {
@private
	// int helpers
	RequestManager	*loadRequest_;
	NSDateFormatter	*dateFormatter_;
}

+ (BestOffersLoader *)sharedIntance;

- (BOOL)loadBestOffersWithDelegate:(id<BestOffersLoaderDelegate>)aDelegate;

@end