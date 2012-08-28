/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import <UIKit/UIKit.h>
#import "SDWebImageDownloaderDelegate.h"
#import "SDWebImageManagerDelegate.h"
#import "SDImageCacheDelegate.h"

@interface SDWebImageManager : NSObject <SDWebImageDownloaderDelegate, SDImageCacheDelegate>
{
    NSMutableArray	*delegates;
    NSMutableArray	*downloaders;
    NSMutableDictionary	*downloaderForURL;
    NSMutableArray	*failedURLs;
	
	NSMutableArray	*placeholdersImages;
	NSMutableArray	*externalDelegates;
}

+ (id)sharedManager;
- (UIImage *) imageWithURL: (NSURL *) url;

- (void) downloadWithURL: (NSURL *) url
   withNormalPlaceholder: (UIImage *) normalPlaceholderImage
				delegate: (id<SDWebImageManagerDelegate>) delegate;

- (void) downloadWithURL: (NSURL *) url
   withNormalPlaceholder: (UIImage *) normalPlaceholderImage
				delegate: (id<SDWebImageManagerDelegate>) delegate
		externalDelegate: (id) externalDelegate;

- (void) downloadWithURL: (NSURL *) url
   withNormalPlaceholder: (UIImage *) normalPlaceholderImage
   withFailedPlaceholder: (UIImage *) placeholderImage
				delegate: (id<SDWebImageManagerDelegate>) delegate;

- (void) cancelForDelegate: (id<SDWebImageManagerDelegate>) delegate;

- (void) clearFaildURLs;

@end
