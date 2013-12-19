//
//  ResultTableViewCell.m
//  Heartbeat
//
//  Created by Or Maayan on 12/18/13.
//  Copyright (c) 2013 michael leybovich. All rights reserved.
//

#import "ResultTableViewCell.h"

@interface ResultTableViewCell ()
@property (nonatomic) NSDateFormatter *dateFormatter;
@end

@implementation ResultTableViewCell

#define facebookButtonRadius 18
#define facebookButtonleftMargin 4
#define facebookButtontopMargin 4
#define facebookButtonrightMargin 24
#define facebookButtonWidth 2*facebookButtonRadius
#define facebookButtonHeight 2*facebookButtonRadius


- (void)updateCell {
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    
    UIFont *labelFont =  [UIFont systemFontOfSize:[UIFont systemFontSize]];//self.bounds.size.width * 0.06];
    
    NSString *date = [self.dateFormatter stringFromDate:self.date];
    //
    
    self.resultLabel.attributedText = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%d bpm\n%@", self.bpm, date] attributes:@{NSParagraphStyleAttributeName : paragraphStyle, NSFontAttributeName : labelFont, NSForegroundColorAttributeName : [UIColor blueColor]}];
}

#pragma mark - Properties

- (NSDateFormatter *)dateFormatter {
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"he_IL"]];
        [_dateFormatter setDateStyle:NSDateFormatterFullStyle];
        [_dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        [_dateFormatter setDateFormat:@"EEEE dd.MM.yy ',' 'בשעה' HH:mm"];
    }
    return _dateFormatter;
}

- (void)setBpm:(NSUInteger)bpm
{
    _bpm = bpm;
    [self updateCell];
}

- (void)setDate:(NSDate *)date
{
    _date = date;
    [self updateCell];
}

+ (CGFloat)desiredCellHeight{
    return 44;
}

#pragma mark - Lifecycle

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initializeSubViews];
    }
    return self;
}

- (void)initializeSubViews {
    self.clipsToBounds = YES;
    self.autoresizesSubviews = YES;
    self.textLabel.hidden = YES;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    self.facebookButton.layer.cornerRadius = facebookButtonRadius/2;
    self.facebookButton.layer.masksToBounds = YES;
    
    self.resultLabel.numberOfLines = 0;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
