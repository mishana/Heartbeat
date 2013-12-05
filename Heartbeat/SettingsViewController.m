//
//  SettingsViewController.m
//  Heartbeat
//
//  Created by michael leybovich on 9/24/13.
//  Copyright (c) 2013 michael leybovich. All rights reserved.
//

#import "SettingsViewController.h"
#import "Settings.h"
#import "FacebookProfileTableViewCell.h"
#import "HeartBeatAppDelegate.h"

@interface SettingsViewController () <UITableViewDataSource , UITableViewDelegate , FBLoginViewDelegate , FBUserSettingsDelegate>
// Properties
@property (strong, nonatomic) Settings *settings;
@property (strong, nonatomic) FBLoginView *loginView;
@property (nonatomic, strong) FBUserSettingsViewController *userSettingsViewController;

// IBOutlets
@property (weak, nonatomic) IBOutlet UISwitch *autoStopAfterSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *continuesModeSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *beepSwitch;

@end

@implementation SettingsViewController

#pragma mark - Properties

- (Settings *)settings
{
    if (!_settings) _settings = [Settings currentSettings];
    return _settings;
}

- (FBLoginView *)loginView {
    if (!_loginView) {
        //NSArray *permissions = @[@"basic_info",@"user_birthday"];
        _loginView = [[FBLoginView alloc] initWithReadPermissions:nil];
        _loginView.delegate = self;
        _loginView.loginBehavior = FBSessionLoginBehaviorUseSystemAccountIfPresent;//
    }
    return _loginView;
}

- (FBUserSettingsViewController *)userSettingsViewController {
    if (!_userSettingsViewController) {
        _userSettingsViewController =[[FBUserSettingsViewController alloc] init];
        _userSettingsViewController.delegate = self;
    }
    return _userSettingsViewController;
}

#pragma mark - Lifecycle

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.settings synchronize];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    //self.tableView.delegate = nil;
    //self.tableView.dataSource = nil;
    //self.tableView = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"FacebookActiveSessionStateChanged" object:nil];
}

- (void)viewDidLoad
{
    //------------------DESIGN BLOCK-----------------

    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {

    //self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.177 green:0.341 blue:0.945 alpha:0.8];

    
    //self.navigationController.navigationBar.titleTextAttributes = @{ UITextAttributeTextColor : [UIColor whiteColor] };
        
        self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.075 green:0.439 blue:0.753 alpha:1.0];
        self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
        
        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    }
    
    //-----------------------------------------------
    
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.autoStopAfterSwitch.on = self.settings.autoStopAfter;
    self.continuesModeSwitch.on = self.settings.isContinuousMode;
    self.beepSwitch.on = self.settings.beepWithPulse;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(facebookActiveSessionStateDidChange:)
                                                 name:@"FacebookActiveSessionStateChanged" object:nil];
}

#pragma mark - NSNotifications

- (void)facebookActiveSessionStateDidChange:(NSNotification *)notification {
#warning - incomplete implementation
    // probably should update Facebook Profile Cell
    //[self updateCell:[self getFacebookProfileCell]];
    [self reloadFacebookProfileCellWithAnimation:@(UITableViewRowAnimationNone)];
}

#pragma mark - IBActions

- (IBAction)changeBeepWithPulseOption:(UISwitch *)sender {
    self.settings.beepWithPulse = sender.on;
}

- (IBAction)changeContinuesModeOption:(UISwitch *)sender {
    [self.autoStopAfterSwitch setOn:!sender.on animated:YES];
    self.settings.continuousMode = sender.on;
    
    if (sender.on) {
        self.settings.autoStopAfter = 0;
    }
    else {
        self.settings.autoStopAfter = 20;
    }
}

- (IBAction)changeAutoStopOption:(UISwitch *)sender
{
    [self.continuesModeSwitch setOn:!sender.on animated:YES];
    self.settings.continuousMode = !sender.on;
    
    if (sender.on) {
        self.settings.autoStopAfter = 20;
    }
    else {
        self.settings.autoStopAfter = 0;
    }
}

