//
//  Algorithm.h
//  Heartbeat
//
//  Created by Or Maayan on 9/13/13.
//  Copyright (c) 2013 michael leybovich. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Algorithm : NSObject

@property (nonatomic , readwrite) NSUInteger frameRate;// the frame rate of the video
@property (nonatomic , readwrite) NSUInteger numOfPeaks;// number of peaks in the last calibrationDuration frames
@property (nonatomic , readwrite) NSUInteger WindowSize;// size in frames
@property (nonatomic , readwrite) NSUInteger calibrationDuration;// duration in frames
@property (nonatomic , readwrite) NSUInteger WindowSizeForAverageCalculation;// size must be <= calibrationDuration
@property (nonatomic , readwrite) NSUInteger framesCounter;
@property (nonatomic , readwrite) double ** buttterworthValues;
@property (nonatomic , readwrite) NSArray *points;// represent the array of color values (doubles) wrapped by NSNumbers
@property (nonatomic , readwrite) NSArray *bpmValues;// array of the calculated beats per minute values wrapped by NSNumbers
                                                     // array size should be approximately WindowSizeForAverageCalculation
@property (nonatomic , readwrite) NSArray *bpmAverageValues;// array of average values of the bpm wrapped by NSNumbers;
// array size should be approximately WindowSizeForAverageCalculation
@property (nonatomic , readwrite) NSArray *isPeak;// array of the BOOLs represent if the matching point is peak in the graph
@property (nonatomic , readwrite) NSUInteger firstPeakPlace;// first place peak was determined. if 0 the none found

//

- (CGFloat)getColorValueFrom:(UIColor *)color;

// outside API
@property (nonatomic , readonly) BOOL isCalibrationOver;
@property (nonatomic , readonly) BOOL isFinalResultDetermined;
@property (nonatomic , readonly) NSUInteger bpmFinalResult;

//

- (void)newFrameDetectedWithDominantColor:(UIColor *)color;

@end
