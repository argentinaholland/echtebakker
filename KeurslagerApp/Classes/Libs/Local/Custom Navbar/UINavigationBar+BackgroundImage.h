//
//  UINavigationBar+BackgroundImage.h
//  NetworkRail
//
//  Created by James Hewitt on 17/07/2009.
//  Copyright 2009 Tenero Software Limited. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UINavigationBar (BackgroundImage)
- (void)subclassInsertSubview:(UIView *)view atIndex:(NSInteger)index;
- (void)subclassSendSubviewToBack:(UIView *)view;

@end
