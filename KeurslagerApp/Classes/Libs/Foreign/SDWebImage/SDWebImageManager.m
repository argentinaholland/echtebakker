/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "SDWebImageManager.h"
#import "SDImageCache.h"
#import "SDWebImageDownloader.h"

//#import "VLog.h"

static SDWebImageManager *instance;

@implementation SDWebImageManager

- (id) init
{
	if ((self = [super init]))
	{
		delegates			= [[NSMutableArray alloc] init];
		downloaders			= [[NSMutableArray alloc] init];
		downloaderForURL	= [[NSMutableDictionary alloc] init];
		failedURLs			= [[NSMutableArray alloc] init];
		
		placeholdersImages	= [[NSMutableArray alloc] init];
		externalDelegates	= [[NSMutableArray alloc] init];
	}
	return self;
}

- (void) dealloc
{
	[delegates			release], delegates			= nil;
	[downloaders		release], downloaders		= nil;
	[downloaderForURL	release], downloaderForURL	= nil;
	[failedURLs			release], failedURLs		= nil;
	
	[placeholdersImages	release]; placeholdersImages = nil;
	[externalDelegates	release]; externalDelegates	= nil;
	
	[super dealloc];
}


+ (id) sharedManager
{
	if (nil == instance)
	{
		instance = [[SDWebImageManager alloc] init];
	}

	return instance;
}

/**
 * @deprecated
 */
- (UIImage *) imageWithURL: (NSURL *) url
{
	return [[SDImageCache sharedImageCache] imageFromKey:[url absoluteString]];
}

- (void) downloadWithURL: (NSURL *) url
   withNormalPlaceholder: (UIImage *) normalPlaceholderImage
				delegate: (id<SDWebImageManagerDelegate>) delegate
{
	//VLog (@"downloadWithURL:withNormalPlaceholder:delegate:");
	
    if (!url || !delegate || [failedURLs containsObject:url])
    {
		if (nil != normalPlaceholderImage)
		{
			//VLog (@"downloadWithURL:withNormalPlaceholder:delegate: 0");
			return;
		}
		
		if ([delegate respondsToSelector: @selector(webImageManager:didFailWithError:)])
		{
			//VLog (@"downloadWithURL:withNormalPlaceholder:delegate: 1");
			
			[delegate performSelector: @selector(webImageManager:didFailWithError:)
						   withObject: self
						   withObject: nil];
		}
		
        return;
    }

    // Check the on-disk cache async so we don't block the main thread
    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:delegate, @"delegate", url, @"url", nil];
    [[SDImageCache sharedImageCache] queryDiskCacheForKey:[url absoluteString] delegate:self userInfo:info];
}

// 
- (void) downloadWithURL: (NSURL *) url
   withNormalPlaceholder: (UIImage *) normalPlaceholderImage
				delegate: (id<SDWebImageManagerDelegate>) delegate
		externalDelegate: (id) externalDelegate
{
	//VLog (@"downloadWithURL:withNormalPlaceholder:delegate:externalDelegate:");
	
    if (!url || !delegate || [failedURLs containsObject:url])
    {
		if (nil != normalPlaceholderImage)
		{
			//VLog (@"downloadWithURL:withNormalPlaceholder:delegate:externalDelegate: 0");
			return;
		}
		
		if ( (nil != externalDelegate) && [delegate respondsToSelector: @selector(webImageManager:didFailWithDelegate:)] )
		{
			//VLog (@"downloadWithURL:withNormalPlaceholder:delegate:externalDelegate: 1");
			[delegate performSelector: @selector(webImageManager:didFailWithDelegate:)
						   withObject: self
						   withObject: externalDelegate];
			return;
		}
		
		if ([delegate respondsToSelector: @selector(webImageManager:didFailWithError:)])
		{
			//VLog (@"downloadWithURL:withNormalPlaceholder:delegate:externalDelegate: 2");
			[delegate performSelector: @selector(webImageManager:didFailWithError:)
						   withObject: self
						   withObject: nil];
		}
		
        return;
    }
	
	NSDictionary *info;
	if (nil != externalDelegate)
	{
		info = [NSDictionary dictionaryWithObjectsAndKeys:
				delegate, @"delegate",
				url, @"url",
				externalDelegate, @"externalDelegate",
				nil];
	} else {
		info = [NSDictionary dictionaryWithObjectsAndKeys:
				delegate, @"delegate",
				url, @"url",
				nil];
	}
	
    // Check the on-disk cache async so we don't block the main thread
    [[SDImageCache sharedImageCache] queryDiskCacheForKey:[url absoluteString] delegate:self userInfo:info];
}


