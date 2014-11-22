 //
//  CreateVaultViewController.h
//  Tresor
//
//  Created by Feldmaus on 18.06.14.
//  Copyright (c) 2014 ischlecken. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditVaultViewController : UIViewController
@property(weak   , nonatomic) IBOutlet UITextView*   vaultName;
@property(weak   , nonatomic) IBOutlet UIPickerView* vaultType;
@property(weak   , nonatomic)          Vault*        initialVault;
@property(readonly,nonatomic)          NSString*     selectedVaultType;
@end
