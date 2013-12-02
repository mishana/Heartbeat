//
//  FacebookUserManager.h
//  Heartbeat
//
//  Created by or maayan on 12/01/13.
//  Copyright (c) 2013 Or Maayan. All rights reserved.
//

//#import <Foundation/Foundation.h>

#import <FacebookSDK/FacebookSDK.h>

extern NSString *const SUInvalidSlotNumber;

@protocol FBGraphUser;

@interface FacebookUserManager : NSObject

// This is where our active session is maintained
@property (strong, readonly) FBSession *currentSession;

- (id)init;

- (NSString*)getUserID;
- (NSString*)getUserName;
- (void)updateUser:(NSDictionary<FBGraphUser> *)user;

- (BOOL)isLoggedIn;

- (void)switchToNoActiveUser;
- (FBSession *)switchToUser;

@end
