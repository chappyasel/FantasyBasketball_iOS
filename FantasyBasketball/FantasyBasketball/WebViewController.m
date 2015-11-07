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

@property UINavigationBar *navBar;
@property UIBarButtonItem *refreshButton;

@end

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [self loadNavBar];
    [self.webDisplay loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.link]]];
    self.webDisplay.scrollView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
}

- (void) adjustViewsForOrientation:(UIInterfaceOrientation) orientation {
    switch (orientation) {
        case UIInterfaceOrientationPortrait: case UIInterfaceOrientationPortraitUpsideDown: {
            [self.navBar setFrame:CGRectMake(0, 0, 414, 64)];
            self.webDisplay.frame = CGRectMake(0, 0, 414, 736);
            self.webDisplay.scrollView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
        } break;
        case UIInterfaceOrientationLandscapeLeft: case UIInterfaceOrientationLandscapeRight: {
            [self.navBar setFrame:CGRectMake(0, 0, 736, 44)];
            self.webDisplay.frame = CGRectMake(0, 0, 736, 414);
            self.webDisplay.scrollView.contentInset = UIEdgeInsetsMake(44, 0, 0, 0);
        } break;
        case UIInterfaceOrientationUnknown: break;
    }
}

- (void)loadNavBar {
    self.navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 64)];
    if (self.view.frame.size.height < 500) self.navBar.frame = CGRectMake(0, 0, self.view.frame.size.width, 44);
    UINavigationItem *navItem = [[UINavigationItem alloc] initWithTitle:@""];
    self.refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshButtonPressed:)];
    navItem.rightBarButtonItem = self.refreshButton;
    UIBarButtonItem *bi2 = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(backButtonPressed:)];
    navItem.leftBarButtonItem = bi2;
    self.navBar.items = [NSArray arrayWithObject:navItem];
    [self.view addSubview:self.navBar];
}

- (void)refreshButtonPressed:(UIButton *)sender {
    [self.webDisplay reload];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    NSLog(@"MEMORY WARNING");
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
