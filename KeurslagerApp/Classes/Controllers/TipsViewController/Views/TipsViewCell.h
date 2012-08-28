//
//  TipsViewCell.h
//  KeurslagerApp
//
//  Created by mac-227 on 27.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SpinnerImageView;

@interface TipsViewCell : UITableViewCell

@property (nonatomic, retain) IBOutlet SpinnerImageView* thumImageView;
@property (nonatomic, retain) IBOutlet UILabel* titleLabel;
@property (nonatomic, retain) IBOutlet UILabel* dateLabel;

@end

