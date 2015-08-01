//
//  MatchupViewController.m
//  FantasyBasketball
//
//  Created by Chappy Asel on 1/17/15.
//  Copyright (c) 2015 CD. All rights reserved.
//

#import "MatchupViewController.h"

@interface MatchupViewController ()

@end

@implementation MatchupViewController

TFHpple *parserMU;

bool handleError;

NSMutableArray *playersMU1;
int numStartersMU1 = 0;
NSMutableArray *playersMU2;
int numStartersMU2 = 0;
NSMutableArray *scoresMU1;
NSMutableArray *scoresMU2;
NSMutableArray *cells;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Matchup";
    handleError = NO;
    cells = [[NSMutableArray alloc] init];
    [self loadplayersMU];
    if (handleError) return;
    [self loadTableView];
    [self refreshScores];
}

- (void)refreshScores {
    if (handleError) return;
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
    self.tableView.separatorInset = UIEdgeInsetsMake(15, 0, 0, 15);
    self.tableView.contentOffset = CGPointMake(0, 0);
    [self loadTableHeaderView];
}

- (void)loadTableHeaderView {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 414, 40)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 110, 30)];
    label.text = @"Auto-refresh:";
    label.textAlignment = NSTextAlignmentRight;
    label.textColor = [UIColor lightGrayColor];
    self.autorefreshSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(130, 4.5, 51, 31)];
    self.autorefreshSwitch.onTintColor = [UIColor lightGrayColor];
    [self.autorefreshSwitch addTarget:self action:@selector(autorefreshStateChanged:) forControlEvents:UIControlEventValueChanged];
    updateTimer = [[NSTimer alloc] initWithFireDate:[NSDate date] interval:2 target:self selector:@selector(timerFired:) userInfo:nil repeats:YES];
    [headerView addSubview:label];
    [headerView addSubview:self.autorefreshSwitch];
    self.tableView.tableHeaderView = headerView;
}

- (void)autorefreshStateChanged:(UISwitch *)sender{
    if (handleError) return;
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
    [self refreshScores];
}

- (void)loadplayersMU {
    numStartersMU1 = 0, numStartersMU2 = 0;
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://games.espn.go.com/fba/boxscorefull?leagueId=%d&teamId=%d&scoringPeriodId=%d&seasonId=%d&view=scoringperiod&version=full",self.session.leagueID,self.session.teamID,self.session.scoringPeriodID,self.session.seasonID]];
    NSError *error;
    NSData *html = [NSData dataWithContentsOfURL:url options:NSDataReadingMapped error:&error];
    if (error) NSLog(@"Matchup error: %@",error);
    parserMU = [TFHpple hppleWithHTMLData:html];
    NSString *XpathQueryString = @"//table[@class='playerTableTable tableBody']/tr";
    NSArray *nodes = [parserMU searchWithXPathQuery:XpathQueryString];
    playersMU1 = [[NSMutableArray alloc] initWithCapacity:13];
    playersMU2 = [[NSMutableArray alloc] initWithCapacity:13];
    if (nodes.count == 0) {
        NSLog(@"Error");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Matchup Found"
                                                        message:@"No matchup was found for this week. \n\nThis message is to be expected in the offseason. \n\nIf you should have a game this week, check your league, team, seaason, and scoringID in the \"more\" tab."
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        handleError = YES;
        return;
    }
    handleError = NO;
    for (int i = 0; i < nodes.count; i++) {
        TFHppleElement *element = nodes[i];
        if ([element objectForKey:@"id"]) {
            NSMutableArray *dict = [[NSMutableArray alloc] initWithCapacity:22];
            for (TFHppleElement *stat in element.children) {
                if (![stat.content isEqualToString:@""]) {
                    if ([[stat objectForKey:@"class"] isEqualToString:@"playertablePlayerName"]) {
                        [dict addObject: [stat.children[0] content]];
                        [dict addObject: [stat.children[1] content]];
                        if (stat.children.count == 4) [dict addObject: [stat.children[2] content]];
                        else [dict addObject: @""];
                    }
                    else if ([[stat objectForKey:@"class"] isEqualToString:@"gameStatusDiv"]) {
                        [dict addObject: stat.content];
                        [dict addObject: [[[stat childrenWithTagName:@"a"] firstObject] objectForKey:@"href"]];
                    }
                    else [dict addObject: stat.content];
                }
            }
            if (dict.count == 17) { //not playing
                [dict insertObject:@"--" atIndex:5];
                [dict insertObject:@"--" atIndex:6];
                [dict insertObject:@"--" atIndex:7];
            }
            [dict insertObject:@"--" atIndex:4]; //type
            [dict insertObject:@"--" atIndex:9]; //gs
            [dict insertObject:@"--" atIndex:21]; //tot
            [dict insertObject:@"--" atIndex:23]; //pct
            [dict insertObject:@"--" atIndex:24]; //+/-
            //[dict setObject:[[element objectForKey:@"id"] substringFromIndex:4] forKey:@"playerID"];
            if (i < 13)[playersMU1 addObject:[[FBPlayer alloc] initWithData:dict]];
            else [playersMU2 addObject:[[FBPlayer alloc] initWithData:dict]];
        }
    }
    for (FBPlayer *player in playersMU1) if(player.isStarting) numStartersMU1 ++;
    for (FBPlayer *player in playersMU2) if(player.isStarting) numStartersMU2 ++;
}

