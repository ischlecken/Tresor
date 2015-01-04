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
#import "ConfirmPINViewController.h"
#import "PasswordView.h"
#import "PUKViewController.h"

@interface ConfirmPINViewController () <PasswordViewDelegate>
@property (weak  , nonatomic) IBOutlet UIBarButtonItem* createPUKButton;
@property (strong, nonatomic) IBOutlet PasswordView*    passwordView;
@end

@implementation ConfirmPINViewController

@synthesize parameter=_parameter;

/**
 *
 */
-(void) viewDidLoad
{ [super viewDidLoad];
  
  self.passwordView.showButton    = PasswordViewShowButtonWhenAllDigitsAreEntered;
  self.passwordView.buttonText    = _LSTR(@"PINConfirmed");
}


/**
 *
 */
-(void) viewWillAppear:(BOOL)animated
{ [super viewWillAppear:animated];
  
  [self.passwordView resetDigits];
  self.createPUKButton.enabled = NO;
}

#pragma mark PasswordViewDelegate

/**
 *
 */
-(void) passwordViewCanceled:(PasswordView *)passwordView
{
}


/**
 *
 */
-(void) passwordViewButtonPushed:(PasswordView *)passwordView
{ if( [self.parameter.vaultParameter.pin isEqualToString:passwordView.password] )
    _NSLOG(@"pin %@ confirmed.",self.parameter.vaultParameter.pin);
}

/**
 *
 */
-(void) passwordViewDigitsEntered:(PasswordView *)passwordView allDigits:(BOOL)allDigits
{ if( allDigits )
  {
    if( [self.passwordView.password isEqualToString:self.parameter.vaultParameter.pin] )
      self.createPUKButton.enabled = YES;
    else
      [self.passwordView resetDigits];
  } /* of if */
  else
    self.createPUKButton.enabled = NO;
}


#pragma mark prepare Segue

/**
 *
 */
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{ _NSLOG(@"[%@]",segue.identifier);
  
  if( [[segue identifier] isEqualToString:@"CreatePUK"] )
  { id vc0 = [segue destinationViewController];
    
    if( [vc0 conformsToProtocol:@protocol(EditVaultParameter)] )
    { id<EditVaultParameter> vc1 = vc0;
      
      vc1.parameter = self.parameter;
      
      if( [vc0 isKindOfClass:[PUKViewController class]] )
      {
        
        ((PUKViewController*)vc0).validatePUK = NO;
      } /* of if */
    } /* of if */
  } /* of if */
}

@end
