//
//  PasswordViewController.m
//  Tresor
//
//  Created by Feldmaus on 21.08.14.
//  Copyright (c) 2014 ischlecken. All rights reserved.
//
#import "PasswordViewController.h"
#import "PasswordView.h"

@interface PasswordViewController () <PasswordViewDelegate>
@end

@implementation PasswordViewController


/**
 *
 */
-(void) viewDidLoad
{ [super viewDidLoad];
  
  PasswordView* pv = (PasswordView*)self.view;
  
  pv.maxDigits = 6;
  pv.delegate  = self;
}

/**
 *
 */
-(BOOL)prefersStatusBarHidden
{ return YES; }

/**
 *
 */
-(void) cancelPasswordView:(PasswordView *)passwordView
{ _NSLOG_SELECTOR;
  
  [self performSegueWithIdentifier:@"passwordControllerUnwindSegue" sender:self];
}


/**
 *
 */
-(void) closePasswordView:(PasswordView *)passwordView
{ _NSLOG_SELECTOR;
  
  self.password = ((PasswordView*)self.view).password;
  
  [self performSegueWithIdentifier:@"passwordControllerUnwindSegue" sender:self];
}
@end
