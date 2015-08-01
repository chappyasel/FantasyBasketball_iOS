//
//  SettingsViewController.m
//  FantasyBasketball
//
//  Created by Chappy Asel on 1/14/15.
//  Copyright (c) 2015 CD. All rights reserved.
//

#import "SettingsViewController.h"
#import "FBSession.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

FBSession *session;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadNavBar];
    session = [FBSession sharedInstance];
    _leagueInput.placeholder = [NSString stringWithFormat:@"%d",session.leagueID];
    _teamInput.placeholder = [NSString stringWithFormat:@"%d",session.teamID];
    _seasonInput.placeholder = [NSString stringWithFormat:@"%d",session.seasonID];
    _scoringIDInput.placeholder = [NSString stringWithFormat:@"%d",session.scoringPeriodID];
    _leagueInput.delegate = self;
    _teamInput.delegate = self;
    _seasonInput.delegate = self;
    _scoringIDInput.delegate = self;
    [self loadKeyboardDismissBar];
}

- (void)loadNavBar {
    self.title = @"Settings";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Menu"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(presentLeftMenuViewController:)];
}

- (void)loadKeyboardDismissBar {
    NSArray *textFields = [[NSArray alloc] initWithObjects:_leagueInput, _teamInput, _seasonInput, _scoringIDInput, nil];
    for (UITextField *field in textFields) {
        UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:field action:@selector(resignFirstResponder)];
        UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 414, 44)];
        toolbar.items = [NSArray arrayWithObject:barButton];
        field.inputAccessoryView = toolbar;
    }
}

#pragma mark - Text Field

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField == _leagueInput) session.leagueID = [textField.text intValue];
    else if (textField == _teamInput) session.teamID = [textField.text intValue];
    else if (textField == _seasonInput) session.seasonID = [textField.text intValue];
    else if (textField == _scoringIDInput) session.scoringPeriodID = [textField.text intValue];
}

@end
