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

@interface TresorAppDelegate () <DecryptedPayloadKeyPromiseDelegate>
@property NSData* lastPasswordKey;
@property NSDate* lastPasswordKeyTS;
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

#pragma mark DecryptedPayloadKeyPromiseDelegate

/**
 *
 */
-(PMKPromise*) decryptedPayloadKeyPromiseForPayload:(Payload*)payload
{ _NSLOG_SELECTOR;
  
  PMKPromise* promise = nil;
  
  if( self.lastPasswordKey && self.lastPasswordKeyTS.timeIntervalSinceNow>-60.0 )
  { self.lastPasswordKeyTS = [NSDate date];
    promise = [PMKPromise promiseWithValue:self.lastPasswordKey];
  } /* of if */
  else
  { UIViewController*         vc = self.window.rootViewController;
    PasswordViewController1* pvc = [PasswordViewController1 new];
    
    pvc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    promise = [vc promiseViewController:pvc animated:YES completion:nil]
    .then(^(NSString* password)
    { _NSLOG(@"password=%@",password);
      
      return [password dataUsingEncoding:NSUTF8StringEncoding];
    })
    .pause(2.0)
    .then(^(NSData* passwordKey)
    { _NSLOG(@"passwordKey=%@",passwordKey);
      
      self.lastPasswordKey   = passwordKey;
      self.lastPasswordKeyTS = [NSDate date];
            
      return passwordKey;
    });
  } /* of else */
  
  return promise;
}

@end
