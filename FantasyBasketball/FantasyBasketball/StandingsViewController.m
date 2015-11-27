//
//  StandingsViewController.m
//  FantasyBasketball
//
//  Created by Chappy Asel on 11/7/15.
//  Copyright © 2015 CD. All rights reserved.
//

#import "StandingsViewController.h"
#import "MyTeamViewController.h"

@interface StandingsViewController ()

@property NSMutableArray *standingTables; //name, teams -> (link, name, wins, losses, ties, gb)
@property NSMutableArray *teamStats; //link, name, pf, pa, moves

@property BOOL loaded;

@end

@implementation StandingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Standings";
    self.navigationItem.rightBarButtonItem = nil;
    self.loaded = NO;
    [self beginAsyncLoading];
}

- (void)beginAsyncLoading {
    dispatch_queue_t myQueue = dispatch_queue_create("My Queue",NULL);
    dispatch_async(myQueue, ^{
        [self loadLeagueStandingsWithCompletionBlock:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                self.loaded = YES;
                [self.tableView reloadData];
            });
        }];
    });
}

- (void)loadLeagueStandingsWithCompletionBlock:(void (^)(void)) completed {
    self.standingTables = [[NSMutableArray alloc] init];
    self.teamStats = [[NSMutableArray alloc] init];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://games.espn.go.com/fba/standings?leagueId=%@&seasonId=%@",self.session.leagueID,self.session.seasonID]];
    NSError *error;
    NSData *html = [NSData dataWithContentsOfURL:url options:NSDataReadingMapped error:&error];
    if (error) NSLog(@"Standings error: %@",error);
    TFHpple *parser = [TFHpple hppleWithHTMLData:html];
    NSArray *nodes = [parser searchWithXPathQuery:@"//div[@class='games-fullcol games-fullcol-extramargin']/table"];
    NSArray *standingTables = [[nodes[0] firstChild] children];
    for (int i = 1; i < standingTables.count; i+= 2) {
        TFHppleElement *table = [standingTables[i] children][1];
        NSMutableArray *teams = [[NSMutableArray alloc] init];
        for (int t = 3; t < table.children.count; t++) {
            TFHppleElement *team = table.children[t];
            NSString *link = [NSString stringWithFormat:@"%@%@",@"http://games.espn.go.com",team.firstChild.firstChild.attributes[@"href"]];
            NSString *teamName = team.firstChild.content;
            NSArray *info = @[[team.children[1] content], [team.children[2] content],
                              [team.children[3] content], [team.children[5] content]];
            [teams addObject:[[NSDictionary alloc] initWithObjects:@[link, teamName, info[0], info[1], info[2], info[3]] forKeys:@[@"link", @"name", @"wins", @"losses", @"ties", @"gb"]]];
        }
        NSString *leagueName = [table.children[1] content];
        [self.standingTables addObject:[[NSDictionary alloc] initWithObjects:@[teams, leagueName] forKeys:@[@"teams", @"name"]]];
    }
    TFHppleElement *statTable = nodes[1];
    for (int i = 7; i <statTable.children.count; i+=2) {
        TFHppleElement *teamRow = statTable.children[i];
        NSString *link = [NSString stringWithFormat:@"%@%@",@"http://games.espn.go.com",[teamRow.children[1] firstChild].attributes[@"href"]];
        NSString *teamName = [teamRow.children[1] content];
        NSArray *info = @[link, teamName, [teamRow.children[16] content], [teamRow.children[17] content], [teamRow.children[19] content]];
        NSArray *keys = @[@"link", @"name", @"pf", @"pa", @"moves"];
        [self.teamStats addObject:[[NSDictionary alloc] initWithObjects:info forKeys:keys]];
    }
    completed();
}

