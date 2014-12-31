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
#import "ButtonAnimationAction.h"
#import "ButtonLayer.h"


@implementation OnAnimationAction

/**
 *
 */
- (instancetype)init
{ self = [super init];
  
  if( self )
  { self.disappearDuration = 0.6;
  }
  
  return self;
}

/**
 *
 */
-(void) runActionForKey:(NSString *)event object:(id)anObject arguments:(NSDictionary *)dict
{ ButtonLayer*      layer    = (ButtonLayer*)anObject;
  CFTimeInterval    duration = 0.6;

  CABasicAnimation* anim2 = [CABasicAnimation animationWithKeyPath:@"strokeStart"];
  anim2.duration            = duration;
  anim2.fromValue           = @(1.0);
  anim2.toValue             = @(0.0);
  anim2.fillMode            = kCAFillModeForwards;
  anim2.removedOnCompletion = NO;
  [layer.innerRing addAnimation:anim2 forKey:@"strokeBeginAnim"];

  CABasicAnimation* anim3 = [CABasicAnimation animationWithKeyPath:@"fillColor"];
  anim3.duration            = duration;
  anim3.fromValue           = (id)[UIColor clearColor].CGColor;
  anim3.toValue             = (id)[UIColor colorWithWhite:1.0 alpha:0.5].CGColor;
  anim3.fillMode            = kCAFillModeRemoved;
  anim3.removedOnCompletion = NO;
  [layer addAnimation:anim3 forKey:@"fillColorAnim"];

  CABasicAnimation* anim4 = [CABasicAnimation animationWithKeyPath:@"fillColor"];
  anim4.beginTime           = CACurrentMediaTime()+duration;
  anim4.duration            = self.disappearDuration;
  anim4.fromValue           = (id)[UIColor colorWithWhite:1.0 alpha:0.5].CGColor;
  anim4.toValue             = (id)[UIColor colorWithWhite:1.0 alpha:1.0].CGColor;
  anim4.fillMode            = kCAFillModeForwards;
  anim4.removedOnCompletion = NO;
  [layer addAnimation:anim4 forKey:@"fillColor1Anim"];

}

@end


@implementation OffAnimationAction

/**
 *
 */
-(void) runActionForKey:(NSString *)event object:(id)anObject arguments:(NSDictionary *)dict
{ ButtonLayer*      layer    = (ButtonLayer*)anObject;
  CFTimeInterval    duration = 0.6;
  
  CABasicAnimation* anim2 = [CABasicAnimation animationWithKeyPath:@"strokeStart"];
  anim2.duration            = duration;
  anim2.fromValue           = @(0.0);
  anim2.toValue             = @(1.0);
  anim2.fillMode            = kCAFillModeForwards;
  anim2.removedOnCompletion = NO;
  [layer.innerRing addAnimation:anim2 forKey:@"strokeBeginAnim"];
  
  CABasicAnimation* anim3 = [CABasicAnimation animationWithKeyPath:@"fillColor"];
  anim3.duration            = duration;
  anim3.toValue             = (id)[UIColor clearColor].CGColor;
  anim3.fromValue           = (id)[UIColor colorWithWhite:1.0 alpha:1.0].CGColor;
  anim3.fillMode            = kCAFillModeForwards;
  anim3.removedOnCompletion = NO;
  [layer addAnimation:anim3 forKey:@"fillColor1Anim"];
}

@end

@implementation OnAnimationAction1

/**
 *
 */
