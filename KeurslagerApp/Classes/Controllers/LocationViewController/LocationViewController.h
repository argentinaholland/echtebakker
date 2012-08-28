//
//  LocationViewController.h
//  KeurslagerApp
//
//  Created by mac-227 on 04.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>


@interface LocationViewController : UIViewController
<MKMapViewDelegate>
{
	NSMutableArray* annotationsArray;
	MKMapRect       annotationsRect;
}

@property (nonatomic, retain) IBOutlet MKMapView* mapView;

@end
