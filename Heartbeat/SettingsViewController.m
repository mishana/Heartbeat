//
//  SettingsViewController.m
//  Heartbeat
//
//  Created by michael leybovich on 9/24/13.
//  Copyright (c) 2013 michael leybovich. All rights reserved.
//

#import "SettingsViewController.h"
#import "Settings.h"
//#import "FacebookSDK/FacebookSDK.h"

@interface SettingsViewController () <UITableViewDelegate>
@property (strong, nonatomic) Settings *settings;

// IBOutlets
@property (weak, nonatomic) IBOutlet UISwitch *autoStopAfterSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *continuesModeSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *beepSwitch;

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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

@end
