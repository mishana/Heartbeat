//
//  ResultsViewController.m
//  Heartbeat
//
//  Created by michael leybovich on 10/8/13.
//  Copyright (c) 2013 michael leybovich. All rights reserved.
//

#import "ResultsViewController.h"

@interface ResultsViewController () <UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UICollectionView *resultCollectionView;
@property (nonatomic, strong) NSNumber *numOfResults;

@end

@implementation ResultsViewController

- (NSNumber *)numOfResults
{
    if (!_numOfResults) _numOfResults = @(10);
    return _numOfResults;
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
#warning need to update this later
    return [self.numOfResults integerValue];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Result" forIndexPath:indexPath];

    return cell;
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
    
    self.title = @"תוצאות";
    
    //------------------DESIGN BLOCK-----------------

    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        
        // navigation bar configuration
        ///*
        // A slightly darker color - facebook like
        //self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0 green:0.245 blue:0.67 alpha:1.0];
        
        self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.075 green:0.439 blue:0.753 alpha:1.0];
        self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    }
    
    //-----------------------------------------------
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)swipeResult:(UISwipeGestureRecognizer *)gesture
{
    /*
    CGPoint swipeLocation = [gesture locationInView:self.resultCollectionView];
    NSIndexPath *indexPath = [self.resultCollectionView indexPathForItemAtPoint:swipeLocation];
    
    if (indexPath) {
        self.numOfResults = @([self.numOfResults integerValue] - 1);
        [self.resultCollectionView deleteItemsAtIndexPaths:@[indexPath]];
    }
    */
}

@end
