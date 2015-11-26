//
//  WebViewController.h
//  FantasyBasketball
//
//  Created by Chappy Asel on 1/18/15.
//  Copyright (c) 2015 CD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@interface WebViewController : UIViewController <WKNavigationDelegate, UIGestureRecognizerDelegate>

@property NSString *link;

@property (strong, nonatomic) IBOutlet WKWebView *webView;

@end
