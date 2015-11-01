//
//  FBViewController.m
//  FantasyBasketball
//
//  Created by Chappy Asel on 7/31/15.
//  Copyright © 2015 CD. All rights reserved.
//

#import "FBViewController.h"

@interface FBViewController ()

@property (nonatomic, strong) ZFModalTransitionAnimator *animator;

@end

@implementation FBViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Menu"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(presentLeftMenuViewController:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                                                                           target:self
                                                                                           action:@selector(fadeIn:)];
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
    self.session = [FBSession sharedInstance];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.showsHorizontalScrollIndicator = NO;
    self.tableView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:self.tableView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - FBPickerView delegate

-(void) fadeIn:(UIButton *)sender {
    
}

-(void)fadeOutWithPickerView: (FBPickerView *) pickerView {
    [pickerView setAlpha:1.0];
    [UIView animateWithDuration:0.1 animations:^{
        [pickerView setAlpha:0.0];
    } completion:^(BOOL finished) {
        [pickerView removeFromSuperview];
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }];
}

#pragma mark - tableView dataSource

- (NSInteger) tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (UITableViewCell *) tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    return nil;
}

#pragma mark - PlayerCell delegate

- (void)linkWithPlayer:(FBPlayer *)player {
    _session.player = player;
    PlayerViewController *modalVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"p"];
    modalVC.modalPresentationStyle = UIModalPresentationCustom;
    self.animator = [[ZFModalTransitionAnimator alloc] initWithModalViewController:modalVC];
    self.animator.dragable = YES;
    self.animator.bounces = YES;
    self.animator.behindViewAlpha = 0.8;
    self.animator.behindViewScale = 0.9;
    self.animator.transitionDuration = 0.5;
    self.animator.direction = ZFModalTransitonDirectionBottom;
    [self.animator setContentScrollView:modalVC.bottomScrollView];
    modalVC.transitioningDelegate = self.animator;
    [self presentViewController:modalVC animated:YES completion:nil];
}

- (void)linkWithGameLink:(FBPlayer *)player {
    _session.link = [player gameLink];
    UIViewController *viewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"w"];
    viewController.modalPresentationStyle = UIModalPresentationFormSheet;
    viewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:viewController animated:YES completion:nil];
}

#pragma mark - FBPickerView delegate

- (void)doneButtonPressedInPickerView:(FBPickerView *)pickerView {
    
}

- (void)cancelButtonPressedInPickerView:(FBPickerView *)pickerView {
    
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
// Get the new view controller using [segue destinationViewController].
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
}

@end
