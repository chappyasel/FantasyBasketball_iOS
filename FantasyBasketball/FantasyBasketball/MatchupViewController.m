//
//  MatchupViewController.m
//  FantasyBasketball
//
//  Created by Chappy Asel on 1/17/15.
//  Copyright (c) 2015 CD. All rights reserved.
//

#import "MatchupViewController.h"
#import "Session.h"
#import "Player.h"
#import "TFHpple.h"

@interface MatchupViewController ()

@end

@implementation MatchupViewController

Session *session;
UINavigationBar *barMU;
NSMutableArray *playersMU1;
NSMutableArray *playersMU2;
NSMutableArray *scoresMU1;
NSMutableArray *scoresMU2;
NSMutableArray *cells;
TFHpple *parserMU;
int numStartersMU1 = 0;
int numStartersMU2 = 0;
bool expanded = NO;

- (void)viewDidLoad {
    [super viewDidLoad];
    cells = [[NSMutableArray alloc] init];
    [self loadplayersMU];
    [self loadTableView];
    [self loadNavBar];
    [self refreshScores];
}

- (void)viewWillAppear:(BOOL)animated{
    //[[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(orientationChanged:)    name:UIDeviceOrientationDidChangeNotification  object:nil];
}

- (void)loadNavBar {
    //NAV
    barMU = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, 414, 120)];
    [barMU addSubview:_scoreView];
    UINavigationItem *navItem = [[UINavigationItem alloc] init];
    UIBarButtonItem *bi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshButtonPressed:)];
    navItem.rightBarButtonItem = bi;
    //UIBarButtonItem *bi2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(refreshButtonPressed:)];
    //navItem.leftBarButtonItem = bi2;
    barMU.items = [NSArray arrayWithObject:navItem];
    [self.view addSubview:barMU];
}

- (void)refreshScores {
    NSString *XpathQueryString = @"//tr[@style='text-align:right; background:#f2f2e8']/td/span";
    NSArray *nodes = [parserMU searchWithXPathQuery:XpathQueryString];
    _team1Display1.text = [nodes[0] content];
    _team2Display1.text = [nodes[1] content];
    NSString *XpathQueryString2 = @"//div[@style='font-size:18px; margin-bottom:14px; font-family:Helvetica,sans-serif;']/b";
    NSArray *nodes2 = [parserMU searchWithXPathQuery:XpathQueryString2];
    _team1Display2.text = [nodes2[0] content];
    _team2Display2.text = [nodes2[1] content];
}

- (void)loadTableView {
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorInset = UIEdgeInsetsMake(15, 0, 0, 15);
    _tableView.contentInset = UIEdgeInsetsMake(120, 0, 47, 0);
    _tableView.contentOffset = CGPointMake(0, 0); //CORECTLY DISPLAYS HEADER
    _tableView.showsHorizontalScrollIndicator = NO;
    _tableView.showsVerticalScrollIndicator = NO;
    [self loadTableHeaderView];
    [self.view addSubview:_tableView];
    [_tableView reloadData];
}

- (void)loadTableHeaderView {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 414, 40)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 100, 30)];
    label.text = @"Auto-refresh:";
    label.textAlignment = NSTextAlignmentRight;
    label.textColor = [UIColor lightGrayColor];
    self.autorefreshSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(120, 4.5, 51, 31)];
    self.autorefreshSwitch.onTintColor = [UIColor lightGrayColor];
    [self.autorefreshSwitch addTarget:self action:@selector(autorefreshStateChanged:) forControlEvents:UIControlEventValueChanged];
    updateTimer = [[NSTimer alloc] initWithFireDate:[NSDate date] interval:2 target:self selector:@selector(timerFired:) userInfo:nil repeats:YES];
    [headerView addSubview:label];
    [headerView addSubview:self.autorefreshSwitch];
    _tableView.tableHeaderView = headerView;
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

