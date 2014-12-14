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

#import "PasswordView.h"
#import "ButtonLayer.h"
#import "ShimmeringTextLayer.h"

#define kPound   @"#"
#define kStar    @"*"

/*
 #define kPound   @"\u274C"
 #define kStar    @"\U0001F519"
 #define kSmiley  @"\U0001F604"

 BACK WITH LEFTWARDS ARROW ABOVE
 Unicode: U+1F519 (U+D83D U+DD19), UTF-8: F0 9F 94 99
 
 CROSS MARK
 Unicode: U+274C, UTF-8: E2 9D 8C
 */

#pragma mark - PasswordView

@interface PasswordView ()

@property(assign,nonatomic) NSInteger       digitPosition;
@property(strong,nonatomic) NSMutableArray* digits;
@property(strong,nonatomic) NSMutableArray* digitColors;

@property NSArray*             buttonLayers;
@property NSArray*             dotLayers;
@property UIFont*              digitFont;
@property ShimmeringTextLayer* textButton;
@end

@implementation PasswordView

/**
 *
 */
-(id) initWithFrame:(CGRect)frame
{ self = [super initWithFrame:frame];
 
  if (self)
    [self commonInit];
  
  return self;
}

/**
 *
 */
-(id) initWithCoder:(NSCoder*)coder
{ self = [super initWithCoder:coder];
  
  if( self )
    [self commonInit];
  
  return self;
}

/**
 *
 */
