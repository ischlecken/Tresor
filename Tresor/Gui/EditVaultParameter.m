//
//  EditVaultParameter.m
//  Tresor
//
//  Created by Feldmaus on 14.12.14.
//  Copyright (c) 2014 ischlecken. All rights reserved.
//

#import "EditVaultParameter.h"

@implementation EditVaultParameter

/**
 *
 */
-(instancetype) init
{ self = [super init];
 
  if( self )
  {
    self.vaultTypes = @[@"Bank",@"EMail",@"Accounts",@"Internet",@"Sonstiges"];
    self.vaultType  = 2;
  } /* of if */
  
  return self;
}

/**
 *
 */
-(instancetype) initWithVault:(Vault*)vault
{ self =[self init];
  
  if( self && vault )
  { self.vault     = vault;
    self.vaultName = vault.vaultname;
    self.vaultType = NSUIntegerMax;
    
    if( vault.vaulticon )
      self.vaultIcon = [UIImage imageWithData:vault.vaulticon];
    
    if( vault.vaulttype )
      for( NSUInteger i=0;i<self.vaultTypes.count;i++ )
        if( [self.vaultTypes[i] isEqualToString:vault.vaulttype] )
        { self.vaultType = i;
          
          break;
        } /* of if */
  } /* of if */
  
  return self;
}

/**
 *
 */
+(instancetype) editVaultParameterWithVault:(Vault*)vault
{ EditVaultParameter* result = [[EditVaultParameter alloc] initWithVault:vault];
  
  return result;
}

/**
 *
 */
-(NSString*) selectedVaultType
{ NSString* result = nil;
  
  if( self.vaultType!=NSUIntegerMax && self.vaultType<self.vaultTypes.count )
    result = self.vaultTypes[self.vaultType];
  
  return result;
}
@end
