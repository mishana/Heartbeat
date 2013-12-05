//
//  SettingsViewController.h
//  Heartbeat
//
//  Created by michael leybovich on 9/24/13.
//  Copyright (c) 2013 michael leybovich. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FacebookSDK/FacebookSDK.h"

@interface SettingsViewController : UITableViewController

+ (void)loginView:(FBLoginView *)loginView handleError:(NSError *)error;// handle facebook login error

@end
