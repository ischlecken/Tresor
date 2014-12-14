//
//  CreateVaultViewController.m
//  Tresor
//
//  Created by Feldmaus on 18.06.14.
//  Copyright (c) 2014 ischlecken. All rights reserved.
//

#import "EditVaultViewController.h"

@interface EditVaultViewController () <UIPickerViewDataSource,UIPickerViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextFieldDelegate>

@property(weak   , nonatomic) IBOutlet UITextField*             vaultName;
@property(weak   , nonatomic) IBOutlet UIImageView*             vaultIcon;
@property(weak   , nonatomic) IBOutlet UIPickerView*            vaultType;

@property(strong , nonatomic)          UIImagePickerController* imgPicker;
@end

@implementation EditVaultViewController

@synthesize parameter=_parameter;

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
  
  [self initControls];
}

/**
 *
 */
-(EditVaultParameter*)parameter
{ self->_parameter.vaultName = self.vaultName.text;

  return self->_parameter;
}

/**
 *
 */
-(void) setParameter:(EditVaultParameter *)parameter
{ self->_parameter = parameter;
  
  [self initControls];
}


/**
 *
 */
-(void) initControls
{ _NSLOG_SELECTOR;
  
  [self.vaultType reloadAllComponents];
  
  self.vaultName.text = self->_parameter.vaultName;
  
  if( self->_parameter.vaultIcon )
    self.vaultIcon.image = self->_parameter.vaultIcon;
  
  if( self->_parameter.vaultType!=NSUIntegerMax )
    [self.vaultType selectRow:self->_parameter.vaultType inComponent:0 animated:NO];
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
{ return self.parameter.vaultTypes.count; }

/**
 *
 */
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{ return self.parameter.vaultTypes[row]; }


/**
 *
 */
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{ _NSLOG_SELECTOR;

  self.parameter.vaultType = row;
}


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
  
  self.parameter.vaultIcon = self.vaultIcon.image;
  
  [self dismissViewControllerAnimated:YES completion:NULL];
}

/**
 *
 */
-(void) imagePickerControllerDidCancel:(UIImagePickerController*)picker
{ [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark UITextFieldDelegate

/**
 *
 */
-(void) textFieldDidEndEditing:(UITextField *)textField
{ _NSLOG_SELECTOR;
  
  self.parameter.vaultName = textField.text;
}

@end
