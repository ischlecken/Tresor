//
//  MasterViewController.h
//  Tresor
//
//  Created by Feldmaus on 04.05.14.
//  Copyright (c) 2014 ischlecken. All rights reserved.
//

@interface VaultViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property(strong,nonatomic) NSFetchedResultsController* fetchedResultsController;

@end