/*
- (void)orientationChanged:(NSNotification *)notification{
    [self adjustViewsForOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
}

- (void) adjustViewsForOrientation:(UIInterfaceOrientation) orientation {
    switch (orientation) {
        case UIInterfaceOrientationPortrait: case UIInterfaceOrientationPortraitUpsideDown: {
            [barMU setFrame:CGRectMake(0, 0, 414, 120)];
            _scoreView.frame = barMU.frame;
            _tableView.contentInset = UIEdgeInsetsMake(120, 0, 0, 0);
            _tableView.frame = CGRectMake(0, 0, 414, 687);
            _team1Display1.frame = CGRectMake(23, 18, 180, 50);
            _team1Display2.frame = CGRectMake(38, 64, 150, 50);
            _team2Display1.frame = CGRectMake(211, 18, 180, 50);
            _team2Display2.frame = CGRectMake(226, 64, 150, 50);
            _team1Display1.font = [UIFont boldSystemFontOfSize:45];
            _team1Display2.font = [UIFont boldSystemFontOfSize:19];
            _team2Display1.font = [UIFont boldSystemFontOfSize:45];
            _team2Display2.font = [UIFont boldSystemFontOfSize:19];
        } break;
        case UIInterfaceOrientationLandscapeLeft: case UIInterfaceOrientationLandscapeRight: {
            [barMU setFrame:CGRectMake(0, 0, 736-414, 414-47)];
            _scoreView.frame = barMU.frame;
            _tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
            _tableView.frame = CGRectMake(736-414, 0, 414, 414-(736-687));
            _team1Display1.frame = CGRectMake(16, 115, 140, 65);
            _team1Display2.frame = CGRectMake(16, 188, 140, 65);
            _team2Display1.frame = CGRectMake(167, 115, 140, 65);
            _team2Display2.frame = CGRectMake(167, 188, 140, 65);
            _team1Display1.font = [UIFont boldSystemFontOfSize:60];
            _team1Display2.font = [UIFont boldSystemFontOfSize:22];
            _team2Display1.font = [UIFont boldSystemFontOfSize:60];
            _team2Display2.font = [UIFont boldSystemFontOfSize:22];
        } break;
        case UIInterfaceOrientationUnknown: break;
    }
}
*/

- (IBAction)refreshButtonPressed:(UIButton *)sender {
    [self loadplayersMU];
    [_tableView reloadData];
    [self refreshScores];
}

- (void)loadplayersMU {
    numStartersMU1 = 0, numStartersMU2 = 0;
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://games.espn.go.com/fba/boxscorefull?leagueId=%d&teamId=%d&scoringPeriodId=%d&seasonId=%d&view=scoringperiod&version=full",session.leagueID,session.teamID,session.scoringPeriodID,session.seasonID]];
    NSData *html = [NSData dataWithContentsOfURL:url];
    parserMU = [TFHpple hppleWithHTMLData:html];
    NSString *XpathQueryString = @"//table[@class='playerTableTable tableBody']/tr";
    NSArray *nodes = [parserMU searchWithXPathQuery:XpathQueryString];
    playersMU1 = [[NSMutableArray alloc] initWithCapacity:13];
    playersMU2 = [[NSMutableArray alloc] initWithCapacity:13];
    for (int i = 0; i < nodes.count; i++) {
        TFHppleElement *element = nodes[i];
        if ([element objectForKey:@"id"]) {
            NSMutableArray *data = [[NSMutableArray alloc] initWithCapacity:22];
            for (TFHppleElement *stat in element.children) {
                if (![stat.content isEqualToString:@""]) {
                    if ([[stat objectForKey:@"class"] isEqualToString:@"playertablePlayerName"]) {
                        [data addObject: [stat.children[0] content]];
                        [data addObject: [stat.children[1] content]];
                        if (stat.children.count == 4) [data addObject: [stat.children[2] content]];
                        else [data addObject: @""];
                    }
                    else if ([[stat objectForKey:@"class"] isEqualToString:@"gameStatusDiv"]) {
                        [data addObject: stat.content];
                        [data addObject: [[[stat childrenWithTagName:@"a"] firstObject] objectForKey:@"href"]];
                    }
                    else [data addObject: stat.content];
                }
            }
            if (data.count == 17) { //not playing
                [data insertObject:@"--" atIndex:5];
                [data insertObject:@"--" atIndex:6];
                [data insertObject:@"--" atIndex:7];
            }
            [data insertObject:@"--" atIndex:4]; //type
            [data insertObject:@"--" atIndex:9]; //gs
            [data insertObject:@"--" atIndex:21]; //tot
            [data insertObject:@"--" atIndex:23]; //pct
            [data insertObject:@"--" atIndex:24]; //+/-
            [data addObject:[[element objectForKey:@"id"] substringFromIndex:4]];
            if (i < 13)[playersMU1 addObject:[[Player alloc] initWithData:data]];
            else [playersMU2 addObject:[[Player alloc] initWithData:data]];
        }
    }
    for (Player *player in playersMU1) if(player.isStarting) numStartersMU1 ++;
    for (Player *player in playersMU2) if(player.isStarting) numStartersMU2 ++;
}

