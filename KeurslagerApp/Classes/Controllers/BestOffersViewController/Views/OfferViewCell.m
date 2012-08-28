//
//  OfferViewCell.m
//  KeurslagerApp
//
//  Created by mac-227 on 06.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "OfferViewCell.h"
#import "SpinnerImageView.h"


@implementation OfferViewCell

@synthesize thumImageView;
@synthesize titleLabel;
@synthesize descLabel;
@synthesize unitLabel;
@synthesize priceLabel;
@synthesize dateLabel;

- (void)dealloc {
	self.thumImageView = nil;
	self.titleLabel = nil;
	self.descLabel = nil;
	self.unitLabel = nil;
	self.priceLabel = nil;
	self.dateLabel = nil;
	[super dealloc];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
	
    // Configure the view for the selected state
}

@end
