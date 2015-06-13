//  Created by Stefan Thomas on 26.01.15.
//  Copyright (c) 2015 LSSiEurope. All rights reserved.
//
#import "EditPayloadItemViewController.h"
#import "SelectIconViewController.h"
#import "TextfieldTableViewCell.h"
#import "PickerTableViewCell.h"

#pragma mark - EditPayloadItemData

@implementation EditPayloadItemData


/**
 *
 */
-(NSString*) description
{ NSString* result = [NSString stringWithFormat:@"title:%@ subtitle:%@ icon:%@ iconcolor:%@ payloadobject:%@",
                      self.title,self.subtitle,self.icon,self.iconcolor,self.payloadObject];
  
  return result;
}
@end

#pragma mark - EditPayloadItemViewController

@interface EditPayloadItemViewController () <TextfieldTableViewCellDelegate,UIPickerViewDataSource,UIPickerViewDelegate>
@property(nonatomic, strong) NSArray*      sections;
@property(nonatomic, strong) NSIndexPath*  pickerIndexPath;
@end

@implementation EditPayloadItemViewController

/**
 *
 */
- (void)viewDidLoad
{ [super viewDidLoad];
  
  [self.tableView registerNib:[UINib nibWithNibName:@"TextfieldTableViewCell" bundle:nil] forCellReuseIdentifier:@"TextfieldCell"];
  [self.tableView registerNib:[UINib nibWithNibName:@"PickerTableViewCell"    bundle:nil] forCellReuseIdentifier:@"PickerCell"];

  self.tableView.rowHeight          = UITableViewAutomaticDimension;
  self.tableView.estimatedRowHeight = 56.0f;

  NSMutableArray* sectionInfo   = [[NSMutableArray alloc] initWithCapacity:3];
  
  NSMutableArray* nameAndIconItems = [[NSMutableArray alloc] initWithArray:
  @[ [SettingsItem settingItemWithTitle:@"title"
                              andCellId:@"TextfieldCell"],
     
     [SettingsItem settingItemWithTitle:@"subtitle"
                              andCellId:@"TextfieldCell"]
     
  ]];
  
  if( [self.item.payloadObjectClass isSubclassOfClass:[NSString class]] )
    [nameAndIconItems addObject:[SettingsItem settingItemWithTitle:@"data" andCellId:@"TextfieldCell"]];
  
  [sectionInfo addObject:[MutableSectionInfo sectionWithTitle:@"iconandname" andItems:[[NSMutableArray alloc] initWithArray:nameAndIconItems]]];
  
  NSArray*        iconColors         = [_TRESORCONFIG colorWithName:kIconColorsName];
  NSMutableArray* iconColorHexValues = [[NSMutableArray alloc] initWithCapacity:iconColors.count];
  
  for( UIColor* c in iconColors )
    [iconColorHexValues addObject:[c colorHexString]];
  
  //_NSLOG(@"iconColorHexValues:%@",iconColorHexValues);
  
  NSMutableArray* iconColorsValues       = [[NSMutableArray alloc] initWithArray:iconColorHexValues];
  NSInteger       selectedIconColor      = -1;
  
  for( NSInteger i=0;i<iconColorsValues.count;i++ )
    if( [[iconColorsValues objectAtIndex:i] isEqualToString:self.item.iconcolor] )
    { selectedIconColor = i;
  
      break;
    } /* of if */
  
  if( selectedIconColor==-1 )
  { [iconColorsValues insertObject:self.item.iconcolor atIndex:0];
    
    selectedIconColor = 0;
  } /* of if */
  
  NSArray* iconColorSectionItems =
  @[
    [SettingsItem settingItemWithTitle:@"icon"
                             andCellId:@"Cell"],

    [SettingsItem settingItemWithTitle:@"iconcolor"
                              andCellId:@"PickerCell"
                        andPickerValues:iconColorsValues
                        andSelectedPickerValue:selectedIconColor]
  ];
  [sectionInfo addObject:[MutableSectionInfo sectionWithTitle:@"iconcolor" andItems:[[NSMutableArray alloc] initWithArray:iconColorSectionItems]]];
  
  self.sections = sectionInfo;
  
  self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[_TRESORCONFIG colorWithName:kTitleColorName]};
}


