//
//  SettingsViewController.m
//  Heartbeat
//
//  Created by michael leybovich on 9/24/13.
//  Copyright (c) 2013 michael leybovich. All rights reserved.
//

#import "SettingsViewController.h"
#import "Settings.h"

@interface SettingsViewController () <UITableViewDelegate>
@property (strong, nonatomic) Settings *settings;

@end

@implementation SettingsViewController

#pragma - UITableViewDataSource methods
//
-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *rtlLabel = [[UILabel alloc] init];
    NSString *text;
    
    switch(section) {
        case 0:
            text = @"   אפשרויות";
            break;
        case 1:
            text = @"   עזרה";
            break;
        case 2:
            text = @"   פרופיל";
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
    return 35;
}
//

- (Settings *)settings
{
    if (!_settings) _settings = [Settings currentSettings];
    return _settings;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.settings synchronize];
}

- (IBAction)changeAutoStopOption:(UISwitch *)sender
{
    self.settings.continuousMode = !sender.isOn;
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
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
