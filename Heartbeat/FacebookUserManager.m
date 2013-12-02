//
//  FacebookUserManager.m
//  Heartbeat
//
//  Created by or maayan on 12/01/13.
//  Copyright (c) 2013 Or Maayan. All rights reserved.
//


#import "FacebookUserManager.h"

#import <FacebookSDK/FBSessionTokenCachingStrategy.h>
#import <FacebookSDK/FacebookSDK.h>

@interface FacebookUserManager()

@property (strong, readwrite) FBSession *currentSession;

@end

static NSString *const SUUserIDKeyFormat = @"FacebookUserID";
static NSString *const SUUserNameKeyFormat = @"FacebookUserName";

@implementation FacebookUserManager

- (id)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)sendNotification {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"FacebookUserManagerUserChanged"
                                                        object:nil];
}

- (BOOL)isLoggedIn{
    return [self getUserID] != nil;
}

- (FBSession*)createSession{
    NSArray *permissions = @[@"basic_info",@"user_birthday"];
    // create a session object, with defaults accross the board
    FBSession *session = [[FBSession alloc] initWithAppID:nil
                                              permissions:permissions
                                          urlSchemeSuffix:nil
                                       tokenCacheStrategy:nil];
    return session;
}

- (NSString*)getUserName {
    
    NSString *key = [NSString stringWithFormat:SUUserNameKeyFormat];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    // Don't assume we have a full FBGraphObject -- builds compiled with earlier versions of SDK
    // may have saved only a plain NSDictionary.
    return [defaults objectForKey:key];
}

- (NSString*)getUserID{
    
    NSString *key = [NSString stringWithFormat:SUUserIDKeyFormat];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    // Don't assume we have a full FBGraphObject -- builds compiled with earlier versions of SDK
    // may have saved only a plain NSDictionary.
    return [defaults objectForKey:key];
}

- (void)updateUser:(NSDictionary<FBGraphUser> *)user {
    

    NSString *idKey = [NSString stringWithFormat:SUUserIDKeyFormat];
    NSString *nameKey = [NSString stringWithFormat:SUUserNameKeyFormat];

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if (user != nil) {
        NSLog(@"FacebookUserManager updating..., fbid = %@, name = %@", user.id, user.name);
        [defaults setObject:user.id forKey:idKey];
        [defaults setObject:user.name forKey:nameKey];
    } else {
        NSLog(@"FacebookUserManager clearing user...");

        // Can't be current user anymore
        [self switchToNoActiveUser];

        // Also need to remove the user from useDefaults
        [defaults removeObjectForKey:idKey];
        [defaults removeObjectForKey:nameKey];
    }

    [defaults synchronize];

    //[self sendNotification];
}

- (void)switchToNoActiveUser {
    NSLog(@"FacebookUserManager switching to no active user");
    self.currentSession = nil;
    [self sendNotification];
}

#warning maybe not needed in future
- (FBSession *)switchToUser {

    FBSession *session = [self createSession];

    self.currentSession = session;

    [self sendNotification];

    return session;
}

@end
