//
//  SettingsViewController.m
//  Heartbeat
//
//  Created by michael leybovich on 9/24/13.
//  Copyright (c) 2013 michael leybovich. All rights reserved.
//

#import "SettingsViewController.h"
#import "Settings.h"
#import "SUProfileTableViewCell.h"
#import "FacebookSDK/FacebookSDK.h"
#import "FacebookUserManager.h"
#import "HeartBeatAppDelegate.h"

@interface SettingsViewController () <UITableViewDataSource , UITableViewDelegate>
@property (strong, nonatomic) Settings *settings;

// IBOutlets
@property (weak, nonatomic) IBOutlet UISwitch *autoStopAfterSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *continuesModeSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *beepSwitch;

// Facebook
@property (nonatomic) BOOL pendingLogin;
@property (strong, nonatomic) FBRequest *pendingRequest;

@end

@implementation SettingsViewController

- (Settings *)settings
{
    if (!_settings) _settings = [Settings currentSettings];
    return _settings;
}

//

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.settings synchronize];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    //self.tableView.delegate = nil;
    //self.tableView.dataSource = nil;
    //self.tableView = nil;
}

- (void)viewDidLoad
{
    //------------------DESIGN BLOCK-----------------

    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {

    //self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.177 green:0.341 blue:0.945 alpha:0.8];

    
    //self.navigationController.navigationBar.titleTextAttributes = @{ UITextAttributeTextColor : [UIColor whiteColor] };
        
        self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.075 green:0.439 blue:0.753 alpha:1.0];
        self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    }
    
    //-----------------------------------------------
    
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.autoStopAfterSwitch.on = self.settings.autoStopAfter;
    self.continuesModeSwitch.on = self.settings.isContinuousMode;
    self.beepSwitch.on = self.settings.beepWithPulse;
}

//

- (void)loginDefaultUser {
    HeartBeatAppDelegate *appDelegate = (HeartBeatAppDelegate *)[[UIApplication sharedApplication] delegate];
    FacebookUserManager *userManager = appDelegate.userManager;
    
    if ([userManager isLoggedIn]) {
        [self login];
    }
}

