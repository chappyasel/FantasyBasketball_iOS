//
//  DailyLeadersViewController.m
//  FantasyBasketball
//
//  Created by Chappy Asel on 1/17/15.
//  Copyright (c) 2015 CD. All rights reserved.
//

#import "DailyLeadersViewController.h"

@interface DailyLeadersViewController ()

@end

@implementation DailyLeadersViewController

NSMutableArray *playersDL;
NSMutableArray *scrollViewsDL;
TFHpple *parser;
float scrollDistanceDL;
int scoringDay;
int team;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Daily Leaders";
    scoringDay = self.session.scoringPeriodID;
    team = -1; //All defualt
    [self loadplayersDL];
}

- (void)loadTableView {
    [self loadTableHeaderView];
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
    self.tableView.tableHeaderView = headerView;
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

-(void)viewWillAppear:(BOOL)animated{
    [self loadTableView];
    [self loadDatePickerData];
}

- (IBAction)refreshButtonPressed:(UIButton *)sender {
    [self loadplayersDL];
    scrollViewsDL = [[NSMutableArray alloc] init];
    [self.tableView reloadData];
}

- (void)loadplayersDL {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://games.espn.go.com/fba/leaders?leagueId=%d&teamId=%d&scoringPeriodId=%d&startIndex=0&proTeamId=%d",self.session.leagueID,self.session.teamID,scoringDay,team]];
    NSData *html = [NSData dataWithContentsOfURL:url];
    parser = [TFHpple hppleWithHTMLData:html];
    NSString *XpathQueryString = @"//table[@class='playerTableTable tableBody']/tr";
    NSArray *nodes = [parser searchWithXPathQuery:XpathQueryString];
    playersDL = [[NSMutableArray alloc] init];
    for (int i = 0; i < nodes.count; i++) {
        TFHppleElement *element = nodes[i];
        if ([element objectForKey:@"id"]) {
            NSMutableArray *data = [[NSMutableArray alloc] initWithCapacity:15];
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
            if (data.count == 16) { //not playing
                [data insertObject:@"--" atIndex:5];
                [data insertObject:@"--" atIndex:6];
                [data insertObject:@"--" atIndex:7];
            }
            [data insertObject:@"--" atIndex:0]; //pos
            [data insertObject:@"--" atIndex:8]; //gp
            [data insertObject:@"--" atIndex:9]; //gs
            [data insertObject:@"--" atIndex:21]; //tot
            [data insertObject:@"--" atIndex:23]; //pct
            [data insertObject:@"--" atIndex:24]; //+/-
            [data addObject:[[element objectForKey:@"id"] substringFromIndex:4]];
            [playersDL addObject:[[FBPlayer alloc] initWithData:data]];
        }
    }
}

#pragma mark - Table View

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return playersDL.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *cell = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 40)];
    cell.backgroundColor = [UIColor lightGrayColor];
    //NAME
    UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 180, 40)];
    name.text = @"  NAME               TYPE";
    name.font = [UIFont boldSystemFontOfSize:17];
    [cell addSubview:name];
    //STATS SCROLLVIEW
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(180, 0, self.tableView.frame.size.width-130, 40)];
    [scrollView setContentSize:CGSizeMake(13*50+150, 40)];
    [scrollView setShowsHorizontalScrollIndicator:NO];
    [scrollView setShowsVerticalScrollIndicator:NO];
    [scrollView setBounces:NO];
    [cell addSubview:scrollView];
    scrollView.delegate = self;
    scrollView.tag = 1;
    [scrollView setContentOffset:CGPointMake(scrollDistanceDL, 0)];
    [scrollViewsDL addObject:scrollView];
    //STATS LABELS
    NSString *arr[14] = {@"STATUS", @"FPTS", @"MIN", @"FGM", @"FGA", @"FTM", @"FTA", @"REB", @"AST", @"BLK", @"STL", @"TO", @"PTS"};
    UILabel *stats1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 40)];
    stats1.text = [NSString stringWithFormat:@"%@",arr[0]];
    stats1.textAlignment = NSTextAlignmentCenter;
    stats1.font = [UIFont boldSystemFontOfSize:17];
    [scrollView addSubview:stats1];
    for (int i = 1; i < 13; i++) {
        UILabel *stats = [[UILabel alloc] initWithFrame:CGRectMake(50*i+100, 0, 50, 40)];
        stats.text = [NSString stringWithFormat:@"%@",arr[i]];
        stats.textAlignment = NSTextAlignmentCenter;
        stats.font = [UIFont boldSystemFontOfSize:17];
        [scrollView addSubview:stats];
    }
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PlayerCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Identifier"];
    FBPlayer *player = playersDL[indexPath.row];
    cell = [[PlayerCell alloc] initWithPlayer:player view:self scrollDistance:scrollDistanceDL];
    cell.delegate = self;
    return cell;
}

