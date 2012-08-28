//
//  NewsViewCell.m
//  KeurslagerApp
//
//  Created by mac-227 on 04.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NewsViewCell.h"


@implementation NewsViewCell

@synthesize titleLabel;
@synthesize dateLabel;
@synthesize introductionLabel;

- (void)dealloc {
	self.titleLabel = nil;
	self.dateLabel = nil;
	self.introductionLabel = nil;
	[super dealloc];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	if (self) {
		// Initialization code
	}
	return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	[super setSelected:selected animated:animated];

	// Configure the view for the selected state
}

@end
