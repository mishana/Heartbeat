//
//  VideoManagerViewController.m
//  Heartbeat
//
//  Created by Or Maayan on 9/14/13.
//  Copyright (c) 2013 michael leybovich. All rights reserved.
//

#import "VideoManagerViewController.h"
#import "UIImage+ImageAverageColor.h"
#import "Algorithm.h"
#import "Settings.h"
#import <AudioToolbox/AudioToolbox.h>
#import "Result.h"
#import "UILabel+FSHIghlightAnimationAdditions.h"

@interface VideoManagerViewController ()
// AVFoundation
@property (nonatomic,strong) AVCaptureSession * session;
@property (strong) AVCaptureDevice * videoDevice;
@property (strong) AVCaptureDeviceInput * videoInput;
@property (strong) AVCaptureVideoDataOutput * frameOutput;

// Audio
@property (nonatomic, retain) AVAudioPlayer *BeepSound;

// Algorithm
@property (nonatomic , strong) Algorithm *algorithm;
@property (nonatomic , strong) Algorithm *algorithm2;
@property (strong , nonatomic) NSDate *algorithmStartTime;
@property (strong , nonatomic) NSDate *bpmFinalResultFirstTimeDetected;

@property (strong, nonatomic) Settings *settings;

// view Outlets
@property (weak, nonatomic) IBOutlet UILabel *bpmLabel;
@property (weak, nonatomic) IBOutlet UILabel *fingerDetectLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *finalBPMLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeTillResultLabel;

@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (weak, nonatomic) IBOutlet UIImageView *beatingHeart;
@property (weak, nonatomic) IBOutlet UIImageView *heart;

@property (weak, nonatomic) IBOutlet UIButton *helpButton;

// tab bar configuration properties
@property (strong, nonatomic) UIColor *tabBarColor;
@property (strong, nonatomic) UIColor *tabBarItemColor;
@property (nonatomic, getter = isTabBarTranslucent) BOOL tabBarTranslucent;

@property (nonatomic, strong) Result *result;

@end

@implementation VideoManagerViewController

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

// Properties

- (Settings *)settings
{
    if (!_settings)
        _settings = [Settings currentSettings];
    
    return _settings;
}

- (NSDate *)algorithmStartTime
{
    if (!_algorithmStartTime) {
        _algorithmStartTime = [NSDate date];
    }
    return _algorithmStartTime;
}

- (NSDate *)bpmFinalResultFirstTimeDetected
{
    if (!_bpmFinalResultFirstTimeDetected) {
        _bpmFinalResultFirstTimeDetected = [NSDate date];
    }
    return _bpmFinalResultFirstTimeDetected;
}

- (Algorithm *)algorithm
{
    if (!_algorithm) {
        _algorithm = [[Algorithm alloc] init];
    }
    return _algorithm;
}

- (Algorithm *)algorithm2
{
    if (!_algorithm2) {
        _algorithm2 = [[Algorithm alloc] init];
        _algorithm2.windowSize = 9;
        _algorithm2.filterWindowSize = 45;
    }
    return _algorithm2;
}

- (Result *)result
{
    if (!_result) _result = [[Result alloc] init];
    return _result;
}

//

- (void)startRunningSession
{
    dispatch_queue_t sessionQ = dispatch_queue_create("start running session thread", NULL);
    
    dispatch_async(sessionQ, ^{
        // turn flash on
        if ([self.videoDevice hasTorch] && [self.videoDevice hasFlash]){
            [self.videoDevice lockForConfiguration:nil];
            [self.videoDevice setTorchMode:AVCaptureTorchModeOn];
            [self.videoDevice setFlashMode:AVCaptureFlashModeOn];
            [self.videoDevice unlockForConfiguration];
        }
        [self.session startRunning];
    });
}

- (void)stopRunningSession
{
    dispatch_queue_t sessionQ = dispatch_queue_create("stop running session thread", NULL);
    
    dispatch_async(sessionQ, ^{
        [self.session stopRunning];
        // turn flash off (maybe unnecessary because stopRunning do this)
        if ([self.videoDevice hasTorch] && [self.videoDevice hasFlash]){
            [self.videoDevice lockForConfiguration:nil];
            [self.videoDevice setTorchMode:AVCaptureTorchModeOff];
            [self.videoDevice setFlashMode:AVCaptureFlashModeOff];
            [self.videoDevice unlockForConfiguration];
        }
    });
}

