//
//  SUProfileTableViewCell.h
//  Heartbeat
//
//  Created by or maayan on 12/01/13.
//  Copyright (c) 2013 Or Maayan. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <FacebookSDK/FacebookSDK.h>

@interface SUProfileTableViewCell : UITableViewCell

@property (copy, nonatomic) NSString *userID;
@property (copy, nonatomic) NSString *userName;
// This view is used to display the profile pictures within the list of user accounts
//@property (strong, nonatomic) FBProfilePictureView *profilePic;

@property (readonly) CGFloat desiredHeight;

@property (strong, nonatomic) FBProfilePictureView *profilePic;
@property (strong, nonatomic) FBLoginView *loginView;

@end
