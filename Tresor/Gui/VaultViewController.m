//
//  MasterViewController.m
//  Tresor
//
//  Created by Feldmaus on 04.05.14.
//  Copyright (c) 2014 ischlecken. All rights reserved.
//

#import "VaultViewController.h"
#import "PayloadItemListViewController.h"
#import "EditVaultViewController.h"
#import "TresorError.h"
#import "PasswordViewController.h"
#import "MBProgressHUD.h"

@interface VaultViewController ()
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end

@implementation VaultViewController

#pragma mark Init

/**
 *
 */
- (void)viewDidLoad
{ [super viewDidLoad];
  
  self.title = _TRESORCONFIG.appName;
  
  [_TRESORMODEL addObserver:self forKeyPath:@"vaultsInEditMode" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:NULL];
}


/**
 *
 */
-(void) viewDidAppear:(BOOL)animated
{ [super viewDidAppear:animated];

  [self.navigationController setToolbarHidden:NO];
}

/**
 *
 */
-(void) dealloc
{ [_TRESORMODEL removeObserver:self forKeyPath:@"vaultsInEditMode"];
}

#pragma mark Actions


/**
 *
 */
-(IBAction) editVaultAction:(id)sender
{ [self.tableView setEditing:!self.tableView.editing animated:YES];
}


/**
 *
 */
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{ _NSLOG(@"[%@]",segue.identifier);
  
  if( [[segue identifier] isEqualToString:@"showPayload"] )
  { NSIndexPath* indexPath = [self.tableView indexPathForSelectedRow];
    Vault*       vault     = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    
    PayloadItemListViewController* payloadItemListViewController = [segue destinationViewController];
    
    payloadItemListViewController.vault = vault;
    payloadItemListViewController.path  = [NSIndexPath new];
    
    if( vault.commit )
      [vault.commit parentPathForPath:[NSIndexPath new]]
      .then(^(NSArray* parentPath)
      { id decryptedPayload = [[parentPath firstObject] decryptedPayload];
        
        if( ![decryptedPayload isKindOfClass:[PayloadItemList class]] )
          return (id) _TRESORERROR(TresorErrorUnexpectedObjectClass);
        
        payloadItemListViewController.readonlyPayloadItemList = decryptedPayload;
        
        return (id) decryptedPayload;
      });
    
  } /* of if */
  else if( [[segue identifier] isEqualToString:@"CreateVaultSegue"] )
  { EditVaultViewController* ebbc      = (EditVaultViewController*)[segue.destinationViewController topViewController];
    
    ebbc.parameter = [EditVaultParameter new];
  } /* of else if */
  else if( [[segue identifier] isEqualToString:@"UpdateVaultSegue"] )
  { NSIndexPath*             indexPath = sender;
    Vault*                   vault     = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    EditVaultViewController* ebbc      = (EditVaultViewController*)[segue.destinationViewController topViewController];
    
    ebbc.parameter = [EditVaultParameter editVaultParameterWithVault:vault];
  } /* of else if */
  else if( [[segue identifier] isEqualToString:@"PaswordSegue"] )
  {
  } /* of else if */
  
}

/**
 *
 */
-(IBAction) createVaultUnwindAction:(UIStoryboardSegue *)unwindSegue
{ _NSLOG_SELECTOR;
  
  if( [unwindSegue.identifier isEqualToString:@"CreateVault"] )
  { EditVaultViewController*   evvc  = unwindSegue.sourceViewController;
    
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:_APPWINDOW animated:YES];
    hud.color     = _HUDCOLOR;
    hud.labelText = _LSTR(@"CreatingVault");
    
    [Vault vaultObjectWithParameter:evvc.parameter.vaultParameter]
    .then(^(Vault* vault)
    { MasterKey* mk = vault.pinMasterKey;
        
      [mk decryptedMasterKeyUsingPIN:evvc.parameter.vaultParameter.pin]
      .then(^(NSData* decryptedKey)
      { _NSLOG(@"decryptedKey:%@",[decryptedKey hexStringValue]);
      });
    })
    .catch(^(NSError* error)
    { addToErrorList(@"error while createing vault",error,AddErrorUIFeedback);
    })
    .finally(^()
    { [MBProgressHUD hideHUDForView:_APPWINDOW animated:YES]; });

  } /* of if */
}

/**
 *
 */
-(IBAction) editVaultUnwindAction:(UIStoryboardSegue *)unwindSegue
{ _NSLOG_SELECTOR;
  
  if( [unwindSegue.identifier isEqualToString:@"EditVault"] )
  { EditVaultViewController*   evvc  = unwindSegue.sourceViewController;
    NSError*                   error = nil;
    Vault*                     vault = evvc.parameter.vault;
    
    vault.vaultname = evvc.parameter.vaultParameter.name;
    vault.vaulttype = [evvc.parameter selectedVaultType];
    if( evvc.parameter.vaultParameter.icon )
      vault.vaulticon = UIImagePNGRepresentation(evvc.parameter.vaultParameter.icon);
      
    [_MOC save:&error];
    
    if( vault==nil )
      addToErrorList(@"error while updating vault",error,AddErrorUIFeedback);
  } /* of if */
}


/**
 *
 */
