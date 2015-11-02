//
//  WebViewController.h
//  FantasyBasketball
//
//  Created by Chappy Asel on 1/18/15.
//  Copyright (c) 2015 CD. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController <UIWebViewDelegate, UIGestureRecognizerDelegate>

@property NSString *link;

@property (weak, nonatomic) IBOutlet UIWebView *webDisplay;

@end