- (void)login{
    HeartBeatAppDelegate *appDelegate = (HeartBeatAppDelegate *)[[UIApplication sharedApplication]delegate];
    FacebookUserManager *userManager = appDelegate.userManager;
    
    // If we can't log in as new user, we don't want to still be logged in as previous user,
    // particularly if it might not be obvious to the user that the login failed.
    [userManager switchToNoActiveUser];
    self.pendingLogin = YES;
    [self updateFacebookUserCell];

    // user is going to log on via Facebook Login with option to Fallback to web view
    FBSessionLoginBehavior behavior =
    FBSessionLoginBehaviorWithFallbackToWebView;
    
    FBSession *session = [userManager switchToUser];
    [self updateFacebookUserCell];//*
    
    // we pass the correct behavior here to indicate the login workflow to use (Facebook Login, fallback, etc.)
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

- (void)updateCell:(SUProfileTableViewCell *)cell {
    HeartBeatAppDelegate *appDelegate = (HeartBeatAppDelegate *)[[UIApplication sharedApplication]delegate];
    FacebookUserManager *userManager = appDelegate.userManager;
    
    NSString *userID = [userManager getUserID];
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    cell.editingAccessoryType = UITableViewCellAccessoryNone;
    
    if (userID == nil) {
        cell.userName = @"LogIn with Facebook";
        cell.userID = nil;
        
        /*
        cell.userName = nil;
        UIImageView *imgView = [[UIImageView alloc] init];
        imgView.image = [UIImage imageNamed:@"login-with-facebook.png"];
        [imgView setFrame:CGRectMake((cell.frame.size.width - imgView.image.size.width)/2, (cell.desiredHeight-imgView.image.size.height)/2, imgView.image.size.width, imgView.image.size.height)];
        //imgView.bounds = cell.bounds;
        
        [cell addSubview:imgView];
         */
        
    } else {
        if (self.pendingLogin) {
            cell.userName = @"Logging in...";
        } else {
            cell.userName = [userManager getUserName];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        cell.userID = userID;
    }
}

- (void)updateFacebookUserCell{
    SUProfileTableViewCell *cell = (SUProfileTableViewCell *)[self.tableView cellForRowAtIndexPath:
                                                              [self indexPathForFacebookUserCell]];
    [self updateCell:cell];
}

- (NSIndexPath*)indexPathForFacebookUserCell{
    // I assume FacebookUserCell is placed first in the settings tab table view
    // See comment in userSlotFromIndexPath:
    return [NSIndexPath indexPathForRow:0
                              inSection:0];
}

- (void)updateForSessionChange {
    HeartBeatAppDelegate *appDelegate = (HeartBeatAppDelegate *)[[UIApplication sharedApplication]delegate];
    FacebookUserManager *userManager = appDelegate.userManager;

    // Get the current session from the userManager
    FBSession *session = userManager.currentSession;
    
    if (session.isOpen) {
        // fetch profile info such as name, id, etc. for the open session
        FBRequest *me = [[FBRequest alloc] initWithSession:session
                                                 graphPath:@"me"];
        
        self.pendingRequest= me;
        
        [me startWithCompletionHandler:^(FBRequestConnection *connection,
                                         NSDictionary<FBGraphUser> *result,
                                         NSError *error) {
            // because we have a cached copy of the connection, we can check
            // to see if this is the connection we care about; a prematurely
            // cancelled connection will short-circuit here
            if (me != self.pendingRequest) {
                return;
            }
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
            [self updateFacebookUserCell];
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
                [self indexPathForFacebookUserCell];
            }];
        }
    }
}

// IBActions

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

#pragma - UITableViewDataSource methods

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
    if (indexPath.section == 0 && indexPath.row == 0) {
        HeartBeatAppDelegate *appDelegate = (HeartBeatAppDelegate *)[[UIApplication sharedApplication]delegate];
        FacebookUserManager *userManager = [appDelegate userManager];
        
        if (editingStyle == UITableViewCellEditingStyleDelete) {
            [userManager updateUser:nil];
            [self updateFacebookUserCell];
        }
        
    } else {
        return [super tableView:tableView commitEditingStyle:editingStyle forRowAtIndexPath:indexPath];
    }
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 0) {
        HeartBeatAppDelegate *appDelegate = (HeartBeatAppDelegate *)[[UIApplication sharedApplication]delegate];
        FacebookUserManager *userManager = [appDelegate userManager];
        
        return [userManager getUserID] != nil;
    } else {
        return NO;
    }
    
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 0) {
        static NSString *CellIdentifier = @"FacebookProfileCell";
        SUProfileTableViewCell *cell = (SUProfileTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            cell = [[SUProfileTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        [self updateCell:cell];
        
        return cell;
    }
    
    else {
        return [super tableView:tableView cellForRowAtIndexPath:indexPath];
    }
}

#pragma mark UITableViewDelegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 0) {
        SUProfileTableViewCell *cell = (SUProfileTableViewCell*)[self tableView:tableView
                                                      cellForRowAtIndexPath:indexPath];
        return cell.desiredHeight;
    }
    else {
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 0) {
        // this is the facebook user cell
        HeartBeatAppDelegate *appDelegate = (HeartBeatAppDelegate *)[[UIApplication sharedApplication]delegate];
        FacebookUserManager *userManager = [appDelegate userManager];
        if (userManager.isLoggedIn) {
            // go to another view controller
            // currently not doing anything
        } else {
            // logging in
            [self login];
        }
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
    } else {
        // shouldn't do anything
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
    
    return;
}

- (NSString*)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 0) {
        return @"Log Out";
    }
}

@end
