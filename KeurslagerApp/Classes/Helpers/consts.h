//
//  consts.h
//  EasyTrip
//
//  Created by mac-227 on 27.01.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

// ie.adforce.easytrip.adhoc
// XCode.team.provision

#import <MapKit/MapKit.h>


// custom navigation bar
extern NSString *const kNavigationBarCustomBackgroundImageName;
extern NSString *const kNavigationBarClearBackgroundImageName;
extern float kCustomNavigationBarColorValues[4];
extern NSString *const kCustomBackButtonImageName;


// strings
extern NSString *const kAppTitle;
extern NSString *const kContactPhoneNumber;

extern NSString *const kBackButtonTitle;
extern NSString *const kCarParkSearchSectionTitle;
extern NSString *const kParkLocatorSectionTitle;
extern NSString *const kRoadNewsSectionTitle;
extern NSString *const kOptionsSectionName;
extern NSString *const kHomeButtonName;
extern NSString *const kBackButtonName;
extern NSString *const kNewsSectionName;
extern NSString *const kContactUsSectionName;
extern NSString *const kHelpSectionName;
extern NSString *const kInformationSectionName;
extern NSString *const kHelpFindCarparkSectionName;
extern NSString *const kHelpRoutePlannerSectionName;
extern NSString *const kHelpSaveLocationSectionName;

extern NSString *const kListButtonTitle;
extern NSString *const kMapButtonTitle;


extern NSString *const kAppErrorTitle;
extern NSString *const kLocationUndefinedErrorTitle;
extern NSString *const kLocationUndefinedErrorMessage;
extern NSString *const kNoInternetConnectionErrorTitle;
extern NSString *const kNoInternetConnectionErrorMessage;
extern NSString *const kUnableToLoadMapErrorTitle;
extern NSString *const kUnableToLoadMapErrorMessage;

extern NSString *const kAppWaitMessage;
extern NSString *const kAppLoadingMessage;
extern NSString *const kDeviceDoesntSupportFeature;

extern NSString *const kStartLocationTitle;
extern NSString *const kEndLocationTitle;
extern NSString *const kViaLocationTitle;

extern NSString *const kSpecialOffersTitle;
extern NSString *const kSpecialOffersMessageFormat;

extern NSString *const kAppleAppStoreURL;


// map draw consts
// UICRouteOverlayMapView consts
extern float kRouteLineColorValues[4];
extern float kHighlightedRouteLineColorValues[4];
extern const CGFloat kRouteLineWidth;


// CLController
extern NSString *const kIPodModelName;

// 10 debug value
extern const float kCLControllerDistanceFilterForIPhone;
extern const float kCLControllerDistanceFilterForIPod; // 100


// debug values
#define kCLControllerDesiredAccuracyForIPhone kCLLocationAccuracyBestForNavigation
#define kCLControllerDesiredAccuracyForIPod   kCLLocationAccuracyBestForNavigation
//extern const CLLocationAccuracy kCLControllerDesiredAccuracyForIPhone;
//extern const CLLocationAccuracy kCLControllerDesiredAccuracyForIPod;

// 
extern const double kLocatinUpdateDistance;

extern const NSTimeInterval	kTrafficAlertsUpdateInterval;	// 15 mins
extern const NSTimeInterval	kTrafficAlertsScrollInterval;	// 5 secs

extern const NSTimeInterval	kNewsUpdateInterval;		// 30 mins	debug (60)


// mail for feedback
extern NSString *const kEasyTripMailAddress;
extern NSString *const kAppMailSubject;

// mail for sharing
extern NSString *const kAppMailMessage;


extern NSString *const kAppFacebookMessage;

extern NSString *const kEasyTripLogoURL;

extern NSString *const kFacebookAppID;
extern NSString *const kFacebookAPIKey;
extern NSString *const kFacebookAppSecret;

// Fouth Screen Advert Lib
extern NSString *const kFSAdvertID;
extern NSString *const kMedialetsID;


extern const int kDefaultNumberOfFloors;
extern const int kDefaultNumberOfSpaces;


extern NSString* const kBackgroundImage;
//extern float kApplicationBackgoundColorValues[4];
extern float kApplicationBackgoundColorValues[4];

extern const int kInternetConnecitonOfflineErrorCode;


// 
extern NSString* const kLocaleIdentifier;

extern const double kMaxDistanceToNearestCarpark; // 5 km
extern const double kMinDistanceToSaveLocation; // 100 m

extern NSString* const kSmallNoImageIcon;
extern NSString* const kNoImageIcon;


const NSUInteger kMaxVisibleNearestCarparks;
