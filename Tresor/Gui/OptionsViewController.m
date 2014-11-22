//  Created by Stefan Thomas on 29.07.13.
//  Copyright (c) 2013 Stefan Thomas. All rights reserved.
//
#import "OptionsViewController.h"
#import "SectionInfo.h"

#define kSectionSettings  @"settings"

@interface OptionsViewController ()
@property(nonatomic, strong) NSArray* sections;
@end


@implementation OptionsViewController

/**
 *
 */
- (void)viewDidLoad
{ _NSLOG_SELECTOR;
  
  [super viewDidLoad];
}




/**
 *
 */
-(void) viewWillAppear:(BOOL)animated
{ _NSLOG_SELECTOR;
  
  [super viewWillAppear:animated];

  [self createSections];
  [self.tableView reloadData];
}


#pragma mark init sectioninfo

/**
 *
 */
-(void) createSections
{ NSMutableArray* settingsSectionItems = [[NSMutableArray alloc] initWithCapacity:4];
  
  [settingsSectionItems addObjectsFromArray:@[@"colorscheme",@"walkthrough",@"purgefavorites"]];
  
  if( gErrorList && gErrorList.count>0 )
    [settingsSectionItems addObject:@"errorlist"];

  self.sections = @[[SectionInfo sectionWithTitle:@""    andItems:@[@"about",@"contact"]],
                    [MutableSectionInfo mutableSectionWithTitle:kSectionSettings andItems:settingsSectionItems],
                    ];

}

/**
 *
 */
-(IBAction) returnToResultAction:(id)sender
{ _NSLOG_SELECTOR;
  
}


#pragma mark - Table view data source


/**
 *
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{ return [self.sections count]; }


/**
 *
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{ NSInteger result = [[self.sections[section] items] count];
  
  return result;
}



/**
 *
 */
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{ NSString* result = nil;
  NSString* title  = [self.sections[section] title];
  
  if( title!=nil && title.length>0 )
  { NSString* key = [NSString stringWithFormat:@"Options.%@",title];
   
    result = [[NSBundle mainBundle] localizedStringForKey:key value:@"" table:nil];
  } /* of if */
  
  return result;
}

/**
 *
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{ UITableViewCell* cell = nil;
  
  { SectionInfo*     si            = self.sections[indexPath.section];
    NSString*        option        = nil;
    NSInteger        dataRow       = indexPath.row;
    
    option = si.items[dataRow];
    
    NSString*        key           = [NSString stringWithFormat:@"Options.%@",option];
    NSString*        displayOption = [[NSBundle mainBundle] localizedStringForKey:key value:@"" table:nil];
    
    cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
  
    cell.accessoryType                       = UITableViewCellAccessoryNone;
    cell.textLabel.text                      = displayOption;
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    cell.accessoryType                       = UITableViewCellAccessoryNone;
    cell.imageView.image                     = [si tintedImage];
    
    if( [option isEqualToString:@"about"] )
      cell.textLabel.text = [NSString stringWithFormat:displayOption,_APPDELEGATE.appName];
  } /* of else */
  
  return cell;
}


#pragma mark Table view delegate


/**
 *
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{ SectionInfo*     si               = self.sections[indexPath.section];
  NSString*        option           = option = si.items[indexPath.row];
  BOOL             shouldUndoReveal = NO;
  
  if( [option isEqualToString:@"about"] )
  { NSString*     aboutTitleTmpl   = _LSTR(@"AboutTitle");
    NSString*     aboutMessageTmpl = _LSTR(@"AboutMessage");
    NSString*     aboutTitle       = [NSString stringWithFormat:aboutTitleTmpl,_APPDELEGATE.appName];
    NSString*     aboutMessage     = [NSString stringWithFormat:aboutMessageTmpl,_APPDELEGATE.appVersion,_APPDELEGATE.appBuild];
    UIAlertView*  alertBox         = [[UIAlertView alloc ] initWithTitle:aboutTitle message:aboutMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    
    [alertBox show];
    
    [TresorUtil playSound:@"tresor"];
    shouldUndoReveal = YES;
  } /* of if */
  
  if( shouldUndoReveal )
    [self dismissViewControllerAnimated:YES completion:NULL];
}
@end
