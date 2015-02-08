//
//  TextfieldBooleanTableViewCell.h
//  tankradar
//
//  Created by Feldmaus on 20.10.14.
//  Copyright (c) 2014 LSSi Europe. All rights reserved.
//

#import <UIKit/UIKit.h>


@class TextfieldBooleanTableViewCell;

@protocol TextfieldBooleanTableViewCellDelegate <NSObject>
-(void) optionFlipped:(BOOL)enabled forTextfieldBooleanTableViewCell:(TextfieldBooleanTableViewCell*)tableViewCell andContext:(id)context;
-(void) inputFieldChanged:(NSString*)text forTextfieldBooleanTableViewCell:(TextfieldBooleanTableViewCell*)tableViewCell andContext:(id)context;
@end


@interface TextfieldBooleanTableViewCell : UITableViewCell
@property (weak  , nonatomic) IBOutlet UIImageView* iconImage;
@property (weak  , nonatomic) IBOutlet UITextField* inputField;
@property (weak  , nonatomic) IBOutlet UISwitch*    optionSwitch;

@property (weak  , nonatomic)          id<TextfieldBooleanTableViewCellDelegate> delegate;
@property (strong, nonatomic)          id                                        context;

-(void) setEnabled:(BOOL)enabled;
@end
