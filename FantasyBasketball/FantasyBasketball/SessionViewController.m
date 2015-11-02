//
//  SessionViewController.m
//  FantasyBasketball
//
//  Created by Chappy Asel on 11/1/15.
//  Copyright © 2015 CD. All rights reserved.
//

#import "SessionViewController.h"
#import "AppDelegate.h"

@interface SessionViewController ()

@end

@implementation SessionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.nameInput.delegate = self;
    self.leagueInput.delegate = self;
    self.teamInput.delegate = self;
    self.seasonInput.delegate = self;
    self.scoringIDInput.delegate = self;
    [self loadKeyboardDismissBar];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    [self.nameInput becomeFirstResponder];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.session.name = self.nameInput.text;
    self.session.leagueID = [NSNumber numberWithInt:[self.leagueInput.text intValue]];
    self.session.teamID = [NSNumber numberWithInt:[self.teamInput.text intValue]];
    self.session.seasonID = [NSNumber numberWithInt:[self.seasonInput.text intValue]];
    self.session.scoringPeriodID = [NSNumber numberWithInt:[self.scoringIDInput.text intValue]];
    [self.delegate sessionVCDidDissapearWithResultSession:self.session];
}

- (void)loadKeyboardDismissBar {
    NSArray *textFields = [[NSArray alloc] initWithObjects:self.leagueInput, self.teamInput, self.seasonInput, self.scoringIDInput, nil];
    for (UITextField *field in textFields) {
        UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:field action:@selector(resignFirstResponder)];
        UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 414, 44)];
        toolbar.items = [NSArray arrayWithObject:barButton];
        field.inputAccessoryView = toolbar;
    }
}

- (IBAction)doneButtonPressed:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - keyboard notifications

- (void)keyboardWillShow: (NSNotification *) notif{
    CGSize keyboardSize = [[[notif userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    int height = MIN(keyboardSize.height,keyboardSize.width);
    [self.scrollView setContentOffset:CGPointMake(0, height) animated:YES];
}

- (void)keyboardWillHide: (NSNotification *) notif{
    [self.scrollView setContentOffset:CGPointMake(0, 00) animated:YES];
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
