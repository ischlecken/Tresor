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
  
  if( [self.view isKindOfClass:[PasswordView class]] )
  { PasswordView* passwordView = (PasswordView*)self.view;
    
    passwordView.showButton = PasswordViewShowButtonAlways;
    passwordView.buttonText = _LSTR(@"Test");
  } /* of if */
}

/**
 *
 */
-(BOOL)prefersStatusBarHidden
{ return YES; }

/**
 *
 */
-(void) passwordViewCanceled:(PasswordView *)passwordView
{ _NSLOG_SELECTOR;
  
  [self performSegueWithIdentifier:@"passwordControllerUnwindSegue" sender:self];
}


/**
 *
 */
-(void) passwordViewButtonPushed:(PasswordView *)passwordView
{ _NSLOG_SELECTOR;
  
  self.password = ((PasswordView*)self.view).password;
  
  [self performSegueWithIdentifier:@"passwordControllerUnwindSegue" sender:self];
}
@end
