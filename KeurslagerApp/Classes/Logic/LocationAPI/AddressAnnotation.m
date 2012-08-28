//
//  AddressAnnotation.m
//  KeurslagerApp
//
//  Created by mac-227 on 04.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AddressAnnotation.h"


@implementation AddressAnnotation

@synthesize coordinate;
@synthesize title;
@synthesize subtitle;

@synthesize linkURL, email, address, phone1, phone2;

- (void)dealloc {
	self.title = nil;
	self.subtitle = nil;
	
	self.linkURL = nil;
	self.email = nil;
	self.address = nil;
	self.phone1 = nil;
	self.phone2 = nil;
	[super dealloc];
}


@end
