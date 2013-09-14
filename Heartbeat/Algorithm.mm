//
//  Algorithm.m
//  Heartbeat
//
//  Created by Or Maayan on 9/13/13.
//  Copyright (c) 2013 michael leybovich. All rights reserved.
//

#import "Algorithm.h"
#import "Butterworth.h"

@interface Algorithm()
@property (nonatomic , readwrite) BOOL isCalibrationOver;
@property (nonatomic , readwrite) BOOL isFinalResultDetermined;
@property (nonatomic , readwrite) NSUInteger bpmLatestResult;
@end

@implementation Algorithm

// Properties

#define FPS 30
#define WINDOW_SIZE 12
#define CALIBRATION_DURATION 150
#define WINDOW_SIZE_FOR_AVERAGE_CALCULATION 150

- (NSUInteger)frameRate{
    if (!_frameRate) {
        _frameRate = FPS;
    }
    return _frameRate;
}

- (NSUInteger)WindowSize{
    if (!_WindowSize) {
        _WindowSize = WINDOW_SIZE;
    }
    return _WindowSize;
}

- (NSUInteger)calibrationDuration{
    if (!_calibrationDuration) {
        _calibrationDuration = CALIBRATION_DURATION;
    }
    return _calibrationDuration;
}

- (NSUInteger)WindowSizeForAverageCalculation{
    if (!_WindowSizeForAverageCalculation) {
        _WindowSizeForAverageCalculation = WINDOW_SIZE_FOR_AVERAGE_CALCULATION;
    }
    return _WindowSizeForAverageCalculation;
}

- (NSMutableArray *)points
{
    if (!_points) {
        _points = [NSMutableArray array];
    }
    return _points;
}

- (NSMutableArray *)bpmValues
{
    if (!_bpmValues) {
        _bpmValues = [NSMutableArray arrayWithCapacity:WINDOW_SIZE_FOR_AVERAGE_CALCULATION+1];
    }
    return _bpmValues;
}

- (NSMutableArray *)bpmAverageValues
{
    if (!_bpmAverageValues) {
        _bpmAverageValues = [NSMutableArray array];
    }
    return _bpmAverageValues;
}

- (NSMutableArray *)isPeak
{
    if (!_isPeak) {
        _isPeak = [NSMutableArray array];
    }
    return _isPeak;
}

#define FILTER_ORDER 3
#define FILTER_LOWER_BAND 0.05
#define FILTER_UPPER_BAND 0.2

- (double**)buttterworthValues{
    if (!_buttterworthValues) {
        double frequencyBands[2] = {FILTER_LOWER_BAND , FILTER_UPPER_BAND};
        _buttterworthValues = butter(frequencyBands, FILTER_ORDER);
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
    if (self.isCalibrationOver && (fabs(self.bpmLatestResult - [self.bpmAverageValues[0] doubleValue]) <= FINAL_RESULT_MARGIN)) {
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

//

- (NSArray *)getLatestPoints:(NSUInteger)numOfPoints{
    NSRange range;
    range.length = numOfPoints;
    range.location = [self.points count] - range.length;
    return [self.points objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:range]];
}

- (void)convertObjectsFromArray:(NSArray *)arrayOfNSNumbers to:(double *)arrayOfDoubles
{
    for (int i=0; i<[arrayOfNSNumbers count]; i++) {
        arrayOfDoubles[i] = [arrayOfNSNumbers[i] doubleValue];
    }
}

- (BOOL)isPeak:(double *)graph :(int)window
{
    // graph size should be window*2+1
    // window must be positive
    double middlePoint = graph[window];
    for (int i=0; i < window; i++) {
        if (middlePoint <= graph[i]) { // the middle point should be larger from all points detected before it
            return NO;
        }
    }
    for (int i=window+1; i <= 2*window; i++) {
        if (middlePoint < graph[i]) {// the middle point should be larger or equal to all points detected after it
            return NO;
        }
    }
    return YES;
}

- (double)mean:(double *)points withSize:(int)n
{
    // points is NSArray of NSNumbers of doubles
    
    double sum = 0;
    for (int i=0 ; i<n ; i++) {
        sum += points[i];
    }
    return sum/n;
}

- (void)Substract:(double)num fromArray:(double *)points withSize:(int)n
{
    for (int i=0 ; i<n ; i++) {
        points[i] -= num;
        //points[i] *= -1;//*
    }
}

//

#define DEFAULT_BPM_VALUE 72

- (void)newFrameDetectedWithAverageColor:(UIColor *)color
{
    if (self.isFinalResultDetermined) {
        // do nothing
        return;
    }
    
    self.framesCounter++;
    
    if (self.framesCounter <= 2*self.WindowSize || !self.firstPeakPlace) {
        [self.points addObject:@([self getColorValueFrom:color])];
        [self.isPeak addObject:@(NO)];
        [self.bpmValues addObject:@(DEFAULT_BPM_VALUE)];
        [self.bpmAverageValues addObject:@(DEFAULT_BPM_VALUE)];
        
        if (self.framesCounter <= 2*self.WindowSize) {
            return;// continue
        }
        
        int dynamicWindowSize = self.WindowSize*2+1;
        double x[dynamicWindowSize] , y[dynamicWindowSize];
        NSArray *dynamicWindowArray = [self getLatestPoints:dynamicWindowSize];
        [self convertObjectsFromArray:dynamicWindowArray to:x];
        [self Substract:[self mean:x withSize:dynamicWindowSize] fromArray:x withSize:dynamicWindowSize];
        filter(2*FILTER_ORDER, self.buttterworthValues[1], self.buttterworthValues[0], dynamicWindowSize, x, y);
        
        // self.framesCounter-self.WindowSize-1 is i-w in the script
        self.isPeak[self.framesCounter-self.WindowSize-1] = @([self isPeak:x :self.WindowSize]);
        
        self.numOfPeaks += [self.isPeak[self.framesCounter-self.WindowSize-1] intValue];
        
        if ([self.isPeak[self.framesCounter-self.WindowSize-1] boolValue]) {
            self.firstPeakPlace = self.framesCounter-self.WindowSize-1;
            self.bpmValues[self.framesCounter-self.WindowSize-1] = @(100);
            self.bpmAverageValues[self.framesCounter-self.WindowSize-1] = @(100);
            
        }
        
        return;// continue
    }
    
    // left to implement...
    
    
    
    
}

@end
