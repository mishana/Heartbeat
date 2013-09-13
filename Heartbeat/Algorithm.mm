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
@property (nonatomic , readwrite) NSUInteger bpmLatestResult;
@end

@implementation Algorithm

// Properties

- (NSUInteger)frameRate{
    if (!_frameRate) {
        _frameRate = 30;
    }
    return _frameRate;
}

- (NSUInteger)WindowSize{
    if (!_WindowSize) {
        _WindowSize = 12;
    }
    return _WindowSize;
}

- (NSUInteger)calibrationDuration{
    if (!_calibrationDuration) {
        _calibrationDuration = 150;
    }
    return _calibrationDuration;
}

- (NSUInteger)WindowSizeForAverageCalculation{
    if (!_WindowSizeForAverageCalculation) {
        _WindowSizeForAverageCalculation = 150;
    }
    return _WindowSizeForAverageCalculation;
}

- (double**)buttterworthValues{
    if (!_buttterworthValues) {
        double frequencyBands[2] = {0.05 , 0.2};
        _buttterworthValues = butter(frequencyBands, 3);
    }
    return _buttterworthValues;
}

// outside API

- (BOOL)isCalibrationOver{
    if (self.framesCounter > self.calibrationDuration) {
        return _isCalibrationOver = YES;
    }
    else {
        _isCalibrationOver = NO;
    }
    return _isCalibrationOver;
}

#define FINAL_RESULT_MARGIN 1

- (BOOL)isFinalResultDetermined{
    //* shouldn't be called if bpmAverageValues is empty
    if (self.bpmLatestResult - [self.bpmAverageValues[0] doubleValue] <= FINAL_RESULT_MARGIN) {
        return _isFinalResultDetermined = YES;
    }
    else {
        _isFinalResultDetermined = NO;
    }
    return _isFinalResultDetermined;
}

//

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
