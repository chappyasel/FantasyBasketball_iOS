//
//  FBViewController.m
//  FantasyBasketball
//
//  Created by Chappy Asel on 7/31/15.
//  Copyright © 2015 CD. All rights reserved.
//

#import "FBViewController.h"

@interface FBViewController ()

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

#pragma mark - PlayerCell delegate

- (void)linkWithPlayer:(FBPlayer *)player {
    _session.player = player;
    UIViewController *viewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"p"];
    MZFormSheetController *formSheet = [[MZFormSheetController alloc] initWithViewController:viewController];
    formSheet.shouldDismissOnBackgroundViewTap = YES;
    formSheet.transitionStyle = MZFormSheetTransitionStyleSlideFromBottom;
    formSheet.shouldCenterVertically = YES;
    formSheet.cornerRadius = 5.0;
    formSheet.portraitTopInset = 6.0;
    formSheet.landscapeTopInset = 6.0;
    formSheet.presentedFormSheetSize = CGSizeMake(375, 680);
    [self mz_presentFormSheetController:formSheet animated:YES completionHandler:nil];
}

- (void)linkWithGameLink:(FBPlayer *)player {
    _session.link = [player gameLink];
    UIViewController *viewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"w"];
    viewController.modalPresentationStyle = UIModalPresentationFormSheet;
    viewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:viewController animated:YES completion:nil];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
// Get the new view controller using [segue destinationViewController].
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
}

@end
