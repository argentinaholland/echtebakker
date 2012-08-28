/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import <UIKit/UIKit.h>
#import "SDWebImageManagerDelegate.h"

@interface UIImageView (WebCache) <SDWebImageManagerDelegate>

- (void) setImageWithURL: (NSURL *) url;

- (void) setImageWithURL: (NSURL *) url
		placeholderImage: (UIImage *) placeholder;

- (void) setImageWithURL: (NSURL *) url
		placeholderImage: (UIImage *) placeholder
				delegate: (id) delegate;

- (void) setImageWithURL: (NSURL *) url
		placeholderImage: (UIImage *) placeholder
  failedPlaceholderImage: (UIImage *) failedPlaceholder;

- (void) cancelCurrentImageLoad;

+ (void) clearBadURLs;

@end

@protocol UIImageViewWebCacheDelegate

@optional

- (void) UIImageViewWebCacheDidFinish: (UIImageView *) view;
- (void) UIImageViewWebCacheDidFail: (UIImageView *) view;

@end

