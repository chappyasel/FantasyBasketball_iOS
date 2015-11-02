//
//  WebViewController.m
//  FantasyBasketball
//
//  Created by Chappy Asel on 1/18/15.
//  Copyright (c) 2015 CD. All rights reserved.
//

#import "WebViewController.h"
#import "FBSession.h"

@interface WebViewController ()

@end

@implementation WebViewController

UINavigationBar *barWV;
UIBarButtonItem *refreshButton;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadNavBar];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [_webDisplay loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.link]]];
    _webDisplay.clipsToBounds = NO;
}

- (void) adjustViewsForOrientation:(UIInterfaceOrientation) orientation {
    switch (orientation) {
        case UIInterfaceOrientationPortrait: case UIInterfaceOrientationPortraitUpsideDown: {
            [barWV setFrame:CGRectMake(0, 0, 414, 64)];
            _webDisplay.frame = CGRectMake(0, 0, 414, 736);
            _webDisplay.scrollView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
        } break;
        case UIInterfaceOrientationLandscapeLeft: case UIInterfaceOrientationLandscapeRight: {
            [barWV setFrame:CGRectMake(0, 0, 736, 44)];
            _webDisplay.frame = CGRectMake(0, 0, 736, 414);
            _webDisplay.scrollView.contentInset = UIEdgeInsetsMake(44, 0, 0, 0);
        } break;
        case UIInterfaceOrientationUnknown: break;
    }
}

- (void)loadNavBar {
    barWV = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 64)];
    if (self.view.frame.size.height < 500) barWV.frame = CGRectMake(0, 0, self.view.frame.size.width, 44);
    UINavigationItem *navItem = [[UINavigationItem alloc] initWithTitle:@""];
    refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshButtonPressed:)];
    navItem.rightBarButtonItem = refreshButton;
    UIBarButtonItem *bi2 = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(backButtonPressed:)];
    navItem.leftBarButtonItem = bi2;
    barWV.items = [NSArray arrayWithObject:navItem];
    [self.view addSubview:barWV];
}

- (void)refreshButtonPressed:(UIButton *)sender {
    [_webDisplay reload];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    NSLog(@"MEMORY WARNING");
}

#pragma mark - Swipe Gesture

- (IBAction)UserDidSwipe:(UISwipeGestureRecognizer *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Navigation

- (void)backButtonPressed:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

@end
