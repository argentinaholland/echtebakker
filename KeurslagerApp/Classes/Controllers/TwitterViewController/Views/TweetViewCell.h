//
//  TweetViewCell.h
//  KeurslagerApp
//
//  Created by mac-227 on 04.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@class SpinnerImageView;

@interface TweetViewCell : UITableViewCell

@property (nonatomic, retain) IBOutlet SpinnerImageView* profileImageView;
@property (nonatomic, retain) IBOutlet UILabel* nameLabel;
@property (nonatomic, retain) IBOutlet UILabel* textLabel;
@property (nonatomic, retain) IBOutlet UILabel* dateLabel;

@end
