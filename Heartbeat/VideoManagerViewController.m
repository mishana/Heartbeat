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
@property (strong , nonatomic) NSDate *algorithmStartTime;
@property (strong, nonatomic) Settings *settings;

// view Outlets
@property (weak, nonatomic) IBOutlet UILabel *bpmLabel;
@property (weak, nonatomic) IBOutlet UILabel *fingerDetectLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *finalBPMLabel;

@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (weak, nonatomic) IBOutlet UIImageView *beatingHeart;

// tab bar configuration properties
@property (strong, nonatomic) UIColor *tabBarColor;
@property (strong, nonatomic) UIColor *tabBarItemColor;
@property (nonatomic, getter = isTabBarTranslucent) BOOL tabBarTranslucent;

@end

@implementation VideoManagerViewController

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
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

- (Algorithm *)algorithm
{
    if (!_algorithm) {
        _algorithm = [[Algorithm alloc] init];
    }
    return _algorithm;
}

//

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.settings = nil;
    self.algorithmStartTime = nil;
    self.algorithm = nil;
    
    // tab bar configuration
    
    self.tabBarController.tabBar.barTintColor = [UIColor colorWithRed:0.075 green:0.439 blue:0.753 alpha:1.0];
    self.tabBarController.tabBar.tintColor = [UIColor whiteColor];
    self.tabBarController.tabBar.translucent = NO;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    dispatch_queue_t sessionQ = dispatch_queue_create("session thread", NULL);
    
    dispatch_async(sessionQ, ^{
        if ([self.videoDevice hasTorch] && [self.videoDevice hasFlash]){
            [self.videoDevice lockForConfiguration:nil];
            [self.videoDevice setTorchMode:AVCaptureTorchModeOn];
            [self.videoDevice setFlashMode:AVCaptureFlashModeOn];
            [self.videoDevice unlockForConfiguration];
        }
        [self.session startRunning];
    });
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // tab bar configuration
    self.tabBarController.tabBar.barTintColor = self.tabBarColor;
    self.tabBarController.tabBar.tintColor = self.tabBarItemColor;
    self.tabBarController.tabBar.translucent = self.isTabBarTranslucent;
    
    dispatch_queue_t sessionQ = dispatch_queue_create("session thread", NULL);
    
    dispatch_async(sessionQ, ^{
        [self.session stopRunning];
    });
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
}

//

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //------------------DESIGN BLOCK-----------------
    
    // tab bar configuration
    self.tabBarColor = self.tabBarController.tabBar.barTintColor;
    self.tabBarItemColor = self.tabBarController.tabBar.tintColor;
    self.tabBarTranslucent = self.tabBarController.tabBar.translucent;

    // background configuration
    UIImage *backgroundImage = [UIImage imageNamed:@"Background_2.jpg"];
    /*UIImageView *backgroundView = [[UIImageView alloc] initWithImage:backgroundImage];
    [self.view addSubview:backgroundView];*/
    
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
    
    /*// turn flash on
    if ([self.videoDevice hasTorch] && [self.videoDevice hasFlash]){
        [self.videoDevice lockForConfiguration:nil];
        [self.videoDevice setTorchMode:AVCaptureTorchModeOn];
        [self.videoDevice setFlashMode:AVCaptureFlashModeOn];
        [self.videoDevice unlockForConfiguration];
    }
    //
    
    [self.session startRunning];*/
}

//

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
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            
            if (self.algorithm.isFinalResultDetermined) {
                self.finalBPMLabel.text = [NSString stringWithFormat:@"Final BPM: %d" , (int)self.algorithm.bpmLatestResult];
                #warning - incomplete implementation
            } else {
                self.finalBPMLabel.text = @"Final BPM:   ";
                #warning - incomplete implementation
            }
            
            if (self.settings.autoStopAfter) {
                if ([[NSDate date] timeIntervalSinceDate:self.algorithmStartTime] > self.settings.autoStopAfter) {
                    #warning - incomplete implementation
                }
            }
            
            if (red < 210/* || green < 4*/) {
                //finger isn't on camera
                self.fingerDetectLabel.text = @"שים את האצבע על המצלמה";
                self.bpmLabel.text = [NSString stringWithFormat:@"BPM: %d", 0];
                self.algorithm = nil;
                self.algorithmStartTime = nil;
                return;
                
            }
            else {
                self.fingerDetectLabel.text = @"האלגוריתם התחיל";
                //show the time since the start
                self.timeLabel.text = [NSString stringWithFormat:@"time: %.01fs", [[NSDate date] timeIntervalSinceDate:self.algorithmStartTime]];
            }
            
            NSLog([NSString stringWithFormat:@"red: %.01f , green: %.01f , blue: %.01f" , red , green , blue]);
            
            self.bpmLabel.text = [NSString stringWithFormat:@"BPM: %.01f", self.algorithm.bpmLatestResult];
            
        });
        
        [self playBeepSound];
        
    });
    
}

//

- (void)playBeepSound
{
    if (self.settings.beepWithPulse && self.algorithm.isPeakInLastFrame){
        [self.BeepSound play];
    }
}

- (void)heartAnimation
{
    /*
    [UIView transitionWithView:self.beatingHeart
                      duration:0.2
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{ self.beatingHeart.tintColor = [UIColor redColor];}
                    completion:NULL];
    self.beatingHeart.tintColor = [UIColor grayColor];
     */
}

//

// Create a UIImage from sample buffer data
- (UIImage *) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer
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
