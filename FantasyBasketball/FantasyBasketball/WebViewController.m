//
//  WebViewController.m
//  FantasyBasketball
//
//  Created by Chappy Asel on 1/18/15.
//  Copyright (c) 2015 CD. All rights reserved.
//

#import "WebViewController.h"
#import "FBSession.h"
#import "PlayerViewController.h"

@interface WebViewController ()

@property UINavigationBar *navBar;
@property UIBarButtonItem *refreshButton;

@property BOOL loaded;

@end

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.loaded = false;
    self.webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, 320, 320)];
    [self.view addSubview:self.webView];
    [self.webView setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.webView.navigationDelegate = self;
    
    if ([self.link containsString:@"http://www.espn.com/nba/boxscore?"])
        self.link = [[self.link stringByReplacingOccurrencesOfString:@"nba/boxscore?id" withString:@"core/nba/gamecast?gameId"]
                                stringByAppendingString:@"&action=stats"];
    NSURL *url = [NSURL URLWithString:self.link];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
}

- (void)viewWillAppear:(BOOL)animated {
    if (!self.loaded) [self loadNavBar];
}

- (void)viewDidAppear:(BOOL)animated {
    if (!self.loaded) {
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.webView
                                                              attribute:NSLayoutAttributeWidth
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeWidth
                                                             multiplier:1.0
                                                               constant:0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.webView
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeHeight
                                                             multiplier:1.0
                                                               constant:-64]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.webView
                                                              attribute:NSLayoutAttributeCenterX
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeCenterX
                                                             multiplier:1.0
                                                               constant:0.0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.webView
                                                              attribute:NSLayoutAttributeCenterY
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeCenterY
                                                             multiplier:1.0
                                                               constant:32.0]];
    }
    self.loaded = YES;
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
    [self.webView reload];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Navigation

- (void)backButtonPressed:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - navigation delegate

-(void)webView:(WKWebView *)webView didStartProvisionalNavigation: (WKNavigation *)navigation {
    NSString *urlString = webView.URL.absoluteString;
    if ([urlString containsString:@"/players/"]) {
        NSArray *urlArray = [urlString componentsSeparatedByString:@"/"];
        NSString *nameString = urlArray[urlArray.count-2];
        [self linkWithPlayerNameArray:[nameString componentsSeparatedByString:@"-"]];
        
        NSURL *nsurl=[NSURL URLWithString:self.link];
        NSURLRequest *nsrequest=[NSURLRequest requestWithURL:nsurl];
        [self.webView loadRequest:nsrequest]; //keep old link
    }
}

- (void)linkWithPlayerNameArray: (NSArray *)array {
    PlayerViewController *modalVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"p"];
    modalVC.modalPresentationStyle = UIModalPresentationCustom;
    modalVC.playerFirstName = array[0];
    modalVC.playerLastName = array[1];
    self.animator = [[ZFModalTransitionAnimator alloc] initWithModalViewController:modalVC];
    self.animator.dragable = YES;
    self.animator.bounces = YES;
    self.animator.behindViewAlpha = 0.8;
    self.animator.behindViewScale = 0.9;
    self.animator.transitionDuration = 0.3;
    self.animator.direction = ZFModalTransitonDirectionBottom;
    [self.animator setContentScrollView:modalVC.bottomScrollView];
    modalVC.transitioningDelegate = self.animator;
    [self presentViewController:modalVC animated:YES completion:nil];
}

- (void)webView:(WKWebView *)webView didFinishNavigation: (WKNavigation *)navigation{
    
}

-(void)webView:(WKWebView *)webView didFailNavigation: (WKNavigation *)navigation withError:(NSError *)error {
    
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

@end
