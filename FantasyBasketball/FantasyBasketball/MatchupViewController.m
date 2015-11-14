//
//  MatchupViewController.m
//  FantasyBasketball
//
//  Created by Chappy Asel on 1/17/15.
//  Copyright (c) 2015 CD. All rights reserved.
//

#import "MatchupViewController.h"

@interface MatchupViewController ()

@property TFHpple *parser;

@property bool handleError;

@property NSMutableArray *playersTeam1;
@property int numStartersTeam1;
@property NSMutableArray *playersTeam2;
@property int numStartersTeam2;

@property NSArray *scoresTeam1;
@property JBBarChartView *barChartTeam1;
@property NSArray *scoresTeam2;
@property JBBarChartView *barChartTeam2;

@property NSMutableArray *cells;

@property NSMutableArray <NSString *> *pickerData;
@property NSString *selectedPickerData;
@property int scoringDay; //time of stats

@end

@implementation MatchupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Matchup";
    _handleError = NO;
    self.cells = [[NSMutableArray alloc] init];
    [self loadPickerViewData];
    [self loadplayersMU];
    if (_handleError) return;
    [self loadTableView];
    [self loadBarCharts];
}

- (void)refreshScoresWithFirstTeamName: (NSString *)firstName {
    if (_handleError) return;
    NSString *XpathQueryString = @"//tr[@class='tableBody']";
    NSArray <TFHppleElement *> *nodes = [self.parser searchWithXPathQuery:XpathQueryString];
    NSString *team1Name = nodes[0].firstChild.content;
    NSString *team2Name = nodes[1].firstChild.content;
    int t1;
    int t2;
    if ([team1Name containsString:firstName]) {
        self.team1Display2.text = team1Name;
        self.team2Display2.text = team2Name;
        t1 = 0;
        t2 = 1;
    }
    else {
        self.team1Display2.text = team2Name;
        self.team2Display2.text = team1Name;
        t1 = 1;
        t2 = 0;
    }
    self.team1Display1.text = ((TFHppleElement *)nodes[t1].children[10]).content;
    self.team2Display1.text = ((TFHppleElement *)nodes[t2].children[10]).content;
    self.scoresTeam1 = @[    @"200", //acts as setter for height
                             ((TFHppleElement *)nodes[t1].children[2]).content,
                             ((TFHppleElement *)nodes[t1].children[3]).content,
                             ((TFHppleElement *)nodes[t1].children[4]).content,
                             ((TFHppleElement *)nodes[t1].children[5]).content,
                             ((TFHppleElement *)nodes[t1].children[6]).content,
                             ((TFHppleElement *)nodes[t1].children[7]).content,
                             ((TFHppleElement *)nodes[t1].children[8]).content];
    
    self.scoresTeam2 = @[    ((TFHppleElement *)nodes[t2].children[8]).content,
                             ((TFHppleElement *)nodes[t2].children[7]).content,
                             ((TFHppleElement *)nodes[t2].children[6]).content,
                             ((TFHppleElement *)nodes[t2].children[5]).content,
                             ((TFHppleElement *)nodes[t2].children[4]).content,
                             ((TFHppleElement *)nodes[t2].children[3]).content,
                             ((TFHppleElement *)nodes[t2].children[2]).content,
                             @"200"];
    [self.barChartTeam1 reloadData];
    [self.barChartTeam2 reloadData];
}

- (void)loadBarCharts {
    float width = self.view.frame.size.width/2-15;
    self.barChartTeam1 = [[JBBarChartView alloc] init];
    self.barChartTeam1.frame = CGRectMake(-width/8, 0, width, 104);
    self.barChartTeam1.dataSource = self;
    self.barChartTeam1.delegate = self;
    self.barChartTeam1.inverted = YES;
    self.barChartTeam1.alpha = 0.5;
    self.barChartTeam1.userInteractionEnabled = NO;
    [self.scoreView addSubview:self.barChartTeam1];
    [self.scoreView sendSubviewToBack:self.barChartTeam1];
    [self.barChartTeam1 reloadData];
    
    self.barChartTeam2 = [[JBBarChartView alloc] init];
    self.barChartTeam2.frame = CGRectMake(width+2*15+width/8, 0, width, 104);
    self.barChartTeam2.dataSource = self;
    self.barChartTeam2.delegate = self;
    self.barChartTeam2.inverted = YES;
    self.barChartTeam2.alpha = 0.5;
    self.barChartTeam2.userInteractionEnabled = NO;
    [self.scoreView addSubview:self.barChartTeam2];
    [self.scoreView sendSubviewToBack:self.barChartTeam2];
    [self.barChartTeam2 reloadData];
}

