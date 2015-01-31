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
#import "PasswordViewController1.h"
#import "UIViewController+PromiseKit.h"
#import "SSKeychain.h"

@interface TresorAppDelegate () <DecryptedMasterKeyPromiseDelegate>
@property NSData* decryptedMasterKey;
@property NSDate* decryptedMasterKeyTS;
@end

@implementation TresorAppDelegate

/**
 * po [[[UIApplication sharedApplication] keyWindow] recursiveDescription]
 */
-(BOOL) application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{ _NSLOG(@"options:%@",launchOptions);
  
  [CryptoService sharedInstance].delegate = self;
  
  [self.window setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"Background"]]];
  
  self.window.rootViewController.view.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.8];
  
  NSArray* allAccounts = [SSKeychain allAccounts];
  for( id account in allAccounts )
    _NSLOG("account:%@",account);

  return YES;
}
							
/**
 *
 */
- (void)applicationWillResignActive:(UIApplication *)application
{
}

/**
 *
 */
- (void)applicationDidEnterBackground:(UIApplication *)application
{
}

/**
 *
 */
- (void)applicationWillEnterForeground:(UIApplication *)application
{
}

/**
 *
 */
- (void)applicationDidBecomeActive:(UIApplication *)application
{
}

/**
 *
 */
- (void)applicationWillTerminate:(UIApplication *)application
{
  [CryptoService sharedInstance].delegate = nil;
}

/**
 *
 */
-(void)applicationProtectedDataWillBecomeUnavailable:(UIApplication *)application
{ _NSLOG_SELECTOR;
}


/**
 *
 */
-(void)applicationProtectedDataDidBecomeAvailable:(UIApplication *)application
{ _NSLOG_SELECTOR;
}

#pragma mark DecryptedMasterKeyPromiseDelegate

/**
 *
 */
-(PMKPromise*) decryptedMasterKey:(MasterKey*)masterKey
{ PMKPromise* promise = nil;
  
  if( self.decryptedMasterKey && self.decryptedMasterKeyTS.timeIntervalSinceNow>-60.0 )
  { self.decryptedMasterKeyTS = [NSDate date];
    
    promise = [PMKPromise promiseWithValue:self.decryptedMasterKey];
  } /* of if */
  else
  { self.decryptedMasterKey = nil;
    
    if( masterKey )
    { UIViewController*         vc = self.window.rootViewController;
      PasswordViewController1* pvc = [PasswordViewController1 new];
      
      pvc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
      promise = [vc promiseViewController:pvc animated:YES completion:nil]
      .then(^(NSString* pin)
      { _NSLOG(@"pin               :%@",pin);
        
        return [masterKey decryptedMasterKeyUsingPIN:pin];
      })
      //.pause(2.0)
      .then(^(NSData* decryptedMasterKey)
      { _NSLOG(@"decryptedMasterKey:%@",[decryptedMasterKey shortHexStringValue]);
        
        self.decryptedMasterKey   = decryptedMasterKey;
        self.decryptedMasterKeyTS = [NSDate date];
              
        return decryptedMasterKey;
      });
    } /* of if */
  } /* of else */
  
  return promise;
}

@end
