//
//  PasswordView.h
//  Tresor
//
//  Created by Feldmaus on 21.08.14.
//  Copyright (c) 2014 ischlecken. All rights reserved.
//

@class PasswordView;

@protocol PasswordViewDelegate <NSObject>
-(void)      cancelPasswordView:(PasswordView*)passwordView;
-(void)      closePasswordView:(PasswordView*)passwordView;
@end

@interface PasswordView : UIView
-(NSString*) password;

@property(assign  ,nonatomic) NSInteger                maxDigits;
@property(weak    ,nonatomic) id<PasswordViewDelegate> delegate;
@end
