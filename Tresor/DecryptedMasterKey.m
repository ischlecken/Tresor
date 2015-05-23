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
 * Copyright (c) 2015 ischlecken.
 */
#import "DecryptedMasterKey.h"
#import "PasswordViewController1.h"
#import "MBProgressHUD.h"

#pragma mark - DecryptedMasterKey

@interface DecryptedMasterKey ()
{ NSData*   _decryptedMasterKey;
  NSDate*   _decryptedMasterKeyTS;
  NSNumber* _timeoutProgress;
}
@end

@implementation DecryptedMasterKey

/**
 *
 */
-(void) updateTimeout
{ float result = fmin(fabs([self.decryptedMasterKeyTS timeIntervalSinceNow]/kDecryptedMasterKeyTimeout),1.0);
  
  if( self->_timeoutProgress==nil || [self->_timeoutProgress floatValue]!=result )
  { if( result>=1.0 )
    { self->_decryptedMasterKey = nil;
      
      [[DecryptedObjectCache sharedInstance] flushForVault:self.vault];
    } /* of if */
    
    [self willChangeValueForKey:@"timeoutProgress"];
    self->_timeoutProgress = [NSNumber numberWithFloat:result];
    [self didChangeValueForKey:@"timeoutProgress"];
    
    _NSLOG(@"timeoutProgress:%f",result);
  } /* of if */
}

/**
 *
 */
-(AnyPromise*) decryptedMasterKey:(MasterKey*)masterKey
{ AnyPromise* promise = nil;
  
  if( self.decryptedMasterKey && self.decryptedMasterKeyTS.timeIntervalSinceNow>-kDecryptedMasterKeyTimeout )
  { self->_decryptedMasterKeyTS = [NSDate date];
    [self updateTimeout];
    
    promise = [AnyPromise promiseWithValue:self.decryptedMasterKey];
  } /* of if */
  else
  { self->_decryptedMasterKey = nil;
    
    if( masterKey )
    { UIViewController*         vc = _APPWINDOW.rootViewController;
      PasswordViewController1* pvc = [PasswordViewController1 new];
      
      pvc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
      promise = [vc promiseViewController:pvc animated:YES completion:nil]
      .then(^(NSString* pin)
      { _NSLOG(@"pin               :%@",pin);
        
        MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:_APPWINDOW animated:YES];
        
        hud.color     = _HUDCOLOR;
        hud.labelText = _LSTR(@"DecryptPayload");
        
        return [masterKey decryptedMasterKeyUsingPIN:pin];
      })
      //.pause(2.0)
      .then(^(NSData* decryptedMasterKey)
      { _NSLOG(@"decryptedMasterKey:%@",[decryptedMasterKey shortHexStringValue]);
        
        self->_decryptedMasterKey   = decryptedMasterKey;
        self->_decryptedMasterKeyTS = [NSDate date];
        [self updateTimeout];
        
        return decryptedMasterKey;
      });
    } /* of if */
  } /* of else */
  
  return promise;
}
@end

#pragma mark - DecryptedMasterKeyManager

@interface DecryptedMasterKeyManager ()
@property NSMutableArray* vaults;
@property NSTimer*        updateTimer;
@end

@implementation DecryptedMasterKeyManager

/**
 *
 */
+(instancetype)     sharedInstance
{ static DecryptedMasterKeyManager* _inst = nil;
  static dispatch_once_t            oncePredicate;
  
  dispatch_once(&oncePredicate,^{ _inst = [self new]; });
  
  return _inst;
}

/**
 *
 */
-(instancetype)init
{ self = [super init];
 
  if( self )
  { self.vaults      = [[NSMutableArray alloc] initWithCapacity:3];
    self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(updateTimeoutInfo:) userInfo:nil repeats:YES];
  } /* of if */
  
  return self;
}

/**
 *
 */
-(DecryptedMasterKey*) getInfo:(Vault*)vault
{ DecryptedMasterKey* result = nil;
  
  for( DecryptedMasterKey* dmk in self.vaults )
    if( dmk.vault==vault )
    { result = dmk;
      
      break;
    } /* of if */
  
  if( result==nil )
  { result = [DecryptedMasterKey new];
    
    result.vault = vault;
    
    [self.vaults addObject:result];
  } /* of if */

  return result;
}

/**
 *
 */
-(AnyPromise*) decryptedMasterKey:(MasterKey*)masterKey
{ AnyPromise* result = nil;
 
  if( masterKey==nil || masterKey.vault==nil )
    @throw [NSException exceptionWithName:@"masterKeyVaultNotSetException" reason:nil userInfo:nil];
  
  DecryptedMasterKey* dmk = [self getInfo:masterKey.vault];
  
  result = [dmk decryptedMasterKey:masterKey];
  
  return result;
}

/**
 *
 */
-(void) updateTimeoutInfo:(NSTimer *)timer
{ for( DecryptedMasterKey* dmk in self.vaults )
    [dmk updateTimeout];
}

@end
