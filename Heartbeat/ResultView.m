//
//  ResultView.m
//  Heartbeat
//
//  Created by michael leybovich on 10/12/13.
//  Copyright (c) 2013 michael leybovich. All rights reserved.
//

#import "ResultView.h"

@implementation ResultView

- (void)drawRect:(CGRect)rect
{
    // Drawing code
    UIBezierPath *frameRect = [UIBezierPath bezierPathWithRect:self.bounds];
    
    [frameRect addClip];
    
    [[UIColor whiteColor] setFill];
    UIRectFill(self.bounds);
    
    [self drawOneRect];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

////////////////////////////-DEMO-/////////////////////////////////////////
#define CORNER_RADIUS 12.0
#define FIGURE_FONT_SCALE_FACTOR 0.20
#define FIGURE_SIZE_WIDTH self.bounds.size.width/5
#define FIGURE_SIZE_HEIGHT self.bounds.size.height/6.5

- (CGPoint)middle
{
    return CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
}

- (CGPoint)figureOriginWithMiddle:(CGPoint)middle figureSize:(CGSize)figureSize
{
    return CGPointMake(
                       middle.x-figureSize.width/2.0,
                       middle.y-figureSize.height/2.0
                       );
}

- (UIBezierPath *)squiggleRect
{
    CGPoint middle = [self middle];
    CGSize figureSize = CGSizeMake(FIGURE_SIZE_WIDTH, FIGURE_SIZE_HEIGHT);
    CGPoint figureOrigin = [self figureOriginWithMiddle:middle figureSize:figureSize];
    
    UIBezierPath *squiggleRect = [UIBezierPath bezierPath];
    
    CGPoint startPoint = CGPointMake(
                                     (figureOrigin.x - figureSize.width),
                                     figureOrigin.y + (figureSize.height * 3/4)
                                     );
    CGPoint endPoint = CGPointMake(
                                   (figureOrigin.x - figureSize.width) + (figureSize.width * 3),
                                   figureOrigin.y + figureSize.height/4
                                   );
    CGPoint controlPoint_1 = CGPointMake(
                                         (figureOrigin.x - figureSize.width) + (figureSize.width * 3)/2 - figureSize.width/2,
                                         figureOrigin.y - (figureSize.height * 1.3)
                                         );
    CGPoint controlPoint_2 = CGPointMake(
                                         (figureOrigin.x - figureSize.width) + (figureSize.width * 3)/2 + figureSize.width/10,
                                         figureOrigin.y + figureSize.height
                                         );
    
    [squiggleRect moveToPoint:startPoint];
    [squiggleRect addCurveToPoint:endPoint controlPoint1:controlPoint_1 controlPoint2:controlPoint_2];
    
    CGPoint controlPoint_3 = CGPointMake(
                                         (figureOrigin.x - figureSize.width) + (figureSize.width * 3)/2 + figureSize.width/2,
                                         figureOrigin.y + figureSize.height + (figureSize.height * 1.3)
                                         );
    CGPoint controlPoint_4 = CGPointMake(
                                         (figureOrigin.x - figureSize.width) + (figureSize.width * 3)/2 - figureSize.width/10,
                                         figureOrigin.y
                                         );
    
    [squiggleRect moveToPoint:endPoint];
    [squiggleRect addCurveToPoint:startPoint controlPoint1:controlPoint_3 controlPoint2:controlPoint_4];
    
    return [squiggleRect copy];
}

- (UIBezierPath *)stripes
{
    UIBezierPath *stripes = [UIBezierPath bezierPath];
    
    for (int i = 0; i < self.bounds.size.width; i+=4) {
        [stripes moveToPoint:CGPointMake(i, 0)];
        [stripes addLineToPoint:CGPointMake(i, self.bounds.size.height)];
    }
    return stripes;
}

- (void)drawRect:(UIBezierPath *)rect withColor:(UIColor *)color andShading:(int)shading
{
    [color setFill];
    [color setStroke];
    
    [rect addClip];
    
    if (shading == 1)
        UIRectFill(rect.bounds);
    
    [rect stroke];
    
    if (shading == 2)
        [[self stripes] stroke];
}

- (void)drawOneRect
{
    [self drawRect:[self squiggleRect]
         withColor:[UIColor purpleColor]
        andShading:2];
}

- (void)pushContext
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
}

- (void)pushContextAndTranslateCoordinatesX:(CGFloat)x Y:(CGFloat)y
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, x, y);
}

- (void)pushContextAndRotateWithAngle:(CGFloat)angle
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, self.bounds.size.width, self.bounds.size.height);
    
    CGContextRotateCTM(context, angle);
}

- (void)popContext
{
    CGContextRestoreGState(UIGraphicsGetCurrentContext());
}

@end
