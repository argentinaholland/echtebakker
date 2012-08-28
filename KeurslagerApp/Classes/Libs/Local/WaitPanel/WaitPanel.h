//
//  ActivityIndicator.h
//
//  Created by Julius Sirait on 13/04/09.
//

#import <UIKit/UIKit.h>


@interface WaitPanel : UIViewController {
	UILabel					*label_;
	UIActivityIndicatorView	*indView_;
	UIView					*bgView_;
	UIView					*tintView_;
	
	UIView					*parentView_;
}

- (id) initWithParentView:(UIView *)parentView;

- (void) show;
- (void) showWithLabel:(NSString *)labelStr;
- (void) hide;

@end