- (void)tabBarConfiguration
{
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        
        // tab bar configuration
        ///*
        self.tabBarController.tabBar.barTintColor = [UIColor colorWithRed:0.075 green:0.439 blue:0.753 alpha:1.0];
        self.tabBarController.tabBar.tintColor = [UIColor whiteColor];
        self.tabBarController.tabBar.translucent = NO;
        
        // set selected and unselected icons
        UITabBarItem *item0 = [self.tabBarController.tabBar.items objectAtIndex:0];
        UITabBarItem *item1 = [self.tabBarController.tabBar.items objectAtIndex:1];
        UITabBarItem *item2 = [self.tabBarController.tabBar.items objectAtIndex:2];
        
        // set colors of selected text
        [item0 setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:self.tabBarItemColor, UITextAttributeTextColor, nil] forState:UIControlStateSelected];
        
        [item1 setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], UITextAttributeTextColor, nil] forState:UIControlStateSelected];
        
        [item2 setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:self.tabBarItemColor, UITextAttributeTextColor, nil] forState:UIControlStateSelected];
        
        // set colors of un-selected text
        [item0 setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], UITextAttributeTextColor, nil] forState:UIControlStateNormal];
        
        [item2 setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], UITextAttributeTextColor, nil] forState:UIControlStateNormal];
        
        // this way, the icon gets rendered as it is (thus, it needs to be green in this example)
        item0.image = [[UIImage imageNamed:@"pieChart_Line.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        item2.image = [[UIImage imageNamed:@"Settings_Line-1.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
        // this icon is used for selected tab and it will get tinted as defined in self.tabBar.tintColor
        item0.selectedImage = [UIImage imageNamed:@"pieChart_full.png"];
        item1.selectedImage = [UIImage imageNamed:@"Heart_Full.png"];
        item2.selectedImage = [UIImage imageNamed:@"settings_full-1.png"];
        //*/
    }
}

- (void)resetAlgorithm
{
    self.settings = nil;
    self.algorithmStartTime = nil;
    self.bpmFinalResultFirstTimeDetected = nil;
    self.algorithm = nil;
    self.algorithm2 = nil;
}

//

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self resetAlgorithm];
    
    [self tabBarConfiguration];
    
    //[self heartAnimation:self.heart];
    //[self heartAnimation:self.beatingHeart];
    //[self.fingerDetectLabel setTextWithChangeAnimation:@"שים את האצבע על המצלמה"];
}

