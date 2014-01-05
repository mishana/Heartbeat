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
#import "TKProgressCircleView.h"

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

@property (nonatomic,strong) TKProgressCircleView *progressCircle;

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

#pragma mark - Properties

- (TKProgressCircleView *)progressCircle
{
	if(!_progressCircle) {
        _progressCircle = [[TKProgressCircleView alloc] init];
        _progressCircle.center = CGPointMake(self.view.bounds.size.width * 0.5, 127);
        //_progressCircle.center = CGPointMake(self.view.bounds.size.width/4, self.view.bounds.size.height/6);

    }
	return _progressCircle;
}

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
        //_algorithm2.windowSize = 9;
        _algorithm2.filterWindowSize = 60;
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

#pragma mark - View Lifecycle

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self resetAlgorithm];
    
    [self tabBarConfiguration];
    
    [self.progressCircle setProgress:0];
    self.bpmLabel.text = @"00";
    self.fingerDetectLabel.font = [self.fingerDetectLabel.font fontWithSize:20];
}

- (NSArray *)heartsFromRes:(int)from toRes:(int)to
{
    int minRes = 16;
    int maxRes = 128;
    
    if (to > maxRes) to = maxRes;
    if (from < minRes) from = minRes;
    
    NSMutableArray *hearts = [[NSMutableArray alloc] init];

    // hearts array initialization
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
        [item0 setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor grayColor], NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
        
        [item1 setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor grayColor], NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
        
        [item2 setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor grayColor], NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
        
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
        
        [self.fingerDetectLabel setTextWithChangeAnimation:@"שים את האצבע על המצלמה"];
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
    
    NSURL *beepSound = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"pulse-beep" ofType:@"wav"]];
    self.BeepSound = [[AVAudioPlayer alloc] initWithContentsOfURL:beepSound error:nil];
    self.BeepSound.volume = 0.05;
    
    //-----------------------------------------------
    
    self.bpmLabel.font = [UIFont fontWithName:@"DBLCDTempBlack" size:70.0];
    
    [self.view addSubview:self.progressCircle];
}

#pragma mark - Algorithm & Animation

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
                    
                    [self.progressCircle setProgress:0 animated:YES];
                    
                    //------------------------------------------------
                    #warning - incomplete implementation
                }
                //self.finalBPMLabel.text = [NSString stringWithFormat:@"Final BPM: %d , BPM2: %d" , (int)self.algorithm.bpmLatestResult , (int)self.algorithm2.bpmLatestResult];
                self.finalBPMLabel.text = @"";
                
                //self.timeTillResultLabel.text = [NSString stringWithFormat:@"time till result: %.01fs" , TIME_TO_DETERMINE_BPM_FINAL_RESULT - [[NSDate date] timeIntervalSinceDate:self.bpmFinalResultFirstTimeDetected]];
                self.timeTillResultLabel.text = @"";
                
                [self.progressCircle setProgress:[[NSDate date] timeIntervalSinceDate:self.bpmFinalResultFirstTimeDetected] / TIME_TO_DETERMINE_BPM_FINAL_RESULT animated:YES];
                
            } else {
                //self.finalBPMLabel.text = @"Final BPM: 0 , BPM2: 0";
                self.finalBPMLabel.text = @"";
                
                //self.timeTillResultLabel.text = @"time till result:   ";
                self.timeTillResultLabel.text = @"";
                
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
                            
                            [self.progressCircle setProgress:0 animated:YES];

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
                        
                        [self.progressCircle setProgress:0 animated:YES];
                        
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
                
                self.fingerDetectLabel.font = [self.fingerDetectLabel.font fontWithSize:20];
                self.fingerDetectLabel.text = @"שים את האצבע על המצלמה";
                
                self.bpmLabel.text = @"00";
                [self.progressCircle setTwirlMode:NO];
                [self.progressCircle setProgress:0];

                //self.bpmLabel.text = @"אין דופק";
                //self.bpmLabel.text = [NSString stringWithFormat:@"BPM: %d", 0];
                self.algorithm = nil;
                self.algorithm2 = nil;
                self.algorithmStartTime = nil;
                self.bpmFinalResultFirstTimeDetected = nil;
                return;
            }
            else {
                self.fingerDetectLabel.text = @"";
                //show the time since the start
                //self.timeLabel.text = [NSString stringWithFormat:@"time: %.01fs", [[NSDate date] timeIntervalSinceDate:self.algorithmStartTime]];
                self.timeLabel.text = @"";
            }
            
            NSLog([NSString stringWithFormat:@"red: %.01f , green: %.01f , blue: %.01f" , red , green , blue]);
            
            /*if (self.algorithm.shouldShowLatestResult && self.algorithm2.shouldShowLatestResult) {
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
            }*/
            
            if (self.algorithm.shouldShowLatestResult) {
                self.bpmLabel.text = [NSString stringWithFormat:@"%.0f", self.algorithm.bpmLatestResult];
                [self.progressCircle setTwirlMode:NO];
                
                self.fingerDetectLabel.font = [self.fingerDetectLabel.font fontWithSize:24];
                self.fingerDetectLabel.text = @"מחשב דופק";
            }
            else {
                [self.progressCircle setTwirlMode:YES];
                
                self.fingerDetectLabel.font = [self.fingerDetectLabel.font fontWithSize:24];
                self.fingerDetectLabel.text = @"מחפש דופק";
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

- (IBAction)done:(UIStoryboardSegue *)segue {
    // do nothing
}

@end
