//
//  TapControllingView.h
//  KeurslagerApp
//
//  Created by mac-214 on 5/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//


@class TapControllingView;

@protocol TapControllingViewDelegate <NSObject>

@optional
- (void)tapControllingImageView:(TapControllingView*)view gotSingleTapAtPoint:(CGPoint)tapPoint;
- (void)tapControllingImageView:(TapControllingView*)view gotDoubleTapAtPoint:(CGPoint)tapPoint;
- (void)tapControllingImageView:(TapControllingView*)view gotTwoFingerTapAtPoint:(CGPoint)tapPoint;

@end


@interface TapControllingView : UIImageView
{
	id <TapControllingViewDelegate> delegate;
	
	// Touch detection
	CGPoint tapLocation;            // Needed to record location of single tap, which will only be registered after delayed perform.
	BOOL isMultipleTouchesDetected; // YES if a touch event contains more than one touch; reset when all fingers are lifted.
	BOOL isTwoFingersTapPossible;   // Set to NO when 2-finger tap can be ruled out (e.g. 3rd finger down, fingers touch down too far apart, etc).
}

@property (nonatomic, assign) id <TapControllingViewDelegate> delegate;

@end

