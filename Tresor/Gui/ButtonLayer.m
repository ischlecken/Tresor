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
    
    BOOL isDigit = [ButtonLayer isDigit:digit];
    
    self.strokeColor   = isDigit ? [UIColor colorWithWhite:1.0 alpha:1.0].CGColor : [UIColor colorWithWhite:0.9 alpha:1.0].CGColor;
    self.digitColor    = isDigit ? [UIColor colorWithWhite:1.0 alpha:1.0]         : [UIColor colorWithWhite:0.9 alpha:1.0];
    self.fillColor     = [UIColor clearColor].CGColor;
    self.lineWidth     = isDigit ? 2.0 : 1.5;
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
+(BOOL) isDigit:(NSString*)digit
{ BOOL result = NO;
  
  if( digit && digit.length==1 )
  { unichar         ch         = [digit characterAtIndex:0];
    NSCharacterSet* numericSet = [NSCharacterSet decimalDigitCharacterSet];

    result = [numericSet characterIsMember:ch];
  } /* of if */
  
  return result;
}

/**
 *
 */
-(BOOL) isDigit
{ return [ButtonLayer isDigit:self.digit]; }

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
-(void) setDisplayDigit:(BOOL)displayDigit
{ self->_displayDigit = displayDigit;
  
  self.digitLabel.displayDigit = displayDigit;
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
  
  id<CAAction> result = nil;
  
  if( [key isEqualToString:@"pushed"] )
    result = self.pushed ? [OffAnimationAction1 new] : [OnAnimationAction1 new];
  else if( [key isEqualToString:@"enabled"] )
    result = self.enabled ? [OffAnimationAction2 new] : [OnAnimationAction2 new];
  else if( [key isEqualToString:@"digit"] )
  { if( self.digit )
      result = [OffAnimationAction new];
    else
    { OnAnimationAction* action = [OnAnimationAction new];
      
      if( self.displayDigit )
        action.disappearDuration = 36.0;
      
      result = action;
    } /* of else */
  } /* of else if */
  
  return result;
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


/**
 *
 */
-(void) disableButton
{ self.digitColor = [self isDigit] ? [UIColor colorWithWhite:1.0 alpha:0.4] : [UIColor colorWithWhite:0.9 alpha:0.4];
  self.enabled    = NO;
}


/**
 *
 */
-(void) enableButton
{ self.digitColor = [self isDigit] ? [UIColor colorWithWhite:1.0 alpha:1.0] : [UIColor colorWithWhite:0.9 alpha:1.0];
  self.enabled    = YES;
}
@end


