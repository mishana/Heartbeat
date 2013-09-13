//
//  HelpMethods.m
//  SunglassesDemo
//
//  Created by Or Maayan on 9/8/13.
//  Copyright (c) 2013 Stanford. All rights reserved.
//

#import "HelpMethods.h"

@implementation HelpMethods

struct pixel {
    unsigned char r, g, b, a;
};

+ (UIColor*) getDominantColor:(UIImage*)image
{
    CGFloat red = 0;
    CGFloat green = 0;
    CGFloat blue = 0;
    
    // Allocate a buffer big enough to hold all the pixels
    struct pixel* pixels = (struct pixel*) calloc(1, image.size.width * image.size.height * sizeof(struct pixel));
    
    if (pixels != nil)
    {
        CGContextRef context = CGBitmapContextCreate(
                                                     (void*) pixels,
                                                     image.size.width,
                                                     image.size.height,
                                                     8,
                                                     image.size.width * sizeof(struct pixel), // * 4
                                                     CGImageGetColorSpace(image.CGImage),
                                                     kCGImageAlphaPremultipliedLast
                                                     );
        
        if (context != NULL)
        {
            // Draw the image in the bitmap
            
            CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, image.size.width, image.size.height), image.CGImage);
            
            // Now that we have the image drawn in our own buffer, we can loop over the pixels to
            // process it. This simple case simply counts all pixels that have a pure red component.
            
            // There are probably more efficient and interesting ways to do this. But the important
            // part is that the pixels buffer can be read directly.
            
            NSUInteger numberOfPixels = image.size.width * image.size.height;
            for (int i=0; i<numberOfPixels; i++) {
                red += pixels[i].r;
                green += pixels[i].g;
                blue += pixels[i].b;
                NSLog(@"%c" , pixels[i].a); //*
            }
            
            
            red /= numberOfPixels;
            green /= numberOfPixels;
            blue/= numberOfPixels;
            
            
            CGContextRelease(context);
        }
        
        free(pixels);
    }
    return [UIColor colorWithRed:red/255.0f green:green/255.0f blue:blue/255.0f alpha:1.0f];
}

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
