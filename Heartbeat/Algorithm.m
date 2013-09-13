//
//  Algorithm.m
//  Heartbeat
//
//  Created by Or Maayan on 9/13/13.
//  Copyright (c) 2013 michael leybovich. All rights reserved.
//

#import "Algorithm.h"
#import "Butterworth.h"
#import "HelpMethods.h"

@interface Algorithm()
@property (nonatomic , readwrite) BOOL isCalibrationOver;
@property (nonatomic , readwrite) BOOL isFinalResultDetermined;
@property (nonatomic , readwrite) NSUInteger bpmFinalResult;
@end

@implementation Algorithm

- (NSUInteger)frameRate{
    if (!_frameRate) {
        _frameRate = 30;
    }
    return _frameRate;
}

- (NSUInteger)WindowSize{
    return 12;
}

- (NSUInteger)calibrationDuration{
    return 150;
}

- (NSUInteger)WindowSizeForAverageCalculation{
    return 150;
}

- (double**)buttterworthValues{
    double frequencyBands[2] = {0.05 , 0.2};
    return butter(frequencyBands, 3);
}

- (CGFloat)getColorValueFrom:(UIColor *)color
{
    // default value is green (for iphone 5)
    CGFloat green;
    
    if ([color getRed:nil green:&green blue:nil alpha:nil]) {
        return green;
    }
    else {
        //error
        NSLog(@"color error");
        return 0;
    }
}

- (void)newFrameDetectedWithDominantColor:(UIColor *)color
{
    self.framesCounter++;
    
    // ...
}

@end
