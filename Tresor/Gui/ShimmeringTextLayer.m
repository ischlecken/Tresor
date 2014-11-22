/*
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see http://www.gnu.org/licenses/.
 *
 * Copyright (c) 2014 ischlecken.
 */
#import <QuartzCore/QuartzCore.h>
#import <CoreText/CoreText.h>
#import "ShimmeringTextLayer.h"

@interface ShimmeringTextLayer ()
@property(strong,nonatomic) UIFont* textFont;
@end

@implementation ShimmeringTextLayer

@dynamic fontName,text,textColor,textFont;

/**
 *
 */
-(id) init
{ self = [super init];
  
  if( self )
  { self.textColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    self.fontName  = @"Courier";
    
    [self setNeedsDisplay];
  } /* of if */
  
  return self;
}


/**
 *
 */
- (id)initWithLayer:(id)layer
{ self = [super initWithLayer:layer];
  
  if( self )
  { if ([layer isKindOfClass:[ShimmeringTextLayer class]])
    { ShimmeringTextLayer* other = (ShimmeringTextLayer*)layer;
      
      self.text       = other.text;
      self.textColor  = other.textColor;
      self.fontName   = other.fontName;
      self.textFont   = other.textFont;
    } /* of if */
  } /* of if */
  
  return self;
}

/**
 *
 */
-(void) startAnimation
{
  CABasicAnimation* anim1 = [CABasicAnimation animationWithKeyPath:@"textColor"];
  anim1.duration            = 2.0;
  anim1.fromValue           = (id)[UIColor orangeColor].CGColor;
  anim1.toValue             = (id)[UIColor colorWithWhite:1.0 alpha:1].CGColor;
  anim1.fillMode            = kCAFillModeForwards;
  anim1.repeatCount         = HUGE_VALF;
  anim1.autoreverses        = YES;
  anim1.timingFunction      = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
  anim1.removedOnCompletion = NO;
  [self addAnimation:anim1 forKey:@"digitColorAnim"];

}

/**
 *
 */
-(void) stopAnimation
{
  [self removeAllAnimations];
}


/**
 *
 */
-(void) drawInContext:(CGContextRef)ctx
{
  if( self.text )
  { NSDictionary*       stringAttribs  = @{NSFontAttributeName:self.textFont ,NSForegroundColorAttributeName:self.textColor};
    CGFloat             ascent         = 0;
    CGFloat             descent        = 0;
    CGFloat             leading        = 0;
    NSAttributedString* title          = [[NSAttributedString alloc] initWithString:self.text attributes:stringAttribs];
    CTLineRef           line           = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)(title));
    CGFloat             width          = CTLineGetTypographicBounds(line,&ascent,&descent,&leading);
    
    CGContextSaveGState(ctx);
    CGContextTranslateCTM(ctx, self.bounds.origin.x, self.bounds.origin.y+self.bounds.size.height);
    CGContextScaleCTM(ctx, 1, -1);
    
    UIGraphicsPushContext(ctx);
    
    CGContextSetTextPosition(ctx,0.5*(self.bounds.size.width-width),(self.bounds.size.height-ascent-descent-leading)*0.5+descent+leading);
    CTLineDraw(line, ctx);
    CFRelease(line);
    
    UIGraphicsPopContext();
    
    CGContextRestoreGState(ctx);
  } /* of if */
}


/**
 *
 */
+(BOOL) needsDisplayForKey:(NSString *)key
{ if( [key isEqualToString:@"text"]      ||
      [key isEqualToString:@"textColor"] ||
      [key isEqualToString:@"fontName"]
    )
    return YES;
  
  return [super needsDisplayForKey:key];
}


/**
 *
 */
-(id<CAAction>) actionForKey:(NSString *)key
{ //_NSLOG(@"[%@]: text=%@",key,self.text);

  return nil;
}

/**
 *
 */
-(void) setBounds:(CGRect)bounds
{ [super setBounds:bounds];
  
  [self calcFontSize];
}

/**
 *
 */
-(void) calcFontSize
{ if( self.textFont==nil )
  { CGFloat height = self.bounds.size.height>0 ? self.bounds.size.height : 12;
  
    //_NSLOG(@"[%@]: fontSize=%lf fontName=%@",self.text,height,self.fontName);
  
    self.textFont = [UIFont fontWithName:self.fontName size:height];
    [self needsDisplay];
  } /* of if */
}
@end


