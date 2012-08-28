//
//  SpinnerImageView.h
//  RTENews
//
//  Created by Alexander Belyavskiy on 10/15/10.
//  Copyright 2010 ITechArt Group. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SpinnerImageView : UIImageView {
	UIActivityIndicatorView *spinner_;
	BOOL	isBorderVisible_;
}

@property (nonatomic, assign) BOOL	bordersVisible;
@property (nonatomic, retain) UIColor	*bordersColor;

/*
- (UIColor *) bordersColor;
- (void) setBordersColor: (UIColor *) bordersColor;
*/
@end
