//
//  FacebookProfileTableViewCell.h
//  Heartbeat
//
//  Created by or maayan on 12/01/13.
//  Copyright (c) 2013 Or Maayan. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <FacebookSDK/FacebookSDK.h>

@interface FacebookProfileTableViewCell : UITableViewCell

@property (copy, nonatomic) NSString *userID;
@property (copy, nonatomic) NSString *userName;
@property (strong, nonatomic) FBProfilePictureView *profilePic;
@property (strong, nonatomic) FBLoginView *loginView;

- (CGFloat)desiredCellHeight;

@end
