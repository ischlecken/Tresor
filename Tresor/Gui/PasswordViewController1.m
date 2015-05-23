/*
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see http://www.gnu.org/licenses/.
 *
 * Copyright (c) 2014 ischlecken.
 */

#import "PasswordViewController1.h"
#import "PasswordView.h"


@interface PasswordViewController1 () <PasswordViewDelegate>
@end

@implementation PasswordViewController1
{ PMKResolver resolver;
}

/**
 *
 */
-(instancetype) init
{ self = [super init];
  
  if (self)
  {
    _promise = [AnyPromise promiseWithResolverBlock:^(PMKResolver resolve)
    { self->resolver = resolve; }];
  } /* of if */
  
  return self;
}

/**
 *
 */
-(void) loadView
{ self.view = [PasswordView new]; }

/**
 *
 */
-(void) viewDidLoad
{ [super viewDidLoad];

  PasswordView* pv = (PasswordView*)self.view;
  
  pv.maxDigits  = 8;
  pv.showButton = PasswordViewShowButtonWhenAllDigitsAreEntered;
  pv.buttonText = _LSTR(@"CheckPIN");
  pv.delegate   = self;
}

/**
 *
 */
-(BOOL)prefersStatusBarHidden
{ return YES; }

/**
 *
 */
-(void) passwordViewCanceled:(PasswordView *)passwordView
{ _NSLOG_SELECTOR;
  
  self->resolver(_TRESORERROR(TresorErrorNoPassword));
}


/**
 *
 */
-(void) passwordViewButtonPushed:(PasswordView *)passwordView
{ //_NSLOG_SELECTOR;
  
  self.password = ((PasswordView*)self.view).password;
  
  self->resolver(self.password);
}

@end
