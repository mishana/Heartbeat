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

@interface VideoManagerViewController ()
@property (nonatomic,strong) AVCaptureSession * session;
@property (strong) AVCaptureDevice * videoDevice;
@property (strong) AVCaptureDeviceInput * videoInput;
@property (strong) AVCaptureVideoDataOutput * frameOutput;
@property (nonatomic , strong) Algorithm *algorithm;
@property (weak, nonatomic) IBOutlet UILabel *bpmLabel;
@property (weak, nonatomic) IBOutlet UILabel *fingerDetectLabel;
@property (strong , nonatomic) NSDate *algorithmStartTime;
@property (strong, nonatomic) Settings *settings;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIView *backgroundView;

@end

@implementation VideoManagerViewController

- (Settings *)settings
{
    if (!_settings) _settings = [Settings currentSettings];
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

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.settings = nil;
    self.algorithm = nil;
    [self.session stopRunning];
}

- (void)viewDidAppear:(BOOL)animated
{
    if ([self.videoDevice hasTorch] && [self.videoDevice hasFlash]){
        [self.videoDevice lockForConfiguration:nil];
        [self.videoDevice setTorchMode:AVCaptureTorchModeOn];
        [self.videoDevice setFlashMode:AVCaptureFlashModeOn];
        [self.videoDevice unlockForConfiguration];
    }
    [self.session startRunning];
}

- (IBAction)turnOffFlash
{
    [self.session stopRunning];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // background configuration
    UIImage *backgroundImage = [UIImage imageNamed:@"stawberry_iPhone.jpg"];
    /*UIImageView *backgroundView = [[UIImageView alloc] initWithImage:backgroundImage];
    [self.view addSubview:backgroundView];*/
    
    self.backgroundView.backgroundColor = [UIColor colorWithPatternImage:backgroundImage];
    self.backgroundView.alpha = 1;
    
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
    
    // turn flash on
    if ([self.videoDevice hasTorch] && [self.videoDevice hasFlash]){
        [self.videoDevice lockForConfiguration:nil];
        [self.videoDevice setTorchMode:AVCaptureTorchModeOn];
        [self.videoDevice setFlashMode:AVCaptureFlashModeOn];
        [self.videoDevice unlockForConfiguration];
    }
    //
    
    [self.session startRunning];
    
    // should call [self.session stopRunning]
    // also should close the flash
    
    //[self.session stopRunning];
    
}

// Delegate routine that is called when a sample buffer was written
- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection
{
    // Create a UIImage from the sample buffer data
    UIImage *image = [self imageFromSampleBuffer:sampleBuffer];
    
#warning - incomplete implementation
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIColor *dominantColor = [image averageColorPrecise];
        
        CGFloat red , green , blue , alpha;
        [dominantColor getRed:&red green:&green blue:&blue alpha:&alpha];
        blue = blue*255.0f;
        green = green*255.0f;
        red = red*255.0f;
        
        if (red < 210/* || green < 4*/) {
            //finger isn't on camera
            self.fingerDetectLabel.text = @"שים את האצבע על המצלמה";
            self.bpmLabel.text = [NSString stringWithFormat:@"BPM: %.01f", 0];
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
        
        [self.algorithm newFrameDetectedWithAverageColor:dominantColor];
        
        self.bpmLabel.text = [NSString stringWithFormat:@"BPM: %.01f", self.algorithm.bpmLatestResult];
        
        
    });
    
    //
    
}

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
