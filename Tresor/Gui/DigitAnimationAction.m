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
#import "DigitAnimationAction.h"
#import "DigitLayer.h"


@implementation DigitLayerDigitColorAction

/**
 *
 */
-(void) runActionForKey:(NSString *)event object:(id)anObject arguments:(NSDictionary *)dict
{ DigitLayer*       layer    = (DigitLayer*)anObject;
  CFTimeInterval    duration = 1.8;
  
  CABasicAnimation* anim3 = [CABasicAnimation animationWithKeyPath:@"digitColor"];
  anim3.duration            = duration;
  anim3.fromValue           = (id)[UIColor blackColor].CGColor;
  anim3.toValue             = (id)[UIColor colorWithWhite:1.0 alpha:1.0].CGColor;
  anim3.fillMode            = kCAFillModeForwards;
  anim3.removedOnCompletion = NO;
  [layer addAnimation:anim3 forKey:@"digitColorAnim"];
}

@end

