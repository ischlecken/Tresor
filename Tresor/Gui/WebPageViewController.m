//  Created by Stefan Thomas on 16.01.15.
//  Copyright (c) 2015 LSSiEurope. All rights reserved.
//
#import "WebPageViewController.h"


@interface WebPageViewController () <UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView*               webPageView;
@property (weak, nonatomic)          UIActivityIndicatorView* activityView;
@end

@implementation WebPageViewController

/**
 *
 */
-(void) viewDidLoad
{ _NSLOG_SELECTOR;
  
  [super viewDidLoad];
  
  [self startActivity];
  
  [self loadLandingURL];
}

/**
 *
 */
-(void) startActivity
{ if( self.activityView==nil )
  { UIActivityIndicatorView* av = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    [av setColor:[_TRESORCONFIG colorWithName:kTintColorName]];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:av];
    
    self.activityView = av;
    
    [self.activityView startAnimating];
  } /* of if */
}

/**
 *
 */
-(void) stopActivity
{ [self.activityView stopAnimating];
  self.activityView = nil;
  
  self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                                                         target:self
                                                                                         action:@selector(showExternalAction:)];
}



/**
 *
 */
-(void) loadLandingURL
{ _NSLOG(@"webPageURL:%@",self.webPageURL);
  
  if( self.webPageURL )
  { NSURL* url = [NSURL URLWithString:self.webPageURL];
    
    if( url )
    { NSURLRequest* urlRequest = [NSURLRequest requestWithURL:url];
      
      if( urlRequest )
      { _NSLOG(@"load urlRequest:%@",urlRequest);
        
        [self.webPageView loadRequest:urlRequest];
      } /* of if */
    } /* of if */
  } /* of if */
}

#pragma mark UIWebViewDelegate

/**
 *
 */
-(BOOL) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{ //_NSLOG(@"request:%@ navigationType:%ld",request,(long)navigationType);
  
  if( (navigationType==UIWebViewNavigationTypeLinkClicked || navigationType==UIWebViewNavigationTypeFormSubmitted) &&
      self.activityView==nil
    )
    [self startActivity];
  
  return YES;
}

/**
 *
 */
-(void) webViewDidStartLoad:(UIWebView *)webView
{ //_NSLOG_SELECTOR;
}

/**
 *
 */
-(void) webViewDidFinishLoad:(UIWebView *)webView
{ //_NSLOG_SELECTOR;
  
  if( !webView.isLoading )
    [self stopActivity];
}

/**
 *
 */
-(void) webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{ _NSLOG_SELECTOR;
}

#pragma mark Actions

/**
 *
 */
-(void) showExternalAction:(id)sender
{ [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.webPageURL]];
}
@end
