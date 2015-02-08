//
//  GradientView.m
//  CallerID
//
//  Created by Stefan Thomas on 19.12.14.
//  Copyright (c) 2014 LSSi Europe. All rights reserved.
//

#import "GradientView.h"

@implementation GradientView


/**
 *
 */
-(void) drawRect:(CGRect)rect
{ CGContextRef ctx = UIGraphicsGetCurrentContext();
  
  NSArray* gradientColors = [_TRESORCONFIG colorWithName:kGradientColorsName];
  
  UIColor* color0 = gradientColors[0];
  UIColor* color2 = gradientColors[1];
  
  CGColorSpaceRef colorSpace  = CGColorSpaceCreateDeviceRGB();
  CGFloat         locations[] = { 0.4,0.9 };
  NSArray*        colors      = @[(__bridge id)color0.CGColor,(__bridge id)color2.CGColor];
  CGGradientRef   gradient    = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)colors, locations);
  CGPoint         startPoint  = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMinY(self.frame));
  CGPoint         endPoint    = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame));

  CGContextDrawLinearGradient(ctx, gradient, startPoint, endPoint, 0);
  
  CGGradientRelease(gradient);
  CGColorSpaceRelease(colorSpace);
}

@end
