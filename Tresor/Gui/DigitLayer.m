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
#import "DigitLayer.h"
#import "DigitAnimationAction.h"

@interface DigitLayer ()
@property(strong,nonatomic) UIFont* digitFont;
@end

@implementation DigitLayer

@dynamic fontName,digit,digitColor,digitFont;

/**
 *
 */
-(id) init
{ self = [super init];
  
  if( self )
  { self.digitColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    self.fontName   = @"Courier";
    
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
  { if ([layer isKindOfClass:[DigitLayer class]])
    { DigitLayer* other = (DigitLayer*)layer;
      
      self.digit       = other.digit;
      self.digitColor  = other.digitColor;
      self.fontName    = other.fontName;
      self.digitFont   = other.digitFont;
    } /* of if */
  } /* of if */
  
  return self;
}


/**
 *
 */
-(void) drawInContext:(CGContextRef)ctx
{
  if( self.digit )
  { NSDictionary*       stringAttribs  = @{NSFontAttributeName:self.digitFont ,NSForegroundColorAttributeName:self.digitColor};
    CGFloat             ascent         = 0;
    CGFloat             descent        = 0;
    CGFloat             leading        = 0;
    NSAttributedString* title          = [[NSAttributedString alloc] initWithString:self.digit attributes:stringAttribs];
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
{ if( [key isEqualToString:@"digit"]      ||
      [key isEqualToString:@"digitColor"] ||
      [key isEqualToString:@"fontName"]
    )
    return YES;
  
  return [super needsDisplayForKey:key];
}


/**
 *
 */
-(id<CAAction>) actionForKey:(NSString *)key
{ //_NSLOG(@"[%@]: digit=%@",key,self.digit);

  id<CAAction> result = nil;
  
  if( [key isEqualToString:@"digit"] )
  { DigitLayerDigitColorAction* action = [DigitLayerDigitColorAction new];
    
    if( self.displayDigit )
      action.duration = 36.0;
    
    result = action;
  } /* of if */
  
  return result;
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
{ if( self.digitFont==nil )
  { CGFloat height = self.bounds.size.height>0 ? self.bounds.size.height*0.6 : 12;
  
    //_NSLOG(@"[%@]: fontSize=%lf fontName=%@",self.digit,height,self.fontName);
  
    self.digitFont = [UIFont fontWithName:self.fontName size:height];
  } /* of if */
}
@end