- (NSArray *)heartsFromRes:(int)from toRes:(int)to
{
    int minRes = 16;
    int maxRes = 128;
    
    // hearts array initialization
    /*{
        UIImage *heart_16 = [UIImage imageNamed:@"h5_16.png"];
        UIImage *heart_17 = [UIImage imageNamed:@"h5_17.png"];
        UIImage *heart_18 = [UIImage imageNamed:@"h5_18.png"];
        UIImage *heart_19 = [UIImage imageNamed:@"h5_19.png"];
        UIImage *heart_20 = [UIImage imageNamed:@"h5_20.png"];
        UIImage *heart_21 = [UIImage imageNamed:@"h5_21.png"];
        UIImage *heart_22 = [UIImage imageNamed:@"h5_22.png"];
        UIImage *heart_23 = [UIImage imageNamed:@"h5_23.png"];
        UIImage *heart_24 = [UIImage imageNamed:@"h5_24.png"];
        UIImage *heart_25 = [UIImage imageNamed:@"h5_25.png"];
        UIImage *heart_26 = [UIImage imageNamed:@"h5_26.png"];
        UIImage *heart_27 = [UIImage imageNamed:@"h5_27.png"];
        UIImage *heart_28 = [UIImage imageNamed:@"h5_28.png"];
        UIImage *heart_29 = [UIImage imageNamed:@"h5_29.png"];
        UIImage *heart_30 = [UIImage imageNamed:@"h5_30.png"];
        UIImage *heart_31 = [UIImage imageNamed:@"h5_31.png"];
        UIImage *heart_32 = [UIImage imageNamed:@"h5_32.png"];
        UIImage *heart_33 = [UIImage imageNamed:@"h5_33.png"];
        UIImage *heart_34 = [UIImage imageNamed:@"h5_34.png"];
        UIImage *heart_35 = [UIImage imageNamed:@"h5_35.png"];
        UIImage *heart_36 = [UIImage imageNamed:@"h5_36.png"];
        UIImage *heart_37 = [UIImage imageNamed:@"h5_37.png"];
        UIImage *heart_38 = [UIImage imageNamed:@"h5_38.png"];
        UIImage *heart_39 = [UIImage imageNamed:@"h5_39.png"];
        UIImage *heart_40 = [UIImage imageNamed:@"h5_40.png"];
        UIImage *heart_41 = [UIImage imageNamed:@"h5_41.png"];
        UIImage *heart_42 = [UIImage imageNamed:@"h5_42.png"];
        UIImage *heart_43 = [UIImage imageNamed:@"h5_43.png"];
        UIImage *heart_44 = [UIImage imageNamed:@"h5_44.png"];
        UIImage *heart_45 = [UIImage imageNamed:@"h5_45.png"];
        UIImage *heart_46 = [UIImage imageNamed:@"h5_46.png"];
        UIImage *heart_47 = [UIImage imageNamed:@"h5_47.png"];
        UIImage *heart_48 = [UIImage imageNamed:@"h5_48.png"];
        
        UIImage *heart_49 = [UIImage imageNamed:@"h5_49.png"];
        UIImage *heart_50 = [UIImage imageNamed:@"h5_50.png"];
        UIImage *heart_51 = [UIImage imageNamed:@"h5_51.png"];
        UIImage *heart_52 = [UIImage imageNamed:@"h5_52.png"];
        UIImage *heart_53 = [UIImage imageNamed:@"h5_53.png"];
        UIImage *heart_54 = [UIImage imageNamed:@"h5_54.png"];
        UIImage *heart_55 = [UIImage imageNamed:@"h5_55.png"];
        UIImage *heart_56 = [UIImage imageNamed:@"h5_56.png"];
        UIImage *heart_57 = [UIImage imageNamed:@"h5_57.png"];
        UIImage *heart_58 = [UIImage imageNamed:@"h5_58.png"];
        UIImage *heart_59 = [UIImage imageNamed:@"h5_59.png"];
        UIImage *heart_60 = [UIImage imageNamed:@"h5_60.png"];
        UIImage *heart_61 = [UIImage imageNamed:@"h5_61.png"];
        UIImage *heart_62 = [UIImage imageNamed:@"h5_62.png"];
        UIImage *heart_63 = [UIImage imageNamed:@"h5_63.png"];
        UIImage *heart_64 = [UIImage imageNamed:@"h5_64.png"];
        UIImage *heart_65 = [UIImage imageNamed:@"h5_65.png"];
        UIImage *heart_66 = [UIImage imageNamed:@"h5_66.png"];
        UIImage *heart_67 = [UIImage imageNamed:@"h5_67.png"];
        UIImage *heart_68 = [UIImage imageNamed:@"h5_68.png"];
        UIImage *heart_69 = [UIImage imageNamed:@"h5_69.png"];
        UIImage *heart_70 = [UIImage imageNamed:@"h5_70.png"];
        UIImage *heart_71 = [UIImage imageNamed:@"h5_71.png"];
        UIImage *heart_72 = [UIImage imageNamed:@"h5_72.png"];
        UIImage *heart_73 = [UIImage imageNamed:@"h5_73.png"];
        UIImage *heart_74 = [UIImage imageNamed:@"h5_74.png"];
        UIImage *heart_75 = [UIImage imageNamed:@"h5_75.png"];
        UIImage *heart_76 = [UIImage imageNamed:@"h5_76.png"];
        UIImage *heart_77 = [UIImage imageNamed:@"h5_77.png"];
        UIImage *heart_78 = [UIImage imageNamed:@"h5_78.png"];
        UIImage *heart_79 = [UIImage imageNamed:@"h5_79.png"];
        UIImage *heart_80 = [UIImage imageNamed:@"h5_80.png"];
        UIImage *heart_81 = [UIImage imageNamed:@"h5_81.png"];
        UIImage *heart_82 = [UIImage imageNamed:@"h5_82.png"];
        UIImage *heart_83 = [UIImage imageNamed:@"h5_83.png"];
        UIImage *heart_84 = [UIImage imageNamed:@"h5_84.png"];
        UIImage *heart_85 = [UIImage imageNamed:@"h5_85.png"];
        UIImage *heart_86 = [UIImage imageNamed:@"h5_86.png"];
        UIImage *heart_87 = [UIImage imageNamed:@"h5_87.png"];
        UIImage *heart_88 = [UIImage imageNamed:@"h5_88.png"];
        UIImage *heart_89 = [UIImage imageNamed:@"h5_89.png"];
        UIImage *heart_90 = [UIImage imageNamed:@"h5_90.png"];
        UIImage *heart_91 = [UIImage imageNamed:@"h5_91.png"];
        UIImage *heart_92 = [UIImage imageNamed:@"h5_92.png"];
        UIImage *heart_93 = [UIImage imageNamed:@"h5_93.png"];
        UIImage *heart_94 = [UIImage imageNamed:@"h5_94.png"];
        UIImage *heart_95 = [UIImage imageNamed:@"h5_95.png"];
        UIImage *heart_96 = [UIImage imageNamed:@"h5_96.png"];
        
        UIImage *heart_97 = [UIImage imageNamed:@"h5_97.png"];
        UIImage *heart_98 = [UIImage imageNamed:@"h5_98.png"];
        UIImage *heart_99 = [UIImage imageNamed:@"h5_99.png"];
        UIImage *heart_100 = [UIImage imageNamed:@"h5_100.png"];
        UIImage *heart_101 = [UIImage imageNamed:@"h5_101.png"];
        UIImage *heart_102 = [UIImage imageNamed:@"h5_102.png"];
        UIImage *heart_103 = [UIImage imageNamed:@"h5_103.png"];
        UIImage *heart_104 = [UIImage imageNamed:@"h5_104.png"];
        UIImage *heart_105 = [UIImage imageNamed:@"h5_105.png"];
        UIImage *heart_106 = [UIImage imageNamed:@"h5_106.png"];
        UIImage *heart_107 = [UIImage imageNamed:@"h5_107.png"];
        UIImage *heart_108 = [UIImage imageNamed:@"h5_108.png"];
        UIImage *heart_109 = [UIImage imageNamed:@"h5_109.png"];
        UIImage *heart_110 = [UIImage imageNamed:@"h5_110.png"];
        UIImage *heart_111 = [UIImage imageNamed:@"h5_111.png"];
        UIImage *heart_112 = [UIImage imageNamed:@"h5_112.png"];
        UIImage *heart_113 = [UIImage imageNamed:@"h5_113.png"];
        UIImage *heart_114 = [UIImage imageNamed:@"h5_114.png"];
        UIImage *heart_115 = [UIImage imageNamed:@"h5_115.png"];
        UIImage *heart_116 = [UIImage imageNamed:@"h5_116.png"];
        UIImage *heart_117 = [UIImage imageNamed:@"h5_117.png"];
        UIImage *heart_118 = [UIImage imageNamed:@"h5_118.png"];
        UIImage *heart_119 = [UIImage imageNamed:@"h5_119.png"];
        UIImage *heart_120 = [UIImage imageNamed:@"h5_120.png"];
        UIImage *heart_121 = [UIImage imageNamed:@"h5_121.png"];
        UIImage *heart_122 = [UIImage imageNamed:@"h5_122.png"];
        UIImage *heart_123 = [UIImage imageNamed:@"h5_123.png"];
        UIImage *heart_124 = [UIImage imageNamed:@"h5_124.png"];
        UIImage *heart_125 = [UIImage imageNamed:@"h5_125.png"];
        UIImage *heart_126 = [UIImage imageNamed:@"h5_126.png"];
        UIImage *heart_127 = [UIImage imageNamed:@"h5_127.png"];
        UIImage *heart_128 = [UIImage imageNamed:@"h5_128.png"];
        
        hearts = @[heart_16, heart_17, heart_18, heart_19, heart_20, heart_21, heart_22, heart_23, heart_24, heart_25, heart_26, heart_27, heart_28, heart_29, heart_30, heart_31, heart_32, heart_33, heart_34, heart_35, heart_36, heart_37, heart_38, heart_39, heart_40, heart_41, heart_42, heart_43, heart_44, heart_45, heart_46, heart_47, heart_48, heart_49, heart_50, heart_51, heart_52, heart_53, heart_54, heart_55, heart_56, heart_57, heart_58, heart_59, heart_60, heart_61, heart_62, heart_63, heart_64, heart_65, heart_66, heart_67, heart_68, heart_69, heart_70, heart_71, heart_72, heart_73, heart_74, heart_75, heart_76, heart_77, heart_78, heart_79, heart_80, heart_81, heart_82, heart_83, heart_84, heart_85, heart_86, heart_87, heart_88, heart_89, heart_90, heart_91, heart_92, heart_93, heart_94, heart_95, heart_96, heart_97, heart_98, heart_99, heart_100, heart_101, heart_102, heart_103, heart_104, heart_105, heart_106, heart_107, heart_108, heart_109, heart_110, heart_111, heart_112, heart_113, heart_114, heart_115, heart_116, heart_117, heart_118, heart_119, heart_120, heart_121, heart_122, heart_123, heart_124, heart_125, heart_126, heart_127, heart_128];
    }*/

    if (to > maxRes) to = maxRes;
    if (from < minRes) from = minRes;
    
    NSMutableArray *hearts = [[NSMutableArray alloc] init];

    for (int i = from; i <= to; ++i) {
        NSString *imageName = [NSString stringWithFormat:@"h5_%d@2x.png", i];
        [hearts addObject:[UIImage imageNamed:imageName]];
    }
    
    return hearts;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self startRunningSession];
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES]; // prevent the iphone from sleeping
    
    [self.fingerDetectLabel setTextWithChangeAnimation:@"שים את האצבע על המצלמה"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        
        // tab bar configuration
        ///*
        self.tabBarController.tabBar.barTintColor = self.tabBarColor;
        self.tabBarController.tabBar.tintColor = self.tabBarItemColor;
        self.tabBarController.tabBar.translucent = self.isTabBarTranslucent;
        
        // set selected and unselected icons
        UITabBarItem *item0 = [self.tabBarController.tabBar.items objectAtIndex:0];
        UITabBarItem *item1 = [self.tabBarController.tabBar.items objectAtIndex:1];
        UITabBarItem *item2 = [self.tabBarController.tabBar.items objectAtIndex:2];
        
        // set colors of un-selected text
        [item0 setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor grayColor], UITextAttributeTextColor, nil] forState:UIControlStateNormal];
        
        [item1 setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor grayColor], UITextAttributeTextColor, nil] forState:UIControlStateNormal];
        
        [item2 setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor grayColor], UITextAttributeTextColor, nil] forState:UIControlStateNormal];
        
        // this way, the icon gets rendered as it is
        item0.image = [UIImage imageNamed:@"pieChart_Line.png"];
        item1.image = [UIImage imageNamed:@"Heart_line.png"];
        item2.image = [UIImage imageNamed:@"Settings_Line-1.png"];
        //*/
    }
    
    [self stopRunningSession];
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];// enable sleeping

}

