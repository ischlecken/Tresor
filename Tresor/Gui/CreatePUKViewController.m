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
#import "CreatePUKViewController.h"
#import "PasswordView.h"

@interface CreatePUKViewController () <PasswordViewDelegate,UITextFieldDelegate>
@property(nonatomic,weak  ) IBOutlet UIScrollView* scrollView;
@property(nonatomic,weak  ) IBOutlet UIView*       contentView;

@property(nonatomic,weak  ) IBOutlet UITextField*  textField_0;
@property(nonatomic,weak  ) IBOutlet UITextField*  textField_1;
@property(nonatomic,weak  ) IBOutlet UITextField*  textField_2;
@property(nonatomic,weak  ) IBOutlet UITextField*  textField_3;

@property(nonatomic,weak  ) IBOutlet UITextField*  textField_4;
@property(nonatomic,weak  ) IBOutlet UITextField*  textField_5;
@property(nonatomic,weak  ) IBOutlet UITextField*  textField_6;
@property(nonatomic,weak  ) IBOutlet UITextField*  textField_7;

@property(nonatomic,weak  ) IBOutlet UITextField*  textField_8;
@property(nonatomic,weak  ) IBOutlet UITextField*  textField_9;
@property(nonatomic,weak  ) IBOutlet UITextField*  textField_a;
@property(nonatomic,weak  ) IBOutlet UITextField*  textField_b;

@property(nonatomic,weak  ) IBOutlet UITextField*  textField_c;
@property(nonatomic,weak  ) IBOutlet UITextField*  textField_d;
@property(nonatomic,weak  ) IBOutlet UITextField*  textField_e;
@property(nonatomic,weak  ) IBOutlet UITextField*  textField_f;

@property(nonatomic,weak  ) IBOutlet UITextField*  activeTextField;

@property(nonatomic,strong)          NSArray*      textFields;

@end

@implementation CreatePUKViewController

@synthesize parameter=_parameter;

/**
 *
 */
-(void) viewDidLoad
{ [super viewDidLoad];
  
  self.textFields = @[self.textField_0,self.textField_1,self.textField_2,self.textField_3,
                      self.textField_4,self.textField_5,self.textField_6,self.textField_7,
                      self.textField_8,self.textField_9,self.textField_a,self.textField_b,
                      self.textField_c,self.textField_d,self.textField_e,self.textField_f,
                     ];
  
  
  NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:self.contentView
                                                                    attribute:NSLayoutAttributeLeading
                                                                    relatedBy:0
                                                                       toItem:self.view
                                                                    attribute:NSLayoutAttributeLeft
                                                                   multiplier:1.0
                                                                     constant:0];
  [self.view addConstraint:leftConstraint];
  
  NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:self.contentView
                                                                     attribute:NSLayoutAttributeTrailing
                                                                     relatedBy:0
                                                                        toItem:self.view
                                                                     attribute:NSLayoutAttributeRight
                                                                    multiplier:1.0
                                                                      constant:-0];
  [self.view addConstraint:rightConstraint];
}

/**
 *
 */
-(void) viewWillAppear:(BOOL)animated
{ [super viewWillAppear:animated];
 
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(keyboardDidShow:)
                                               name:UIKeyboardDidShowNotification
                                             object:nil];
  
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(keyboardWillBeHidden:)
                                               name:UIKeyboardWillHideNotification
                                             object:nil];
}

/**
 *
 */
-(void) viewWillDisappear:(BOOL)animated
{ [super viewWillDisappear:animated];
  
  [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification  object:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark keyboard delegate

/**
 *
 */
-(void) keyboardDidShow:(NSNotification *)notification
{ _NSLOG_SELECTOR;
  
  NSDictionary* info   = [notification userInfo];
  CGRect        kbRect = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
  
  kbRect = [self.view convertRect:kbRect fromView:nil];
  
  UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbRect.size.height, 0.0);
  
  self.scrollView.contentInset          = contentInsets;
  self.scrollView.scrollIndicatorInsets = contentInsets;
  
  CGRect aRect = self.view.frame;
  aRect.size.height -= kbRect.size.height;
  
  if( !CGRectContainsPoint(aRect, self.activeTextField.frame.origin) )
    [self.scrollView scrollRectToVisible:self.activeTextField.frame animated:YES];
}

/**
 *
 */
-(void) keyboardWillBeHidden:(NSNotification *)notification
{ _NSLOG_SELECTOR;
  
  UIEdgeInsets contentInsets = UIEdgeInsetsZero;

  self.scrollView.contentInset         = contentInsets;
  self.scrollView.scrollIndicatorInsets = contentInsets;
}

#pragma mark UITextFieldDelegate

/**
 *
 */
-(void) textFieldDidBeginEditing:(UITextField *)textField
{ _NSLOG_SELECTOR;
 
  self.activeTextField = textField;
}

/**
 *
 */
-(void) textFieldDidEndEditing:(UITextField *)textField
{ _NSLOG_SELECTOR;
  
  self.activeTextField = nil;
}

#pragma mark PasswordViewDelegate

/**
 *
 */
-(void) cancelPasswordView:(PasswordView *)passwordView
{ _NSLOG_SELECTOR;
  
}


/**
 *
 */
-(void) closePasswordView:(PasswordView *)passwordView
{ _NSLOG_SELECTOR;
  
  self.puk = passwordView.password;
  
}

#pragma mark prepare Segue

/**
 *
 */
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{ _NSLOG(@"[%@]",segue.identifier);
  
  if( [[segue identifier] isEqualToString:@"ConfirmPUK"] )
  { id vc0 = [segue destinationViewController];
    
    if( [vc0 conformsToProtocol:@protocol(EditVaultParameter)] )
    { id<EditVaultParameter> vc1 = vc0;
      
      vc1.parameter = self.parameter;
    } /* of if */
  } /* of if */
}

@end
