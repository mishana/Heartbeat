//
//  SUProfileTableViewCell.m
//  Heartbeat
//
//  Created by or maayan on 12/01/13.
//  Copyright (c) 2013 Or Maayan. All rights reserved.
//


#import "SUProfileTableViewCell.h"

@implementation SUProfileTableViewCell

#define leftMargin 4
#define topMargin 4
#define rightMargin 24
#define pictureWidth 56
#define pictureHeight 56

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

- (void)initializeSubViews {
    if (!FBSession.activeSession.isOpen){
        // do nothing
    } else {
        FBProfilePictureView *profilePic = [[FBProfilePictureView alloc]
                                            initWithFrame:CGRectMake(leftMargin,
                                                                     topMargin,
                                                                     pictureWidth,
                                                                     pictureHeight)];
        
        self.profilePic = profilePic;
    }
    
    self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"facebook-cell-background-1x5.png"]];
    self.backgroundView.alpha = 0.9;
    
    self.clipsToBounds = YES;
    self.autoresizesSubviews = YES;
}

- (void)layoutSubviews{
    [super layoutSubviews];

    if (FBSession.activeSession.isOpen){
        [self.loginView removeFromSuperview];
        [self addSubview:self.profilePic];
        
        CGSize size = self.bounds.size;
        self.textLabel.frame = CGRectMake(leftMargin * 2 + pictureWidth,
                                          topMargin,
                                          size.width - (leftMargin * 2 + pictureWidth)*2 - rightMargin,
                                          size.height - topMargin*2);
        self.textLabel.backgroundColor = [UIColor clearColor];
        self.textLabel.font = [self.textLabel.font fontWithSize:20];
        self.textLabel.textAlignment = NSTextAlignmentCenter;
    } else {
        [self.profilePic removeFromSuperview];
        
        self.loginView.frame = self.bounds;
        self.loginView.clipsToBounds = YES;
        [self addSubview:self.loginView];
    }
}

#pragma mark - Properties

- (NSString*)userID {
    return self.profilePic.profileID;
}

- (void)setUserID:(NSString *)userID {
    // Setting the profileID property of the profile picture view causes the view to fetch and display
    // the profile picture for the given user
    self.profilePic.profileID = userID;
    
    if (!userID) {
        [self setNeedsDisplay];
        #warning need to check if necessary
    }
}

- (NSString*)userName {
    return self.textLabel.text;
}

- (void)setUserName:(NSString *)userName {
    self.textLabel.text = userName;
}

- (void)setLoginView:(FBLoginView *)loginView {
    _loginView = loginView;
    [self setNeedsDisplay];
}

- (void)setProfilePic:(FBProfilePictureView *)profilePic {
    _profilePic = profilePic;
    [self setNeedsDisplay];
    #warning need to check if necessary
}

//
#define LoginViewHeight 45 // login view is 45 height maximum
#warning probably shouldn't use here magic number

- (CGFloat)desiredHeight {
    if (!FBSession.activeSession.isOpen){
        return LoginViewHeight;
    } else {
        return topMargin * 2 + pictureHeight;
    }
}

@end
