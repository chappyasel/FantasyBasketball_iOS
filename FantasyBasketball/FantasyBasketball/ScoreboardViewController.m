//
//  ScoreboardViewController.m
//  FantasyBasketball
//
//  Created by Chappy Asel on 11/7/15.
//  Copyright © 2015 CD. All rights reserved.
//

#import "ScoreboardViewController.h"
#import "MatchupViewController.h"

@interface ScoreboardViewController ()

@property NSMutableArray *leagueScoreboard; //link, teams -> (name, abbreviation, record, manager, score, teamLink)
@property NSMutableArray *NBAScoreboard; //status, tv, teams -> (abbreviation, image, name, score)

@property BOOL isInLeagueMode;

@property NSMutableArray *cells;

@end

@implementation ScoreboardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Scoreboard";
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.isInLeagueMode = YES;
    [self setupTableHeaderView];
    [self beginAsyncLoading];
}

- (void)beginAsyncLoading {
    dispatch_queue_t myQueue = dispatch_queue_create("My Queue",NULL);
    dispatch_async(myQueue, ^{
        [self loadLeagueScoreboardWithCompletionBlock:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.isInLeagueMode) {
                    [self.tableView reloadData];
                    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
                }
            });
        }];
        [self loadNBAScoreboardWithCompletionBlock:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!self.isInLeagueMode) {
                    [self.tableView reloadData];
                    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
                }
            });
        }];
    });
}

- (void)refreshNonAsync {
    [self loadLeagueScoreboardWithCompletionBlock:^{
        if (self.isInLeagueMode) [self.tableView reloadData];
    }];
    [self loadNBAScoreboardWithCompletionBlock:^{
        if (!self.isInLeagueMode) [self.tableView reloadData];
    }];
}

- (void)loadLeagueScoreboardWithCompletionBlock:(void (^)(void)) completed {
    self.leagueScoreboard = [[NSMutableArray alloc] init];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://games.espn.go.com/fba/scoreboard?leagueId=%@&seasonId=%@",self.session.leagueID,self.session.seasonID]];
    NSError *error;
    NSData *html = [NSData dataWithContentsOfURL:url options:NSDataReadingMapped error:&error];
    if (error) NSLog(@"Scoreboard error: %@",error);
    TFHpple *parser = [TFHpple hppleWithHTMLData:html];
    NSArray *nodes = [parser searchWithXPathQuery:@"//div[@id='scoreboardMatchups']/div/table/tr/td/table"];
    for (int i = 0; i < nodes.count; i++) {
        TFHppleElement *matchupElement = nodes[i];
        NSMutableArray *muTeams = [[NSMutableArray alloc] init];
        for (int t = 0; t < 2; t++) {
            NSMutableDictionary *teamDict = [[NSMutableDictionary alloc] init];
            TFHppleElement *team = matchupElement.children[t];
            teamDict[@"score"] = [team.children[1] content];
            NSArray *nameAbbrev = [team.firstChild.firstChild.content componentsSeparatedByString:@" "];
            NSString *name = nameAbbrev[0];
            for (int i = 1; i < nameAbbrev.count-1; i++) name = [NSString stringWithFormat:@"%@ %@",name,nameAbbrev[i]];
            teamDict[@"name"] = name;
            teamDict[@"abbreviation"] = [[nameAbbrev[nameAbbrev.count-1] stringByReplacingOccurrencesOfString:@")" withString:@""] stringByReplacingOccurrencesOfString:@"(" withString:@""];
            NSArray *recordManager = [[[team.firstChild.children[1] content] stringByReplacingOccurrencesOfString:@")" withString:@" "] componentsSeparatedByString:@" "];
            NSString *manager = recordManager[1];
            for (int i = 2; i < recordManager.count; i++) manager = [NSString stringWithFormat:@"%@ %@",manager,recordManager[i]];
            teamDict[@"manager"] = manager;
            teamDict[@"record"] = [recordManager[0] stringByReplacingOccurrencesOfString:@"(" withString:@""];
            [muTeams addObject:teamDict];
        }
        NSString *link = [matchupElement.children[2] firstChild].firstChild.firstChild.attributes[@"href"];
        link = [NSString stringWithFormat:@"%@%@",@"http://games.espn.go.com",link];
        [self.leagueScoreboard addObject:[[NSDictionary alloc] initWithObjects:@[muTeams, link] forKeys:@[@"teams", @"link"]]];
    }
    completed();
}

