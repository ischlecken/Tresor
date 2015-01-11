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
@property(weak   , nonatomic) IBOutlet UIBarButtonItem*         createPINButton;

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
{ self->_parameter.vaultParameter.name = self.vaultName.text;

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
  
  self.vaultName.text = self->_parameter.vaultParameter.name;
  
  if( self->_parameter.vaultParameter.icon )
    self.vaultIcon.image = self->_parameter.vaultParameter.icon;
  
  if( self->_parameter.vaultParameter.type!=nil )
    for( NSUInteger i=0;i<self->_parameter.vaultTypes.count;i++ )
      if( [self->_parameter.vaultTypes[i] isEqualToString:self->_parameter.vaultParameter.type] )
      { [self.vaultType selectRow:i inComponent:0 animated:NO];
        
        break;
      } /* of if */
  
  self.createPINButton.enabled = NO;
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

  self.parameter.vaultParameter.type = self.parameter.vaultTypes[row];
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
  
  self.parameter.vaultParameter.icon = self.vaultIcon.image;
  
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
  
  self.parameter.vaultParameter.name = textField.text;
}

/**
 *
 */
-(BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{ BOOL       result    = YES;
  NSUInteger newLength = textField.text.length;
  
  if( string.length>0 )
    newLength += string.length;
  else
    newLength -= range.length;
  
  _NSLOG(@"range:(%ld,%ld) newLength:%ld",(long)range.location,(long)range.length,(long)newLength);
  
  self.createPINButton.enabled = newLength>0;
  
  return result;
}

/**
 *
 */
-(BOOL) textFieldShouldClear:(UITextField *)textField
{ self.createPINButton.enabled = NO;
  
  return YES;
}

/**
 *
 */
-(BOOL) textFieldShouldReturn:(UITextField *)textField
{ _NSLOG_SELECTOR;
  
  [textField resignFirstResponder];
  
  return YES;
}

#pragma mark prepare Segue

/**
 *
 */
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{ _NSLOG(@"[%@]",segue.identifier);
  
  if( [[segue identifier] isEqualToString:@"CreatePIN"] )
  { id vc0 = [segue destinationViewController];
    
    if( [vc0 conformsToProtocol:@protocol(EditVaultParameter)] )
    { id<EditVaultParameter> vc1 = vc0;
      
      vc1.parameter = self.parameter;
    } /* of if */
  } /* of if */
}

@end
