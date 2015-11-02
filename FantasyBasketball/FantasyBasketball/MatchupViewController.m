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
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 40)];
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
    [self.tableView setContentOffset:CGPointMake(0,40)];
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
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://games.espn.go.com/fba/boxscorefull?leagueId=%@&teamId=%@&scoringPeriodId=%@&seasonId=%@&view=scoringperiod&version=full",self.session.leagueID,self.session.teamID,self.session.scoringPeriodID,self.session.seasonID]];
    NSError *error;
    NSData *html = [NSData dataWithContentsOfURL:url options:NSDataReadingMapped error:&error];
    if (error) NSLog(@"Matchup error: %@",error);
    parserMU = [TFHpple hppleWithHTMLData:html];
    //table[@class='playerTableTable tableBody']/tr
    NSArray *nodes = [parserMU searchWithXPathQuery:@"//table[@class='playerTableTable tableBody']/tr"];
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
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            NSArray <TFHppleElement *> *children = element.children;
            [dict setObject:children[0].content forKey:@"isStarting"];
            [dict setObject:[children[1].children[0] content] forKey:@"firstName+lastName"];
            [dict setObject:[children[1].children[1] content] forKey:@"team+position"];
            if (children[1].children.count == 4) [dict setObject:[children[1].children[2] content] forKey:@"injury"];
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
            if (i < 13) [playersMU1 addObject:[[FBPlayer alloc] initWithDictionary:dict]];
            else [playersMU2 addObject:[[FBPlayer alloc] initWithDictionary:dict]];
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