- (void) downloadWithURL: (NSURL *) url
   withNormalPlaceholder: (UIImage *) normalPlaceholderImage
   withFailedPlaceholder: (UIImage *) placeholderImage
				delegate: (id<SDWebImageManagerDelegate>) delegate
{
	//VLog (@"downloadWithURL:withNormalPlaceholder:withFailedPlaceholder:delegate:");
	
	if ( !url || !delegate || [failedURLs containsObject: url] )
	{
		if ( placeholderImage && [delegate respondsToSelector:@selector(webImageManager:didFinishWithParams:)] )
		{
			//VLog (@"downloadWithURL:withNormalPlaceholder:withFailedPlaceholder:delegate: 0");
			
			NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
									placeholderImage, @"image",
									nil];
			
			[delegate performSelector: @selector(webImageManager:didFinishWithParams:)
						   withObject: self
						   withObject: params];
			return;
		}
		
		if (nil != normalPlaceholderImage)
		{
			//VLog (@"downloadWithURL:withNormalPlaceholder:withFailedPlaceholder:delegate: 1");
			return;
		}
		
		if ([delegate respondsToSelector: @selector(webImageManager:didFailWithError:)])
		{
			//VLog (@"downloadWithURL:withNormalPlaceholder:withFailedPlaceholder:delegate: 2");
			
			[delegate performSelector: @selector(webImageManager:didFailWithError:)
						   withObject: self
						   withObject: nil];
		}
		
		return;
	}
	
	// Check the on-disk cache async so we don't block the main thread
	NSDictionary *info;
	if (nil != placeholderImage)
	{
		info = [NSDictionary dictionaryWithObjectsAndKeys:
				delegate, @"delegate",
				url, @"url",
				placeholderImage, @"placeholder",
				nil];
	} else {
		info = [NSDictionary dictionaryWithObjectsAndKeys:
				delegate, @"delegate",
				url, @"url",
				nil];
	}
	
	[[SDImageCache sharedImageCache] queryDiskCacheForKey:[url absoluteString] delegate:self userInfo:info];
}

- (void) cancelForDelegate: (id<SDWebImageManagerDelegate>) delegate
{
	//VLog (@"cancelForDelegate:");
	
	NSUInteger idx = [delegates indexOfObjectIdenticalTo: delegate];

	if (NSNotFound == idx)
	{
		return;
	}

	SDWebImageDownloader *downloader = [[downloaders objectAtIndex:idx] retain];

	[delegates removeObjectAtIndex: idx];
	[downloaders removeObjectAtIndex: idx];
	
	[placeholdersImages removeObjectAtIndex: idx];
	[externalDelegates removeObjectAtIndex: idx];

	if (![downloaders containsObject: downloader])
	{
		// No more delegate are waiting for this download, cancel it
		[downloader cancel];
		[downloaderForURL removeObjectForKey: downloader.url];
	}

	[downloader release];
}

#pragma mark SDImageCacheDelegate

- (void) imageCache: (SDImageCache *) imageCache
	   didFindImage: (UIImage *) image
			 forKey: (NSString *) key
		   userInfo: (NSDictionary *) info
{
	//VLog (@"imageCache:didFindImage:forKey:userInfo:");
	
	id<SDWebImageManagerDelegate> delegate = [info objectForKey:@"delegate"];
	if ([delegate respondsToSelector: @selector(webImageManager:didFinishWithParams:)])
	{
		NSDictionary *params = nil;
		id externalDelegate = [info objectForKey: @"externalDelegate"];
		if (nil != externalDelegate)
		{
			params = [NSDictionary dictionaryWithObjectsAndKeys:
					  externalDelegate, @"delegate",
					  image, @"image",
					  nil];
		} else {
			params = [NSDictionary dictionaryWithObjectsAndKeys:
					  image, @"image",
					  nil];
		}
		
		[delegate performSelector: @selector(webImageManager:didFinishWithParams:)
					   withObject: self
					   withObject: params];
	}
}

- (void)imageCache:(SDImageCache *)imageCache
didNotFindImageForKey:(NSString *)key
		  userInfo:(NSDictionary *)info
{
	//VLog(@"imageCache:didNotFindImageForKey:userInfo:");
	
	NSURL *url = [info objectForKey:@"url"];
	id<SDWebImageManagerDelegate> delegate = [info objectForKey:@"delegate"];
	UIImage *image = [info objectForKey:@"placeholder"];
	id externalDelegate = [info objectForKey:@"externalDelegate"];

	// Share the same downloader for identical URLs so we don't download the same URL several times
	SDWebImageDownloader *downloader = [downloaderForURL objectForKey:url];

	if (nil == downloader) {
		downloader = [SDWebImageDownloader downloaderWithURL:url delegate:self];
		[downloaderForURL setObject:downloader forKey:url];
	}


	[delegates addObject:delegate];
	[downloaders addObject:downloader];
	
	if (nil != image) {
		[placeholdersImages addObject:image];
	} else {
		[placeholdersImages addObject:[NSNull null]];
	}
	
	if (nil != externalDelegate) {
		[externalDelegates addObject:externalDelegate];
	} else {
		[externalDelegates addObject:[NSNull null]];
	}
}


#pragma mark SDWebImageDownloaderDelegate

