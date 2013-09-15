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
#define CALIBRATION_DURATION 120
#define WINDOW_SIZE_FOR_AVERAGE_CALCULATION 120

- (CGFloat)frameRate{
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
        _bpmValues = [NSMutableArray array];
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
    if (self.isCalibrationOver && (fabs(self.bpmLatestResult - [self.bpmAverageValues[self.framesCounter - self.calibrationDuration] doubleValue]) <= FINAL_RESULT_MARGIN)) {
        return _isFinalResultDetermined = YES;
    }
    else {
        _isFinalResultDetermined = NO;
    }
    return _isFinalResultDetermined;
}

- (NSUInteger)bpmLatestResult
{
    if ([self.bpmAverageValues count]) {
        return [[self.bpmAverageValues lastObject] intValue];
    }
    return 0;
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
        //return;
    }
    // initial
    self.framesCounter++;
    [self.points addObject:@([self getColorValueFrom:color])];
    [self.isPeak addObject:@(NO)];
    [self.bpmValues addObject:@(DEFAULT_BPM_VALUE)];
    [self.bpmAverageValues addObject:@(DEFAULT_BPM_VALUE)];
    //
    // renaming local parameters
    int i = self.framesCounter;
    int w = self.WindowSize;
    
    //
    
    if (i <= 2*w || !self.firstPeakPlace) {

        if (i <= 2*w) {
            return;// continue
        }
        
        int dynamicWindowSize = w*2+1;
        double x[dynamicWindowSize] , y[dynamicWindowSize];
        NSArray *dynamicWindowArray = [self getLatestPoints:dynamicWindowSize];
        [self convertObjectsFromArray:dynamicWindowArray to:x];
        [self Substract:[self mean:x withSize:dynamicWindowSize] fromArray:x withSize:dynamicWindowSize];
        filter(2*FILTER_ORDER, self.buttterworthValues[1], self.buttterworthValues[0], dynamicWindowSize, x, y);
        
        // i-w-1 is i-w in the script
        self.isPeak[i-w-1] = @([self isPeak:x :w]);
        
        self.numOfPeaks += [self.isPeak[i-w-1] intValue];
        
        if ([self.isPeak[i-w-1] boolValue]) {
            self.firstPeakPlace = i-w-1;
            self.bpmValues[i-w-1] = @(100);
            self.bpmAverageValues[i-w-1] = @(100);
            
        }
        
        return;// continue
    }
    
    // left to implement...
    
    if (i < self.calibrationDuration + (self.firstPeakPlace + w) -1) {
        
        int dynamicWindowSize = w*2+1;
        double x[dynamicWindowSize] , y[dynamicWindowSize];
        NSArray *dynamicWindowArray = [self getLatestPoints:dynamicWindowSize];
        [self convertObjectsFromArray:dynamicWindowArray to:x];
        [self Substract:[self mean:x withSize:dynamicWindowSize] fromArray:x withSize:dynamicWindowSize];
        filter(2*FILTER_ORDER, self.buttterworthValues[1], self.buttterworthValues[0], dynamicWindowSize, x, y);
        
        // i-w-1 is i-w in the script
        self.isPeak[i-w-1] = @([self isPeak:x :w]);
        
        self.numOfPeaks += [self.isPeak[i-w-1] intValue];
        
        NSUInteger frames = i - self.firstPeakPlace;
        if (frames > self.calibrationDuration) {
            frames = self.calibrationDuration;
        }
        
        self.bpmValues[i-w-1] = @((self.numOfPeaks/(frames/self.frameRate))*60);
        
        int k = i-(self.firstPeakPlace+w)-1;
        self.bpmAverageValues[i-w-1] = @([self.bpmAverageValues[i-w-2] doubleValue] * k/(k+2) + [self.bpmValues[i-w-1] doubleValue] * 2/(k+2));
    }
    else {
        //calibration is over
        
        int dynamicWindowSize = w*2+1;
        double x[dynamicWindowSize] , y[dynamicWindowSize];
        NSArray *dynamicWindowArray = [self getLatestPoints:dynamicWindowSize];
        [self convertObjectsFromArray:dynamicWindowArray to:x];
        [self Substract:[self mean:x withSize:dynamicWindowSize] fromArray:x withSize:dynamicWindowSize];
        filter(2*FILTER_ORDER, self.buttterworthValues[1], self.buttterworthValues[0], dynamicWindowSize, x, y);
        
        // i-w-1 is i-w in the script
        self.isPeak[i-w-1] = @([self isPeak:x :w]);
        
        self.numOfPeaks += [self.isPeak[i-w-1] intValue] - [self.isPeak[i-w-1-self.calibrationDuration] intValue];
        
        NSUInteger frames = self.calibrationDuration;
        
        self.bpmValues[i-w-1] = @((self.numOfPeaks/(frames/self.frameRate))*60);
        
        double tempSum = 0;
        for (int j = 1; j <= self.WindowSizeForAverageCalculation; j++) {
            tempSum += [self.bpmValues[i-w-1-self.WindowSizeForAverageCalculation+j] doubleValue];
        }
        double average_bpm = tempSum/self.WindowSizeForAverageCalculation;
        
        int k = self.calibrationDuration + (self.firstPeakPlace + w) -1 + 1;// 1 simulate the weight of the calibration
        
        self.bpmAverageValues[i-w-1] = @([self.bpmAverageValues[i-w-2] doubleValue] * k/(k+2) + average_bpm * 2/(k+2));
        
        if (i == 450) {
            self.bpmLatestResult;
            
        }
        
    }
    
    
}

@end
