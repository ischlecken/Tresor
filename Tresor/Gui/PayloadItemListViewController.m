//  Created by Feldmaus on 04.05.14.
//  Copyright (c) 2014 ischlecken. All rights reserved.
//
#import "PayloadItemListViewController.h"
#import "TresorError.h"
#import "TresorModel.h"
#import "CryptoService.h"
#import "TresorUtil.h"
#import "MBProgressHUD.h"
#import "EditPayloadItemViewController.h"

#define kSecretViewTag 142

@interface PayloadItemListViewController ()
@property NSIndexPath* secretIndexPath;
@property NSArray*     icons;
@end

@implementation PayloadItemListViewController

@dynamic payloadItemList;

/**
 *
 */
- (void)viewDidLoad
{ [super viewDidLoad];

  if( [_TRESORMODEL isVaultInEditMode:self.vault] )
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelEditAction:)] animated:YES];
  else
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editAction:)] animated:YES];
  
  self.title = self.vault.vaultname;
  
  BOOL isInEditMode = [_TRESORMODEL isVaultInEditMode:self.vault];
  [self.navigationController setToolbarHidden:!isInEditMode animated:YES];
  
  self.icons = @[
  @"3d-view",
  @"addfolder",
  @"android-os",
  @"apple-os",
  @"bitcoin",
  @"coin",
  @"credit-card",
  @"delicious",
  @"email-12",
  @"facebook-like",
  @"facebook",
  @"fax",
  @"flickr",
  @"folder",
  @"gear",
  @"google-plus",
  @"icloud",
  @"id-card-1",
  @"id-card",
  @"key",
  @"linkedin",
  @"linux-os",
  @"password",
  @"paypal",
  @"phone",
  @"pinterest",
  @"server",
  @"share",
  @"sharethis",
  @"shield",
  @"skype",
  @"sms",
  @"twitter",
  @"user",
  @"vault",
  @"vimeo",
  @"windows-os",
  @"wireless",
  @"wordpress",
  @"xing",
  @"youtube-new"];
  
  [_TRESORMODEL addObserver:self forKeyPath:@"vaultsInEditMode" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:NULL];
  
  self.decryptedMasterKey           = [[DecryptedMasterKeyManager sharedInstance] getInfo:self.vault];
  self.timeoutProgressView.progress = [[self.decryptedMasterKey timeoutProgress] floatValue];
  
  [self.decryptedMasterKey addObserver:self forKeyPath:@"timeoutProgress" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:NULL];
}

/**
 *
 */
-(void) dealloc
{ [_TRESORMODEL            removeObserver:self forKeyPath:@"vaultsInEditMode"];
  [self.decryptedMasterKey removeObserver:self forKeyPath:@"timeoutProgress"];
}

#pragma mark Modelchanged

/**
 *
 */
-(PayloadItemList*) payloadItemList
{ return [self.tableView isEditing] ? self.editPayloadItemList : self.readonlyPayloadItemList; }

/**
 *
 */
-(void) setReadonlyPayloadItemList:(PayloadItemList*)value
{ self->_readonlyPayloadItemList = value;
  
  if( ![self.tableView isEditing] )
    [self.tableView reloadData];
}

/**
 *
 */
-(void) setEditPayloadItemList:(PayloadItemList*)value
{ self->_editPayloadItemList = value;
  
  if( [self.tableView isEditing] )
    [self.tableView reloadData];
}

/**
 *
 */
-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{ if( [keyPath isEqualToString:@"vaultsInEditMode"] )
  { [self setEditMode:[_TRESORMODEL isVaultInEditMode:self.vault]];
  } /* of if */
  else if( [keyPath isEqualToString:@"timeoutProgress"] )
  { self.timeoutProgressView.progress = [self.decryptedMasterKey.timeoutProgress floatValue];
  } /* of else if */
}

/**
 *
 */
