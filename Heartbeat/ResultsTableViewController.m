//
//  ResultsTableViewController.m
//  Heartbeat
//
//  Created by Or Maayan on 12/18/13.
//  Copyright (c) 2013 michael leybovich. All rights reserved.
//

#import "ResultsTableViewController.h"
#import "ResultTableViewCell.h"
#import "Result.h"
#import <FacebookSDK/FacebookSDK.h>
#import "HeartBeatProtocols.h"

@interface ResultsTableViewController () <UIActionSheetDelegate, UIAlertViewDelegate , FBUserSettingsDelegate>

@property (nonatomic) int resultsNumOld;
@property (nonatomic, strong) FBUserSettingsViewController *userSettingsViewController;
@property (nonatomic, strong) NSIndexPath *selectedIndex;// will be used for the publish action

@end

typedef void (^CompletionBlock)(void);

@implementation ResultsTableViewController

#pragma mark - Properties

- (FBUserSettingsViewController *)userSettingsViewController {
    if (!_userSettingsViewController) {
        _userSettingsViewController =[[FBUserSettingsViewController alloc] init];
        _userSettingsViewController.delegate = self;
    }
    return _userSettingsViewController;
}

#pragma mark - Helper Methods

- (NSArray *)resultsByDate
{
    return [[Result allResults] sortedArrayUsingSelector:@selector(compareByDate:)];
}

- (int)numOfResults
{
    return [[Result allResults] count];
}

#pragma mark - Lifecycle

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.resultsNumOld == [self numOfResults] - 1) {
        NSUInteger indexes[2];
        indexes[0] = 0;
        indexes[1] = 0;
        NSIndexPath *indexPath = [[NSIndexPath alloc] initWithIndexes:indexes length:2];
        
        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    self.resultsNumOld = [self numOfResults];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"תוצאות";
    
    //------------------DESIGN BLOCK-----------------
    
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        
        // navigation bar configuration
        ///*
        // A slightly darker color - facebook like
        //self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0 green:0.245 blue:0.67 alpha:1.0];
        
        self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.075 green:0.439 blue:0.753 alpha:1.0];
        self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
        
        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    }
    
    //-----------------------------------------------
    
    self.resultsNumOld = [self numOfResults];
}

#pragma mark - public methods

- (void)scrollToTop
{
    NSUInteger indexes[2];
    indexes[0] = 0;
    indexes[1] = 0;
    NSIndexPath *indexPath = [[NSIndexPath alloc] initWithIndexes:indexes length:2];
    
    if ([self.tableView numberOfRowsInSection:0]) {
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

#pragma mark - UIActionSheet methods

#define FACEBOOK_ACTION_SHEET_TAG 1

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == FACEBOOK_ACTION_SHEET_TAG) {
        switch (buttonIndex) {
            case 0: { // share
                [self shareResult];
                // after the share we maybe need to update self.selectedIndex to nil
                break;
            }
            case 1: // settings
                [self.navigationController pushViewController:self.userSettingsViewController animated:YES];
                break;
        }
    }
}

- (UIActionSheet *)getFacebookActionSheet {
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Facebook"
                                                       delegate:self
                                              cancelButtonTitle:@"בטל"
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:@"שתף", @"בדוק הגדרות",  nil];
    [sheet setTag:FACEBOOK_ACTION_SHEET_TAG];
    return sheet;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self numOfResults];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"ResultCell";
    ResultTableViewCell *cell = (ResultTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[ResultTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    [self updateCell:cell usingResult:[self resultsByDate][indexPath.row]];
    
    return cell;
}

- (void)updateCell:(UITableViewCell *)cell usingResult:(Result *)result
{
    if ([cell isKindOfClass:[ResultTableViewCell class]]) {
        ResultTableViewCell *resultCell = (ResultTableViewCell *)cell;
        resultCell.bpm = result.bpm;
        resultCell.date = result.end;
        resultCell.accessoryType = UITableViewCellAccessoryNone;
        
        [resultCell.facebookButton addTarget:self action:@selector(clickFacebookButton:) forControlEvents:UIControlEventTouchUpInside];
    }
}

//

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [((Result *)[[self resultsByDate] objectAtIndex:indexPath.item]) deleteFromResults];
        self.resultsNumOld = [self numOfResults];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // not supported
        // return [super tableView:tableView commitEditingStyle:editingStyle forRowAtIndexPath:indexPath];
    }   
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UITableViewDelegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [ResultTableViewCell desiredCellHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // for now doing nothing
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSString*)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"Delete";
}

#pragma mark - FBUserSettingsDelegate methods

- (void)loginViewControllerDidLogUserOut:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"FacebookActiveSessionStateChanged" object:nil];
}

