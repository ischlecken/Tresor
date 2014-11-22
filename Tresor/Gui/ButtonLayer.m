//
//  PasswordView.m
//  Tresor
//
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

#import "ButtonLayer.h"
#import "ButtonAnimationAction.h"

@interface ButtonLayer ()
@end

@implementation ButtonLayer

@dynamic pushed,fontName,index,digit,digitColor,enabled;

/**
 *
 */
-(id) initWithDigit:(NSString*)digit
{ self = [super init];
  
  if( self )
  { self->_innerRing   = [CAShapeLayer new];
    self->_digitLabel  = [DigitLayer new];
    
    [self addSublayer:self.innerRing];
    [self addSublayer:self.digitLabel];
    
    self.strokeColor   = [UIColor colorWithWhite:1.0 alpha:1.0].CGColor;
    self.digitColor    = [UIColor colorWithWhite:1.0 alpha:1.0];
    self.fillColor     = [UIColor clearColor].CGColor;
    self.lineWidth     = 2.0;
    self.strokeStart   = 0.0;
    self.fontName      = @"Arial";
    self.enabled       = YES;
    self.digit         = digit;
    
    self.innerRing.fillColor   = [UIColor clearColor].CGColor;
    self.innerRing.strokeColor = [UIColor colorWithWhite:0.9 alpha:1.0].CGColor;
    self.innerRing.lineWidth   = 2.5;
    self.innerRing.strokeStart = 1.0;
    
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
  { if ([layer isKindOfClass:[ButtonLayer class]])
    { ButtonLayer* other = (ButtonLayer*)layer;
      
      self.digit      = other.digit;
      self.digitColor = other.digitColor;
      self.pushed     = other.pushed;
      self.enabled    = other.enabled;
      self.index      = other.index;
      self.fontName   = other.fontName;
    } /* of if */
  } /* of if */
  
  return self;
}

/**
 *
 */
-(void) dealloc
{ _NSLOG_SELECTOR;
  
}

/**
 *
 */
+(BOOL) needsDisplayForKey:(NSString *)key
{ if( [key isEqualToString:@"digit"]      ||
      [key isEqualToString:@"digitColor"] ||
      [key isEqualToString:@"fontName"]   ||
      [key isEqualToString:@"pushed"]     ||
      [key isEqualToString:@"enabled"]
    )
    return YES;
  
  return [super needsDisplayForKey:key];
}



/**
 *
 */
-(void) layoutSublayers
{ //_NSLOG(@"[%@]: bounds=(%lf,%lf,%lf,%lf)",self.digit,self.bounds.origin.x,self.bounds.origin.y,self.bounds.size.width,self.bounds.size.height);
  
  self.innerRing.frame  = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
  self.digitLabel.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
}


/**
 *
 */
-(id<CAAction>) actionForKey:(NSString *)key
{ //_NSLOG(@"[%@]: digit=%@",key,self.digit);
  
  if( [key isEqualToString:@"pushed"] )
    return self.pushed ? [OffAnimationAction1 new] : [OnAnimationAction1 new];
  else if( [key isEqualToString:@"enabled"] )
    return self.enabled ? [OffAnimationAction2 new] : [OnAnimationAction2 new];
  else if( [key isEqualToString:@"digit"] )
    return self.digit ? [OffAnimationAction new] : [OnAnimationAction new];
  
  return nil;
}

/**
 *
 */
-(void) setBounds:(CGRect)bounds
{ [super setBounds:bounds];
  
  //_NSLOG(@"[%@]: bounds=(%lf,%lf,%lf,%lf)",self.digit,self.bounds.origin.x,self.bounds.origin.y,self.bounds.size.width,self.bounds.size.height);

  CGMutablePathRef arcPath = CGPathCreateMutable();
  CGFloat x = self.bounds.size.width  * 0.5;
  CGFloat y = self.bounds.size.height * 0.5;
  CGFloat r = self.bounds.size.width  * 0.5;
  CGPathAddArc(arcPath, NULL, x, y, r, 0, 2.0*M_PI, YES);

  self.path           = arcPath;
  self.innerRing.path = arcPath;
}

/**
 *
 */
-(void) didChangeValueForKey:(NSString*)key
{ [super didChangeValueForKey:key];
  
 // _NSLOG(@"[%@] key=%@",self.digit,key);
  
  if( [key isEqualToString:@"fontName"] )
    self.digitLabel.fontName = self.fontName;
  else if( [key isEqualToString:@"digit"] )
    self.digitLabel.digit = self.digit;
  else if( [key isEqualToString:@"digitColor"] )
    self.digitLabel.digitColor = self.digitColor;
}

@end


