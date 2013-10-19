//
//  ResultsViewController.m
//  Heartbeat
//
//  Created by michael leybovich on 10/8/13.
//  Copyright (c) 2013 michael leybovich. All rights reserved.
//

#import "ResultsViewController.h"
#import "ResultCollectionViewCell.h"
#import "Result.h"

@interface ResultsViewController () <UICollectionViewDataSource, UIActionSheetDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *resultCollectionView;
//@property (nonatomic, strong) NSNumber *numOfResults;
@property (nonatomic) int resultsNumOld;

@property (nonatomic, strong) NSIndexPath *deleteIndex;

@end

@implementation ResultsViewController

- (NSArray *)resultsByDate
{
    return [[Result allResults] sortedArrayUsingSelector:@selector(compareByDate:)];
}

- (int)numOfResults
{
    return [[Result allResults] count];
}

/*- (NSNumber *)numOfResults
{
    if (!_numOfResults) _numOfResults = @(10);
    return _numOfResults;
}*/

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
    return [self numOfResults];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Result" forIndexPath:indexPath];
    
    [self updateCell:cell usingResult:[self resultsByDate][indexPath.item] ];

    return cell;
}

- (void)updateCell:(UICollectionViewCell *)cell usingResult:(Result *)result
{
    if ([cell isKindOfClass:[ResultCollectionViewCell class]]) {
        ResultView *resultView = ((ResultCollectionViewCell *)cell).resultView;
        
        resultView.bpm = result.bpm;
        resultView.date = result.end;
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.resultsNumOld == [self numOfResults] - 1) {
        NSUInteger indexes[2];
        indexes[0] = 0;
        indexes[1] = 0;
        NSIndexPath *indexPath = [[NSIndexPath alloc] initWithIndexes:indexes length:2];

        [self.resultCollectionView insertItemsAtIndexPaths:@[indexPath]];
    }
    self.resultsNumOld = [self numOfResults];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
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
    
    self.resultsNumOld = [self numOfResults];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.destructiveButtonIndex) {
        [((Result *)[[self resultsByDate] objectAtIndex:self.deleteIndex.item]) deleteFromResults];
        
        self.resultsNumOld = [self numOfResults];
        [self.resultCollectionView deleteItemsAtIndexPaths:@[self.deleteIndex]];
    }
}

- (IBAction)swipeResult:(UISwipeGestureRecognizer *)gesture
{
    ///*
    CGPoint swipeLocation = [gesture locationInView:self.resultCollectionView];
    NSIndexPath *indexPath = [self.resultCollectionView indexPathForItemAtPoint:swipeLocation];
    
    if (indexPath) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                 delegate:self
                                                        cancelButtonTitle:@"Cancel"
                                                   destructiveButtonTitle:@"Delete Result"
                                                        otherButtonTitles:nil];
        
        [self.resultCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionBottom animated:YES];
        
        [actionSheet showFromTabBar:self.tabBarController.tabBar];
        
        self.deleteIndex = indexPath;
    }
    //*/
}

@end
