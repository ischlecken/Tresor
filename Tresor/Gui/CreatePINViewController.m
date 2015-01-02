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
#import "CreatePINViewController.h"
#import "PasswordView.h"
#import "MBProgressHUD.h"

@interface CreatePINViewController () <PasswordViewDelegate>
@property (strong, nonatomic) IBOutlet PasswordView*    passwordView;
@property (weak  , nonatomic) IBOutlet UIBarButtonItem* confirmButton;
@end

@implementation CreatePINViewController

@synthesize parameter=_parameter;

/**
 *
 */
-(void) viewDidLoad
{ [super viewDidLoad];
  
  self.passwordView.showButton    = PasswordViewShowButtonWhenNoDigitIsEntered;
  self.passwordView.buttonText    = _LSTR(@"GeneratePin");
}

/**
 *
 */
-(void) viewWillAppear:(BOOL)animated
{ [super viewWillAppear:animated];
  
  [self.passwordView resetDigits];
  self.confirmButton.enabled = NO;
}


/**
 *
 */
-(void) generatePIN
{ _NSLOG_SELECTOR;
  
  NSUInteger      keySize      = self.passwordView.maxDigits;
  NSData*         passwordData = [NSData dataWithRandom:keySize];
  NSData*         salt         = [NSData dataWithRandom:keySize];

#if TARGET_IPHONE_SIMULATOR
  NSUInteger      iterations   = 4000000;
#else
  NSUInteger      iterations   = 1000000;
#endif
  
  MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:_APPWINDOW animated:YES];
  hud.labelText = _LSTR(@"GeneratingPin");
  
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^
  { _NSLOG(@"generatePIN.start");
   
    NSError*  error      = nil;
    NSData*   derivedKey = [passwordData deriveKeyWithAlgorithm:deriveKeyAlgoPBKDF2CC withLength:keySize usingSalt:salt andIterations:iterations error:&error];
    NSString* pin        = [[derivedKey hexStringValue] substringToIndex:self.passwordView.maxDigits];
   _NSLOG(@"generatePIN.stop:<%@>",pin);
   
   dispatch_async(dispatch_get_main_queue(), ^
   { [MBProgressHUD hideHUDForView:_APPWINDOW animated:YES];
     
     for( NSUInteger i=0;i<pin.length;i++ )
       [self.passwordView addDigit:[pin substringWithRange:NSMakeRange(i, 1)]];
   });
  });
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
{ [self generatePIN];
}

/**
 *
 */
-(void) passwordViewDigitsEntered:(PasswordView *)passwordView allDigits:(BOOL)allDigits
{ self.confirmButton.enabled = allDigits;
  
  if( allDigits )
    self.parameter.vaultPIN = passwordView.password;
}

#pragma mark prepare Segue

/**
 *
 */
-(BOOL) shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{ BOOL result = YES;
  
  if( [identifier isEqualToString:@"ConfirmPIN"] )
  {
    if( self.parameter.vaultPIN )
    { NSString* allowedChars = @"0123456789ABCDEF";
      
      for( NSUInteger i=0;i<allowedChars.length;i++ )
      { unichar ch = [allowedChars characterAtIndex:i];
        
        if( [self.parameter.vaultPIN containsOnlyCharacter:ch] )
        { result = NO;
         
          NSString* msg = [NSString stringWithFormat:@"PIN contains only character %@",[allowedChars substringWithRange:NSMakeRange(i, 1)]];
          
          _NSLOG(@"%@",msg);
          
          UIAlertController* alert = [UIAlertController alertControllerWithTitle:_LSTR(@"PINCheckFailedTitle") message:msg preferredStyle:UIAlertControllerStyleAlert];
          
          [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action)
          { self.confirmButton.enabled = NO;
            
            [self.passwordView resetDigits];
          }]];
          
          [self presentViewController:alert animated:YES completion:NULL];
          
          break;
        } /* of if */
      } /* of for */
    } /* of if */
  } /* of if */
  
  return result;
}

/**
 *
 */
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{ _NSLOG(@"[%@]",segue.identifier);
  
  if( [[segue identifier] isEqualToString:@"ConfirmPIN"] )
  { id vc0 = [segue destinationViewController];
    
    if( [vc0 conformsToProtocol:@protocol(EditVaultParameter)] )
    { id<EditVaultParameter> vc1 = vc0;
      
      vc1.parameter = self.parameter;
    } /* of if */
  } /* of if */
}

@end
