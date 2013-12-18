//
//  ResultTableViewCell.h
//  Heartbeat
//
//  Created by Or Maayan on 12/18/13.
//  Copyright (c) 2013 michael leybovich. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ResultTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *facebookButton;
@property (weak, nonatomic) IBOutlet UILabel *resultLabel;

- (CGFloat)desiredCellHeight;

@end