- (void)loadTableView {
    self.tableView.separatorInset = UIEdgeInsetsMake(15, 0, 0, 15);
    self.tableView.contentOffset = CGPointMake(0, 0);
    [self loadTableHeaderView];
}

- (void)loadTableHeaderView {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 414, 40)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, 125, 30)];
    label.text = @"AUTO-REFRESH:";
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont boldSystemFontOfSize:14];
    label.textAlignment = NSTextAlignmentRight;
    self.autorefreshSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(130, 4.5, 51, 31)];
    self.autorefreshSwitch.onTintColor = [UIColor whiteColor];
    self.autorefreshSwitch.tintColor = [UIColor whiteColor];
    [self.autorefreshSwitch addTarget:self action:@selector(autorefreshStateChanged:) forControlEvents:UIControlEventValueChanged];
    updateTimer = [[NSTimer alloc] initWithFireDate:[NSDate date] interval:2 target:self selector:@selector(timerFired:) userInfo:nil repeats:YES];
    [headerView addSubview:label];
    [headerView addSubview:self.autorefreshSwitch];
    self.tableView.tableHeaderView = headerView;
    [self.tableView setContentOffset:CGPointMake(0,40)];
}

- (void)autorefreshStateChanged:(UISwitch *)sender{
    if (_handleError) return;
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
    [self loadplayersMU];
    [self.tableView reloadData];
}

