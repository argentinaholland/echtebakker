//
//  KSOffer.h
//  KeurslagerApp
//
//  Created by mac-227 on 06.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KSOffer : NSObject {
	NSString* title;
	NSURL*    thumbURL;
	NSString* desc;
	NSString* unit;
	NSString* date;
	
	NSString* priceCurrency;
	NSString* priceNumbers;
	NSString* priceSeparator;
	NSString* priceDecimals;
	
	// unused
	NSURL*    url;
}

@property (nonatomic, retain) NSString* title;
@property (nonatomic, retain) NSURL*    thumbURL;
@property (nonatomic, retain) NSString* desc;
@property (nonatomic, retain) NSString* unit;
@property (nonatomic, retain) NSString* date;

@property (nonatomic, retain) NSString* priceCurrency;
@property (nonatomic, retain) NSString* priceNumbers;
@property (nonatomic, retain) NSString* priceSeparator;
@property (nonatomic, retain) NSString* priceDecimals;

@property (nonatomic, retain) NSURL* url;

@end
