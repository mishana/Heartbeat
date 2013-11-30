//
//  ResultCollectionViewCell.m
//  Heartbeat
//
//  Created by michael leybovich on 10/12/13.
//  Copyright (c) 2013 michael leybovich. All rights reserved.
//

#import "ResultCollectionViewCell.h"
#import <FacebookSDK/FacebookSDK.h>

@interface ResultCollectionViewCell () <UIActionSheetDelegate, UIAlertViewDelegate>
@end

typedef void (^RPSBlock)(void);

@implementation ResultCollectionViewCell {
    RPSBlock _alertOkHandler;
}

- (IBAction)clickFacebookButton:(id)sender {
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Facebook"
                                                       delegate:self
                                              cancelButtonTitle:@"Do Nothing"
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:@"Share on Facebook", @"Check settings",  nil];
    // Show the sheet
    [sheet showInView:sender];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != 0) { // ok
        if (_alertOkHandler) {
            _alertOkHandler();
            _alertOkHandler = nil;
        }
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0: { // share
            BOOL didDialog = NO;
            didDialog = [self shareResult];
            
            if (!didDialog) {
                [self alertWithMessage:
                 @"Upgrade the Facebook application on your device and "
                 @"get cool new sharing features for this application. "
                 @"What do you want to do?"
                                    ok:@"Upgrade Now"
                                cancel:@"Decide Later"
                            completion:^{
                                // launch itunes to get the Facebook application installed/upgraded
                                [[UIApplication sharedApplication]
                                 openURL:[NSURL URLWithString:@"itms-apps://itunes.com/apps/Facebook"]];
                            }];
            }
            break;
        }
        case 1: // settings
            //[self.navigationController pushViewController:[[FBUserSettingsViewController alloc] init] animated:YES];
            break;
    }
}

//

- (BOOL)shareResult {
    id<FBOpenGraphAction> action = (id<FBOpenGraphAction>)[FBGraphObject openGraphActionForPost];

    return nil !=
    [FBDialogs presentShareDialogWithOpenGraphAction:action
                                          actionType:@"bpm:"
                                 previewPropertyName:@"bpm"
                                             handler:nil];
}

//

- (void)requestPermissionsWithCompletion:(RPSBlock)completion {
    [FBSession.activeSession requestNewPublishPermissions:[NSArray arrayWithObject:@"publish_actions"]
                                          defaultAudience:FBSessionDefaultAudienceEveryone
                                        completionHandler:^(FBSession *session, NSError *error) {
                                            if (!error) {
                                                // Now have the permission
                                                completion();
                                            } else {
                                                NSLog(@"Error: %@", error.description);
                                            }
                                        }];
}

- (void)alertWithMessage:(NSString *)message
                      ok:(NSString *)ok
                  cancel:(NSString *)cancel
              completion:(RPSBlock)completion {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Share with Facebook"
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:cancel
                                              otherButtonTitles:ok, nil];
    _alertOkHandler = [completion copy];
    [alertView show];
}

- (void)publishResult {
    
    FBRequestConnection *connection = [[FBRequestConnection alloc] init];
    
    NSMutableDictionary<FBOpenGraphObject> *result = [self createResultObject];
    FBRequest *objectRequest = [FBRequest requestForPostOpenGraphObject:result];
    [connection addRequest:objectRequest
         completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
             if (error) {
                 NSLog(@"Error: %@", error.description);
             }
         }
            batchEntryName:@"objectCreate"];
    
    /*
    NSMutableDictionary<FBGraphObject> *action = [self createPlayActionWithGame:@"{result=objectCreate:$.id}"];
    FBRequest *actionRequest = [FBRequest requestForPostWithGraphPath:@"me/fb_sample_rps:play"
                                                          graphObject:action];
    [connection addRequest:actionRequest
         completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
             if (error) {
                 NSLog(@"Error: %@", error.description);
             } else {
                 NSLog(@"Posted OG action with id: %@", result[@"id"]);
             }
         }];
     */
    
    [connection start];
}

- (NSMutableDictionary<FBOpenGraphObject> *)createResultObject {

    NSString *resultName = @"60";// should be the bpm result
    
    NSMutableDictionary<FBOpenGraphObject> *result = [FBGraphObject openGraphObjectForPost];
    result[@"type"] = @"Heartbeat:bpm";
    result[@"title"] = @"Heartbeat";
    result[@"data"][@"result"] = resultName;
    
    return result;
}


@end