//

- (void)applicationWillEnterForeground
{
    if (self.isViewLoaded && self.view.window) {
        [self resetAlgorithm];
        
        [self tabBarConfiguration];
    }
}

- (void)applicationEnteredForeground
{
    if (self.isViewLoaded && self.view.window) {
        [self startRunningSession];
    }
}

- (void)applicationEnteredBackground
{
    if (self.isViewLoaded && self.view.window) {
        [self stopRunningSession];
    }
}

//

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //------------------Notifications BLOCK-----------------
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationEnteredForeground) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationEnteredBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    //------------------------------------------------------

    
    //------------------DESIGN BLOCK-----------------
    
    self.helpButton.tintColor = [UIColor whiteColor];
    
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {

        // tab bar configuration
        ///*
        self.tabBarColor = self.tabBarController.tabBar.barTintColor;
        self.tabBarItemColor = self.tabBarController.tabBar.tintColor;
        self.tabBarTranslucent = self.tabBarController.tabBar.translucent;
        //*/
    }

    // background configuration
    UIImage *backgroundImage = [UIImage imageNamed:@"Background_2.jpg"];
    
    self.backgroundView.backgroundColor = [UIColor colorWithPatternImage:backgroundImage];
    self.backgroundView.alpha = 1;
    
    //------------------------------------------------
    
    // Create the session
    self.session = [[AVCaptureSession alloc] init];
    
    // Configure the session to produce lower resolution video frames
    self.session.sessionPreset = AVCaptureSessionPreset352x288;
    
    // Find a suitable AVCaptureDevice
    self.videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // Create a device input with the device and add it to the session.
    NSError *error = nil;
    self.videoInput = [AVCaptureDeviceInput deviceInputWithDevice:self.videoDevice error:&error];
    
    if (!self.videoInput) {
        // Handling the error appropriately.
    }
    [self.session addInput:self.videoInput];
    
    // Create a VideoDataOutput and add it to the session
    self.frameOutput = [[AVCaptureVideoDataOutput alloc] init];
    
    // Configure your output.
    // Specify the pixel format
    self.frameOutput.videoSettings = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    
    // shouldn't throw away frames
    self.frameOutput.alwaysDiscardsLateVideoFrames = NO;
    
    dispatch_queue_t queue = dispatch_queue_create("frameOutputQueue", NULL);
    [self.frameOutput setSampleBufferDelegate:self queue:queue];
    
    [self.session addOutput:self.frameOutput];
    
    //------------------SOUND BEEP BLOCK-------
    
    NSURL *beepSound = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"beep-7" ofType:@"wav"]];
    self.BeepSound = [[AVAudioPlayer alloc] initWithContentsOfURL:beepSound error:nil];
    self.BeepSound.volume = 0.03;
    
    //-----------------------------------------------
}

