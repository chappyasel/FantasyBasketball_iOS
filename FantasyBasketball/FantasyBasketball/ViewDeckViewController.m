//
//  ViewDeckViewController.m
//  FantasyBasketball
//
//  Created by Chappy Asel on 7/31/15.
//  Copyright © 2015 CD. All rights reserved.
//

#import "ViewDeckViewController.h"
#import "IIViewDeckController.h"
#import "MatchupViewController.h"

@interface ViewDeckViewController ()

@property (nonatomic, strong) UIViewController *leftViewController;
@property (nonatomic, strong) UIViewController *centerViewController;

@property (nonatomic, strong) IIViewDeckController *deckController;

@end

@implementation ViewDeckViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _leftViewController = [[UIViewController alloc] init];
    _centerViewController = [[MatchupViewController alloc] init];
    _deckController =  [[IIViewDeckController alloc]
                                            initWithCenterViewController: [[UINavigationController alloc] initWithRootViewController:_centerViewController]
                                            leftViewController: _leftViewController
                                            rightViewController:nil];
    _deckController.centerhiddenInteractivity = IIViewDeckCenterHiddenNotUserInteractiveWithTapToClose;
    _deckController.delegateMode = IIViewDeckDelegateAndSubControllers;
    [self presentViewController:_deckController animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
