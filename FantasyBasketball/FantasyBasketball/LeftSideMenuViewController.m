//
//  LeftSideMenuViewController.m
//  FantasyBasketball
//
//  Created by Chappy Asel on 7/31/15.
//  Copyright © 2015 CD. All rights reserved.
//

#import "LeftSideMenuViewController.h"

#import "SettingsViewController.h"
#import "MatchupViewController.h"
#import "MyTeamViewController.h"
#import "PlayersViewController.h"
#import "DailyLeadersViewController.h"

@implementation LeftSideMenuViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, (self.view.frame.size.height - 64 * 5) / 2.0f, self.view.frame.size.width, 64 * 5) style:UITableViewStylePlain];
        tableView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.opaque = NO;
        tableView.backgroundColor = [UIColor clearColor];
        tableView.backgroundView = nil;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.bounces = NO;
        tableView;
    });
    [self.view addSubview:self.tableView];
}

#pragma mark UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    int i = (int)indexPath.row;
    if (i == 0) {
        [self.sideMenuViewController setContentViewController:[[UINavigationController alloc] initWithRootViewController:[[SettingsViewController alloc] init]] animated:YES];
    }
    else if (i == 1) {
        [self.sideMenuViewController setContentViewController:[[UINavigationController alloc] initWithRootViewController:[[MatchupViewController alloc] init]] animated:YES];
    }
    else if (i == 2) {
        [self.sideMenuViewController setContentViewController:[[UINavigationController alloc] initWithRootViewController:[[MyTeamViewController alloc] init]] animated:YES];
    }
    else if (i == 3) {
        [self.sideMenuViewController setContentViewController:[[UINavigationController alloc] initWithRootViewController:[[PlayersViewController alloc] init]] animated:YES];
    }
    else if (i == 4) {
        [self.sideMenuViewController setContentViewController:[[UINavigationController alloc] initWithRootViewController:[[DailyLeadersViewController alloc] init]] animated:YES];
    }
    [self.sideMenuViewController hideMenuViewController];
}

#pragma mark UITableView Datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 64;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex {
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:21];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.highlightedTextColor = [UIColor lightGrayColor];
        cell.selectedBackgroundView = [[UIView alloc] init];
    }
    NSArray *titles = @[@"Settings", @"Matchup", @"My Team", @"Players", @"Daily Leaders"];
    //NSArray *images = @[@"MU.png", @"MT.png", @"PL.png", @"DL.png", @"MU.png"];
    cell.textLabel.text = titles[indexPath.row];
    //cell.imageView.image = [UIImage imageNamed:images[indexPath.row]];
    return cell;
}

@end
