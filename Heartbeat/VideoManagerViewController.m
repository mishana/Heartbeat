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

@interface VideoManagerViewController ()
@property (nonatomic,strong) AVCaptureSession * session;
@property (strong) AVCaptureDevice * videoDevice;
@property (strong) AVCaptureDeviceInput * videoInput;
@property (strong) AVCaptureVideoDataOutput * frameOutput;
@property (nonatomic,strong) IBOutlet UIImageView* imgView;
@property (nonatomic , strong) Algorithm *algorithm;
@end

@implementation VideoManagerViewController

- (Algorithm *)algorithm
{
    if (!_algorithm) {
        _algorithm = [[Algorithm alloc] init];
    }
    return _algorithm;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
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
        NSLog([NSString stringWithFormat:@"red: %.01f , green: %.01f , blue: %.01f" , red*255.0f , green*255.0f , blue*255.0f]);
        
        [self.algorithm newFrameDetectedWithAverageColor:dominantColor];
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
