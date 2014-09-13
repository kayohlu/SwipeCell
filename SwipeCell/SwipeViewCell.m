//
//  SwipeViewCell.m
//  SwipeCell
//
//  Created by Karl Grogan on 13/09/2014.
//  Copyright (c) 2014 Karl Grogan. All rights reserved.
//

#import "SwipeViewCell.h"

@implementation SwipeViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