-(void) addPayloadItem:(EditPayloadItemData*)pi
{ [self disableToolbarItems];
  
  _NSLOG(@"addPayloadItem:pi=%@",pi);
  
  if( pi.title && pi.subtitle && pi.payloadObject )
  { Commit*  nextCommit = self.vault.nextCommit;
    
    if( nextCommit )
    { [nextCommit addPayloadItemWithTitle:pi.title
                              andSubtitle:pi.subtitle
                                  andIcon:pi.icon
                             andIconColor:pi.iconcolor
                                andObject:pi.payloadObject
                                  forPath:self.path
       ]
      .then(^(Commit* cm)
       { NSError* error = nil;
        
         if( ![_MOC save:&error] )
           return (id)error;
        
         return (id)[cm parentPathForPath:self.path];
       })
      .then(^(NSArray* parentPath)
       { id decryptedPayload = [[parentPath firstObject] decryptedPayload];
        
         if( ![decryptedPayload isKindOfClass:[PayloadItemList class]] )
           return (id) _TRESORERROR(TresorErrorUnexpectedObjectClass);
        
         self.editPayloadItemList = decryptedPayload;
         [self.tableView reloadData];
         [self enableToolbarItems];
        
         return (id) decryptedPayload;
       });
    } /* of if */
    else
      [self enableToolbarItems];
  } /* of if */
  else
  { _NSLOG(@"mandatory fields not set...");
    
    [self enableToolbarItems];
  } /* of else */
}

/**
 *
 */
-(void) deletePayloadItem:(NSIndexPath*)indexPath
{ _NSLOG(@"indexPath:%@",indexPath);

  NSError* error      = nil;
  Commit*  nextCommit = [self.vault useOrCreateNextCommit:&error];
  
  if( nextCommit )
  { [nextCommit deletePayloadItemForPath:self.path atPosition:indexPath.row]
    .then(^(Commit* commit)
    {
      [self commitChanges:@"Item deleted"];
    });
  } /* of if */
}

#pragma mark Actions

/**
 *
 */
-(void) setEditMode:(BOOL)enable
{ BOOL actEnable = [self.tableView isEditing];
 
  if( actEnable!=enable )
  {
    if( enable )
    { NSError* error      = nil;
      Commit*  nextCommit = [self.vault useOrCreateNextCommit:&error];
      
      if( nextCommit )
      { if( self.secretIndexPath )
        { NSIndexPath* indexPath = [NSIndexPath indexPathForRow:self.secretIndexPath.row - 1 inSection:self.secretIndexPath.section];
          
          [self toggleSecretForSelectedIndexPath:indexPath];
        } /* of if */
        
        [nextCommit parentPathForPath:self.path]
        .then(^(NSArray* parentPath)
          { id decryptedPayload = [[parentPath firstObject] decryptedPayload];
            
            if( ![decryptedPayload isKindOfClass:[PayloadItemList class]] )
              return (id) _TRESORERROR(TresorErrorUnexpectedObjectClass);
            
            self.editPayloadItemList = decryptedPayload;
            [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelEditAction:)] animated:YES];
            [self.navigationController setToolbarHidden:NO animated:YES];
            [self.tableView setEditing:YES animated:YES];
            
            return (id) decryptedPayload;
          });
      } /* of if */
      else
        addToErrorList(@"Could not find next commit", error, AddErrorNothing);
    } /* of if */
    else
    { self.editPayloadItemList = nil;
      
      [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editAction:)] animated:YES];
      [self.tableView setEditing:NO animated:YES];
    } /* of else */
    
    [self.tableView reloadData];
  } /* of if */
}
            
/**
 *
 */
-(IBAction) editAction:(id)sender
{ self.navigationItem.rightBarButtonItem.enabled = NO;
  
  [_TRESORMODEL editMode:YES forVault:self.vault];
  [self setEditMode:YES];
}