/*
- (void)loadNBAScoreboardWithCompletionBlock:(void (^)(void)) completed {
    self.NBAScoreboard = [[NSMutableArray alloc] init];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyymmdd"];
    NSDate *date = [NSDate date];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://espn.go.com/nba/scoreboard/_/date/%@",@"20151128"]];
    NSError *error;
    NSData *html = [NSData dataWithContentsOfURL:url options:NSDataReadingMapped error:&error];
    if (error) NSLog(@"Scoreboard error: %@",error);
    TFHpple *parser = [TFHpple hppleWithHTMLData:html];
    NSArray <TFHppleElement *> *nodes = [parser searchWithXPathQuery:@"//div[@id='events']"];
    for (int i = 0; i < nodes.count; i++) {
        TFHppleElement *gameInfo = nodes[i].firstChild.firstChild.firstChild;
        TFHppleElement *gameStatus = [nodes[i].firstChild.firstChild children][3];
        NSString *liveStatus = [gameStatus.firstChild.firstChild.children[1] content];
        NSString *image = [gameStatus.firstChild.children[1] firstChild].firstChild.attributes[@"src"];
        image = [NSString stringWithFormat:@"%@%@",@"http://www.nba.com",image];
        NSArray *teamsElements = [gameStatus.firstChild.children[2] children];
        NSMutableArray *teams = [[NSMutableArray alloc] init];
        for (int e = 0; e < teamsElements.count; e++) {
            TFHppleElement *t = teamsElements[e];
            NSString *abbrev = t.firstChild.content;
            NSString *teamImage = [(TFHppleElement *)t.children[1] attributes][@"src"];
            NSString *name = [(TFHppleElement *)t.children[1] attributes][@"title"];
            TFHppleElement *scoreRow = [gameStatus.children[1] firstChild].children[e+1];
            [teams addObject:[[NSDictionary alloc] initWithObjects:@[abbrev, teamImage, name, scoreRow] forKeys:@[@"abbreviation",@"image",@"name",@"score"]]];
        }
        TFHppleElement *actionRow = [nodes[i].children[1] firstChild];
        [self.NBAScoreboard addObject:[[NSDictionary alloc] initWithObjects:@[teams, image, liveStatus] forKeys:@[@"teams", @"tv", @"status"]]];
    }
    completed();
}
 */

- (void)loadNBAScoreboardWithCompletionBlock:(void (^)(void)) completed {
    self.NBAScoreboard = [[NSMutableArray alloc] init];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyymmdd"];
    NSDate *date = [NSDate date];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.nba.com/gameline/%@/",@"20151125"]];
    NSError *error;
    NSData *html = [NSData dataWithContentsOfURL:url options:NSDataReadingMapped error:&error];
    if (error) NSLog(@"Scoreboard error: %@",error);
    TFHpple *parser = [TFHpple hppleWithHTMLData:html];
    NSArray <TFHppleElement *> *nodes = [parser searchWithXPathQuery:@"//div[@id='nbaSSOuter']/div/div"];
    for (int i = 0; i < nodes.count; i++) {
        TFHppleElement *gameInfo = nodes[i].firstChild.firstChild.firstChild;
        TFHppleElement *gameStatus = [nodes[i].firstChild.firstChild children][3];
        NSString *liveStatus = [gameStatus.firstChild.firstChild.children[1] content];
        NSString *image = [gameStatus.firstChild.children[1] firstChild].firstChild.attributes[@"src"];
        image = [NSString stringWithFormat:@"%@%@",@"http://www.nba.com",image];
        NSArray *teamsElements = [gameStatus.firstChild.children[2] children];
        NSMutableArray *teams = [[NSMutableArray alloc] init];
        for (int e = 0; e < teamsElements.count; e++) {
            TFHppleElement *t = teamsElements[e];
            NSString *abbrev = t.firstChild.content;
            NSString *teamImage = [(TFHppleElement *)t.children[1] attributes][@"src"];
            NSString *name = [(TFHppleElement *)t.children[1] attributes][@"title"];
            TFHppleElement *scoreRow = [gameStatus.children[1] firstChild].children[e+1];
            [teams addObject:[[NSDictionary alloc] initWithObjects:@[abbrev, teamImage, name, scoreRow] forKeys:@[@"abbreviation",@"image",@"name",@"score"]]];
        }
        TFHppleElement *actionRow = [nodes[i].children[1] firstChild];
        [self.NBAScoreboard addObject:[[NSDictionary alloc] initWithObjects:@[teams, image, liveStatus] forKeys:@[@"teams", @"tv", @"status"]]];
    }
    completed();
}


