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
#define WINDOW_SIZE_FOR_FILTER_CALCULATION 60// should be at least WINDOW_SIZE*2
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
        return green*255.0f;
    }
    else {
        //error
        NSLog(@"color error");
        return 0;
    }
}

//

- (void)getLatestPoints:(NSUInteger)numOfPoints andSetIntoDoubleArray:(double *)arrayOfDoubles{
    NSRange range;
    range.length = numOfPoints;
    range.location = [self.points count] - range.length;
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:range];
    
    NSUInteger index = [indexSet firstIndex];
    for (int i=0; index != NSNotFound ; i++ , index = [indexSet indexGreaterThanIndex: index]) {
        arrayOfDoubles[i] = [self.points[index] doubleValue];
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
        points[i] *= -1;//*
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

    // renaming local parameters
    int i = self.framesCounter;
    int w = self.WindowSize;
    int calib = self.calibrationDuration;
    
    //
    if (i <= WINDOW_SIZE_FOR_FILTER_CALCULATION) {
        return;// continue, nothing to be done yet
    }
    
    if (!self.firstPeakPlace) {
        
        int dynamicWindowSize = WINDOW_SIZE_FOR_FILTER_CALCULATION+1;
        double x[dynamicWindowSize] , y[dynamicWindowSize];
        [self getLatestPoints:dynamicWindowSize andSetIntoDoubleArray:x];
        [self Substract:[self mean:x withSize:dynamicWindowSize] fromArray:x withSize:dynamicWindowSize];
        filter(2*FILTER_ORDER, self.buttterworthValues[1], self.buttterworthValues[0], dynamicWindowSize, x, y);
        
        double *z = y+dynamicWindowSize-2*w-1;
        self.isPeak[i-w-1] = @([self isPeak:z :w]);

        self.numOfPeaks += [self.isPeak[i-w-1] boolValue];
        
        if ([self.isPeak[i-w-1] boolValue]) {
            self.firstPeakPlace = i-w-1;
            self.bpmValues[i-w-1] = @(60*self.frameRate/w);
            self.bpmAverageValues[i-w-1] = @([self.bpmValues[i-w-1] doubleValue]);
        }
        
        return;// continue
    }
    
    if (i < calib + (self.firstPeakPlace + w + 1)) {
        
        int dynamicWindowSize = WINDOW_SIZE_FOR_FILTER_CALCULATION+1;
        double x[dynamicWindowSize] , y[dynamicWindowSize];
        [self getLatestPoints:dynamicWindowSize andSetIntoDoubleArray:x];
        [self Substract:[self mean:x withSize:dynamicWindowSize] fromArray:x withSize:dynamicWindowSize];
        filter(2*FILTER_ORDER, self.buttterworthValues[1], self.buttterworthValues[0], dynamicWindowSize, x, y);
        
        double *z = y+dynamicWindowSize-2*w-1;
        self.isPeak[i-w-1] = @([self isPeak:z :w] && ![self.isPeak[i-w-2] boolValue]);
        
        self.numOfPeaks += [self.isPeak[i-w-1] boolValue];
        
        NSUInteger frames = i - self.firstPeakPlace-1;
        if (frames > calib) {
            frames = calib;
        }
        
        self.bpmValues[i-w-1] = @((self.numOfPeaks/(frames/self.frameRate))*60);
        
        int k = i-(self.firstPeakPlace+w+1);
        self.bpmAverageValues[i-w-1] = @([self.bpmAverageValues[i-w-2] doubleValue] * k/(k+1) + [self.bpmValues[i-w-1] doubleValue] * 1/(k+1));
    }
    
    else {
        //calibration is over
        int dynamicWindowSize = WINDOW_SIZE_FOR_FILTER_CALCULATION+1;
        double x[dynamicWindowSize] , y[dynamicWindowSize];
        [self getLatestPoints:dynamicWindowSize andSetIntoDoubleArray:x];
        [self Substract:[self mean:x withSize:dynamicWindowSize] fromArray:x withSize:dynamicWindowSize];
        filter(2*FILTER_ORDER, self.buttterworthValues[1], self.buttterworthValues[0], dynamicWindowSize, x, y);
        
        double *z = y+dynamicWindowSize-2*w-1;
        self.isPeak[i-w-1] = @([self isPeak:z :w] && ![self.isPeak[i-w-2] boolValue]);
        
        self.numOfPeaks += [self.isPeak[i-w-1] boolValue] - [self.isPeak[i-w-1-calib] boolValue];
        
        NSUInteger frames = calib;
        
        self.bpmValues[i-w-1] = @((self.numOfPeaks/(frames/self.frameRate))*60);
        
        double tempSum = 0;
        for (int j = 1; j <= self.WindowSizeForAverageCalculation; j++) {
            tempSum += [self.bpmValues[i-w-1-self.WindowSizeForAverageCalculation+j] doubleValue];
        }
        double average_bpm = tempSum/self.WindowSizeForAverageCalculation;
        
        int calibrationWeight = 3;// simulate the weight of the calibration calculated results.
                                  // if it's 0, the calibration is worthless
        int k = i - calib + (self.firstPeakPlace + w + 1) + calibrationWeight;
        
        int sensitiveFactor = 3;// adjust this bigger the make the algorithm more sensitive to changes
        self.bpmAverageValues[i-w-1] = @([self.bpmAverageValues[i-w-2] doubleValue] * k/(k+sensitiveFactor) + average_bpm * sensitiveFactor/(k+sensitiveFactor));
        
        if (i == 600) {
            int lastAverageResult = [self.bpmAverageValues[i-w-1] intValue];
            
        }
    }
    
    if ([self.isPeak[i-w-1] boolValue]) {
        printf("%d\n" , i-w-1);
    }
    
}

@end