#if 0
-(IBAction) addItemAction:(id)sender
{ [self disableToolbarItems];
  
  Commit*  nextCommit = self.vault.nextCommit;
  
  if( nextCommit )
  { NSUInteger iconIndex = random() % self.icons.count;
    
    [nextCommit addPayloadItemWithTitle:@"itemtestAddPayloadItemInCommit.0"
                            andSubtitle:@"subtitletestAddPayloadItemInCommit.0"
                                andIcon:self.icons[iconIndex]
                              andObject:@"blatestAddPayloadItemInCommit.0"
                                forPath:self.path
     ]
    .then(^(Commit* cm)
          { NSError* error = nil;
            
            if( ![_MOC save:&error] )
              return (id)error;
            
            return (id)[cm parentPathForPath:self.path];
          })
    .then(^(NSArray* parentPath)
          { id decryptedPayload = [[parentPath firstObject] decryptedPayload];
            
            if( ![decryptedPayload isKindOfClass:[PayloadItemList class]] )
              return (id) _TRESORERROR(TresorErrorUnexpectedObjectClass);
            
            self.editPayloadItemList = decryptedPayload;
            [self.tableView reloadData];
            [self enableToolbarItems];
            
            return (id) decryptedPayload;
          });
  } /* of if */
  else
    [self enableToolbarItems];
}
#endif


/**
 *
 */
-(IBAction) commitAction:(id)sender
{ [self commitChanges:@"successfull added"];
}

/**
 *
 */
-(void) commitChanges:(NSString*)commitMessage
{ [self disableToolbarItems];
  [self cancelEditUI];
  
  NSError* error      = nil;
  Commit*  nextCommit = self.vault.nextCommit;
  
  if( nextCommit )
  { nextCommit.message = commitMessage;
    self.vault.commit  = nextCommit;
    
    if( ![_MOC save:&error] )
      addToErrorList(@"error while saving data", error, AddErrorNothing);
    else
      [nextCommit parentPathForPath:self.path]
      .then(^(NSArray* parentPath)
            { id decryptedPayload = [[parentPath firstObject] decryptedPayload];
              
              if( ![decryptedPayload isKindOfClass:[PayloadItemList class]] )
                return (id) _TRESORERROR(TresorErrorUnexpectedObjectClass);
              
              self.readonlyPayloadItemList = decryptedPayload;
              [self.tableView reloadData];
              [self enableToolbarItems];
              
              return (id) decryptedPayload;
            });
  } /* of if */
  else
    [self enableToolbarItems];
}

/**
 *
 */
-(IBAction) addFolderAction:(id)sender
{
}

/**
 *
 */
-(IBAction) folderAction:(id)sender
{
}

/**
 *
 */
-(IBAction) cancelEditAction:(id)sender
{ [self cancelEditUI];
  
  NSError* error = nil;
  if( ![self.vault cancelNextCommit:&error] )
    addToErrorList(@"error while cancel next commit", error, AddErrorNothing);
}

/**
 *
 */
-(void) cancelEditUI
{ [_TRESORMODEL editMode:NO forVault:self.vault];
  
  [self setEditMode:NO];
  
  [self.navigationController setToolbarHidden:YES animated:YES];
}

/**
 *
 */
-(void) enableToolbarItems
{ for( UIBarButtonItem* bbi in self.toolbarItems )
    bbi.enabled = YES;
}

/**
 *
 */
-(void) disableToolbarItems
{ for( UIBarButtonItem* bbi in self.toolbarItems )
    bbi.enabled = NO;
}

#pragma mark Navigation



/**
 *
 */
-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{ if( [[segue identifier] isEqualToString:@"AddPayloadItemSegue"] )
  { UINavigationController*        nc = (UINavigationController*)segue.destinationViewController;
    EditPayloadItemViewController* vc = (EditPayloadItemViewController*) nc.topViewController;
    
    NSArray* iconColors = [_TRESORCONFIG colorWithName:kIconColorsName];
    
    vc.item = [EditPayloadItemData new];
    
    vc.item.title              = @"title";
    vc.item.subtitle           = @"subtitle";
    vc.item.icon               = self.icons[0];
    vc.item.iconcolor          = [iconColors[0] colorHexString];
    vc.item.payloadObjectClass = [NSString class];
    vc.item.payloadObject      = nil;
  } /* of if */
}

/**
 *
 */
