//
//  HelpMethods.h
//  SunglassesDemo
//
//  Created by Or Maayan on 9/8/13.
//  Copyright (c) 2013 Stanford. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HelpMethods : NSObject

+ (UIColor*) getDominantColor:(UIImage*)image;
+ (BOOL)isPeak:(NSArray*)graph :(int)window;
+ (double)mean:(NSArray *)points;

@end
