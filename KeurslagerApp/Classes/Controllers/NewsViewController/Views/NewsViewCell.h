//
//  NewsViewCell.h
//  KeurslagerApp
//
//  Created by mac-227 on 04.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewsViewCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UILabel* titleLabel;
@property (nonatomic, retain) IBOutlet UILabel* dateLabel;
@property (nonatomic, retain) IBOutlet UILabel* introductionLabel;

@end