-(IBAction) passwordDoneAction:(UIStoryboardSegue *)unwindSegue
{ _NSLOG_SELECTOR;
  
  PasswordViewController* pvc = unwindSegue.sourceViewController;

  if( pvc.password )
  { UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Password" message:pvc.password preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:NULL]];
    
    dispatch_async(dispatch_get_main_queue(), ^
    { [self presentViewController:alert animated:YES completion:NULL];
    });
  } /* of if */
}

/**
 *
 */
-(IBAction) optionsDoneAction:(UIStoryboardSegue *)unwindSegue
{ _NSLOG_SELECTOR;
  
}

/**
 *
 */
-(IBAction) auditDoneAction:(UIStoryboardSegue *)unwindSegue
{ _NSLOG_SELECTOR;
  
}


#pragma mark Modelchanged

/**
 *
 */
-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
  if( [keyPath isEqualToString:@"vaultsInEditMode"] )
    [self.tableView reloadData];
}


#pragma mark - Table View

/**
 *
 */
-(void) tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{ _NSLOG_SELECTOR;
  
  [self performSegueWithIdentifier:@"UpdateVaultSegue" sender:indexPath];
}

/**
 *
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{ return [[self.fetchedResultsController sections] count]; }

/**
 *
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{ id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
 
  return [sectionInfo numberOfObjects];
}

/**
 *
 */
-(UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{ UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
  
  [self configureCell:cell atIndexPath:indexPath];
  
  return cell;
}

/**
 *
 */
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{ return YES; }

/**
 *
 */
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
  if (editingStyle == UITableViewCellEditingStyleDelete)
  { NSError* error = nil;
    id       vault = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    if( ![Vault deleteVault:vault andError:&error] )
      addToErrorList(@"Error while deleting vault", error, AddErrorUIFeedback);
  }   
}

/**
 *
 */
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{ return NO; }

/**
 *
 */
-(NSArray*) tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{ _NSLOG_SELECTOR;
  
  NSArray* result =
  @[
    [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:_LSTR(@"EditAction.Delete") handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
     { _NSLOG(@"delete row");
       
       NSError* error = nil;
       id       vault = [self.fetchedResultsController objectAtIndexPath:indexPath];
       
       if( ![Vault deleteVault:vault andError:&error] )
         addToErrorList(@"Error while deleting vault", error, AddErrorUIFeedback);
     }],
    [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:_LSTR(@"EditAction.Keys") handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
     { _NSLOG(@"keys row");
     }],
    [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:_LSTR(@"EditAction.More") handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
     { _NSLOG(@"more row");
     }],
    ];
  
  [result[1] setBackgroundColor:[UIColor orangeColor]];
  
  return result;
}





#pragma mark - Fetched results controller

/**
 *
 */
-(NSFetchedResultsController*)fetchedResultsController
{
  if( _fetchedResultsController==nil )
  { NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
   
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Vault" inManagedObjectContext:_MOC];
    [fetchRequest setEntity:entity];

    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];

    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"vaulttype" ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptor];

    [fetchRequest setSortDescriptors:sortDescriptors];

    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                                managedObjectContext:_MOC
                                                                                                  sectionNameKeyPath:nil
                                                                                                           cacheName:@"Vault"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;

    NSError *error = nil;
    if( ![self.fetchedResultsController performFetch:&error] )
      addToErrorList(@"Error while perform fetchedresultscontroller fetch", error, AddErrorUIFeedback);
  } /* of if */

  return _fetchedResultsController;
}

/**
 *
 */
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

/**
 *
 */
- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type
{
  switch(type)
  {
    case NSFetchedResultsChangeInsert:
      [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
      break;
        
    case NSFetchedResultsChangeDelete:
      [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
      break;
    default:
      break;
      
  } /* of switch */
}

/**
 *
 */
- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{ UITableView *tableView = self.tableView;
  
  switch(type)
  {
    case NSFetchedResultsChangeInsert:
        [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
        break;
        
    case NSFetchedResultsChangeDelete:
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        break;
        
    case NSFetchedResultsChangeUpdate:
        [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
        break;
        
    case NSFetchedResultsChangeMove:
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
        break;
  } /* of switch */
}

/**
 *
 */
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{ [self.tableView endUpdates]; }

/*
// Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed. 
 
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    // In the simplest, most efficient, case, reload the table view.
    [self.tableView reloadData];
}
 */

/**
 *
 */
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{ Vault* vault = [self.fetchedResultsController objectAtIndexPath:indexPath];
  
  cell.textLabel.text            = vault.vaultname;
  cell.detailTextLabel.text      = vault.vaulttype;
  cell.detailTextLabel.textColor = [UIColor lightGrayColor];
  cell.imageView.image           = nil;
  
  if( vault.vaulticon!=nil )
    cell.imageView.image = [UIImage imageWithData:vault.vaulticon];
  
  if( [_TRESORMODEL isVaultInEditMode:vault] )
  { cell.textLabel.textColor = [UIColor redColor];
  
    UIFontDescriptor * fontD = [cell.textLabel.font.fontDescriptor fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold | UIFontDescriptorTraitItalic];
    
    cell.textLabel.font = [UIFont fontWithDescriptor:fontD size:0];
  } /* of if */
  else
  { cell.textLabel.textColor = [UIColor blackColor];
    
    UIFontDescriptor * fontD = [cell.textLabel.font.fontDescriptor fontDescriptorWithSymbolicTraits:0];
    
    cell.textLabel.font = [UIFont fontWithDescriptor:fontD size:0];
  } /* of else */
}




@end
