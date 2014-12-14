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

@interface ConfirmPINViewController () <PasswordViewDelegate>
@end

@implementation ConfirmPINViewController

@synthesize parameter=_parameter;

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
  
  self.pin = ((PasswordView*)self.view).password;
  
  [self performSegueWithIdentifier:@"passwordControllerUnwindSegue" sender:self];
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
    } /* of if */
  } /* of if */
}

@end
