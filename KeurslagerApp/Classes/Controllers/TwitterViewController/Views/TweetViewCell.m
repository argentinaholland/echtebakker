//
//  TweetViewCell.m
//  KeurslagerApp
//
//  Created by mac-227 on 04.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TweetViewCell.h"
#import "SpinnerImageView.h"


@implementation TweetViewCell

@synthesize profileImageView;
@synthesize nameLabel;
@synthesize textLabel;
@synthesize dateLabel;

- (void)dealloc {
	self.profileImageView = nil;
	self.nameLabel = nil;
	self.textLabel = nil;
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
