//
//  SelectIconViewController.m
//  vicinity
//
//  Created by Stefan Thomas on 04.02.15.
//  Copyright (c) 2015 LSSiEurope. All rights reserved.
//

#import "SelectIconViewController.h"

@interface SelectIconViewController ()
@property NSArray*     icons;
@property NSIndexPath* selectedIndex;
@end

@implementation SelectIconViewController

static NSString * const reuseIdentifier = @"Cell";

/**
 *
 */
-(void) viewDidLoad
{ [super viewDidLoad];
  
  self.icons = _TRESORCONFIG.iconList;
  
  if( self.icons && self.selectedIconName )
    for( NSInteger i=0;i<self.icons.count;i++ )
    { NSString* icon = self.icons[i];
      
      if( [icon isEqualToString:self.selectedIconName] )
      {
        self.selectedIndex = [NSIndexPath indexPathForRow:i inSection:0];
        break;
      } /* of if */
    } /* of for */
}


/**
 *
 */
-(void) viewDidAppear:(BOOL)animated
{ [super viewDidAppear:animated];
  
  if( self.selectedIndex )
    [self.collectionView scrollToItemAtIndexPath:self.selectedIndex atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:animated];
}

#pragma mark <UICollectionViewDataSource>

/**
 *
 */
-(NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{ return 1; }


/**
 *
 */
-(NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{ return self.icons.count; }

/**
 *
 */
-(UICollectionViewCell*) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{ UICollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
  
  UIImageView* iconView = (UIImageView*)[cell viewWithTag:42];
  
  //_NSLOG(@"icon:%@",self.icons[indexPath.row]);
  
  iconView.image = [UIImage imageNamed:self.icons[indexPath.row]];
  
  cell.layer.borderColor = [UIColor colorWithWhite:0.9 alpha:1.0].CGColor;
  cell.layer.borderWidth = 0.5;
  
  if( self.selectedIndex && [indexPath isEqual:self.selectedIndex] )
  { cell.layer.borderColor = [UIColor blackColor].CGColor;
    cell.layer.borderWidth = 1.0;
  } /* of if */
  
  return cell;
}

#pragma mark <UICollectionViewDelegate>

/**
 *
 */
-(BOOL) collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{ return YES;
}

/**
 *
 */
-(void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{ NSString* iconName = self.icons[indexPath.row];
  
  self.selectedIndex    = indexPath;
  self.selectedIconName = iconName;
  
  [self performSegueWithIdentifier:@"UnwindSelectIconSegue" sender:self];
}


@end
