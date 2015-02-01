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

#define kDecryptedMasterKeyTimeout 30.0

@interface DecryptedMasterKey : NSObject
@property(strong,nonatomic,readonly) NSData*   decryptedMasterKey;
@property(strong,nonatomic,readonly) NSDate*   decryptedMasterKeyTS;
@property(strong,nonatomic,readonly) NSNumber* timeoutProgress;
@property(strong,nonatomic         ) Vault*    vault;
@end


@interface DecryptedMasterKeyManager : NSObject <DecryptedMasterKeyPromiseDelegate>
+(instancetype)        sharedInstance;
-(DecryptedMasterKey*) getInfo:(Vault*)vault;
@end