-(void) runActionForKey:(NSString *)event object:(id)anObject arguments:(NSDictionary *)dict
{ ButtonLayer*      layer    = (ButtonLayer*)anObject;
  CFTimeInterval    duration = 0.6;
  
  CABasicAnimation* anim1 = [CABasicAnimation animationWithKeyPath:@"transform"];
  anim1.duration            = duration;
  anim1.fromValue           = [NSValue valueWithCATransform3D:CATransform3DIdentity];
  anim1.toValue             = [NSValue valueWithCATransform3D:CATransform3DScale(CATransform3DIdentity, 1.8, 1.8, 1.0)];
  anim1.fillMode            = kCAFillModeForwards;
  anim1.removedOnCompletion = NO;
  anim1.timingFunction      = [CAMediaTimingFunction functionWithControlPoints:0.23 :0.97 :0.25 :1.00];
  [layer addAnimation:anim1 forKey:@"transformAnim"];

  CABasicAnimation* anim2 = [CABasicAnimation animationWithKeyPath:@"lineWidth"];
  anim2.duration            = duration;
  anim2.fromValue           = @(2.0);
  anim2.toValue             = @(5.0);
  anim2.fillMode            = kCAFillModeForwards;
  anim2.removedOnCompletion = NO;
  [layer addAnimation:anim2 forKey:@"lineWidthAnim"];
  
  CABasicAnimation* anim3 = [CABasicAnimation animationWithKeyPath:@"fillColor"];
  anim3.duration            = duration;
  anim3.fromValue           = (id)[UIColor clearColor].CGColor;
  anim3.toValue             = (id)[UIColor colorWithWhite:0.9 alpha:1.0].CGColor;
  anim3.fillMode            = kCAFillModeForwards;
  anim3.removedOnCompletion = NO;
  [layer addAnimation:anim3 forKey:@"fillColorAnim"];
}

@end


@implementation OffAnimationAction1

/**
 *
 */
-(void) runActionForKey:(NSString *)event object:(id)anObject arguments:(NSDictionary *)dict
{ ButtonLayer*      layer    = (ButtonLayer*)anObject;
  CFTimeInterval    duration = 0.6;
  
  CABasicAnimation* anim1 = [CABasicAnimation animationWithKeyPath:@"transform"];
  anim1.duration            = duration;
  anim1.toValue             = [NSValue valueWithCATransform3D:CATransform3DIdentity];
  anim1.fromValue           = [NSValue valueWithCATransform3D:CATransform3DScale(CATransform3DIdentity, 1.8, 1.8, 1.0)];
  anim1.fillMode            = kCAFillModeForwards;
  anim1.removedOnCompletion = NO;
  anim1.timingFunction      = [CAMediaTimingFunction functionWithControlPoints:0.23 :0.97 :0.25 :1.00];
  [layer addAnimation:anim1 forKey:@"transformAnim"];
  
  CABasicAnimation* anim2 = [CABasicAnimation animationWithKeyPath:@"lineWidth"];
  anim2.duration            = duration;
  anim2.fromValue           = @(5.0);
  anim2.toValue             = layer.enabled ? @(2.0) : @(0.5);
  anim2.fillMode            = kCAFillModeForwards;
  anim2.removedOnCompletion = NO;
  [layer addAnimation:anim2 forKey:@"lineWidthAnim"];
  
  CABasicAnimation* anim3 = [CABasicAnimation animationWithKeyPath:@"fillColor"];
  anim3.duration            = duration;
  anim3.toValue             = (id)[UIColor clearColor].CGColor;
  anim3.fromValue           = (id)[UIColor colorWithWhite:1.0 alpha:1.0].CGColor;
  anim3.fillMode            = kCAFillModeForwards;
  anim3.removedOnCompletion = NO;
  [layer addAnimation:anim3 forKey:@"fillColorAnim"];
}

@end

@implementation OnAnimationAction2

/**
 *
 */
-(void) runActionForKey:(NSString *)event object:(id)anObject arguments:(NSDictionary *)dict
{ ButtonLayer*      layer    = (ButtonLayer*)anObject;
  CFTimeInterval    duration = 0.6;
  
  CABasicAnimation* anim2 = [CABasicAnimation animationWithKeyPath:@"lineWidth"];
  anim2.duration            = duration;
  anim2.fromValue           = @(0.5);
  anim2.toValue             = @(2.0);
  anim2.fillMode            = kCAFillModeForwards;
  anim2.removedOnCompletion = NO;
  [layer addAnimation:anim2 forKey:@"lineWidthAnim1"];
}

@end


@implementation OffAnimationAction2

/**
 *
 */
-(void) runActionForKey:(NSString *)event object:(id)anObject arguments:(NSDictionary *)dict
{ ButtonLayer*      layer    = (ButtonLayer*)anObject;
  CFTimeInterval    duration = 0.6;
  
  CABasicAnimation* anim2 = [CABasicAnimation animationWithKeyPath:@"lineWidth"];
  anim2.duration            = duration;
  anim2.fromValue           = @(2.0);
  anim2.toValue             = @(0.5);
  anim2.fillMode            = kCAFillModeForwards;
  anim2.removedOnCompletion = NO;
  [layer addAnimation:anim2 forKey:@"lineWidthAnim1"];
}

@end