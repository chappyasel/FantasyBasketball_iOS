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

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Settings";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Menu"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(presentLeftMenuViewController:)];
    self.session = [FBSession sharedInstance];
    self.leagueInput.placeholder = [NSString stringWithFormat:@"%d",self.session.leagueID];
    self.teamInput.placeholder = [NSString stringWithFormat:@"%d",self.session.teamID];
    self.seasonInput.placeholder = [NSString stringWithFormat:@"%d",self.session.seasonID];
    self.scoringIDInput.placeholder = [NSString stringWithFormat:@"%d",self.session.scoringPeriodID];
    self.leagueInput.delegate = self;
    self.teamInput.delegate = self;
    self.seasonInput.delegate = self;
    self.scoringIDInput.delegate = self;
    UIView *view = [[UIView alloc] initWithFrame:self.view.frame];
    view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:view];
    [self loadViews];
    [self loadKeyboardDismissBar];
}

- (void)loadViews {
    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 250, 200)];
    container.center = CGPointMake(self.view.center.x, self.view.center.y-100);
    NSArray *labels = @[@"League:",@"Team:",@"Season:",@"ScoringID:"];
    self.leagueInput = [[UITextField alloc] initWithFrame:CGRectMake(100, 0, 150, 30)];
    self.teamInput = [[UITextField alloc] initWithFrame:CGRectMake(100, 50, 150, 30)];
    self.seasonInput = [[UITextField alloc] initWithFrame:CGRectMake(100, 100, 150, 30)];
    self.scoringIDInput = [[UITextField alloc] initWithFrame:CGRectMake(100, 150, 150, 30)];
    NSMutableArray <UITextField *> *textFields = [[NSMutableArray alloc] initWithArray:
                                                  @[self.leagueInput,self.teamInput,self.seasonInput, self.scoringIDInput]];
    NSArray *placeholders = @[[NSString stringWithFormat:@"%d",self.session.leagueID], [NSString stringWithFormat:@"%d",self.session.teamID],
                              [NSString stringWithFormat:@"%d",self.session.seasonID], [NSString stringWithFormat:@"%d",self.session.scoringPeriodID]];
    for (int i = 0; i < 4; i++) {
        textFields[i].placeholder = placeholders[i];
        textFields[i].delegate = self;
        textFields[i].keyboardType = UIKeyboardTypeNumberPad;
        textFields[i].borderStyle = UITextBorderStyleRoundedRect;
        [container addSubview:textFields[i]];
        UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 50*i, 90, 30)];
        label1.text = labels[i];
        label1.textAlignment = NSTextAlignmentRight;
        label1.textColor = [UIColor lightGrayColor];
        [container addSubview:label1];
    }
    [self.view addSubview:container];
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

#pragma mark - Text Field

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (![textField.text isEqualToString:@""]) {
        if (textField == self.leagueInput) self.session.leagueID = [textField.text intValue];
        else if (textField == self.teamInput) self.session.teamID = [textField.text intValue];
        else if (textField == self.seasonInput) self.session.seasonID = [textField.text intValue];
        else if (textField == self.scoringIDInput) self.session.scoringPeriodID = [textField.text intValue];
    }
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