- (void)loadplayersMU {
    _numStartersTeam1 = 0, _numStartersTeam2 = 0;
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://games.espn.go.com/fba/boxscorefull?leagueId=%@&teamId=%@&scoringPeriodId=%d&seasonId=%@&view=scoringperiod&version=full",self.session.leagueID,self.session.teamID,_scoringDay,self.session.seasonID]];
    NSError *error;
    NSData *html = [NSData dataWithContentsOfURL:url options:NSDataReadingMapped error:&error];
    if (error) NSLog(@"Matchup error: %@",error);
    self.parser = [TFHpple hppleWithHTMLData:html];
    //table[@class='playerTableTable tableBody']/tr
    NSArray *nodes = [self.parser searchWithXPathQuery:@"//table[@class='playerTableTable tableBody']/tr"];
    self.playersTeam1 = [[NSMutableArray alloc] initWithCapacity:13];
    self.playersTeam2 = [[NSMutableArray alloc] initWithCapacity:13];
    if (nodes.count == 0) {
        NSLog(@"Error");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Matchup Found"
                                                        message:@"No matchup was found for this week. \n\nThis message is to be expected in the offseason. \n\nIf you should have a game this week, check your league, team, seaason, and scoringID in the \"more\" tab."
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        _handleError = YES;
        return;
    }
    //team search
    TFHppleElement *name = [self.parser searchWithXPathQuery:@"//table[@id='playertable_0']/tr[@class='playerTableBgRowHead tableHead playertableTableHeader']/td"].firstObject;
    NSString *firstTeamName = [name.content stringByReplacingOccurrencesOfString:@" Box Score" withString:@""];
    _handleError = NO;
    for (int i = 0; i < nodes.count; i++) {
        TFHppleElement *element = nodes[i];
        if ([element objectForKey:@"id"]) {
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            NSArray <TFHppleElement *> *children = element.children;
            [dict setObject:children[0].content forKey:@"isStarting"];
            [dict setObject:[children[1].children[0] content] forKey:@"firstName+lastName"];
            [dict setObject:[children[1].children[1] content] forKey:@"team+position"];
            if (children[1].children.count > 2 && ![((TFHppleElement *)children[1].children[2]).tagName isEqualToString:@"a"])
                [dict setObject:[children[1].children[2] content] forKey:@"injury"];
            [dict setObject:children[2].content forKey:@"isHome+opponent"];
            [dict setObject:children[3].content forKey:@"isPlaying+gameState+score+status"];
            if (![dict[@"isPlaying+gameState+score+status"] isEqualToString:@""]) [dict setObject: [[[children[3] childrenWithTagName:@"a"] firstObject] objectForKey:@"href"] forKey:@"gameLink"];
            [dict setObject:children[5].content forKey:@"gp"];
            [dict setObject:children[6].content forKey:@"min"];
            [dict setObject:children[7].content forKey:@"fgm"];
            [dict setObject:children[8].content forKey:@"fga"];
            [dict setObject:children[9].content forKey:@"ftm"];
            [dict setObject:children[10].content forKey:@"fta"];
            [dict setObject:children[11].content forKey:@"rebounds"];
            [dict setObject:children[12].content forKey:@"assists"];
            [dict setObject:children[13].content forKey:@"steals"];
            [dict setObject:children[14].content forKey:@"blocks"];
            [dict setObject:children[15].content forKey:@"turnovers"];
            [dict setObject:children[16].content forKey:@"points"];
            [dict setObject:children[18].content forKey:@"fantasyPoints"];
            //[dict setObject:[[element objectForKey:@"id"] substringFromIndex:4] forKey:@"playerID"];
            if (i < 13) [self.playersTeam1 addObject:[[FBPlayer alloc] initWithDictionary:dict]];
            else [self.playersTeam2 addObject:[[FBPlayer alloc] initWithDictionary:dict]];
        }
    }
    for (FBPlayer *player in self.playersTeam1) if(player.isStarting) _numStartersTeam1 ++;
    for (FBPlayer *player in self.playersTeam2) if(player.isStarting) _numStartersTeam2 ++;
    [self refreshScoresWithFirstTeamName: firstTeamName];
}

#pragma mark - bar charts delegate

- (NSUInteger)numberOfBarsInBarChartView:(JBBarChartView *)barChartView {
    return 8;
}

- (CGFloat)barChartView:(JBBarChartView *)barChartView heightForBarViewAtIndex:(NSUInteger)index {
    if (barChartView == self.barChartTeam1) return MAX(0, [self.scoresTeam1[index] floatValue]);
    return MAX(0, [self.scoresTeam2[index] floatValue]);
}

- (UIColor *)barChartView:(JBBarChartView *)barChartView colorForBarViewAtIndex:(NSUInteger)index {
    return [UIColor FBMediumOrangeColor];
}

