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

@end

@implementation Algorithm

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
