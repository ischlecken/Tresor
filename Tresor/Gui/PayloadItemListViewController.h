//  Created by Feldmaus on 04.05.14.
//  Copyright (c) 2014 ischlecken. All rights reserved.
//
#import "Vault.h"
#import "Payload.h"
#import "PayloadItemList.h"
#import "PayloadItem.h"
#import "DecryptedMasterKey.h"

@interface PayloadItemListViewController : UITableViewController
@property(strong,nonatomic)          Vault*              vault;
@property(strong,nonatomic)          NSIndexPath*        path;
@property(strong,nonatomic,readonly) PayloadItemList*    payloadItemList;
@property(strong,nonatomic)          PayloadItemList*    readonlyPayloadItemList;
@property(strong,nonatomic)          PayloadItemList*    editPayloadItemList;
@property(strong,nonatomic)          DecryptedMasterKey* decryptedMasterKey;

@property(weak  ,nonatomic) IBOutlet UIProgressView*     timeoutProgressView;

@end
