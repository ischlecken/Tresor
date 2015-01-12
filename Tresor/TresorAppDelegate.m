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
  // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
  // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

/**
 *
 */
- (void)applicationDidEnterBackground:(UIApplication *)application
{
  // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
  // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

/**
 *
 */
- (void)applicationWillEnterForeground:(UIApplication *)application
{
  // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

/**
 *
 */
- (void)applicationDidBecomeActive:(UIApplication *)application
{
  // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

/**
 *
 */
- (void)applicationWillTerminate:(UIApplication *)application
{
  // Saves changes in the application's managed object context before the application terminates.
  
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
{ _NSLOG_SELECTOR;
  
  PMKPromise* promise = nil;
  
  if( self.decryptedMasterKey && self.decryptedMasterKeyTS.timeIntervalSinceNow>-60.0 )
  { self.decryptedMasterKeyTS = [NSDate date];
    promise = [PMKPromise promiseWithValue:self.decryptedMasterKey];
  } /* of if */
  else if( masterKey )
  { UIViewController*         vc = self.window.rootViewController;
    PasswordViewController1* pvc = [PasswordViewController1 new];
    
    pvc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    promise = [vc promiseViewController:pvc animated:YES completion:nil]
    .then(^(NSString* pin)
    { _NSLOG(@"pin=%@",pin);
      
      return [masterKey decryptedMasterKeyUsingPIN:pin];
    })
    .pause(2.0)
    .then(^(NSData* decryptedMasterKey)
    { _NSLOG(@"decryptedMasterKey=%@",decryptedMasterKey);
      
      self.decryptedMasterKey   = decryptedMasterKey;
      self.decryptedMasterKeyTS = [NSDate date];
            
      return decryptedMasterKey;
    });
  } /* of else */
  
  return promise;
}

@end