-(IBAction) unwindToPayloadItemListViewController:(UIStoryboardSegue *)unwindSegue
{ if( [[unwindSegue identifier] isEqualToString:@"AddPayloadItemSegue"] )
  { EditPayloadItemViewController* vc = (EditPayloadItemViewController*) unwindSegue.sourceViewController;
  
    [self addPayloadItem:vc.item];
  
    [self dismissViewControllerAnimated:YES completion:NULL];
  } /* of if */
  else if( [[unwindSegue identifier] isEqualToString:@"CancelPayloadItemSegue"] )
  {
    [self dismissViewControllerAnimated:YES completion:NULL];
  }
}



#pragma mark Table View

/**
 *
 */
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{ return ([self.secretIndexPath isEqual:indexPath] ? 162: self.tableView.rowHeight);
}

/**
 *
 */
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{ return 1; }

/**
 *
 */
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{ NSInteger result = self.payloadItemList.count;

  if( self.secretIndexPath )
    result++;

  return result;
}

/**
 *
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{ NSError*         error = nil;
  UITableViewCell* cell  = nil;
  
  if( self.secretIndexPath )
  { cell = [tableView dequeueReusableCellWithIdentifier:@"SecretCell" forIndexPath:indexPath];

    UITextView* textView = (UITextView*)[cell viewWithTag:kSecretViewTag];
    
    textView.editable = NO;
    
    PayloadItem* pi = [self.payloadItemList objectAtIndex:(indexPath.row-1)];
    Payload*     pl = (Payload*)[_MOC loadObjectWithObjectID:pi.payloadoid andError:&error];
    
    [[CryptoService sharedInstance] decryptPayload:pl]
      .then(^(Payload* pl)
      { textView.text = [[pl decryptedPayload] description];
      });
  } /* of if */
  else
  { cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    PayloadItem* item  = [self.payloadItemList objectAtIndex:[indexPath row]];
    
    cell.textLabel.text            = item.title;
    cell.detailTextLabel.text      = item.subtitle;
    cell.detailTextLabel.textColor = [UIColor lightGrayColor];
    cell.accessoryType             = UITableViewCellAccessoryNone;
    cell.editingAccessoryType      = UITableViewCellAccessoryNone;
    
    cell.imageView.image           = [TresorUtil tintedImage:item.icon];
  } /* of else */
  
  return cell;
}

/**
 *
 */
-(BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{ return YES; }

/**
 *
 */
-(void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{ if( editingStyle==UITableViewCellEditingStyleDelete )
  { NSError* error      = nil;
    Commit*  nextCommit = self.vault.nextCommit;
    
    if( nextCommit )
      [nextCommit deletePayloadItemForPath:self.path atPosition:[indexPath row]]
      .then(^(Commit* cm)
      { NSError* error = nil;
        
        if( ![_MOC save:&error] )
          return (id)error;
        
        return (id)[cm parentPathForPath:self.path];
      })
      .then(^(NSArray* parentPath)
      { id decryptedPayload = [[parentPath firstObject] decryptedPayload];
        
        if( ![decryptedPayload isKindOfClass:[PayloadItemList class]] )
          return (id) _TRESORERROR(TresorErrorUnexpectedObjectClass);
        
        self->_editPayloadItemList = decryptedPayload;
        
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
        
        return (id) decryptedPayload;
      });
    else
      addToErrorList(@"error while get next commit", error, AddErrorNothing);
  } /* of if */
}

/**
 *
 */
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{ return NO; }

/**
 *
 */
-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{ UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:indexPath];
  
  if( self.secretIndexPath )
  { [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self toggleSecretForSelectedIndexPath:indexPath];
  } /* of if */
  else
  { PayloadItem* item        = [self.payloadItemList objectAtIndex:[indexPath row]];
    NSError*     error       = nil;
    Payload*     itemPayload = (Payload*)[_MOC loadObjectWithObjectID:item.payloadoid andError:&error];
      
    if( error==nil )
    { UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
      spinner.frame = CGRectMake(0, 0, 24, 24);
      
      cell.accessoryView = spinner;
      [spinner startAnimating];

      [[CryptoService sharedInstance] decryptPayload:itemPayload]
      .then(^(Payload* pl)
      { if( [pl isPayloadItemList] )
        { PayloadItemListViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"paylodItemListViewController"];
          
          vc.vault                   = self.vault;
          vc.path                    = [self.path indexPathByAddingIndex:[indexPath row]];
          vc.readonlyPayloadItemList = [pl decryptedPayload];
          
          [self.navigationController pushViewController:vc animated:YES];
          
          cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        } /* of if */
        else if( ![self.tableView isEditing] )
        { cell.accessoryType = UITableViewCellAccessoryNone;
          
          [self toggleSecretForSelectedIndexPath:indexPath];
        } /* of else */
        
        return (id) pl;
      })
      .catch(^(NSError* error)
      { _NSLOG(@"Error while decrypting payload:%@",error);
         
         MBProgressHUD* hud = [MBProgressHUD HUDForView:_APPWINDOW];
         
         hud.color     = [UIColor redColor];
         hud.labelText = _LSTR(@"ErrorDecryptingPayload");
         hud.mode      = MBProgressHUDModeText;
         
         [hud hide:YES afterDelay:3];
      })
      .finally(^
      { if( [cell.accessoryView isKindOfClass:[UIActivityIndicatorView class]] )
        { UIActivityIndicatorView* aiv = (UIActivityIndicatorView*)cell.accessoryView;
          
          [aiv stopAnimating];
        } /* of if */
        
        cell.accessoryView = nil;
        
        [MBProgressHUD hideHUDForView:_APPWINDOW animated:YES];
      });
    } /* of if */
    else
      addToErrorList(@"Could not load item payload", error, AddErrorNothing);
  } /* of else */
}