- (void)loginViewControllerDidLogUserIn:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
    [[self getFacebookActionSheet] showFromTabBar:self.tabBarController.tabBar];
    
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"FacebookActiveSessionStateChanged" object:nil];
    // don't need to update the cell because loginViewShowingLoggedInUser in SettingsViewController do it
}

- (void)loginViewController:(id)sender receivedError:(NSError *)error{
    // Facebook SDK * login flow *
    // There are many ways to implement the Facebook login flow.
    // In this sample, the FBUserSettingsViewController is only presented
    // as a log out option after the user has been authenticated, so
    // no real errors should occur. If the FBUserSettingsViewController
    // had been the entry point to the app, then this error handler should
    // be as rigorous as the FBLoginView delegate (SCLoginViewController)
    // in order to handle login errors.
    if (error) {
        NSLog(@"Unexpected error sent to the FBUserSettingsViewController delegate: %@", error);
    }
}

#pragma mark - Facebook

- (void)clickFacebookButton:(UIButton *)sender {
    CGPoint tapLocation = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:tapLocation];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    self.selectedIndex = indexPath;
    
    UIActionSheet *sheet = [self getFacebookActionSheet];
    // Show the sheet
    [sheet showFromTabBar:self.tabBarController.tabBar];
}

//

- (void)shareResult {
    if (FBSession.activeSession.isOpen) {
        // Attempt to post immediately - note the error handling logic will request permissions
        // if they are needed.
        [self postOpenGraphAction];
    } else {
        if (![self presentShareDialogForPulseInfo]) {
#warning maybe we should give the user login option
            
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
        } else {
            //we presented the share dialog already
        }
    }
    
    //if (!presentable) { // this means that the Facebook app is not installed or up to date
    // if the share dialog is not available, lets encourage a login so we can share directly
    //[self presentLoginSettings];
    //}
}

- (void)alertWithMessage:(NSString *)message
                      ok:(NSString *)ok
                  cancel:(NSString *)cancel
              completion:(CompletionBlock)completion {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Share with Facebook"
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:cancel
                                              otherButtonTitles:ok, nil];
    //_alertOkHandler = [completion copy];
    [alertView show];
}

#pragma mark - Open Graph Helpers

// This is a helper function that returns an FBGraphObject representing a pulse
- (id<PulseObject>)getPulseObject
{
    // We create an FBGraphObject object, but we can treat it as
    // an PulseObject with typed properties
    id<PulseObject> result = (id<PulseObject>)[FBGraphObject graphObject];
    
    // Give it a URL that will echo back the name of the meal as its title,
    // description, and body.
    //result.url = @"http://samples.ogp.me/1382050005353225";
    ResultTableViewCell *cell = (ResultTableViewCell *)[self.tableView cellForRowAtIndexPath:self.selectedIndex];
    NSUInteger bpmResult = cell.bpm;// should be the bpm result
    NSDate *date = cell.date;
    NSString *localDate = cell.localDate;
    
    result[@"type"] = @"heartbeat_ios:pulse";
    result[@"title"] = [NSString stringWithFormat:@"Pulse BPM: %d" , bpmResult];
    result[@"description"] = [NSString stringWithFormat:@"Date: %@" , localDate];
    result[@"fbsdk:create_object"] = @YES;
    result[@"locale"] = @"he_IL";//*
    result[@"data"][@"bpm"] = @(bpmResult);//*
    result[@"data"][@"date"] = date;//*
    //result[@"url"] = @"";/ should put here our app link
    //result[@"image"] = @"";
    
    return result;
}

/*
 - (void)enableUserInteraction:(BOOL) enabled {
 if (enabled) {
 [self.activityIndicator stopAnimating];
 } else {
 [self centerAndShowActivityIndicator];
 }
 
 self.announceButton.enabled = enabled;
 [self.view setUserInteractionEnabled:enabled];
 }
 */

- (id<MeaasurePulseAction>)actionFromPulseInfo {
    // Create an Open Graph measure action with the pulse
    id<MeaasurePulseAction> action = (id<MeaasurePulseAction>)[FBGraphObject graphObject];
    
    action.pulse = [self getPulseObject];
    action[@"message"] = [NSString stringWithFormat:@"Heartbeat מדדתי דופק באמצעות"];// not working
    
    return action;
}

