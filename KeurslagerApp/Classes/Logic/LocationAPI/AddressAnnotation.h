//
//  AddressAnnotation.h
//  KeurslagerApp
//
//  Created by mac-227 on 04.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>


@interface AddressAnnotation : NSObject <MKAnnotation> {
	CLLocationCoordinate2D coordinate;
	NSString *title;
	NSString *subtitle;
	
	NSURL* linkURL;
	NSString* email;
	NSString* address;
	NSString* phone1;
	NSString* phone2;
}

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;

@property (nonatomic, copy) NSURL* linkURL;
@property (nonatomic, copy) NSString* email;
@property (nonatomic, copy) NSString* address;
@property (nonatomic, copy) NSString* phone1;
@property (nonatomic, copy) NSString* phone2;

@end