#pragma mark - Facebook
/*

- (void)login{

    // If we can't log in as new user, we don't want to still be logged in as previous user,
    // particularly if it might not be obvious to the user that the login failed.
    [self updateCell:[self getFacebookProfileCell]];

    // user is going to log on via Facebook Login with option to Fallback to web view
    FBSessionLoginBehavior behavior =
    FBSessionLoginBehaviorWithFallbackToWebView;
    
    [self updateCell:[self getFacebookProfileCell]];//*
    
    // we pass the correct behavior here to indicate the login workflow to use (Facebook Login, fallback, etc.)
    if (session.isOpen) {
        [self updateForSessionChange];
    }
    [session openWithBehavior:behavior
            completionHandler:^(FBSession *session,
                                FBSessionState status,
                                NSError *error) {
                // this handler is called back whether the login succeeds or fails; in the
                // success case it will also be called back upon each state transition between
                // session-open and session-close
                if (error) {
                    [userManager switchToNoActiveUser];
                }
                [self updateForSessionChange];
            }];
}

- (void)updateForSessionChange {
    // Get the current session from the userManager
    FBSession *session = userManager.currentSession;
    
    if (session.isOpen) {
        // fetch profile info such as name, id, etc. for the open session
        FBRequest *me = [[FBRequest alloc] initWithSession:session
                                                 graphPath:@"me"];
        
        [me startWithCompletionHandler:^(FBRequestConnection *connection,
                                         NSDictionary<FBGraphUser> *result,
                                         NSError *error) {
            // because we have a cached copy of the connection, we can check
            // to see if this is the connection we care about; a prematurely
            // cancelled connection will short-circuit here
            
#warning should check this
            
            self.pendingRequest = nil;
            self.pendingLogin = NO;
            
            // we interpret an error in the initial fetch as a reason to
            // fail the user switch, and leave the application without an
            // active user (similar to initial state)
            if (error) {
                NSLog(@"Couldn't complete process: %@", error.localizedDescription);
                [userManager switchToNoActiveUser];
                return;
            }
            [userManager updateUser:result];
            [self updateCell:[self getFacebookProfileCell]];
        }];
    } else {
        // in the closed case, we check to see if we picked up a cached token that we
        // expect to be valid and ready for use; if so then we open the session on the spot
#warning need to check this
        if (session.state == FBSessionStateCreatedTokenLoaded) {
            // even though we had a cached token, we need to login to make the session usable
            [session openWithCompletionHandler:^(FBSession *session,
                                                 FBSessionState status,
                                                 NSError *error) {
                [self indexPathForFacebookProfileCell];
            }];
        }
    }
}

 */

- (void)updateCell:(FacebookProfileTableViewCell *)cell {
    if (!FBSession.activeSession.isOpen) {
        //there is no active session
        //cell.userName = @"";
        //cell.userID = nil;
        
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.loginView = self.loginView;
    } else {
        [[FBRequest requestForMe] startWithCompletionHandler:
         ^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *user, NSError *error) {
             if (!error) {
                 cell.userName = user.name;
                 cell.userID = [user objectForKey:@"id"];
             }
         }];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
}

- (FacebookProfileTableViewCell *)getFacebookProfileCell{
    FacebookProfileTableViewCell *cell = (FacebookProfileTableViewCell *)[self.tableView cellForRowAtIndexPath:
                                                              [self indexPathForFacebookProfileCell]];
    return cell;
}

- (NSIndexPath*)indexPathForFacebookProfileCell{
    // I assume FacebookUserCell is placed first in the settings tab table view
    return [NSIndexPath indexPathForRow:0 inSection:0];
}