/*
 *
 */
-(NSArray*) tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{ NSArray* result =
  @[
    [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:_LSTR(@"EditAction.Delete") handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
     { _NSLOG(@"Delete...");
       
       [self deletePayloadItem:indexPath];
     }],
    [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:_LSTR(@"EditAction.Key") handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
     { _NSLOG(@"Key...");
     }],
    [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:_LSTR(@"EditAction.Favorite") handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
     { _NSLOG(@"Favorite...");
     }],
    ];
  
  [result[1] setBackgroundColor:[UIColor orangeColor]];
  [result[2] setBackgroundColor:[UIColor blueColor]];
  
  return result;
}



/**
 *
 */
-(BOOL) indexPathIsSecretCell:(NSIndexPath*)indexPath
{ UITableViewCell* cell   = [self.tableView cellForRowAtIndexPath:indexPath];
  BOOL             result = cell!=nil && [cell viewWithTag:kSecretViewTag]!=nil;
  
  return result;
}


/**
 *
 */
-(void) toggleSecretForSelectedIndexPath:(NSIndexPath *)indexPath
{ [self.tableView beginUpdates];
  
  NSIndexPath* secretIndexPath = [NSIndexPath indexPathForRow:indexPath.row + 1 inSection:indexPath.section];
  
  /**
   * remote other open picker cell if exists
   */
  if( self.secretIndexPath!=nil && [self indexPathIsSecretCell:self.secretIndexPath] && ![self.secretIndexPath isEqual:secretIndexPath] )
  {
    [self.tableView deleteRowsAtIndexPaths:@[self.secretIndexPath] withRowAnimation:UITableViewRowAnimationFade];
    
    /**
     * adjust indexPath, if deleted pickercell is in same section and before indexPath
     */
    if( indexPath.section==self.secretIndexPath.section && indexPath.row>self.secretIndexPath.row )
    { indexPath = [NSIndexPath indexPathForItem:indexPath.row-1 inSection:indexPath.section];
      secretIndexPath = [NSIndexPath indexPathForRow:indexPath.row + 1 inSection:indexPath.section];
    } /* of if */
    
    self.secretIndexPath = nil;
  } /* of if */
  
  if( [self indexPathIsSecretCell:secretIndexPath] )
  { self.secretIndexPath = nil;
    [self.tableView deleteRowsAtIndexPaths:@[secretIndexPath] withRowAnimation:UITableViewRowAnimationFade];
  } /* of if */
  else
  { self.secretIndexPath = secretIndexPath;
    
    [self.tableView insertRowsAtIndexPaths:@[secretIndexPath] withRowAnimation:UITableViewRowAnimationFade];
  } /* of else */
  
  [self.tableView endUpdates];
}

@end
