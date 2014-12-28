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

#import "DigitLayer.h"

@interface ButtonLayer : CAShapeLayer
-(id) initWithDigit:(NSString*)digit;

@property(strong,nonatomic)          NSString*     digit;
@property(strong,nonatomic)          UIColor*      digitColor;
@property(weak  ,nonatomic)          NSString*     fontName;
@property(assign,nonatomic)          BOOL          pushed;
@property(assign,nonatomic)          BOOL          enabled;
@property(assign,nonatomic)          NSUInteger    index;

@property(strong,nonatomic,readonly) CAShapeLayer* innerRing;
@property(strong,nonatomic,readonly) DigitLayer*   digitLabel;

-(void) disableButton;
-(void) enableButton;
@end