#pragma mark - Table View

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_handleError) return 0;
    return 10;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 40;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 52.7;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    float width = self.tableView.frame.size.width;
    UIView *cell = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 40)];
    cell.backgroundColor = [UIColor colorWithRed:228/255.0 green:141/255.0 blue:78/255.0 alpha:1.0];
    //STATS LABELS
    float tot1 = 0;
    float tot2 = 0;
    if (section == 0) {
        for (int i = 0; i < self.numStartersTeam1; i++) {
            FBPlayer *player = self.playersTeam1[i];
            if (player.isPlaying) tot1 += player.fantasyPoints;
        }
        for (int i = 0; i < self.numStartersTeam2; i++) {
            FBPlayer *player = self.playersTeam2[i];
            if (player.isPlaying) tot2 += player.fantasyPoints;
        }
    }
    UILabel *stats = [[UILabel alloc] initWithFrame:CGRectMake(width/2-50, 0, 50, 40)];
    stats.text = [NSString stringWithFormat:@"%.0f",tot1];
    stats.textAlignment = NSTextAlignmentCenter;
    stats.font = [UIFont boldSystemFontOfSize:19];
    stats.textColor = [UIColor whiteColor];
    [cell addSubview:stats];
    UILabel *stats2 = [[UILabel alloc] initWithFrame:CGRectMake(width/2, 0, 50, 40)];
    stats2.text = [NSString stringWithFormat:@"%.0f",tot2];
    stats2.textAlignment = NSTextAlignmentCenter;
    stats2.font = [UIFont boldSystemFontOfSize:19];
    stats2.textColor = [UIColor whiteColor];
    [cell addSubview:stats2];
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FBPlayer *rightPlayer;
    FBPlayer *leftPlayer;
    if (self.playersTeam1.count-1 >= indexPath.row+indexPath.section*_numStartersTeam1)
        leftPlayer = self.playersTeam1[indexPath.row+indexPath.section*_numStartersTeam1];
    if (self.playersTeam2.count-1 >= indexPath.row+indexPath.section*_numStartersTeam2)
        rightPlayer = self.playersTeam2[indexPath.row+indexPath.section*_numStartersTeam2];
    if (self.cells.count >= indexPath.row+indexPath.section*_numStartersTeam1+1) {
        MatchupPlayerCell *cell = self.cells[indexPath.row+indexPath.section*_numStartersTeam1];
        if (!cell) {
            cell = [[MatchupPlayerCell alloc] initWithRightPlayer:rightPlayer leftPlayer:leftPlayer view:self expanded:NO];
            cell.delegate = self;
            cell.index = (int)indexPath.row;
            [self.cells addObject:cell];
        }
        else [cell updateWithRightPlayer:rightPlayer leftPlayer:leftPlayer];
        return cell;
    }
    MatchupPlayerCell *cell = [[MatchupPlayerCell alloc] initWithRightPlayer:rightPlayer leftPlayer:leftPlayer view:self expanded:NO];
    cell.delegate = self;
    cell.index = (int)indexPath.row;
    [self.cells addObject:cell];
    return cell;
}

#pragma mark - FBPickerView

-(void)loadPickerViewData {
    _scoringDay = self.session.scoringPeriodID.intValue;
    self.selectedPickerData = @"Today";
    self.pickerData = [[NSMutableArray alloc] initWithArray: @[@"-", @"-", @"-", @"-", @"-", @"Yesterday", @"Today", @"Tomorrow", @"-", @"-", @"-", @"-", @"-"]];
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"E, MMM d"];
    for (int i = 1; i < 6; i++) { //days before
        date = [NSDate dateWithTimeIntervalSinceNow:-86400*i];
        self.pickerData[5-i] = [formatter stringFromDate:date];
    }
    for (int i = 2; i < 7; i++) { //days after
        date = [NSDate dateWithTimeIntervalSinceNow:86400*i];
        self.pickerData[6+i] = [formatter stringFromDate:date];
    }
}

-(void) fadeIn:(UIButton *)sender {
    self.navigationItem.rightBarButtonItem.enabled = NO;
    FBPickerView *picker = [FBPickerView loadViewFromNib];
    picker.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    picker.delegate = self;
    [picker resetData];
    [picker setData:self.pickerData ForColumn:0];
    [picker selectString:self.selectedPickerData inColumn:0];
    [picker setAlpha:0.0];
    [self.view addSubview:picker];
    [UIView animateWithDuration:0.25 animations:^{
        [picker setAlpha:1.0];
    } completion: nil];
}

#pragma mark - FBPickerView delegate methods

- (void)doneButtonPressedInPickerView:(FBPickerView *)pickerView {
    int data1 = [pickerView selectedIndexForColumn:0];
    self.selectedPickerData = [pickerView selectedStringForColumn:0];
    _scoringDay = self.session.scoringPeriodID.intValue-6+data1;
    if (_scoringDay != self.session.scoringPeriodID.intValue) {
        [self.autorefreshSwitch setOn:NO];
        [self autorefreshStateChanged:self.autorefreshSwitch];
    }
    [self loadplayersMU];
    [self.tableView reloadData];
    [self fadeOutWithPickerView:pickerView];
}

- (void)cancelButtonPressedInPickerView:(FBPickerView *)pickerView {
    [self fadeOutWithPickerView:pickerView];
}

@end