//

#define TIME_TO_DETERMINE_BPM_FINAL_RESULT 3 // in seconds

// Delegate routine that is called when a sample buffer was written
- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection
{
    // Create a UIImage from the sample buffer data
    UIImage *image = [self imageFromSampleBuffer:sampleBuffer];
    
    // dispatch all the algorithm functionality to another thread
    dispatch_queue_t algorithmQ = dispatch_queue_create("algorithm thread", NULL);
    dispatch_async(algorithmQ, ^{
        
        UIColor *dominantColor = [image averageColorPrecise];// get the average color from the image
        CGFloat red , green , blue , alpha;
        [dominantColor getRed:&red green:&green blue:&blue alpha:&alpha];
        blue = blue*255.0f;
        green = green*255.0f;
        red = red*255.0f;
        
        [self.algorithm newFrameDetectedWithAverageColor:dominantColor];
        [self.algorithm2 newFrameDetectedWithAverageColor:dominantColor];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            
            if (self.algorithm.isFinalResultDetermined) {
                if (TIME_TO_DETERMINE_BPM_FINAL_RESULT <= [[NSDate date] timeIntervalSinceDate:self.bpmFinalResultFirstTimeDetected]) {
                    
                    //------------------Results BLOCK-----------------

                    self.result.bpm = (int)self.algorithm.bpmLatestResult;
                    self.result = nil;
                    self.algorithm = nil;
                    self.tabBarController.selectedIndex = 0;
                    
                    //------------------------------------------------
                    #warning - incomplete implementation
                }
                self.finalBPMLabel.text = [NSString stringWithFormat:@"Final BPM: %d , BPM2: %d" , (int)self.algorithm.bpmLatestResult , (int)self.algorithm2.bpmLatestResult];
                self.timeTillResultLabel.text = [NSString stringWithFormat:@"time till result: %.01fs" , TIME_TO_DETERMINE_BPM_FINAL_RESULT - [[NSDate date] timeIntervalSinceDate:self.bpmFinalResultFirstTimeDetected]];
                
            } else {
                self.finalBPMLabel.text = @"Final BPM: 0 , BPM2: 0";
                self.timeTillResultLabel.text = @"time till result:   ";
                self.bpmFinalResultFirstTimeDetected = nil;
                #warning - incomplete implementation
            }
            
            if (red < 210) {
                //finger isn't on camera
                
                if (self.settings.autoStopAfter) {
#warning - incomplete implementation
                    
                    if ([[NSDate date] timeIntervalSinceDate:self.algorithmStartTime] > self.settings.autoStopAfter) {
                        if (self.algorithm.isFinalResultDetermined) {
                            //------------------Results BLOCK-----------------
                            
                            self.result.bpm = (int)self.algorithm.bpmLatestResult;
                            self.result = nil;
                            self.algorithm = nil;
                            self.algorithm2 = nil;
                            self.algorithmStartTime = nil;
                            self.bpmFinalResultFirstTimeDetected = nil;
                            self.tabBarController.selectedIndex = 0;
                            
                            //------------------------------------------------
                            return;
                        }
                    }
                }
                
                else {
                    if (self.algorithm.isFinalResultDetermined) {
                        //------------------Results BLOCK-----------------
                        
                        self.result.bpm = (int)self.algorithm.bpmLatestResult;
                        self.result = nil;
                        self.algorithm = nil;
                        self.algorithm2 = nil;
                        self.algorithmStartTime = nil;
                        self.bpmFinalResultFirstTimeDetected = nil;
                        self.tabBarController.selectedIndex = 0;
                        
                        //------------------------------------------------
                        return;
                    }
                }
                
                self.fingerDetectLabel.text = @"שים את האצבע על המצלמה";
                self.bpmLabel.text = [NSString stringWithFormat:@"BPM: %d", 0];
                self.algorithm = nil;
                self.algorithm2 = nil;
                self.algorithmStartTime = nil;
                self.bpmFinalResultFirstTimeDetected = nil;
                return;
            }
            else {
                self.fingerDetectLabel.text = @"";
                //show the time since the start
                self.timeLabel.text = [NSString stringWithFormat:@"time: %.01fs", [[NSDate date] timeIntervalSinceDate:self.algorithmStartTime]];
            }
            
            NSLog([NSString stringWithFormat:@"red: %.01f , green: %.01f , blue: %.01f" , red , green , blue]);
            
            if (self.algorithm.shouldShowLatestResult && self.algorithm2.shouldShowLatestResult) {
                self.bpmLabel.text = [NSString stringWithFormat:@"BPM: %.01f , BPM2: %.01f", self.algorithm.bpmLatestResult , self.algorithm2.bpmLatestResult];
            }
            else if (self.algorithm.shouldShowLatestResult) {
                self.bpmLabel.text = [NSString stringWithFormat:@"BPM: %.01f , BPM2: %d", self.algorithm.bpmLatestResult , 0];
            }
            else if (self.algorithm2.shouldShowLatestResult) {
                self.bpmLabel.text = [NSString stringWithFormat:@"BPM: %d , BPM2: %.01f", 0 , self.algorithm2.bpmLatestResult];
            }
            else {
                self.bpmLabel.text = [NSString stringWithFormat:@"BPM: %d , BPM2: %d", 0 , 0];
            }
            
            [self animateHeart];
        });
        
        [self playBeepSound];
    });
}

