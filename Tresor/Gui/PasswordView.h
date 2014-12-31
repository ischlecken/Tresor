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
@class PasswordView;

@protocol PasswordViewDelegate <NSObject>
-(void) passwordViewCanceled:(PasswordView*)passwordView;
-(void) passwordViewButtonPushed:(PasswordView*)passwordView;

@optional
-(void) passwordViewDigitsEntered:(PasswordView*)passwordView allDigits:(BOOL)allDigits;
@end

typedef NS_ENUM(NSUInteger, PasswordViewShowButtonType)
{ PasswordViewShowButtonNever=0,
  PasswordViewShowButtonAlways,
  PasswordViewShowButtonWhenNoDigitIsEntered,
  PasswordViewShowButtonWhenAllDigitsAreEntered
};


@interface PasswordView : UIView
-(NSString*) password;

@property(assign  ,nonatomic)          NSInteger                  maxDigits;
@property(assign  ,nonatomic)          BOOL                       displayDigits;
@property(strong  ,nonatomic)          NSString*                  buttonText;
@property(assign  ,nonatomic)          PasswordViewShowButtonType showButton;
@property(weak    ,nonatomic) IBOutlet id<PasswordViewDelegate>   delegate;

-(void) addDigit:(NSString*)digit;
-(void) resetDigits;
@end
