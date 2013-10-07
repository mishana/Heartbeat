//
//  MenuTabBarViewController.m
//  Heartbeat
//
//  Created by michael leybovich on 9/30/13.
//  Copyright (c) 2013 michael leybovich. All rights reserved.
//

#import "MenuTabBarViewController.h"

@implementation MenuTabBarViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.selectedIndex = 1;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