- (void)imageDownloader:(SDWebImageDownloader *)downloader
	 didFinishWithImage:(UIImage *)image
{
	//VLog (@"imageDownloader:didFinishWithImage:");
	
	[downloader retain];
	
	// Notify all the delegates with this downloader
	for (NSInteger idx = [downloaders count] - 1; idx >= 0; idx--)
	{
		SDWebImageDownloader *aDownloader = [downloaders objectAtIndex: idx];
		if (aDownloader == downloader)
		{
			id<SDWebImageManagerDelegate> delegate = [delegates objectAtIndex: idx];
			
			if ( image && [delegate respondsToSelector: @selector(webImageManager:didFinishWithParams:)] )
			{
				NSDictionary *params = nil;
				
				id externalDelegate = [externalDelegates objectAtIndex: idx];
				if ([NSNull null] != externalDelegate)
				{
					params = [NSDictionary dictionaryWithObjectsAndKeys:
							  externalDelegate, @"delegate",
							  image, @"image",
							  nil];
				} else {
					params = [NSDictionary dictionaryWithObjectsAndKeys:
							  image, @"image",
							  nil];
				}
				
				[delegate performSelector: @selector(webImageManager:didFinishWithParams:)
							   withObject: self
							   withObject: params];
			}

			[downloaders removeObjectAtIndex: idx];
			[delegates removeObjectAtIndex: idx];
			
			[placeholdersImages removeObjectAtIndex: idx];
			[externalDelegates removeObjectAtIndex: idx];
			
			//break;	// debug
		}
	}

	if (image)
	{
		// Store the image in the cache
		[[SDImageCache sharedImageCache] storeImage: image
										  imageData: downloader.imageData
                                             forKey: [downloader.url absoluteString]
                                             toDisk: YES];
	}
	else
	{
		// The image can't be downloaded from this URL, mark the URL as failed so we won't try and fail again and again
		[failedURLs addObject: downloader.url];
	}


	// Release the downloader
	[downloaderForURL removeObjectForKey: downloader.url];
	[downloader release];
}

// My implementation
- (void) imageDownloader: (SDWebImageDownloader *) downloader
		didFailWithError: (NSError *) error
{
	//VLog (@"imageDownloader:didFailWithError:");
	
	[downloader retain];
	
	// Notify all the delegates with this downloader
	for (NSInteger idx = [downloaders count] - 1; idx >= 0; idx--)
	{
		SDWebImageDownloader *aDownloader = [downloaders objectAtIndex: idx];
		if (aDownloader == downloader)
		{
			id<SDWebImageManagerDelegate> delegate = [delegates objectAtIndex: idx];
			
			//VLog (@"imageDownloader:didFailWithError: usePlaceholderImage = %d, useExternalDelegate = %d", usePlaceholderImage, useExternalDelegate);
			
			id externalDelegate = [externalDelegates objectAtIndex: idx];
			
			UIImage *image = [placeholdersImages objectAtIndex: idx];
			
			if ( [NSNull null] != (NSNull *)image && [delegate respondsToSelector: @selector(webImageManager:didFinishWithParams:)] )
			{
				//VLog (@"imageDownloader:didFailWithError: 0");
				
				NSDictionary *params = nil;
				if ([NSNull null] != externalDelegate)
				{
					params = [NSDictionary dictionaryWithObjectsAndKeys:
							  externalDelegate, @"delegate",
							  image, @"image",
							  nil];
				} else {
					params = [NSDictionary dictionaryWithObjectsAndKeys:
							  image, @"image",
							  nil];
				}
				
				[delegate performSelector: @selector(webImageManager:didFinishWithParams:)
							   withObject: self
							   withObject: params];
			}
			else if ( [NSNull null] != externalDelegate && [delegate respondsToSelector: @selector(webImageManager:didFailWithDelegate:)] )
			{
				//VLog (@"imageDownloader:didFailWithError: 1");
				
				[delegate performSelector: @selector(webImageManager:didFailWithDelegate:)
							   withObject: self
							   withObject: externalDelegate];
			}
			else if ([delegate respondsToSelector: @selector(webImageManager:didFailWithError:)])
			{
				//VLog (@"imageDownloader:didFailWithError: 2");
				
				[delegate performSelector: @selector(webImageManager:didFailWithError:)
							   withObject: self
							   withObject: error];
			}
			
			
			[downloaders removeObjectAtIndex: idx];
			[delegates removeObjectAtIndex: idx];
			
			[placeholdersImages removeObjectAtIndex: idx];
			[externalDelegates removeObjectAtIndex: idx];
			
			//break;	// debug
		}
	}
	
	// The image can't be downloaded from this URL, mark the URL as failed so we won't try and fail again and again
	[failedURLs addObject: downloader.url];
	
	// Release the downloader
	[downloaderForURL removeObjectForKey: downloader.url];
	[downloader release];
}

- (void) clearFaildURLs
{
	if (failedURLs.count > 0)
	{
		[failedURLs removeAllObjects];
	}
}

@end