#pragma mark - table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 2) {
        [self linkWithTeamLink:self.teamStats[indexPath.row][@"link"]];
    }
    else {
        [self linkWithTeamLink:self.standingTables[indexPath.section][@"teams"][indexPath.row][@"link"]];
    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.loaded) {
        if (section == 2) return self.teamStats.count;
        return [self.standingTables[section][@"teams"] count];
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    float width = self.view.frame.size.width;
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 30)];
    view.backgroundColor = [UIColor FBMediumOrangeColor];
    if (self.loaded) {
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, width-180, 30)];
        if (section == 2) title.text = @"SEASON STATS";
        else title.text = self.standingTables[section][@"name"];
        title.font = [UIFont boldSystemFontOfSize:15];
        title.textColor = [UIColor whiteColor];
        [view addSubview:title];
        if (section == 2) {
            NSArray *arr = @[@"PF", @"PA", @"MOVE"];
            for (int i = 0; i < arr.count; i++) {
                UILabel *stats = [[UILabel alloc] initWithFrame:CGRectMake(width-180+60*i, 0, 60, 30)];
                stats.text = arr[i];
                stats.font = [UIFont boldSystemFontOfSize:15];
                stats.textColor = [UIColor whiteColor];
                stats.textAlignment = NSTextAlignmentCenter;
                [view addSubview:stats];
            }
        }
        else {
            NSArray *arr = @[@"W", @"L", @"T", @"GB"];
            for (int i = 0; i < arr.count; i++) {
                UILabel *stats = [[UILabel alloc] initWithFrame:CGRectMake(width-180+45*i, 0, 45, 30)];
                stats.text = arr[i];
                stats.font = [UIFont boldSystemFontOfSize:15];
                stats.textColor = [UIColor whiteColor];
                stats.textAlignment = NSTextAlignmentCenter;
                [view addSubview:stats];
            }
        }
    }
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    float width = self.view.frame.size.width;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Identifier"];
    cell = nil; //temporary
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Identifier"];
    }
    if (indexPath.section == 2) {
        NSDictionary *team = self.teamStats[indexPath.row];
        UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, width-180, 50)];
        name.text = [NSString stringWithFormat:@"%ld. %@",indexPath.row+1, team[@"name"]];
        name.font = [UIFont systemFontOfSize:16];
        name.textColor = [UIColor darkGrayColor];
        [cell addSubview:name];
        NSArray *arr = @[team[@"pf"], team[@"pa"], team[@"moves"]];
        for (int i = 0; i < arr.count; i++) {
            UILabel *stats = [[UILabel alloc] initWithFrame:CGRectMake(width-180+60*i, 0, 60, 50)];
            stats.text = arr[i];
            stats.font = [UIFont systemFontOfSize:16];
            stats.textColor = [UIColor darkGrayColor];
            stats.textAlignment = NSTextAlignmentCenter;
            [cell addSubview:stats];
        }
    }
    else {
        NSDictionary *team = self.standingTables[indexPath.section][@"teams"][indexPath.row];
        UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, width-180, 50)];
        name.text = [NSString stringWithFormat:@"%ld. %@",indexPath.row+1, team[@"name"]];
        name.font = [UIFont systemFontOfSize:16];
        name.textColor = [UIColor darkGrayColor];
        [cell addSubview:name];
        NSArray *arr = @[team[@"wins"], team[@"losses"], team[@"ties"], team[@"gb"]];
        for (int i = 0; i < arr.count; i++) {
            UILabel *stats = [[UILabel alloc] initWithFrame:CGRectMake(width-180+45*i, 0, 45, 50)];
            stats.text = arr[i];
            stats.font = [UIFont systemFontOfSize:16];
            stats.textColor = [UIColor darkGrayColor];
            stats.textAlignment = NSTextAlignmentCenter;
            [cell addSubview:stats];
        }
    }
    return cell;
}

#pragma mark - link

- (void)linkWithTeamLink:(NSString *)link {
    MyTeamViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"mt"];
    [vc initWithTeamLink:link];
    UINavigationController *modalVC = [[UINavigationController alloc] initWithRootViewController:vc];
    modalVC.navigationBar.barTintColor = [UIColor FBDarkOrangeColor];
    modalVC.navigationBar.tintColor = [UIColor whiteColor];
    modalVC.navigationBar.translucent = NO;
    modalVC.navigationBar.barStyle = UIBarStyleBlack;
    [modalVC.navigationBar setTitleTextAttributes: @{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    modalVC.modalPresentationStyle = UIModalPresentationCustom;
    self.animator = [[ZFModalTransitionAnimator alloc] initWithModalViewController:modalVC];
    self.animator.dragable = NO;
    self.animator.bounces = YES;
    self.animator.behindViewAlpha = 0.8;
    self.animator.behindViewScale = 0.9;
    self.animator.transitionDuration = 0.5;
    self.animator.direction = ZFModalTransitonDirectionBottom;
    [self.animator setContentScrollView:vc.tableView];
    modalVC.transitioningDelegate = self.animator;
    [self presentViewController:modalVC animated:YES completion:nil];
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