#pragma mark - Scroll Views

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.tag == 1) {
        scrollDistanceDL = scrollView.contentOffset.x;
        for (UIScrollView *sV in scrollViewsDL) [sV setContentOffset:CGPointMake(scrollDistanceDL, 0) animated:NO];
        for (NSIndexPath *path in [self.tableView indexPathsForVisibleRows]) [(PlayerCell *)[self.tableView cellForRowAtIndexPath:path] setScrollDistance:scrollDistanceDL];
    }
}

#pragma mark - FBPickerView

NSMutableArray <NSMutableArray <NSString *> *> *pickerData;

- (void)loadDatePickerData {
    pickerData = [[NSMutableArray alloc] initWithCapacity:2];
    pickerData[0] = [[NSMutableArray alloc] initWithCapacity:self.session.scoringPeriodID];
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"E, MMM d"];
    for (int i = 0; i < self.session.scoringPeriodID; i++) pickerData[0][i] = @"";
    for (int i = 1; i < self.session.scoringPeriodID; i++) { //days before
        date = [NSDate dateWithTimeIntervalSinceNow:-86400*i];
        pickerData[0][self.session.scoringPeriodID-1-i] = [formatter stringFromDate:date];
    }
    pickerData[0][self.session.scoringPeriodID-1] = @"Today";
    pickerData[1] = [[NSMutableArray alloc] initWithObjects:@"All", @"FA", @"Atl", @"Bkn", @"Bos", @"Cha", @"Chi", @"Cle", @"Dal", @"Den", @"Det", @"GS", @"Hou", @"Ind", @"LAC", @"LAL", @"Mem", @"Mia", @"Mil", @"Min", @"Nor", @"NY", @"OKC", @"Orl", @"Phi", @"Pho", @"Por", @"SA", @"Sac", @"Tor", @"Uta", @"Wsh", nil];
}

- (void)fadeIn:(UIButton *)sender {
    self.navigationItem.rightBarButtonItem.enabled = NO;
    FBPickerView *picker = [FBPickerView loadViewFromNib];
    picker.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    picker.delegate = self;
    [picker resetData];
    [picker setData:pickerData[0] ForColumn:0];
    [picker setData:pickerData[1] ForColumn:1];
    [picker selectIndex:self.session.scoringPeriodID-1 inColumn:0];
    [picker selectIndex:0 inColumn:1];
    [picker setAlpha:0.0];
    [self.view addSubview:picker];
    [UIView animateWithDuration:0.1 animations:^{
        [picker setAlpha:1.0];
    } completion: nil];
}

#pragma mark - FBPickerView delegate methods

- (void)doneButtonPressedInPickerView:(FBPickerView *)pickerView {
    int data1 = (int)[pickerView selectedIndexForColumn:0];
    int data2 = (int)[pickerView selectedIndexForColumn:1];
    scoringDay = data1+1;
    int indexs[32] = {-1, 0, 1, 17, 2, 30, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 29, 14, 15, 16, 3, 18, 25, 19, 20, 21, 22, 24, 23, 28, 26, 27};
    team = indexs[data2];
    //if (scoringDay == self.session.scoringPeriodID) refreshButton.enabled = YES;
    //else refreshButton.enabled = NO;
    [self loadplayersDL];
    [self.tableView reloadData];
    [self fadeOutWithPickerView:pickerView];
}

- (void)cancelButtonPressedInPickerView:(FBPickerView *)pickerView {
    [self fadeOutWithPickerView:pickerView];
}

@end
