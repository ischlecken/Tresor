//
//  CreateVaultViewController.m
//  Tresor
//
//  Created by Feldmaus on 18.06.14.
//  Copyright (c) 2014 ischlecken. All rights reserved.
//

#import "EditVaultViewController.h"

@interface EditVaultViewController () <UIPickerViewDataSource,UIPickerViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property(nonatomic,strong) NSArray*                 vaultTypes;
@property(nonatomic,strong) UIImagePickerController* imgPicker;
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


#pragma mark Actions

/**
 *
 */
-(IBAction)imageTapped:(id)sender
{ _NSLOG_SELECTOR;
  
  [self.vaultName resignFirstResponder];
    
  self.imgPicker = [[UIImagePickerController alloc] init];
  self.imgPicker.allowsEditing = YES;
  self.imgPicker.delegate      = self;
  self.imgPicker.sourceType    = UIImagePickerControllerSourceTypePhotoLibrary;
    
  [self presentViewController:self.imgPicker animated:YES completion:NULL];
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

#pragma mark UIImagePickerControllerDelegate

/**
 *
 */
-(void) imagePickerController:(UIImagePickerController*)picker didFinishPickingImage:(UIImage*)selectedImage editingInfo:(NSDictionary*)editingInfo
{
  // Create a thumbnail version of the image for the recipe object.
  CGSize  size = selectedImage.size;
  CGFloat ratio = 0;
  if( size.width>size.height )
    ratio = 144.0 / size.width;
  else
    ratio = 144.0 / size.height;
  
  CGRect rect = CGRectMake(0.0, 0.0, ratio * size.width, ratio * size.height);
  
  UIGraphicsBeginImageContext(rect.size);
  [selectedImage drawInRect:rect];
  self.vaultIcon.image = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  
  [self dismissViewControllerAnimated:YES completion:NULL];
}

/**
 *
 */
-(void) imagePickerControllerDidCancel:(UIImagePickerController*)picker
{ [self dismissViewControllerAnimated:YES completion:NULL];
}


@end