#pragma mark - UITableViewDataSource methods

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *rtlLabel = [[UILabel alloc] init];
    NSString *text;
    
    switch(section) {
        case 0:
            text = @"   פרופיל";
            break;
        case 1:
            text = @"   אפשרויות";
            break;
        case 2:
            text = @"   עזרה";
            break;
        case 3:
            text = @"   אודות";
            break;
    }
    rtlLabel.text = text;
    rtlLabel.textColor = [UIColor grayColor];
    rtlLabel.backgroundColor = [UIColor clearColor];
    rtlLabel.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
    rtlLabel.textAlignment = NSTextAlignmentRight;
    
    return rtlLabel;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 36;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath compare:[self indexPathForFacebookProfileCell]] == NSOrderedSame) {

        if (editingStyle == UITableViewCellEditingStyleDelete) {
            [FBSession.activeSession closeAndClearTokenInformation];
            [tableView setEditing:NO animated:YES];
            [self performSelector:@selector(reloadFacebookProfileCellWithAnimation:) withObject:@(UITableViewRowAnimationFade) afterDelay:0.5];
        }
        
    } else {
        return [super tableView:tableView commitEditingStyle:editingStyle forRowAtIndexPath:indexPath];
    }
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath compare:[self indexPathForFacebookProfileCell]] == NSOrderedSame) {

        return FBSession.activeSession.isOpen;
    } else {
        return NO;
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath compare:[self indexPathForFacebookProfileCell]] == NSOrderedSame) {
        static NSString *CellIdentifier = @"FacebookProfileCell";
        FacebookProfileTableViewCell *cell = (FacebookProfileTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            cell = [[FacebookProfileTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        [self updateCell:cell];
        
        return cell;
    }
    
    else {
        return [super tableView:tableView cellForRowAtIndexPath:indexPath];
    }
}

#pragma mark - UITableViewDelegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath compare:[self indexPathForFacebookProfileCell]] == NSOrderedSame) {
        FacebookProfileTableViewCell *cell = (FacebookProfileTableViewCell*)[self tableView:tableView
                                                      cellForRowAtIndexPath:indexPath];
        return cell.desiredCellHeight;
    }
    else {
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath compare:[self indexPathForFacebookProfileCell]] == NSOrderedSame) {
        // this is the facebook user cell

        if (FBSession.activeSession.isOpen) {
            // go to another view controller
            // currently not doing anything
            [self.navigationController pushViewController:self.userSettingsViewController animated:YES];
        } else {
            // logging in
            //[self login];
        }
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
    } else {
        // shouldn't do anything
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
    
    return;
}

- (NSString*)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath compare:[self indexPathForFacebookProfileCell]] == NSOrderedSame) {
        return @"Log Out";
    }
    return @"Forget";
}

#pragma mark - FBUserSettingsDelegate methods

- (void)reloadFacebookProfileCellWithAnimation:(NSNumber *)animation{
    //[self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:@[[self indexPathForFacebookProfileCell]] withRowAnimation:[animation integerValue]];
    //[self.tableView endUpdates];
}

- (void)loginViewControllerDidLogUserOut:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];

    [self performSelector:@selector(reloadFacebookProfileCellWithAnimation:) withObject:@(UITableViewRowAnimationFade) afterDelay:0.5];
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

#pragma mark - FBLoginView delegate

- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView {
    // need to update cell first or send notification
    //[self updateCell:[self getFacebookProfileCell]];
    [self reloadFacebookProfileCellWithAnimation:@(UITableViewRowAnimationNone)];
}

- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView {
    // Facebook SDK * login flow *
    // It is important to always handle session closure because it can happen
    // externally; for example, if the current session's access token becomes
    // invalid. For now, we do nothing
}

+ (void)loginView:(FBLoginView *)loginView
      handleError:(NSError *)error{
    NSString *alertMessage, *alertTitle;
    
    // Facebook SDK * error handling *
    // Error handling is an important part of providing a good user experience.
    // Since this sample uses the FBLoginView, this delegate will respond to
    // login failures, or other failures that have closed the session (such
    // as a token becoming invalid). Please see the [- postOpenGraphAction:]
    // and [- requestPermissionAndPost] on `SCViewController` for further
    // error handling on other operations.
    FBErrorCategory errorCategory = [FBErrorUtility errorCategoryForError:error];
    if ([FBErrorUtility shouldNotifyUserForError:error]) {
        // If the SDK has a message for the user, surface it. This conveniently
        // handles cases like password change or iOS6 app slider state.
        alertTitle = @"Something Went Wrong";
        alertMessage = [FBErrorUtility userMessageForError:error];
    } else if (errorCategory == FBErrorCategoryAuthenticationReopenSession) {
        // It is important to handle session closures as mentioned. You can inspect
        // the error for more context but this sample generically notifies the user.
        alertTitle = @"Session Error";
        alertMessage = @"Your current session is no longer valid. Please log in again.";
    } else if (errorCategory == FBErrorCategoryUserCancelled) {
        // The user has cancelled a login. You can inspect the error
        // for more context. For this sample, we will simply ignore it.
        NSLog(@"user cancelled login");
    } else {
        // For simplicity, this sample treats other errors blindly, but you should
        // refer to https://developers.facebook.com/docs/technical-guides/iossdk/errors/ for more information.
        alertTitle  = @"Unknown Error";
        alertMessage = @"Error. Please try again later.";
        NSLog(@"Unexpected error:%@", error);
    }
    
    if (alertMessage) {
        [[[UIAlertView alloc] initWithTitle:alertTitle
                                    message:alertMessage
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
}

- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView user:(id<FBGraphUser>)user {
    // TODO
}

@end
