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
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@property (nonatomic, strong) NSDate *date;
@property (nonatomic) NSUInteger bpm;
@property (nonatomic, strong) NSString *localDate;// the date in string in the local locale format

+ (CGFloat)desiredCellHeight;

@end
