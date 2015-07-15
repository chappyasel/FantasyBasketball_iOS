//
//  MoreViewController.m
//  FantasyBasketball
//
//  Created by Chappy Asel on 1/14/15.
//  Copyright (c) 2015 CD. All rights reserved.
//

#import "MoreViewController.h"
#import "Session.h"

@interface MoreViewController ()

@end

@implementation MoreViewController

Session *session;

- (void)viewDidLoad {
    [super viewDidLoad];
    session = [Session sharedInstance];
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

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
// Get the new view controller using [segue destinationViewController].
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
}

@end
