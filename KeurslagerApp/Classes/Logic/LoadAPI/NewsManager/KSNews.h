//
//  KSNews.h
//  KeurslagerApp
//
//  Created by mac-227 on 04.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KSNews : NSObject {
	NSString* title;
	NSURL* url;
	NSString* introduction;
	NSURL* thumbURL;
	NSString* date;
}

@property (nonatomic, retain) NSString* title;
@property (nonatomic, retain) NSURL* url;
@property (nonatomic, retain) NSString* introduction;
@property (nonatomic, retain) NSURL* thumbURL;
@property (nonatomic, retain) NSString* date;

@end
