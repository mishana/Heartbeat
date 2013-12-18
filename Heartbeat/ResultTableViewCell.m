//
//  ResultTableViewCell.m
//  Heartbeat
//
//  Created by Or Maayan on 12/18/13.
//  Copyright (c) 2013 michael leybovich. All rights reserved.
//

#import "ResultTableViewCell.h"

@implementation ResultTableViewCell

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

- (CGFloat)desiredCellHeight{
    return 44;
}

@end
