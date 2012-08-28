//
//  OfferViewCell.h
//  KeurslagerApp
//
//  Created by mac-227 on 06.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@class SpinnerImageView;

@interface OfferViewCell : UITableViewCell

@property (nonatomic, retain) IBOutlet SpinnerImageView* thumImageView;
@property (nonatomic, retain) IBOutlet UILabel* titleLabel;
@property (nonatomic, retain) IBOutlet UILabel* descLabel;
@property (nonatomic, retain) IBOutlet UILabel* unitLabel;
@property (nonatomic, retain) IBOutlet UILabel* priceLabel;
@property (nonatomic, retain) IBOutlet UILabel* dateLabel;

@end