#pragma mark - UI

- (void)setupTableHeaderView {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 414, 40)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, 125, 30)];
    label.text = @"AUTO-REFRESH:";
    label.textColor = [UIColor lightGrayColor];
    label.font = [UIFont boldSystemFontOfSize:14];
    label.textAlignment = NSTextAlignmentRight;
    self.autorefreshSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(130, 4.5, 51, 31)];
    self.autorefreshSwitch.onTintColor = [UIColor FBMediumOrangeColor];
    self.autorefreshSwitch.tintColor = [UIColor lightGrayColor];
    [self.autorefreshSwitch addTarget:self action:@selector(autorefreshStateChanged:) forControlEvents:UIControlEventValueChanged];
    updateTimer = [[NSTimer alloc] initWithFireDate:[NSDate date] interval:2 target:self selector:@selector(timerFired:) userInfo:nil repeats:YES];
    [headerView addSubview:label];
    [headerView addSubview:self.autorefreshSwitch];
    self.tableView.tableHeaderView = headerView;
    [self.tableView setContentOffset:CGPointMake(0,40)];
}

- (void)autorefreshStateChanged:(UISwitch *)sender{
    if (sender.isOn) {
        updateTimer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(timerFired:) userInfo:nil repeats:YES];
        [self timerFired:nil];
    }
    else {
        [updateTimer invalidate];
        updateTimer = nil;
    }
}

NSTimer *updateTimer;

- (void)timerFired:(NSTimer *)timer {
    [self refreshButtonPressed:nil];
}

- (IBAction)refreshButtonPressed:(UIButton *)sender {
    [self refreshNonAsync];
    [self.tableView reloadData];
}

#pragma mark - table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.isInLeagueMode) {
        [self linkWithMatchupLink:self.leagueScoreboard[indexPath.row][@"link"]];
    }
}

#pragma mark - Table View

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.isInLeagueMode) return self.leagueScoreboard.count;
    return self.NBAScoreboard.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.isInLeagueMode) return 120;
    return 120;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ScoreboardCell *cell = self.cells[indexPath.row];
    if (!cell) {
        cell = [[ScoreboardCell alloc] initWithMatchup:self.leagueScoreboard[indexPath.row] view:self size:CGSizeMake(self.tableView.frame.size.width, 120)];
        cell.delegate = self;
        [self.cells addObject:cell];
    }
    else [cell updateWithMatchup:self.leagueScoreboard[indexPath.row]];
    return cell;
}

#pragma mark - scoreboard cell delegate

- (void)linkWithMatchupLink: (NSString *)link {
    MatchupViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"mu"];
    [vc initWithMatchupLink:link];
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

#pragma mark - segmented control actions

- (IBAction)scoreboardModeChanged:(UISegmentedControl *)sender {
    if (sender.selectedSegmentIndex == 0) self.isInLeagueMode = YES;
    else self.isInLeagueMode = NO;
    [self.tableView reloadData];
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
