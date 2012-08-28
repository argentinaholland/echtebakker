/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "UIImageView+WebCache.h"
#import "SDWebImageManager.h"

@implementation UIImageView (WebCache)

- (void) setImageWithURL: (NSURL *) url
{
	[self setImageWithURL:url placeholderImage:nil];
}


- (void) setImageWithURL: (NSURL *) url
		placeholderImage: (UIImage *) placeholder
{
	SDWebImageManager *manager = [SDWebImageManager sharedManager];

	// Remove in progress downloader from queue
	[manager cancelForDelegate: self];

	self.image = placeholder;

	if (url)
	{
		[manager downloadWithURL: url
		   withNormalPlaceholder: placeholder
						delegate: self];
	}
}

- (void) setImageWithURL: (NSURL *) url
		placeholderImage: (UIImage *) placeholder
				delegate: (id) delegate
{
	SDWebImageManager *manager = [SDWebImageManager sharedManager];
	
	// Remove in progress downloader from queue
	[manager cancelForDelegate: self];
	
	self.image = placeholder;
	
	if (url)
	{
		[manager downloadWithURL: url
		   withNormalPlaceholder: placeholder
						delegate: self
				externalDelegate: delegate];
	}
}


- (void) setImageWithURL: (NSURL *) url
		placeholderImage: (UIImage *) placeholder
  failedPlaceholderImage: (UIImage *) failedPlaceholder
{
	SDWebImageManager *manager = [SDWebImageManager sharedManager];
	
	// Remove in progress downloader from queue
	[manager cancelForDelegate: self];
	
	self.image = placeholder;
	
	if (url)
	{
		[manager downloadWithURL: url
		   withNormalPlaceholder: placeholder
		   withFailedPlaceholder: failedPlaceholder
						delegate: self];
	}
}

- (void) cancelCurrentImageLoad
{
	[[SDWebImageManager sharedManager] cancelForDelegate: self];
}

- (void) webImageManager: (SDWebImageManager *) imageManager
	 didFinishWithParams: (NSDictionary *) params
{
	//VLog (@"webImageManager:didFinishWithParams:");	// debug
	
	UIImage *newImage = [params objectForKey: @"image"];
	if (newImage)
	{
		//VLog (@"newImage is NOT NULL");	// debug
		self.image = newImage;
	}
	
	id delegate = [params objectForKey: @"delegate"];
	if (delegate)
	{
		//VLog (@"delegate is NOT NULL");	// debug
		if ([delegate respondsToSelector: @selector(UIImageViewWebCacheDidFinish:)])
		{
			[delegate performSelector: @selector(UIImageViewWebCacheDidFinish:)
						   withObject: self];
		}
	}
}

- (void) webImageManager: (SDWebImageManager *) imageManager
		didFailWithError: (NSError *) error
{
	//VLog (@"webImageManager:didFailWithError:");	// debug
	[self removeFromSuperview];
}


- (void) webImageManager: (SDWebImageManager *) imageManager
	 didFailWithDelegate: (id) delegate
{
	//VLog (@"webImageManager:didFailWithDelegate:");	// debug
	if (nil != delegate)
	{
		if ([delegate respondsToSelector: @selector(UIImageViewWebCacheDidFail:)])
		{
			[delegate performSelector: @selector(UIImageViewWebCacheDidFail:)
						   withObject: self];
		}
	}
}

+ (void) clearBadURLs
{
	[[SDWebImageManager sharedManager] clearFaildURLs];
}

@end
