//
//  HelpMethods.m
//  SunglassesDemo
//
//  Created by Or Maayan on 9/8/13.
//  Copyright (c) 2013 Stanford. All rights reserved.
//

#import "HelpMethods.h"

@implementation HelpMethods

+ (BOOL)isPeak:(NSArray*)graph :(int)window
{
    // graph is NSArray of NSNumbers of doubles
    // graph size should be window*2+1
    // window must be positive
    
    NSNumber *middlePoint = graph[window];
    for (NSNumber *point in graph) {
        if ([middlePoint doubleValue] < [point doubleValue]) {
            return NO;
        }
    }
    return YES;
}

+ (double)mean:(NSArray *)points
{
    // points is NSArray of NSNumbers of doubles
    
    double sum = 0;
    for (NSNumber *point in points) {
        sum += [point doubleValue];
    }
    return sum/[points count];
}

@end
