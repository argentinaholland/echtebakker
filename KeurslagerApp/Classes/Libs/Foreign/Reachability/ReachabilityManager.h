/*
 File: ReachabilityManager.h
 Abstract: Basic demonstration of how to use the SystemConfiguration Reachablity APIs.
 Version: 2.2
*/


#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>

typedef enum {
	NotReachable = 0,
	ReachableViaWiFi,
	ReachableViaWWAN
} NetworkStatus;


extern NSString *kNetworkReachabilityChangedNotification;


@interface ReachabilityManager: NSObject
{
	BOOL localWiFiRef;
	SCNetworkReachabilityRef reachabilityRef;
}

//reachabilityWithHostName- Use to check the reachability of a particular host name. 
+ (ReachabilityManager*) reachabilityWithHostName: (NSString*) hostName;

//reachabilityWithAddress- Use to check the reachability of a particular IP address. 
+ (ReachabilityManager*) reachabilityWithAddress: (const struct sockaddr_in*) hostAddress;

//reachabilityForInternetConnection- checks whether the default route is available.  
//  Should be used by applications that do not connect to a particular host
+ (ReachabilityManager*) reachabilityForInternetConnection;

//reachabilityForLocalWiFi- checks whether a local wifi connection is available.
+ (ReachabilityManager*) reachabilityForLocalWiFi;

//Start listening for reachability notifications on the current run loop
- (BOOL) startNotifier;
- (void) stopNotifier;

- (NetworkStatus) currentReachabilityStatus;
//WWAN may be available, but not active until a connection has been established.
//WiFi may require a connection for VPN on Demand.
- (BOOL) connectionRequired;
@end