#pragma mark - Table View

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (handleError) return 0;
    return 10;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 40;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 52.7;
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
            FBPlayer *player = playersMU1[i];
            if (player.isPlaying) tot1 += player.fantasyPoints;
        }
        for (int i = 0; i < numStartersMU2; i++) {
            FBPlayer *player = playersMU2[i];
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
    FBPlayer *rightPlayer;
    FBPlayer *leftPlayer;
    if (playersMU1.count-1 >= indexPath.row+indexPath.section*numStartersMU1)
        leftPlayer = playersMU1[indexPath.row+indexPath.section*numStartersMU1];
    if (playersMU2.count-1 >= indexPath.row+indexPath.section*numStartersMU2)
        rightPlayer = playersMU2[indexPath.row+indexPath.section*numStartersMU2];
    if (cells.count >= indexPath.row+indexPath.section*numStartersMU1+1) {
        MatchupPlayerCell *cell = cells[indexPath.row+indexPath.section*numStartersMU1];
        if (!cell) {
            cell = [[MatchupPlayerCell alloc] initWithRightPlayer:rightPlayer leftPlayer:leftPlayer view:self expanded:NO];
            cell.delegate = self;
            cell.index = (int)indexPath.row;
            [cells addObject:cell];
        }
        else [cell updateWithRightPlayer:rightPlayer leftPlayer:leftPlayer];
        return cell;
    }
    MatchupPlayerCell *cell = [[MatchupPlayerCell alloc] initWithRightPlayer:rightPlayer leftPlayer:leftPlayer view:self expanded:NO];
    cell.delegate = self;
    cell.index = (int)indexPath.row;
    [cells addObject:cell];
    return cell;
}

#pragma mark - FBPickerView

NSArray *pickerData;

-(void)loadDatePickerData {
    pickerData = [[NSArray alloc] initWithObjects: [[NSArray alloc] initWithObjects: @"No PickerView Data", nil], nil];
}

-(void) fadeIn:(UIButton *)sender {
    [self loadDatePickerData];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    FBPickerView *picker = [FBPickerView loadViewFromNib];
    picker.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    picker.delegate = self;
    [picker resetData];
    [picker setData:pickerData[0] ForColumn:0];
    [picker selectIndex:0 inColumn:0];
    [picker setAlpha:0.0];
    [self.view addSubview:picker];
    [UIView animateWithDuration:0.1 animations:^{
        [picker setAlpha:1.0];
    } completion: nil];
}

#pragma mark - FBPickerView delegate methods

- (void)doneButtonPressedInPickerView:(FBPickerView *)pickerView {
    [self fadeOutWithPickerView:pickerView];
}

- (void)cancelButtonPressedInPickerView:(FBPickerView *)pickerView {
    [self fadeOutWithPickerView:pickerView];
}

@end
