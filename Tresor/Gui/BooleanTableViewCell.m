//
//  BooleanTableViewCell.m
//  tankradar
//
//  Created by Feldmaus on 20.10.14.
//  Copyright (c) 2014 LSSi Europe. All rights reserved.
//

#import "BooleanTableViewCell.h"

@implementation BooleanTableViewCell


/**
 *
 */
-(void) awakeFromNib
{ [super awakeFromNib];
  
  self.option.onTintColor = [_TRESORCONFIG colorWithName:kOptionOnColorName];
}

/**
 *
 */
-(IBAction) flipOption:(UISwitch*)sender
{
  [self.delegate optionFlipped:sender.on forBooleanTableViewCell:self andContext:self.context];
}
@end
