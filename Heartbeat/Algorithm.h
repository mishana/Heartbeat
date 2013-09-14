//
//  Algorithm.h
//  Heartbeat
//
//  Created by Or Maayan on 9/13/13.
//  Copyright (c) 2013 michael leybovich. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Algorithm : NSObject

@property (nonatomic , readwrite) NSUInteger framesCounter;
@property (nonatomic , readwrite) NSUInteger frameRate;// the frame rate of the video
@property (nonatomic , readwrite) NSUInteger numOfPeaks;// number of peaks in the last calibrationDuration frames
@property (nonatomic , readwrite) NSUInteger WindowSize;// size in frames
@property (nonatomic , readwrite) NSUInteger calibrationDuration;// duration in frames
@property (nonatomic , readwrite) NSUInteger WindowSizeForAverageCalculation;// size must be <= calibrationDuration
@property (nonatomic , readwrite) NSUInteger firstPeakPlace;// first place peak was determined. if 0 the none found

@property (nonatomic , readwrite) double ** buttterworthValues;//* should we care of releasing this array?

@property (nonatomic , strong , readwrite) NSMutableArray *points;// represent the array of color values (doubles) wrapped by NSNumbers
@property (nonatomic , strong , readwrite) NSMutableArray *bpmValues;// array of the calculated beats per minute values wrapped by NSNumbers
                                                                     // array size should be approximately WindowSizeForAverageCalculation
@property (nonatomic , strong , readwrite) NSMutableArray *bpmAverageValues;// array of average values of the bpm wrapped by NSNumbers;
                                                                            // we could save only the latest bpmAverageValue calculated
@property (nonatomic , strong , readwrite) NSMutableArray *isPeak;// array of the BOOLs represent if the matching point is peak in the graph

//

- (CGFloat)getColorValueFrom:(UIColor *)color;

// outside API

@property (nonatomic , readonly) BOOL isCalibrationOver;
@property (nonatomic , readonly) BOOL isFinalResultDetermined;
@property (nonatomic , readonly) NSUInteger bpmLatestResult;

//

- (void)newFrameDetectedWithAverageColor:(UIColor *)color;

@end
