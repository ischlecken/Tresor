//
//  Created by Stefan Thomas on 15.01.2015.
//  Copyright (c) 2015 LSSi Europe. All rights reserved.
//
#import <MessageUI/MFMailComposeViewController.h>

#import "SettingsViewController.h"
#import "BooleanTableViewCell.h"
#import "TextfieldTableViewCell.h"
#import "PickerTableViewCell.h"
#import "WebPageViewController.h"

#define kSectionTitleOptions      @"options"
#define kSectionTitleUI           @"ui"
#define kSectionTitleAbout        @"about"


@interface SettingsViewController () <MFMailComposeViewControllerDelegate,
                                      TextfieldTableViewCellDelegate,
                                      BooleanTableViewCellDelegate,
                                      UIPickerViewDataSource,UIPickerViewDelegate>
@property(nonatomic, strong)          NSArray*      sections;
@property(nonatomic, strong)          NSIndexPath*  pickerIndexPath;
@end

@implementation SettingsViewController

/**
 *
 */
-(void) viewDidLoad
{ [super viewDidLoad];

  [self.tableView registerNib:[UINib nibWithNibName:@"TextfieldTableViewCell" bundle:nil] forCellReuseIdentifier:@"TextfieldCell"];
  [self.tableView registerNib:[UINib nibWithNibName:@"BooleanTableViewCell"   bundle:nil] forCellReuseIdentifier:@"BooleanCell"];
  [self.tableView registerNib:[UINib nibWithNibName:@"PickerTableViewCell"    bundle:nil] forCellReuseIdentifier:@"PickerCell"];

  self.tableView.rowHeight = UITableViewAutomaticDimension;
  self.tableView.estimatedRowHeight = 56.0f;

  NSMutableArray* sectionInfo   = [[NSMutableArray alloc] initWithCapacity:3];
 
  SelectActionType pickerSelectAction = ^(NSIndexPath* indexPath,SettingsItem* item)
  { [self.tableView beginUpdates];
    
    BOOL                addPicker = YES;
    NSIndexPath*        pip       = [NSIndexPath indexPathForRow:indexPath.row + 1 inSection:indexPath.section];
    MutableSectionInfo* msi       = self.sections[indexPath.section];
    SettingsItem*       si        = msi.items[indexPath.row];
    id                  rowValue  = [_TRESORCONFIG getConfigValue:si.title];
    
    if( pip.row<msi.items.count && [[msi.items[pip.row] cellId] isEqualToString:@"PickerCell"] )
      addPicker = NO;
    
    if( addPicker )
    { NSIndexPath* openPickerIndexPath = [self.sections findFirstSettingItemWithCellId:@"PickerCell"];
      
      //_NSLOG(@"openPickerIndexPath:%@",openPickerIndexPath);
      
      SettingsItem* pickerSetting = [SettingsItem settingItemWithTitle:si.title andCellId:@"PickerCell" andSelectAction:NULL andPickerValues:si.pickerValues];
      
      for( NSInteger i=0;i<si.pickerValues.count;i++ )
      { id v = si.pickerValues[i];
        
        if( [v isEqual:rowValue] )
        { pickerSetting.selectedPickerValue = i;
          
          break;
        } /* of if */
      } /* of for */
      
      if( openPickerIndexPath )
      { NSMutableArray* openPickerItems = (NSMutableArray*)[self.sections[openPickerIndexPath.section] items];
        
        if( openPickerIndexPath.section!=pip.section || openPickerIndexPath.row>pip.row )
        { [openPickerItems removeObjectAtIndex:openPickerIndexPath.row];
          [self.tableView deleteRowsAtIndexPaths:@[openPickerIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
          
          [msi.items insertObject:pickerSetting atIndex:pip.row];
          [self.tableView insertRowsAtIndexPaths:@[pip] withRowAnimation:UITableViewRowAnimationFade];
        } /* of if */
        else
        { [openPickerItems removeObjectAtIndex:openPickerIndexPath.row];
          [self.tableView deleteRowsAtIndexPaths:@[openPickerIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
          
          [msi.items insertObject:pickerSetting atIndex:pip.row-1];
          [self.tableView insertRowsAtIndexPaths:@[pip] withRowAnimation:UITableViewRowAnimationFade];
        } /* of else */
      } /* of if */
      else
      { [msi.items insertObject:pickerSetting atIndex:pip.row];
        [self.tableView insertRowsAtIndexPaths:@[pip] withRowAnimation:UITableViewRowAnimationFade];
      } /* of else */
    } /* of if */
    else
    { [msi.items removeObjectAtIndex:pip.row];
      
      [self.tableView deleteRowsAtIndexPaths:@[pip] withRowAnimation:UITableViewRowAnimationFade];
    } /* of else */
    
    [self.tableView endUpdates];
  };
  
  NSArray* optionsSectionItems =
  @[
    [SettingsItem settingItemWithTitle:@"useCloud"
                             andCellId:@"BooleanCell"],
    
    [SettingsItem settingItemWithTitle:@"useTouchID"
                             andCellId:@"BooleanCell"],
  ];
  [sectionInfo addObject:[MutableSectionInfo sectionWithTitle:kSectionTitleOptions andItems:[[NSMutableArray alloc] initWithArray:optionsSectionItems]]];
  
  NSArray* uiSectionItems =
  @[ [SettingsItem settingItemWithTitle:@"colorSchemeName"
                              andCellId:@"DetailCell"
                        andSelectAction:pickerSelectAction
                        andPickerValues:[_TRESORCONFIG colorSchemeNames]],
     
     
  
  ];
  [sectionInfo addObject:[MutableSectionInfo sectionWithTitle:kSectionTitleUI andItems:[[NSMutableArray alloc] initWithArray:uiSectionItems]]];
  
  NSArray* aboutSectionItems =
  @[
     [SettingsItem settingItemWithTitle:@"help"
                              andCellId:@"BasicCell"
                        andSelectAction:^(NSIndexPath* indexPath,SettingsItem *item)
      { [self performSegueWithIdentifier:@"ShowHelpSegue" sender:item];
      }],
     
     [SettingsItem settingItemWithTitle:@"visit"
                              andCellId:@"BasicCell"
                        andSelectAction:^(NSIndexPath* indexPath,SettingsItem *item)
      { [TresorUtil openHomepage];
      }],
     
     [SettingsItem settingItemWithTitle:@"contact"
                              andCellId:@"BasicCell"
                        andSelectAction:^(NSIndexPath* indexPath,SettingsItem *item)
      { if( [MFMailComposeViewController canSendMail] )
        { MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
          
          NSString* subject = _LSTR(@"contact.subject");
          NSString* message = _LSTR(@"contact.message");
          
          controller.mailComposeDelegate = self;
          [controller setToRecipients:@[kContactEMail]];
          [controller setSubject:[NSString stringWithFormat:subject,[_TRESORCONFIG appName]]];
          [controller setMessageBody:[NSString stringWithFormat:message,[_TRESORCONFIG appName]] isHTML:NO];
          
          [self presentViewController:controller animated:YES completion:NULL];
          
        }
        else
          _NSLOG(@"can not send email");
        
        
      }],
     
     [SettingsItem settingItemWithTitle:@"rate"
                              andCellId:@"BasicCell"
                        andSelectAction:^(NSIndexPath* indexPath,SettingsItem *item)
      { [TresorUtil appStoreRatingReminderDialogue:self];
      }],
     
     [SettingsItem settingItemWithTitle:@"about"
                              andCellId:@"BasicCell"
                        andSelectAction:^(NSIndexPath* indexPath,SettingsItem *item)
      { [TresorUtil aboutDialogue:self];
      }],
  ];
  [sectionInfo addObject:[MutableSectionInfo sectionWithTitle:kSectionTitleAbout andItems:[[NSMutableArray alloc] initWithArray:aboutSectionItems]]];
  
  self.sections = sectionInfo;

  self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[_TRESORCONFIG colorWithName:kTitleColorName]};
}

/**
 *
 */
-(void) viewDidDisappear:(BOOL)animated
{ [super viewDidDisappear:animated];
  
  [self closePickerCells];
}


/**
 *
 */
-(void) closePickerCells
{ NSIndexPath* openPickerIndexPath = [self.sections findFirstSettingItemWithCellId:@"PickerCell"];
  
  if( openPickerIndexPath )
  { NSMutableArray* openPickerItems = (NSMutableArray*)[self.sections[openPickerIndexPath.section] items];
    
    [self.tableView beginUpdates];
    [openPickerItems removeObjectAtIndex:openPickerIndexPath.row];
    [self.tableView deleteRowsAtIndexPaths:@[openPickerIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];
  } /* of if */
}



#pragma mark Datamodel

/**
 *
 */
-(id) valueForConfig:(NSString*)title
{ id result = nil;
  
  if( [_TRESORCONFIG configValueExists:title] )
    result = [_TRESORCONFIG getConfigValue:title];
  
  return result;
}

/**
 *
 */
-(NSString*) stringValueForConfig:(NSString*)title
{ NSString* result = nil;
  
  if( [_TRESORCONFIG configValueExists:title] )
    result = [_TRESORCONFIG getConfigValue:title];
  
  return result;
}

/**
 *
 */
-(void) updateStringValue:(NSString*)value forConfig:(NSString*)title
{ if( [_TRESORCONFIG configValueExists:title] )
    [_TRESORCONFIG setConfigValue:value forKey:title];
  
}


/**
 *
 */
-(BOOL) boolValueForConfig:(NSString*)title
{ BOOL result = NO;
  
  if( [_TRESORCONFIG configValueExists:title] )
  { NSNumber* value = [_TRESORCONFIG getConfigValue:title];
    
    result = [value boolValue];
  } /* of if */
  
  return result;
}

/**
 *
 */
-(void) updateBoolValue:(BOOL)value forConfig:(NSString*)title
{ if( [_TRESORCONFIG configValueExists:title] )
    [_TRESORCONFIG setConfigValue:[NSNumber numberWithBool:value] forKey:title];
}


#pragma mark - Table view data source delegate

/**
 *
 */
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{ return self.sections.count; }

/**
 *
 */
-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{ NSString* result = nil;
  NSString* title  = [self.sections[section] title];
  
  if( title!=nil && title.length>0 )
  { NSString* key = [NSString stringWithFormat:@"settings.sectiontitle.%@",title];
    
    result = [[NSBundle mainBundle] localizedStringForKey:key value:@"" table:nil];
  } /* of if */
  
  return result;
}

/**
 *
 */
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{ SectionInfo* sectionInfo = self.sections[section];
  
  return sectionInfo.items.count;
}

/**
 *
 */
-(void) tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{ UITableViewHeaderFooterView* header = (UITableViewHeaderFooterView*)view;

  header.textLabel.textColor=[UIColor grayColor];
}

/**
 *
 */
-(UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{ UITableViewCell* cell          = nil;
  SectionInfo*     si            = self.sections[indexPath.section];
  NSInteger        dataRow       = indexPath.row;
  SettingsItem*    setting       = si.items[dataRow];
  NSString*        key           = [NSString stringWithFormat:@"settings.title.%@",setting.title];
  NSString*        cellId        = setting.cellId;
  NSString*        displayOption = [[NSBundle mainBundle] localizedStringForKey:key value:@"" table:nil];
  
  displayOption = [NSString stringWithFormat:displayOption,[_TRESORCONFIG appName]];
  
  cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
  
  if( [cell isKindOfClass:[BooleanTableViewCell class]] )
  { BooleanTableViewCell* bcell = (BooleanTableViewCell*)cell;
    
    bcell.label.text      = displayOption;
    bcell.label.textColor = [UIColor whiteColor];
    bcell.option.on       = [self boolValueForConfig:setting.title];
    bcell.context         = setting;
    bcell.delegate        = self;
  } /* of if */
  else if( [cell isKindOfClass:[TextfieldTableViewCell class]] )
  { TextfieldTableViewCell* tbcell = (TextfieldTableViewCell*)cell;
    
    tbcell.titleLabel.text         = displayOption;
    tbcell.inputField.text         = [self stringValueForConfig:setting.title];
    tbcell.inputField.keyboardType = setting.keyboardType;
    tbcell.context                 = setting;
    tbcell.delegate                = self;
  } /* of if */
  else if( [cell isKindOfClass:[PickerTableViewCell class]] )
  { PickerTableViewCell* pcell = (PickerTableViewCell*)cell;
    
    pcell.pickerView.delegate = self;
    
    dispatch_async(dispatch_get_main_queue(), ^
    { [pcell.pickerView reloadAllComponents];
      
      [pcell.pickerView selectRow:setting.selectedPickerValue inComponent:0 animated:NO];
    });
    
  } /* of if */
  else
  { cell.textLabel.text       = displayOption;
    cell.detailTextLabel.text = setting.pickerValues ? [self pickerDisplayValueForSetting:setting andValue:[self valueForConfig:setting.title]] :
                                                       [[self valueForConfig:setting.title] description];
  } /* of else */
  
  cell.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.3];
  
  return cell;
}



#pragma mark TableView delegate

/**
 *
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{ [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
  
  SectionInfo*     si            = self.sections[indexPath.section];
  SettingsItem*    setting       = si.items[indexPath.row];
  
  if( setting.selectAction )
    setting.selectAction(indexPath,setting);
  
  if( setting.pickerValues )
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
}


#pragma mark TextfieldTableViewCellDelegate

/**
 *
 */
-(void) inputFieldChanged:(NSString*)text forTextfieldTableViewCell:(TextfieldTableViewCell*)tableViewCell andContext:(id)context
{  }


#pragma mark BooleanTableViewCellDelegate
/**
 *
 */
-(void) optionFlipped:(BOOL)enabled forBooleanTableViewCell:(BooleanTableViewCell*)tableViewCell andContext:(id)context
{ SettingsItem* si = (SettingsItem*)context;
  
  [self updateBoolValue:enabled forConfig:si.title];
}


#pragma mark UIPickerViewDataSource

/**
 *
 */
-(NSIndexPath*) indexPathForView:(UIView*)v
{ NSIndexPath* result = nil;
  
  while( v!=nil && ![v isKindOfClass:[UITableViewCell class]] )
    v = v.superview;
  
  if( v!=nil )
    result = [self.tableView indexPathForCell:(UITableViewCell*)v];
  
  return result;
}

/**
 *
 */
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{ return 1; }


/**
 *
 */
-(NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{ NSIndexPath* indexPath = [self indexPathForView:pickerView];
  NSInteger    result    = 0;
  
  if( indexPath!=nil )
  { SettingsItem* si = [self.sections[indexPath.section] items][indexPath.row];
    
    result = si.pickerValues.count;
  } /* of if */
  
  return result;
}


#pragma mark UIPickerViewDelegate

/**
 *
 */
-(NSString*) pickerDisplayValueForSetting:(SettingsItem*)si andValue:(id)rowValue
{ NSString* key    = [NSString stringWithFormat:@"settings.picker.%@.%@",si.title,rowValue];
  NSString* value  = [rowValue description];
  NSString* result = [[NSBundle mainBundle] localizedStringForKey:key value:value table:nil];

  //_NSLOG(@"si.title:%@ key:%@ value:%@ result:%@",si.title,key,value,result);
  
  return result;
}


/**
 *
 */
-(UIView*) pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{ if( view==nil )
    view = [[UILabel alloc] init];
  
  UILabel*     labelView = (UILabel*)view;
  NSIndexPath* indexPath = [self indexPathForView:pickerView];
  
  if( indexPath!=nil )
  { SettingsItem* si       = [self.sections[indexPath.section] items][indexPath.row];
    id            rowValue = si.pickerValues[row];
    
    labelView.text            = [self pickerDisplayValueForSetting:si andValue:rowValue];
    labelView.textColor       = [UIColor whiteColor];
    labelView.textAlignment   = NSTextAlignmentCenter;
    labelView.font            = [UIFont boldSystemFontOfSize:24];
  } /* of if */
  
  return view;
}


/**
 *
 */
-(void) pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{ NSIndexPath* indexPath = [self indexPathForView:pickerView];
  
  if( indexPath!=nil )
  { SettingsItem* si       = [self.sections[indexPath.section] items][indexPath.row];
    id            rowValue = si.pickerValues[row];
    
    [_TRESORCONFIG setConfigValue:rowValue forKey:si.title];
    
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row-1 inSection:indexPath.section]]
                          withRowAnimation:UITableViewRowAnimationBottom];
  } /* of if */
}

#pragma mark MFMailComposeViewControllerDelegate

/**
 *
 */
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error;
{ if( result==MFMailComposeResultSent )
  { _NSLOG(@"It's away!");
  } /* of if */
  
  [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Navigation

/**
 *
 */
-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{ if( [[segue identifier] isEqualToString:@"ShowHelpSegue"] )
  { WebPageViewController* vc = [segue destinationViewController];
    
    vc.hidesBottomBarWhenPushed = YES;
    vc.webPageURL               = kHelpURL;
  } /* of if */
}


@end
