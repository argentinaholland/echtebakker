//
//  RequestManager.h
//  EasyTrip
//
//  Created by mac-227 on 23.02.11.
//  Copyright 2011 iTechArt. All rights reserved.
//

#import <UIKit/UIKit.h>


@class RequestManager;

@protocol RequestManagerDelegate <NSObject>
- (void) requestManager: (RequestManager *) aManager didFinishWithResponse: (NSData *) aResponce;
- (void) requestManager: (RequestManager *) aManager didFailWithError: (NSError *) error;
@end


@interface RequestManager : NSObject {
@private
	// ext data
	id<RequestManagerDelegate> delegate_;
	NSURL			*url_;
	id				userInfo_;
	// int data
    NSURLConnection	*connection_;
    NSMutableData	*responce_;
}
@property (nonatomic, retain) NSMutableData	*responce;
@property (nonatomic, retain) id	userInfo;

+ (id) requestWithURL: (NSURL *) anURL
			 delegate: (id<RequestManagerDelegate>) aDelegate
			 userInfo: (id) anUserInfo;

- (void)cancel;

@end
