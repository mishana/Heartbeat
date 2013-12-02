//
//  SUProfileTableViewCell.m
//  Heartbeat
//
//  Created by or maayan on 12/01/13.
//  Copyright (c) 2013 Or Maayan. All rights reserved.
//


#import "SUProfileTableViewCell.h"

static const CGFloat leftMargin = 10;
static const CGFloat topMargin = 5;
static const CGFloat rightMargin = 30;
static const CGFloat pictureWidth = 54;
static const CGFloat pictureHeight = 54;

@interface SUProfileTableViewCell ()

@property (strong, nonatomic) FBProfilePictureView *profilePic;

@end

@implementation SUProfileTableViewCell

#pragma mark - Lifecycle

- (id)init {
    self = [super init];
    if (self) {
        [self initializeSubViews];
    }
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initializeSubViews];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)initializeSubViews {
    FBProfilePictureView *profilePic = [[FBProfilePictureView alloc]
        initWithFrame:CGRectMake(
            leftMargin,
            topMargin,
            pictureWidth,
            pictureHeight)];
    [self addSubview:profilePic];
    self.profilePic = profilePic;

    self.clipsToBounds = YES;
    self.autoresizesSubviews = YES;
}

- (void) layoutSubviews {
    [super layoutSubviews];

    CGSize size = self.bounds.size;

    self.textLabel.frame = CGRectMake(
        leftMargin * 2 + pictureWidth,
        0,
        size.width - leftMargin - pictureWidth - rightMargin,
        size.height);
}

#pragma mark - Properties

- (NSString*)userID {
    return self.profilePic.profileID;
}

- (void)setUserID:(NSString *)userID {
    // Setting the profileID property of the profile picture view causes the view to fetch and display
    // the profile picture for the given user
    self.profilePic.profileID = userID;// ? userID : @"facebookhq";
    
    if (!userID) {
        // remove the delay of FBProfilePictureView fetching...
        for (NSObject *obj in [self.profilePic subviews]) {
            if ([obj isMemberOfClass:[UIImageView class]]) {
                UIImageView *objImg = (UIImageView *)obj;
                objImg.image = [UIImage imageNamed:@"IconFacebook-72@2x.png"];
                break;
#warning still there is a bug with loading the image after startup
            }
        }
    }
    
}

- (NSString*)userName {
    return self.textLabel.text;
}

- (void)setUserName:(NSString *)userName {
    self.textLabel.text = userName;
}

- (CGFloat)desiredHeight {
    return topMargin * 2 + pictureHeight;
}

@end
