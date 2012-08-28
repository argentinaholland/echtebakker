//
//  YoutubeVideo.h
//  KeurslagerApp
//
//  Created by mac-227 on 27.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YoutubeVideo : NSObject {
	NSString* title;
	NSURL*    thumbURL;
	NSURL*    linkURL;
	NSString* desc;
	NSDate*   pubDate; // @"Mon, 09 Jan 2012 12:29:42 +0000"
	NSString* author;
}

@property (nonatomic, retain) NSString* title;
@property (nonatomic, retain) NSURL*    thumbURL;
@property (nonatomic, retain) NSURL*    linkURL;
@property (nonatomic, retain) NSString* desc;
@property (nonatomic, retain) NSDate*   pubDate;
@property (nonatomic, retain) NSString* author;

@end
