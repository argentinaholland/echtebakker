//
//  consts.m
//  EasyTrip
//
//  Created by mac-227 on 13.05.11.
//  Copyright 2011 iTechArt. All rights reserved.
//

#import "consts.h"


float kApplicationBackgoundColorValues[4] = { 232. / 255., 232. / 255., 232. / 255., 1. };

float kRouteLineColorValues[4] = { 0 / 255., 0 / 255., 255 / 255., 0.5 };
float kHighlightedRouteLineColorValues[4] = { 1, 0, 0, 0.5 };



// custom navigation bar
NSString *const kNavigationBarCustomBackgroundImageName	= @"navigationbar_image.png";
NSString *const kNavigationBarClearBackgroundImageName	= @"clear_navigationbar_image.png";
//float kCustomNavigationBarColorValues[4] = { 13 / 255., 20 / 255., 64 / 255., 1. };
float kCustomNavigationBarColorValues[4] = { 0., 0., 0., 1. };
NSString *const kCustomBackButtonImageName	= @"back_button_image.png";



// strings
NSString *const kAppTitle                = @"Keurslager App";
NSString *const kContactPhoneNumber      = @"1890676768";

NSString *const kBackButtonTitle         = @"Back";
NSString *const kCarParkSearchSectionTitle = @"Car Park Search";
NSString *const kParkLocatorSectionTitle = @"Park Me";
NSString *const kRoadNewsSectionTitle    = @"Easytrip News";
NSString *const kOptionsSectionName      = @"Options";
NSString *const kHomeButtonName          = @"Home";
NSString *const kBackButtonName          = @"Back";
NSString *const kNewsSectionName         = @"News";
NSString *const kContactUsSectionName    = @"Contact Us";
NSString *const kHelpSectionName         = @"Help";
NSString *const kInformationSectionName  = @"Information";
NSString *const kHelpFindCarparkSectionName  = @"Find a Car Park Help Page";
NSString *const kHelpRoutePlannerSectionName = @"Route Planner Help Page";
NSString *const kHelpSaveLocationSectionName = @"Save Your Location Help Page";

NSString *const kListButtonTitle         = @"List";
NSString *const kMapButtonTitle          = @"Map";


NSString *const kAppErrorTitle           = @"Error";
NSString *const kLocationUndefinedErrorTitle      = @"Current location Undefined";
NSString *const kLocationUndefinedErrorMessage    = @"Unable to get current location"; // @"Current location is not available now.";
NSString *const kNoInternetConnectionErrorTitle   = @"No Internet Connection";
NSString *const kNoInternetConnectionErrorMessage = @"The Internet Connection is not available now.";
NSString *const kUnableToLoadMapErrorTitle       = @"Unable to load map.";
NSString *const kUnableToLoadMapErrorMessage     = @"Unable to load map.";

NSString *const kAppWaitMessage      = @"Please wait...";
NSString *const kAppLoadingMessage   = @"Loading...";
NSString *const kDeviceDoesntSupportFeature = @"Your device doesn't support this feature.";

NSString *const kStartLocationTitle  = @"Start Location";
NSString *const kEndLocationTitle    = @"End Location";
NSString *const kViaLocationTitle    = @"Via Location";

NSString *const kSpecialOffersTitle  = @"Special Offers";
NSString *const kSpecialOffersMessageFormat = @"Special Offers available in %@ close to %@ car park.";

NSString *const kAppleAppStoreURL	= @"http://itunes.apple.com/ie/app/easytrip-ireland/id457817222?mt=8";


// map draw consts
// UICRouteOverlayMapView consts
float kRouteLineColorValues[4];
float kHighlightedRouteLineColorValues[4];
const CGFloat kRouteLineWidth	= 10.f;


// CLController
NSString *const kIPodModelName		= @"iPod";

// 10 debug value
const float kCLControllerDistanceFilterForIPhone = 10;
const float kCLControllerDistanceFilterForIPod   = 10; // 100

// debug values
//const CLLocationAccuracy kCLControllerDesiredAccuracyForIPhone = kCLLocationAccuracyBestForNavigation;
//const CLLocationAccuracy kCLControllerDesiredAccuracyForIPod   = kCLLocationAccuracyBestForNavigation;	// kCLLocationAccuracyHundredMeters


// 
const double kLocatinUpdateDistance		= 150.;

const NSTimeInterval	kTrafficAlertsUpdateInterval	= 15 * 60;	// 15 mins
const NSTimeInterval	kTrafficAlertsScrollInterval	= 5;		// 5 secs

const NSTimeInterval	kNewsUpdateInterval	= 30 * 60;		// 30 mins	debug (60)


// mail for feedback
NSString *const kEasyTripMailAddress = @"info@easytrip.ie";
NSString *const kAppMailSubject      = @"easytrip iPone Feedback";

// mail for sharing
NSString *const kAppMailMessage		=
@"Hi<br /><br /> I thought you would be interested in the easytrip iPhone app. "
@"It gives you the latest information about all easytrip car parks. "
@"Provide you navigation service through Google maps © and Google directions © services. "
@"You can easily find your car on car parks using \"Find your car\". "
@"It gives you all the latest road from \"AA\" roadwatch website. "
@"And all the latest easytrip news. "
@"You can download <a href=\"%@\">easytrip</a> from Apple’s App Store to your iPhone or iPod Touch 24 hours a day!<br /><br />Thanks";


NSString *const kAppFacebookMessage		=
@"Hi<br /><br /> I thought you would be interested in the easytrip iPhone app. "
@"It gives you the latest information about all easytrip car parks. "
@"Provide you navigation service through Google maps © and Google directions © services. "
@"You can easily find your car on car parks using \"Find your car\". "
@"It gives you all the latest road from \"AA\" roadwatch website. "
@"And all the latest easytrip news. "
@"You can download <a href=\"%@\">easytrip</a> from Apple’s App Store to your iPhone or iPod Touch 24 hours a day!<br /><br />Thanks";

NSString *const kEasyTripLogoURL		= @"http://easytrip.ie/assets/images/easytrip_logo.gif";

NSString *const kFacebookAppID		= @"149027265162161";
NSString *const kFacebookAPIKey		= @"12cdfa9b7e3e7e827cfb058c464b2041";
NSString *const kFacebookAppSecret	= @"484d7f2cb9f767df5960a144243e6020";

// Fouth Screen Advert Lib
//NSString *const kFSAdvertID          = @"397D6711-A8C4-B617-CF93-1CC1C3E3703D"; // demo ID
NSString *const kFSAdvertID          = @"5B087B65-AE0D-0D44-562E-6D61B36BBBAF";
NSString *const kMedialetsID         = @"9b45da1089149731642408c037b96e8c3f37e9db";


const int kDefaultNumberOfFloors		= 10;
const int kDefaultNumberOfSpaces		= 999;


NSString* const kBackgroundImage		= @"bg_image.png";
//float kApplicationBackgoundColorValues[4] = { 232. / 255., 232. / 255., 232. / 255., 1.};
float kApplicationBackgoundColorValues[4];

const int kInternetConnecitonOfflineErrorCode	= -1009;


// 
NSString* const kLocaleIdentifier = @"ir_IR";

const double kMaxDistanceToNearestCarpark = 5000; // 5 km
const double kMinDistanceToSaveLocation = 100; // 100 m

NSString* const kSmallNoImageIcon = @"carpark_details_small_logo_background_image.png";
NSString* const kNoImageIcon      = @"carpark_details_logo_background_image.png";


const NSUInteger kMaxVisibleNearestCarparks = 30;