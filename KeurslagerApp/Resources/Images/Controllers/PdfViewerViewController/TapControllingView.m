//
//  TapControllingView.h
//  KeurslagerApp
//
//  Created by mac-214 on 5/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TapControllingView.h"


const float kDoubleTapDelay = 0.35f;

CGPoint midpointBetweenPoints(CGPoint a, CGPoint b);



@interface TapControllingView ()

- (void)handleSingleTap;
- (void)handleDoubleTap;
- (void)handleTwoFingerTap;

@end


@implementation TapControllingView

@synthesize delegate;

- (void)dealloc {
	self.delegate = nil;
	[super dealloc];
}

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame]))
	{
		[self setUserInteractionEnabled:YES];
		[self setMultipleTouchEnabled:YES];
		isTwoFingersTapPossible = YES;
		isMultipleTouchesDetected = NO;
	}
	
	return self;
}

- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
	// cancel any pending handleSingleTap messages 
	[NSObject cancelPreviousPerformRequestsWithTarget:self
											 selector:@selector(handleSingleTap)
											   object:nil];
	
	// update our touch state
	if ([event touchesForView:self].count > 1) {
		isMultipleTouchesDetected = YES;
	}
	if ([event touchesForView:self].count > 2) {
		isTwoFingersTapPossible = NO;
	}
}

- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event
{
	BOOL isAllTouchesEnded = (touches.count == [event touchesForView:self].count);
	
	// first check for plain single/double tap, which is only possible if we haven't seen multiple touches
	if (!isMultipleTouchesDetected)
	{
		UITouch *touch = [touches anyObject];
		tapLocation = [touch locationInView:self];
		
		if (1 == touch.tapCount)
		{
			[self performSelector:@selector(handleSingleTap)
					   withObject:nil
					   afterDelay:kDoubleTapDelay];
		} else if(2 == touch.tapCount)
		{
			[self handleDoubleTap];
		}
	}
	else if (isMultipleTouchesDetected && isTwoFingersTapPossible)
	{
		// check for 2-finger tap if we've seen multiple touches and haven't yet ruled out that possibility
		
		if (2 == touches.count && isAllTouchesEnded)
		{
			// case 1: this is the end of both touches at once
			
			int i = 0;
			int tapCounts[2];
			CGPoint tapLocations[2];
			for (UITouch *touch in touches)
			{
				tapCounts[i]    = [touch tapCount];
				tapLocations[i] = [touch locationInView:self];
				i++;
			}
			
			// it's a two-finger tap if they're both single taps
			if (1 == tapCounts[0] && 1 == tapCounts[1])
			{
				tapLocation = midpointBetweenPoints(tapLocations[0], tapLocations[1]);
				[self handleTwoFingerTap];
			}
		}
		else if (1 == touches.count && !isAllTouchesEnded)
		{
			// case 2: this is the end of one touch, and the other hasn't ended yet
			
			UITouch *touch = touches.anyObject;
			if (1 == touch.tapCount)
			{
				// if touch is a single tap, store its location so we can average it with the second touch location
				tapLocation = [touch locationInView:self];
			} else {
				isTwoFingersTapPossible = NO;
			}
		}
		else if (1 == touches.count && isAllTouchesEnded)
		{
			// case 3: this is the end of the second of the two touches
			
			UITouch *touch = touches.anyObject;
			if (1 == touch.tapCount)
			{
				// if the last touch up is a single tap, this was a 2-finger tap
				tapLocation = midpointBetweenPoints(tapLocation, [touch locationInView:self]);
				[self handleTwoFingerTap];
			}
		}
	}
	
	// if all touches are up, reset touch monitoring state
	if (isAllTouchesEnded)
	{
		isTwoFingersTapPossible = YES;
		isMultipleTouchesDetected = NO;
	}
}

- (void)touchesCancelled:(NSSet*)touches withEvent:(UIEvent*)event
{
    isTwoFingersTapPossible = YES;
    isMultipleTouchesDetected = NO;
}

#pragma mark -
#pragma mark Private methods implementation

- (void)handleSingleTap {
	if ([delegate respondsToSelector:@selector(tapControllingImageView:gotSingleTapAtPoint:)]) {
		[delegate tapControllingImageView:self gotSingleTapAtPoint:tapLocation];
	}
}

- (void)handleDoubleTap {
	if ([delegate respondsToSelector:@selector(tapControllingImageView:gotDoubleTapAtPoint:)]) {
		[delegate tapControllingImageView:self gotDoubleTapAtPoint:tapLocation];
	}
}
    
- (void)handleTwoFingerTap {
	if ([delegate respondsToSelector:@selector(tapControllingImageView:gotTwoFingerTapAtPoint:)]) {
		[delegate tapControllingImageView:self gotTwoFingerTapAtPoint:tapLocation];
	}
}

    
@end


CGPoint midpointBetweenPoints(CGPoint a, CGPoint b) {
    CGFloat x = (a.x + b.x) / 2.f;
    CGFloat y = (a.y + b.y) / 2.f;
    return CGPointMake(x, y);
}
                    
