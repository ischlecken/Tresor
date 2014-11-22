//
//  CreateVaultViewController.m
//  Tresor
//
//  Created by Feldmaus on 18.06.14.
//  Copyright (c) 2014 ischlecken. All rights reserved.
//

#import "EditVaultViewController.h"

@interface EditVaultViewController () <UIPickerViewDataSource,UIPickerViewDelegate>
@property NSArray* vaultTypes;

@end

@implementation EditVaultViewController

/**
 *
 */
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{ self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  
  if( self )
  {
    
  }
  
  return self;
}

/**
 *
 */
- (void)viewDidLoad
{ [super viewDidLoad];
  
  self.vaultTypes = @[@"Bank",@"EMail",@"Accounts",@"Internet",@"Sonstiges"];
  
  if( self.initialVault )
  {
    self.vaultName.text = self.initialVault.vaultname;
    
    for( int i=0;i<self.vaultTypes.count;i++ )
    { NSString* t=self.vaultTypes[i];
      
      if( [t isEqualToString:self.initialVault.vaulttype] )
      {
        [self.vaultType selectRow:i inComponent:0 animated:NO];
        
        break;
      } /* of if */
    } /* of for */
  } /* of if */
}


/**
 *
 */
-(void) viewWillAppear:(BOOL)animated
{ [super viewWillAppear:animated];

  [self.vaultName becomeFirstResponder];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

/**
 *
 */
-(NSString*) selectedVaultType
{ return self.vaultTypes[[self.vaultType selectedRowInComponent:0]]; }

#pragma mark UIPickerViewDataSource

/**
 *
 */
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{ return 1; }

/**
 *
 */
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{ return self.vaultTypes.count; }

/**
 *
 */
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{ return self.vaultTypes[row]; }

@end
