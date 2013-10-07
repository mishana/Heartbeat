//
//  WelcomeScreenViewController.m
//  Heartbeat
//
//  Created by michael leybovich on 9/21/13.
//  Copyright (c) 2013 michael leybovich. All rights reserved.
//

#import "WelcomeScreenViewController.h"

@implementation WelcomeScreenViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // Status bar configuration
    //[self.navigationController setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
    
    // Hide navigation bar
    [self.navigationController setNavigationBarHidden:YES];
    
    // background configuration
    UIImage *backgroundImage = [UIImage imageNamed:@"iphone_JPG.jpg"];
    UIImageView *backgroundView = [[UIImageView alloc] initWithImage:backgroundImage];
    [self.view addSubview:backgroundView];
    
    //self.view.backgroundColor = [UIColor colorWithPatternImage:backgroundImage];
    //self.view.alpha = 1;
}

@end
