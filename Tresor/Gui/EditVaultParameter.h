//
//  EditVaultParameter.h
//  Tresor
//
//  Created by Feldmaus on 14.12.14.
//  Copyright (c) 2014 ischlecken. All rights reserved.
//
#import "Vault.h"

@interface EditVaultParameter : NSObject

@property(strong,nonatomic) Vault*     vault;

@property(strong,nonatomic) NSString*  vaultName;
@property(assign,nonatomic) NSUInteger vaultType;
@property(strong,nonatomic) NSArray*   vaultTypes;

@property(strong,nonatomic) UIImage*   vaultIcon;

@property(strong,nonatomic) NSString*  vaultPIN;
@property(strong,nonatomic) NSString*  vaultPUK;

+(instancetype) editVaultParameterWithVault:(Vault*)vault;

-(NSString*) selectedVaultType;
@end
