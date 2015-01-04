//
//  EditVaultParameter.h
//  Tresor
//
//  Created by Feldmaus on 14.12.14.
//  Copyright (c) 2014 ischlecken. All rights reserved.
//
#import "Vault.h"

@interface EditVaultParameter : NSObject
@property(strong,nonatomic) Vault*          vault;
@property(strong,nonatomic) NSArray*        vaultTypes;
@property(strong,nonatomic) VaultParameter* vaultParameter;

+(instancetype) editVaultParameterWithVault:(Vault*)vault;

-(NSString*) selectedVaultType;
@end

@protocol EditVaultParameter <NSObject>
@property(strong , nonatomic) EditVaultParameter* parameter;
@end