-(void) commonInit
{ [CATransaction begin];
  [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
  
  self.buttonLayers = @[[[ButtonLayer alloc] initWithDigit:@"1"],
                        [[ButtonLayer alloc] initWithDigit:@"2"],
                        [[ButtonLayer alloc] initWithDigit:@"3"],
                        [[ButtonLayer alloc] initWithDigit:@"4"],
                        [[ButtonLayer alloc] initWithDigit:@"5"],
                        [[ButtonLayer alloc] initWithDigit:@"6"],
                        [[ButtonLayer alloc] initWithDigit:@"7"],
                        [[ButtonLayer alloc] initWithDigit:@"8"],
                        [[ButtonLayer alloc] initWithDigit:@"9"],
                        [[ButtonLayer alloc] initWithDigit:kStar],
                        [[ButtonLayer alloc] initWithDigit:@"0"],
                        [[ButtonLayer alloc] initWithDigit:kPound]
                       ];
  
  NSUInteger position=0;
  for( ButtonLayer* b in self.buttonLayers )
  { b.index    = position++;
    //b.fontName = @"AvenirNext-Bold";
    b.fontName = @"Avenir-Heavy";
    
    [self.layer addSublayer:b];
  } /* of for */
  
  [self setMaxDigits:self.maxDigits];
  
  CAGradientLayer* backgroundLayer = (CAGradientLayer*)self.layer;
  
  backgroundLayer.colors    = @[(id)[UIColor colorWithHue:0.14 saturation:1.0 brightness:1.0 alpha:1.0].CGColor,
                                (id)[UIColor orangeColor].CGColor
                              ];
  
  backgroundLayer.locations = @[@(0.0),@(1.0)];
  backgroundLayer.frame     = CGRectMake(0, 0, 200, 200);
  
  self.textButton           = [ShimmeringTextLayer new];
  self.textButton.text      = @"Prüfen";
  self.textButton.textColor = [UIColor colorWithHue:0.14 saturation:1.0 brightness:1.0 alpha:1.0];
  self.textButton.fontName  = @"Arial";

  [CATransaction commit];
  
  self.multipleTouchEnabled = YES;

  [self findButtonByText:kPound].enabled = NO;
}

/**
 *
 */
+(Class) layerClass
{ Class cls = [CAGradientLayer class];

  return cls;
}


/**
 *
 */
-(void) setMaxDigits:(NSInteger)maxDigits
{ self->_maxDigits = maxDigits;
  self.digits      = [[NSMutableArray alloc] initWithCapacity:self.maxDigits];
  self.digitColors = [[NSMutableArray alloc] initWithCapacity:self.maxDigits];
  
  NSMutableArray* dots     = [[NSMutableArray alloc] initWithCapacity:self.maxDigits];
  NSUInteger      position = 0;
  for( position=0;position<self.maxDigits;position++ )
  { ButtonLayer* dl = [[ButtonLayer alloc] initWithDigit:nil];
    
    dl.index = position;
    dl.digitColor = [UIColor redColor];
    
    [dots addObject:dl];
    
    [self.layer addSublayer:dl];
    
    [self.digits      addObject:[NSNull null]];
    [self.digitColors addObject:[NSNull null]];
  } /* of for */
  
  self.dotLayers       = dots;
  self->_digitPosition = -1;
  
  [self setNeedsLayout];
}

/**
 *
 */
-(ButtonLayer*) buttonLayerForCALayer:(CALayer*)layer
{ ButtonLayer* result = nil;
  
  for( ButtonLayer* b in self.buttonLayers )
    if( b==layer )
    { result = b;
      
      break;
    } /* of if */
  
  return result;
}


#pragma mark CALayer Delegate

/**
 *
 */
-(void) layoutSublayersOfLayer:(CALayer *)layer
{ //_NSLOG_FRAME(@"frame=", layer.frame);
  
  NSUInteger columns       = self.bounds.size.width<self.bounds.size.height ? 3 : 6;
  CGFloat    padding       =28.0;
  CGFloat    buttonPadding =14.0;
  CGFloat    width         = (self.bounds.size.width-padding*2.0)/columns;
  CGFloat    height        = width;
  
  NSUInteger rows          = self.buttonLayers.count / columns + ((self.buttonLayers.count % columns)!=0 );
  CGFloat    heightRows    = rows*height;
  CGFloat    dotSize       = 24;
  CGFloat    dotPadding    = 10;
  CGFloat    dotXOffset    = 0.5*((columns*width)-self.dotLayers.count*(dotSize+dotPadding));

  CGFloat    xOffset       = 0.5*(self.layer.bounds.size.width -columns*width);
  CGFloat    yOffset       =     padding+dotSize+2.0*dotPadding;
  
  for( ButtonLayer* dotLayer in self.dotLayers )
  { CGFloat    x             = dotXOffset + xOffset + (dotSize+dotPadding)*dotLayer.index;
    CGFloat    y             =              yOffset - dotSize-dotPadding;
    CGRect     frame         = CGRectMake(x,y,dotSize,dotSize);
    
    //_NSLOG_FRAME(@"dotFrame=", frame);
    
    dotLayer.frame        = frame;
  } /* of if */
  
  for( ButtonLayer* buttonLayer in self.buttonLayers )
  { CGFloat    x             = buttonLayer.index%columns*width;
    CGFloat    y             = buttonLayer.index/columns*height;
    CGRect     frame         = CGRectMake(xOffset+x+buttonPadding,yOffset+y+buttonPadding, width-2.0*buttonPadding,height-2.0*buttonPadding);
    
    //_NSLOG(@"%@.frame=(%lf,%lf,%lf,%lf)",buttonLayer.digit,frame.origin.x,frame.origin.y,frame.size.width,frame.size.height);
    
    buttonLayer.frame    = frame;
  } /* of if */
  
  CGFloat textHeight = MIN(self.bounds.size.height-(yOffset+heightRows),48.0);
  self.textButton.frame = CGRectMake(0, yOffset+heightRows + (self.bounds.size.height-(yOffset+heightRows)-textHeight)*0.5, self.bounds.size.width,textHeight);
}

#pragma mark Touch Handling

/**
 *
 */
-(ButtonLayer*) findButtonLayer:(CALayer*)layer
{ ButtonLayer* result = nil;
  
  for( ButtonLayer* b in self.buttonLayers )
    if( b==layer )
    { result = b;
      
      break;
    } /* of if */
  
  
  return result;
}

/**
 *
 */
-(ButtonLayer*) findTouchedButton:(UITouch*)touch
{ ButtonLayer* result = nil;
  
  CGPoint viewLocation = [touch locationInView:self];
  
  for( ButtonLayer* b in self.buttonLayers )
    if( CGRectContainsPoint(b.frame, viewLocation) )
    { result = b;
      
      break;
    } /* of if */

  
  return result;
}

/**
 *
 */
-(ButtonLayer*) findButtonByText:(NSString*)digit
{ ButtonLayer* result = nil;
  
  for( ButtonLayer* b in self.buttonLayers )
    if( [b.digit isEqualToString:digit] )
    { result = b;
      
      break;
    } /* of if */
  
  return result;
}

/**
 *
 */
-(void) resetPushStateOfAllButtons:(BOOL)canceled
{ for( ButtonLayer* b in self.buttonLayers )
    if( b.pushed )
    { [self buttonPushed:b];
      
      b.pushed = NO;
    } /* of if */
}

/**
 *
 */
-(BOOL) isButtonPushed
{ BOOL result = NO;
  
  for( ButtonLayer* b in self.buttonLayers )
    if( b.pushed )
    { result = YES;
      
      break;
    } /* of if */
  
  return result;
}

/**
 *
 */
-(void) disableButtons
{ //_NSLOG_SELECTOR;
  
  for( ButtonLayer* b in self.buttonLayers )
    if( ![b.digit isEqualToString:kPound] && ![b.digit isEqualToString:kStar] )
    { b.digitColor = [UIColor colorWithWhite:1.0 alpha:0.4];
      b.enabled    = NO;
    } /* of if */
}

/**
 *
 */
-(void) enableButtons
{ //_NSLOG_SELECTOR;
  
  for( ButtonLayer* b in self.buttonLayers )
    if( ![b.digit isEqualToString:kPound] && ![b.digit isEqualToString:kStar] )
    { b.digitColor = [UIColor colorWithWhite:1.0 alpha:1.0];
      b.enabled    = YES;
    } /* of if */
}


/**
 *
 */
-(void) buttonPushed:(ButtonLayer*)bl
{
  if( bl && bl.enabled )
  { if( [bl.digit isEqualToString:kPound] )
    { if( self.digitPosition>=0 )
      { bl.pushed = YES;
        
        ButtonLayer* dl = [self.dotLayers objectAtIndex:self.digitPosition];
        dl.digit = nil;
        
        [self->_digits replaceObjectAtIndex:self.digitPosition withObject:[NSNull null]];
        
        self->_digitPosition--;
        
        if( self.digitPosition<=self.maxDigits-1 )
        { [self enableButtons];
          
          if( self.textButton.superlayer )
          { [self.textButton stopAnimation];
            [self.textButton removeFromSuperlayer];
          } /* of if */
        } /* of if */
        
        if( self.digitPosition<0 )
          [self findButtonByText:kPound].enabled = NO;
      } /* of if */
    } /* of if */
    else if( [bl.digit isEqualToString:kStar] )
    { [self.delegate cancelPasswordView:self];
    } /* of else if */
    else
    {
      if( self.digitPosition<self.maxDigits-1 )
      { bl.pushed = YES;
        
        self->_digitPosition++;
        
        [self->_digits replaceObjectAtIndex:self.digitPosition withObject:bl.digit];
        
        ButtonLayer* dl = [self.dotLayers objectAtIndex:self.digitPosition];
        dl.digit = bl.digit;
        
        if( self.digitPosition>=self.maxDigits-1 )
        { [self disableButtons];
        
          if( self.textButton.superlayer==nil )
          { [self.layer addSublayer:self.textButton];
            [self.textButton startAnimation];
          } /* of if */
        } /* of if */
        
      } /* of if */
      
      [self findButtonByText:kPound].enabled = YES;
    } /* of else */
  } /* of if */
}


/**
 *
 */
-(void) dumpTouches:(NSSet*)touches withEvent:(UIEvent *)event
{
  /*
  for( UITouch* t in touches )
  {
    _NSLOG(@"0x%lx %@[%lf,%lf,%lf,%lf]: ts:%lf phase:%ld taps:%ld",
           (unsigned long)(__bridge void *)event,
           [t.view.class description],
           t.view.frame.origin.x,t.view.frame.origin.y,t.view.frame.size.width,t.view.frame.size.height,
           t.timestamp,
           (unsigned long)t.phase,
           (unsigned long)t.tapCount
          );
  } 
   */
}

/**
 *
 */
-(NSString*) password
{ NSMutableString* result = [[NSMutableString alloc] initWithCapacity:self.maxDigits];
  
  for( NSUInteger i=0;i<self.maxDigits;i++ )
    if( [self.digits objectAtIndex:i]==[NSNull null] )
      [result appendString:@"-"];
    else
      [result appendString:[self.digits objectAtIndex:i]];
  
  return result;
}



/**
 *
 */
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{ [self dumpTouches:touches withEvent:event];
  
  for( UITouch* touch in touches )
  { ButtonLayer* buttonLayer = [self findTouchedButton:touch];
  
    [self setButtonPushed:buttonLayer withValue:YES];
    
    if( buttonLayer==nil && CGRectContainsPoint(self.textButton.frame, [touch locationInView:self]) && self.digitPosition>=self.maxDigits-1 )
     [self.delegate closePasswordView:self];
  } /* of for */
}

/**
 *
 */
-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{ [self dumpTouches:touches withEvent:event];
  
  for( UITouch* touch in touches )
  { CGPoint viewLocation = [touch locationInView:self];
    BOOL    buttonFound  = NO;
    
    for( ButtonLayer* b in self.buttonLayers )
      if( CGRectContainsPoint(b.frame, viewLocation) )
      { buttonFound = YES;
        
        if( !b.pushed )
        { [self resetPushStateOfAllButtons:NO];
          
          [self setButtonPushed:b withValue:YES];
        } /* of if */
        
        break;
      } /* of if */
    
    if( !buttonFound )
      [self resetPushStateOfAllButtons:NO];
  } /* of for */
  
}

/**
 *
 */
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{ [self dumpTouches:touches withEvent:event];

  for( UITouch* touch in touches )
  { ButtonLayer* buttonLayer = [self findTouchedButton:touch];
    
    [self buttonPushed:buttonLayer];
    buttonLayer.pushed = NO;
  } /* of for */
}

/**
 *
 */
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{ [self dumpTouches:touches withEvent:event];
  
  [self resetPushStateOfAllButtons:YES];
}


/*
 *
 */
-(void) setButtonPushed:(ButtonLayer*)b withValue:(BOOL)pushed
{ if( b.enabled )
    b.pushed = pushed;
}

@end
