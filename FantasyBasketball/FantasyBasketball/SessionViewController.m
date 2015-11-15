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
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, self.scrollView.frame.size.height+260);
    self.nameInput.delegate = self;
    self.leagueInput.delegate = self;
    self.teamInput.delegate = self;
    self.seasonInput.delegate = self;
    self.scoringIDInput.delegate = self;
    [self.nameInput becomeFirstResponder];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if (!self.nameInput.text || [self.nameInput.text isEqualToString:@""]) self.session.name = self.nameInput.placeholder;
    else self.session.name = self.nameInput.text;
    self.session.leagueID = [NSNumber numberWithInt:[self.leagueInput.text intValue]];
    self.session.teamID = [NSNumber numberWithInt:[self.teamInput.text intValue]];
    self.session.seasonID = [NSNumber numberWithInt:[self.seasonInput.text intValue]];
    [self.delegate sessionVCDidDissapearWithResultSession:self.session];
}

- (IBAction)doneButtonPressed:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
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
