
#import <Foundation/Foundation.h>


@interface UIDevice (Addittions)
+ (NSString *)deviceIOSVersion;
+ (BOOL)isIOSVersionGreaterOrEqualTo:(NSString *)theIOSVersionToCompare;
@end