#pragma mark - Table view data source


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
  { NSString* key = [NSString stringWithFormat:@"editpayloaditemviewcontroller.sectiontitle.%@",title];
    
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
-(UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{ UITableViewCell* cell          = nil;
  SectionInfo*     si            = self.sections[indexPath.section];
  NSInteger        dataRow       = indexPath.row;
  SettingsItem*    setting       = si.items[dataRow];
  NSString*        key           = [NSString stringWithFormat:@"editpayloaditemviewcontroller.title.%@",setting.title];
  NSString*        cellId        = setting.cellId;
  NSString*        displayOption = [[NSBundle mainBundle] localizedStringForKey:key value:@"" table:nil];
  
  displayOption = [NSString stringWithFormat:displayOption,[_TRESORCONFIG appName]];
  
  cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
  
  if( [cell isKindOfClass:[TextfieldTableViewCell class]] )
  { TextfieldTableViewCell* tbcell = (TextfieldTableViewCell*)cell;
    
    tbcell.titleLabel.text         = displayOption;
    tbcell.inputField.text         = nil;
    
    if( [setting.title isEqualToString:@"title"] )
      tbcell.inputField.text = self.item.title;
    else if( [setting.title isEqualToString:@"subtitle"] )
      tbcell.inputField.text = self.item.subtitle;
    else if( [setting.title isEqualToString:@"data"] && self.item.payloadObject && [self.item.payloadObject isKindOfClass:[NSString class]] )
      tbcell.inputField.text = (NSString*)self.item.payloadObject;
    
    tbcell.inputField.keyboardType = setting.keyboardType;
    tbcell.context                 = setting;
    tbcell.delegate                = self;
    tbcell.inputField.enabled      = YES;
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
    cell.detailTextLabel.text = nil;
    cell.imageView.image      = nil;
    cell.accessoryType        = UITableViewCellAccessoryNone;
    
    if( [setting.title isEqualToString:@"icon"] )
    { cell.imageView.image = [UIImage imageNamed:self.item.icon];
      cell.accessoryType   = UITableViewCellAccessoryDisclosureIndicator;
    } /* of if */
  } /* of else */
  
  return cell;
}

/**
 *
 */
-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{ [tableView deselectRowAtIndexPath:indexPath animated:NO];
  
  SettingsItem* setting    = [self.sections[indexPath.section] items][indexPath.row];
  
  if( [setting.title isEqualToString:@"icon"] )
  { [self performSegueWithIdentifier:@"IconSelectSegue" sender:self];
  } /* of if */
}


#pragma mark TextfieldTableViewCellDelegate

/**
 *
 */
-(void) inputFieldChanged:(NSString*)text forTextfieldTableViewCell:(TextfieldTableViewCell*)tableViewCell andContext:(id)context
{ _NSLOG(@"text:%@",text);
  
  SettingsItem* setting = (SettingsItem*)context;
  
  if( [setting.title isEqualToString:@"title"] )
    self.item.title = text;
  else if( [setting.title isEqualToString:@"subtitle"] )
    self.item.subtitle = text;
  else if( [setting.title isEqualToString:@"data"] )
    self.item.payloadObject = text;
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
{ NSString* key    = [NSString stringWithFormat:@"editpayloaditemviewcontroller.picker.%@.%@",si.title,rowValue];
  NSString* value  = [rowValue description];
  NSString* result = [[NSBundle mainBundle] localizedStringForKey:key value:value table:nil];
  
  //_NSLOG(@"si.title:%@ key:%@ value:%@ result:%@",si.title,key,value,result);
  
  return result;
}

#if 0
/**
 *
 */
-(NSString*) pickerView:(UIPickerView*) pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{ NSString*    result    = nil;
  NSIndexPath* indexPath = [self indexPathForView:pickerView];
  
  if( indexPath!=nil )
  { SettingsItem* si       = [self.sections[indexPath.section] items][indexPath.row];
    id            rowValue = si.pickerValues[row];
    
    result = [self pickerDisplayValueForSetting:si andValue:rowValue];
  } /* of if */
  
  return result;
}
#endif

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
    labelView.textColor       = [UIColor colorWithHexString:rowValue];
    labelView.textAlignment   = NSTextAlignmentCenter;
    labelView.font            = [UIFont boldSystemFontOfSize:24];
    labelView.shadowColor     = [UIColor colorWithWhite:0.8 alpha:1.0];
    labelView.shadowOffset    = CGSizeMake(1, 1);
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
    
    self.item.iconcolor    = rowValue;
    si.selectedPickerValue = row;
    
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
  } /* of if */
}

#pragma mark Navigation

/**
 *
 */
-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{ if( [[segue identifier] isEqualToString:@"IconSelectSegue"] )
  { SelectIconViewController* vc = [segue destinationViewController];
    
    vc.selectedIconName = self.item.icon;
  } /* of if */
}


/**
 *
 */
-(IBAction) unwindToEditPayloadItemViewController:(UIStoryboardSegue *)unwindSegue
{ _NSLOG_SELECTOR;
  
  if( [[unwindSegue identifier] isEqualToString:@"UnwindSelectIconSegue"] )
  { SelectIconViewController* vc = unwindSegue.sourceViewController;
    
    if( vc.selectedIconName )
    { self.item.icon = vc.selectedIconName;
      
      [self.tableView reloadData];
    } /* of if */
  } /* of if */
}

@end