//

- (void)addAttributes:(NSDictionary *)attributes
              toLabel:(UILabel *)label
              atRange:(NSRange)range
{
    if (range.location != NSNotFound) {
        NSMutableAttributedString *mat = [label.attributedText mutableCopy];
        [mat addAttributes:attributes range:range];
        label.attributedText = mat;
    }
}

- (void)addAttributes:(NSDictionary *)attributes toLabel:(UILabel *)label
{
    NSString *text = [label.attributedText string];
    NSRange range = [text rangeOfString:text];
    
    [self addAttributes:attributes toLabel:label atRange:range];
}

- (void)playBeepSound
{
    if (self.settings.beepWithPulse){
        if (self.algorithm.isPeakInLastFrame && !self.algorithm.isMissedTheLastPeak) {
            [self.BeepSound play];
        }
    }
}

- (void)animateHeart
{
    if (self.algorithm.isPeakInLastFrame && !self.algorithm.isMissedTheLastPeak) {
#warning - cool heartAnimation. still gotta customize it according to the heart beat
        [self.heart stopAnimating];
        
        NSArray *hearts = [self heartsFromRes:64 toRes:108];
        
        NSArray *reversedHearts = [[hearts reverseObjectEnumerator] allObjects];
        
        self.heart.animationImages = [hearts arrayByAddingObjectsFromArray:reversedHearts];
        self.heart.animationDuration = 0.35;
        self.heart.animationRepeatCount = 1;
        
        [self.heart startAnimating];
        
        /*[UIView transitionWithView:self.timeTillResultLabel
                          duration:0.2
                           options:UIViewAnimationOptionCurveEaseIn
                        animations:^{
                            CGFloat fontSize = [UIFont systemFontSize];
                            
                            NSDictionary *attributes = [self.timeTillResultLabel.attributedText attributesAtIndex:0 effectiveRange:NULL];
                            UIFont *existingFont = attributes[NSFontAttributeName];
                            if (existingFont)
                                fontSize = existingFont.pointSize;
                            
                            UIFont *font = [self.timeTillResultLabel.font fontWithSize:fontSize*2];
                            [self addAttributes:@{ NSFontAttributeName : font }
                                        toLabel:self.timeTillResultLabel];
                        }
                        completion:NULL];*/
    }
}

