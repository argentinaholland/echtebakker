//
//  LocationViewController.m
//  KeurslagerApp
//
//  Created by mac-227 on 04.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LocationViewController.h"

#import "AddressAnnotation.h"
#import "LocationsDetailViewController.h"

#import "TweetsLoader.h"
#import "AppDelegate.h"

#import "VLog.h"
#import "helpers.h"
#import "consts.h"


const CGFloat kRouteMapBoundingRectInset	= 10.;

NSString* const kDefaultKeurslagerLinkURL = @"http://www.zijlstraheerenveen.keurslager.nl/";


@interface LocationViewController ()
@property (nonatomic, retain) NSMutableArray* annotationsArray;

- (void)showAnnotationDetails:(id)sender;

- (void)moveToRect:(MKMapRect)mapRect;
- (void)moveToLocation:(CLLocation *)location;
- (void)moveToLocationWithCoordinate:(CLLocationCoordinate2D)aCoordinate;

@end



@implementation LocationViewController

@synthesize annotationsArray;

@synthesize mapView;

- (void)dealloc {
	self.annotationsArray = nil;
	self.mapView = nil;
	[super dealloc];
}

- (void)viewDidUnload {
	self.annotationsArray = nil;
	self.mapView = nil;
	[super viewDidUnload];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
	[super viewDidLoad];
	
	//self.navigationItem.title = @"";
	
	self.annotationsArray = [NSMutableArray arrayWithCapacity:3];
	
	AddressAnnotation* addressAnnotation1 = [[AddressAnnotation new] autorelease];
	addressAnnotation1.title = @"Bakkerij De Korenaar"; //@"Keurslager Wolvega Marten Hoeksma";
	//addressAnnotation1.subtitle = @"Keurslager Wolvega Marten Hoeksma";
	addressAnnotation1.coordinate = CLLocationCoordinate2DMake(53.180408,6.160352);
	addressAnnotation1.linkURL = [NSURL URLWithString:kDefaultKeurslagerLinkURL];
	addressAnnotation1.email = @"info@bakkerijdekorenaar.nl";
	addressAnnotation1.address = @"Gedemptevaart 17, 9231 AS Surhuisterveen ";
	addressAnnotation1.phone1 = @"0512-361262";
	[annotationsArray addObject:addressAnnotation1];
	
	
	AddressAnnotation* addressAnnotation2 = [[AddressAnnotation new] autorelease];
	addressAnnotation2.title = @"Echte Bakker Bruinsma"; // @"Sneekerpoort"
	//addressAnnotation2.subtitle = @"Keurslagerij Sneekerpoort";
	addressAnnotation2.coordinate = CLLocationCoordinate2DMake(53.190105,5.792139);
	addressAnnotation2.linkURL = [NSURL URLWithString:kDefaultKeurslagerLinkURL];
	addressAnnotation2.email = @"bakkerbruinsma@planet.nl";
	addressAnnotation2.address = @"Frans van Mierisstraat 49, 8932 KS Leeuwarden";
	addressAnnotation2.phone1 = @"058-2150426";
	[annotationsArray addObject:addressAnnotation2];
	
	
	AddressAnnotation* addressAnnotation3 = [[AddressAnnotation new] autorelease];
	addressAnnotation3.title = @"Lenes De Echte Bakker";
	//addressAnnotation3.title = @"Zijlstra Heerenveen";
	//addressAnnotation3.title = @"Keurslager Zijlstra Heerenveen";
	//addressAnnotation3.subtitle = @"Keurslager Zijlstra Heerenveen";
	addressAnnotation3.coordinate = CLLocationCoordinate2DMake(52.960203,5.922344);
	addressAnnotation3.linkURL = [NSURL URLWithString:kDefaultKeurslagerLinkURL];
	addressAnnotation3.email = @"lenes@echtebakker.nl";
	addressAnnotation3.address = @"Vleesmarkt 1,8441 EW Heerenveen";
	addressAnnotation3.phone1 = @"0513-622967";
	[annotationsArray addObject:addressAnnotation3];
	
	/*
	MKMapPoint northEastPoint, southWestPoint;
	int i = 0;
	for (AddressAnnotation *annotation in annotationsArray) {
		CLLocationCoordinate2D coordinate = annotation.coordinate;
		MKMapPoint point = MKMapPointForCoordinate(coordinate);
		
		// adjust the bounding box
		if (0 == i) {
			northEastPoint = point;
			southWestPoint = point;
		} else  {
			if (point.x > northEastPoint.x)
				northEastPoint.x = point.x;
			if(point.y > northEastPoint.y)
				northEastPoint.y = point.y;
			if (point.x < southWestPoint.x)
				southWestPoint.x = point.x;
			if (point.y < southWestPoint.y)
				southWestPoint.y = point.y;
		}
		i++;
	}
	
	// save bounding rect
	annotationsRect =
	MKMapRectMake(southWestPoint.x, southWestPoint.y,
				  northEastPoint.x - southWestPoint.x,
				  northEastPoint.y - southWestPoint.y);
	[self moveToRect:annotationsRect];
	*/
	
	[self.mapView addAnnotations:annotationsArray];
	
	
	AddressAnnotation* annotation = nil;
	NSString* twitterUserName = [TweetsLoader sharedIntance].userName;
	if ([twitterUserName isEqualToString:@"wdiertens"]) {
		annotation = addressAnnotation1;
	} else if ([twitterUserName isEqualToString:@"Sneekerpoort"]) {
		annotation = addressAnnotation2;
	} else if ([twitterUserName isEqualToString:@"KeurZijlstra"]) {
		annotation = addressAnnotation3;
	}
	[self moveToLocationWithCoordinate:annotation.coordinate];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	AppDelegate* appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
	[appDelegate customizeNavigationController:self.navigationController withImage:@"KSL_Logo_navbar.png"];
	
	//	self.navigationItem.title = @"";
	//	[appDelegate customizeNavigationController:self.navigationController withImage:@"KSL_Tips_navbar.png"];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark -
#pragma mark Map Stuff

- (void)moveToRect:(MKMapRect)mapRect {
	UIEdgeInsets edgeInsets =
	UIEdgeInsetsMake(kRouteMapBoundingRectInset, kRouteMapBoundingRectInset,
					 kRouteMapBoundingRectInset, kRouteMapBoundingRectInset);
	[self.mapView setVisibleMapRect:mapRect
						edgePadding:edgeInsets
						   animated:YES];
}

- (void)moveToLocation:(CLLocation *)location {
	if (!location) return;
	
	[self moveToLocationWithCoordinate:location.coordinate];
}

- (void)moveToLocationWithCoordinate:(CLLocationCoordinate2D)aCoordinate {
	MKCoordinateRegion aRegion =
	MKCoordinateRegionMakeWithDistance(aCoordinate,
									   2. * kMaxDistanceToNearestCarpark,
									   2. * kMaxDistanceToNearestCarpark);
	[self.mapView setRegion:aRegion animated:TRUE];
}


#pragma mark -
#pragma mark <MKMapViewDelegate> annotation implementation

- (MKAnnotationView *)mapView:(MKMapView *)mapView
			viewForAnnotation:(id<MKAnnotation>)annotation
{
	static NSString *addressAnnotationID	= @"AddressAnnotationID";
	
	if ([annotation isKindOfClass:[AddressAnnotation class]]) {
		MKAnnotationView *addressAnnotation = (MKAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:addressAnnotationID];
		if(!addressAnnotation) {
			addressAnnotation = [[[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:addressAnnotationID] autorelease];
		}
		
		addressAnnotation.image = [UIImage imageNamed:@"address_annotation_icon.png"];
		addressAnnotation.opaque = NO;		
		
		addressAnnotation.enabled = YES;
		addressAnnotation.canShowCallout = YES;	// show titles (and subtitles)
		
		
		// create custom accessory button and associate it with annotation
		UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
		rightButton.tag = [annotationsArray indexOfObject:(AddressAnnotation *)annotation];
		[rightButton addTarget:self
						action:@selector(showAnnotationDetails:)
			  forControlEvents:UIControlEventTouchUpInside];
		addressAnnotation.rightCalloutAccessoryView = rightButton;
		
		// set callout icon
		UIImageView *iconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"address_annotation_icon.png"]];
		iconView.contentMode = UIViewContentModeScaleAspectFit;
		iconView.frame = CGRectMake(0, 0, 28, 28);
		addressAnnotation.leftCalloutAccessoryView = iconView;
		[iconView release];
		
		return addressAnnotation;
	} else {
		return [self.mapView viewForAnnotation:self.mapView.userLocation];
	}
}

- (void)showAnnotationDetails:(id)sender {
	UIButton *accesorryButton = (UIButton *)sender;
	if (NSNotFound == accesorryButton.tag) return;
	
	AddressAnnotation* annotation = [annotationsArray objectAtIndex:accesorryButton.tag];
	LocationsDetailViewController* controller =
	[[LocationsDetailViewController alloc] initWithAnnotation:annotation];
	[self.navigationController pushViewController:controller animated:YES];
	[controller release];
}


@end