#pragma mark - Table View

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 40;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!expanded) return 52.7;
    else return 569;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *cell = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 414, 40)];
    cell.backgroundColor = [UIColor lightGrayColor];
    //Divider
    UILabel *div = [[UILabel alloc] initWithFrame:CGRectMake(129, 0, 1, 40)];
    div.backgroundColor = [UIColor lightGrayColor];
    [cell addSubview:div];
    //STATS LABELS
    float tot1 = 0;
    float tot2 = 0;
    if (section == 0) {
        for (int i = 0; i < numStartersMU1; i++) {
            Player *player = playersMU1[i];
            if (player.isPlaying) tot1 += player.fantasyPoints;
        }
        for (int i = 0; i < numStartersMU2; i++) {
            Player *player = playersMU2[i];
            if (player.isPlaying) tot2 += player.fantasyPoints;
        }
    }
    UILabel *stats = [[UILabel alloc] initWithFrame:CGRectMake(207-50, 0, 50, 40)];
    stats.text = [NSString stringWithFormat:@"%.0f",tot1];
    stats.textAlignment = NSTextAlignmentCenter;
    stats.font = [UIFont boldSystemFontOfSize:19];
    [cell addSubview:stats];
    UILabel *stats2 = [[UILabel alloc] initWithFrame:CGRectMake(207, 0, 50, 40)];
    stats2.text = [NSString stringWithFormat:@"%.0f",tot2];
    stats2.textAlignment = NSTextAlignmentCenter;
    stats2.font = [UIFont boldSystemFontOfSize:19];
    [cell addSubview:stats2];
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Player *rightPlayer;
    Player *leftPlayer;
    if (playersMU1.count-1 >= indexPath.row+indexPath.section*numStartersMU1)
        leftPlayer = playersMU1[indexPath.row+indexPath.section*numStartersMU1];
    if (playersMU2.count-1 >= indexPath.row+indexPath.section*numStartersMU2)
        rightPlayer = playersMU2[indexPath.row+indexPath.section*numStartersMU2];
    if (cells.count >= indexPath.row+indexPath.section*numStartersMU1+1) {
        MatchupPlayerCell *cell = cells[indexPath.row+indexPath.section*numStartersMU1];
        if (!cell) {
            cell = [[MatchupPlayerCell alloc] initWithRightPlayer:rightPlayer leftPlayer:leftPlayer view:self expanded:expanded];
            cell.delegate = self;
            cell.index = (int)indexPath.row;
            [cells addObject:cell];
        }
        else [cell updateWithRightPlayer:rightPlayer leftPlayer:leftPlayer];
        return cell;
    }
    MatchupPlayerCell *cell = [[MatchupPlayerCell alloc] initWithRightPlayer:rightPlayer leftPlayer:leftPlayer view:self expanded:expanded];
    cell.delegate = self;
    cell.index = (int)indexPath.row;
    [cells addObject:cell];
    return cell;
}

#pragma mark - MatchupPlayerCell delegate

- (void)linkWithPlayer:(Player *)player {
    session.player = player;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *viewController = (UIViewController *)[storyboard instantiateViewControllerWithIdentifier:@"p"];
    [self presentViewController:viewController animated:YES completion:nil];
}

- (void)linkWithGameLink:(Player *)player {
    session.link = [player gameLink];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *viewController = (UIViewController *)[storyboard instantiateViewControllerWithIdentifier:@"w"];
    [self presentViewController:viewController animated:YES completion:nil];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
// Get the new view controller using [segue destinationViewController].
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
}

@end