- (void)heartAnimation:(UIImageView *)animatedImage
{
    ///*
    CGFloat gradientWidth = 2.0;
    CGFloat transparency = 0.6;
    
    CAGradientLayer *gradientMask = [CAGradientLayer layer];
    gradientMask.frame = animatedImage.bounds;
    CGFloat gradientSize = gradientWidth / animatedImage.frame.size.width;
    UIColor *gradient = [UIColor colorWithRed:0.9 green:0 blue:0 alpha:transparency];
    UIView *superview = animatedImage.superview;
    
    NSArray *startLocations = @[[NSNumber numberWithFloat:0.0f], [NSNumber numberWithFloat:(gradientSize / 2)], [NSNumber numberWithFloat:gradientSize]];
    NSArray *endLocations = @[[NSNumber numberWithFloat:(1.0f - gradientSize)], [NSNumber numberWithFloat:(1.0f -(gradientSize / 2))], [NSNumber numberWithFloat:1.0f]];
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"locations"];
    
    gradientMask.colors = @[(id)gradient.CGColor, (id)[UIColor redColor].CGColor, (id)gradient.CGColor];
    gradientMask.locations = startLocations;
    gradientMask.startPoint = CGPointMake(0 - (gradientSize * 2), .5);
    gradientMask.endPoint = CGPointMake(1 + gradientSize, .5);
    
    [animatedImage removeFromSuperview];
    animatedImage.layer.mask = gradientMask;
    [superview addSubview:animatedImage];
    
    animation.fromValue = startLocations;
    animation.toValue = endLocations;
    animation.repeatCount = HUGE_VALF;
    animation.duration  = 3.0f;
    
    [gradientMask addAnimation:animation forKey:@"animateGradient"];
    //*/
    /*
    [UIView transitionWithView:self.beatingHeart
                      duration:1
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        self.beatingHeart.layer.shadowColor = [[UIColor redColor] CGColor];
                        self.beatingHeart.layer.shadowOpacity = 1.0;
                        self.beatingHeart.layer.shadowRadius = 3;
                        self.beatingHeart.layer.zPosition = 1;
                    }
                    completion:^(BOOL fin){
                        if (fin) {
                            [UIView transitionWithView:self.beatingHeart
                                              duration:0.3
                                               options:UIViewAnimationOptionTransitionCrossDissolve
                                            animations:^{
                                                self.beatingHeart.layer.shadowOpacity = 0;
                                                self.beatingHeart.layer.shadowRadius = 0;
                                            }
                                            completion:NULL];
                        }
                    }];
     */
}

//

// Create a UIImage from sample buffer data
- (UIImage *)imageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer
{
    // Get a CMSampleBuffer's Core Video image buffer for the media data
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    
    // Lock the base address of the pixel buffer
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    // Get the number of bytes per row for the pixel buffer
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    
    // Get the number of bytes per row for the pixel buffer
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    
    // Get the pixel buffer width and height
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    // Create a device-dependent RGB color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // Create a bitmap graphics context with the sample buffer data
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8,
                                                 bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast);
    
    // Create a Quartz image from the pixel data in the bitmap graphics context
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    
    // Unlock the pixel buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    
    // Free up the context and color space
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    // Create an image object from the Quartz image
    UIImage *image = [UIImage imageWithCGImage:quartzImage];
    
    // Release the Quartz image
    CGImageRelease(quartzImage);
    
    return image;
}

@end
