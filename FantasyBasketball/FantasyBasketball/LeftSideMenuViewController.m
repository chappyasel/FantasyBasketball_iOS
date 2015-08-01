//
//  LeftSideMenuViewController.m
//  FantasyBasketball
//
//  Created by Chappy Asel on 7/31/15.
//  Copyright © 2015 CD. All rights reserved.
//

#import "LeftSideMenuViewController.h"
#import "FBSession.h"
#import "TFHpple.h"

#import "SettingsViewController.h"
#import "MatchupViewController.h"
#import "MyTeamViewController.h"
#import "PlayersViewController.h"
#import "DailyLeadersViewController.h"

@implementation LeftSideMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, (self.view.frame.size.height-(54*5+200))/2.0, self.view.frame.size.width, 54*5+200) style:UITableViewStylePlain];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    int i = (int)indexPath.row;
    if (i == 1) {
        [self.sideMenuViewController setContentViewController:[[UINavigationController alloc] initWithRootViewController:[[SettingsViewController alloc] init]] animated:YES];
    }
    else if (i == 2) {
        [self.sideMenuViewController setContentViewController:[[UINavigationController alloc] initWithRootViewController:[[MatchupViewController alloc] init]] animated:YES];
    }
    else if (i == 3) {
        [self.sideMenuViewController setContentViewController:[[UINavigationController alloc] initWithRootViewController:[[MyTeamViewController alloc] init]] animated:YES];
    }
    else if (i == 4) {
        [self.sideMenuViewController setContentViewController:[[UINavigationController alloc] initWithRootViewController:[[PlayersViewController alloc] init]] animated:YES];
    }
    else if (i == 5) {
        [self.sideMenuViewController setContentViewController:[[UINavigationController alloc] initWithRootViewController:[[DailyLeadersViewController alloc] init]] animated:YES];
    }
    else return;
    [self.sideMenuViewController hideMenuViewController];
}

#pragma mark UITableView Datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) return 200;
    return 54;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex {
    return 6;
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
    NSArray *titles = @[@"", @"Settings", @"Matchup", @"My Team", @"Players", @"Daily Leaders"];
    NSArray *images = @[@"", @"SE@2x.png", @"MA@2x.png", @"MY@2x.png", @"PL@2x.png", @"DL@2x.png"];
    cell.textLabel.text = titles[indexPath.row];
    cell.imageView.image = [UIImage imageNamed:images[indexPath.row]];
    if (indexPath.row == 0) {
        FBSession *session = [FBSession sharedInstance];
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://games.espn.go.com/fba/clubhouse?leagueId=%d&teamId=%d&seasonId=%d",session.leagueID,session.teamID,session.seasonID]];
        NSError *error;
        NSData *html = [NSData dataWithContentsOfURL:url options:NSDataReadingMappedIfSafe error:&error];
        if (error) NSLog(@"%@",error);
        TFHpple *parser = [TFHpple hppleWithHTMLData:html];
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(20, 0, 200, 200)];
        [cell addSubview:view];
        //BOTTOM LINE
        CALayer *bottomBorder = [CALayer layer];
        bottomBorder.frame = CGRectMake(0, 199, 200, 1);
        bottomBorder.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0].CGColor;
        [view.layer addSublayer:bottomBorder];
        //PROFILE PHOTO
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(36, 0, 128, 128)];
        imageView.layer.cornerRadius = 60;
        /*
        imageView.layer.borderWidth = 1;
        imageView.layer.borderColor = [UIColor whiteColor].CGColor;
        */
        imageView.image = [UIImage imageNamed:@"basketball@2x"];
        imageView.alpha = 0.6;
        [view addSubview:imageView];
        //NAME
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 125, 200, 30)];
        NSString *XpathQueryString = @"//h3[@class='team-name']";
        NSArray <TFHppleElement *> *nodes = [parser searchWithXPathQuery:XpathQueryString];
        nameLabel.text = nodes.firstObject.content;
        nameLabel.textAlignment = NSTextAlignmentCenter;
        nameLabel.textColor = [UIColor whiteColor];
        nameLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:19];
        [view addSubview:nameLabel];
        //LEAGUE
        UILabel *leagueLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 150, 200, 20)];
        XpathQueryString = @"//div[@class='games-univ-mod3']/ul";
        nodes = [parser searchWithXPathQuery:XpathQueryString];
        leagueLabel.text = nodes.firstObject.content;
        leagueLabel.textAlignment = NSTextAlignmentCenter;
        leagueLabel.textColor = [UIColor whiteColor];
        leagueLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:15];
        [view addSubview:leagueLabel];
        //RECORD
        UILabel *recordLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 170, 200, 20)];
        XpathQueryString = @"//div[@class='games-univ-mod4']";
        nodes = [parser searchWithXPathQuery:XpathQueryString];
        recordLabel.text = [nodes.firstObject.content substringWithRange:NSMakeRange(8, nodes.firstObject.content.length-16)];
        recordLabel.textAlignment = NSTextAlignmentCenter;
        recordLabel.textColor = [UIColor whiteColor];
        recordLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:15];
        [view addSubview:recordLabel];
    }
    return cell;
}

@end
