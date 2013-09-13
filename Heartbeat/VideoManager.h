//
//  VideoManager.h
//  Heartbeat
//
//  Created by michael leybovich on 9/13/13.
//  Copyright (c) 2013 michael leybovich. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface VideoManager : AVCaptureVideoPreviewLayer

- (void)setupCaptureSession;

@end