// Creates the Open Graph Action.
- (void)postOpenGraphAction {
    //[self enableUserInteraction:NO];
    
    FBRequestConnection *requestConnection = [[FBRequestConnection alloc] init];
    requestConnection.errorBehavior = FBRequestConnectionErrorBehaviorRetry
    | FBRequestConnectionErrorBehaviorReconnectSession;
    
    // Create an Open Graph measure action with the pulse
    id<MeaasurePulseAction> action = [self actionFromPulseInfo];
    //
    action[@"fb:explicitly_shared"] = @"true";
    
    if (action.pulse) {
        // pulse object created successfully
        action[@"pulse"] = action.pulse;
    } else {
        id object = [self getPulseObject];
        FBRequest *createObject = [FBRequest requestForPostOpenGraphObject:object];
        
        // We'll add the object creaction to the batch, and set the action's pulse accordingly.
        [requestConnection addRequest:createObject
                    completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                        if (error) {
                            //[self enableUserInteraction:YES];
                            [self handlePostOpenGraphActionError:error];
                        }
                    }
                       batchEntryName:@"createobject"];
        
        action[@"pulse"] = @"{result=createobject:$.id}";
    }
    
    // Create the request and post the action to the "me/fb_sample_scrumps:eat" path.
    FBRequest *actionRequest = [FBRequest requestForPostWithGraphPath:@"me/heartbeat_ios:measure"
                                                          graphObject:action];
    [requestConnection addRequest:actionRequest
                completionHandler:^(FBRequestConnection *connection,
                                    id result,
                                    NSError *error) {
                    
                    //[self enableUserInteraction:YES];
                    if (result) {
                        [[[UIAlertView alloc] initWithTitle:@"Sucessfully posted to your news feed"
                                                    message:@"Go to Facebook and Check this out!"
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil]
                         show];
                        
                        // start over
                        
                    } else if (error) {
                        [self handlePostOpenGraphActionError:error];
                    }
                }];
    [requestConnection start];
}

- (void)handlePostOpenGraphActionError:(NSError *) error{
    // Facebook SDK * error handling *
    // Some Graph API errors are retriable. For this sample, we will have a simple
    // retry policy of one additional attempt. Please refer to
    // https://developers.facebook.com/docs/reference/api/errors/ for more information.
    //_retryCount++;
    FBErrorCategory errorCategory = [FBErrorUtility errorCategoryForError:error];
    if (errorCategory == FBErrorCategoryThrottling) {
        // We also retry on a throttling error message. A more sophisticated app
        // should consider a back-off period.
        //if (_retryCount < 2) {
        //NSLog(@"Retrying open graph post");
        //[self postOpenGraphAction];
        return;
#warning we don't try to publish again and again
        //} else {
        NSLog(@"Retry count exceeded.");
        //}
    }
    
    // Facebook SDK * pro-tip *
    // Users can revoke post permissions on your app externally so it
    // can be worthwhile to request for permissions again at the point
    // that they are needed. This sample assumes a simple policy
    // of re-requesting permissions.
    else if (errorCategory == FBErrorCategoryPermissions) {
        NSLog(@"Re-requesting permissions");
        [self requestPermissionAndPost];
        return;
    }
    
    else {
        [self presentAlertForError:error];
    }
}
// Helper method to request publish permissions and post.
- (void)requestPermissionAndPost {
    [FBSession.activeSession requestNewPublishPermissions:[NSArray arrayWithObject:@"publish_actions"]
                                          defaultAudience:FBSessionDefaultAudienceFriends
                                        completionHandler:^(FBSession *session, NSError *error) {
                                            if (!error && [FBSession.activeSession.permissions indexOfObject:@"publish_actions"] != NSNotFound) {
                                                // Now have the permission
                                                [self postOpenGraphAction];
                                            } else if (error){
                                                // if the operation is not user cancelled
                                                if ([FBErrorUtility errorCategoryForError:error] != FBErrorCategoryUserCancelled) {
                                                    [self presentAlertForError:error];
                                                }
                                            }
                                        }];
}

- (void) presentAlertForError:(NSError *)error {
    // Facebook SDK * error handling *
    // Error handling is an important part of providing a good user experience.
    // When shouldNotifyUser is YES, a userMessage can be
    // presented as a user-ready message
    if ([FBErrorUtility shouldNotifyUserForError:error]) {
        // The SDK has a message for the user, surface it.
        [[[UIAlertView alloc] initWithTitle:@"Something Went Wrong"
                                    message:[FBErrorUtility userMessageForError:error]
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    } else {
        NSLog(@"unexpected error:%@", error);
    }
}

- (BOOL)presentShareDialogForPulseInfo {
    // Create an Open Graph measure action with the pulse
    id<MeaasurePulseAction> action = [self actionFromPulseInfo];
    
    if (action.pulse) {
        // pulse object created successfully
        action[@"pulse"] = action.pulse;
    }
#warning need to check what hapens when action.pulse is nil
    
    return nil != [FBDialogs presentShareDialogWithOpenGraphAction:action
                                                        actionType:@"heartbeat_ios:measure"
                                               previewPropertyName:@"pulse"
                                                           handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
                                                               if (!error) {
                                                                   NSLog(@"Success!");
                                                               } else {
                                                                   NSLog(@"%@", error);
                                                               }
                                                           }];
}

@end
