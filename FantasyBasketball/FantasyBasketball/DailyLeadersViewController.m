//
//  DailyLeadersViewController.m
//  FantasyBasketball
//
//  Created by Chappy Asel on 1/17/15.
//  Copyright (c) 2015 CD. All rights reserved.
//

#import "DailyLeadersViewController.h"

@interface DailyLeadersViewController ()

@property TFHpple *parser;

@property NSMutableArray *players;

@property NSMutableArray *scrollViews;
@property float globalScrollDistance;

@property NSMutableArray <NSMutableArray <NSString *> *> *pickerData;
@property NSArray <NSString *> *selectedPickerData;
@property int scoringDay;
@property int team;

@end

@implementation DailyLeadersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Daily Leaders";
    self.scrollViews = [[NSMutableArray alloc] init];
    [self loadPickerViewData];
    [self loadplayers];
}

- (void)loadTableView {
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
}

- (IBAction)refreshButtonPressed:(UIButton *)sender {
    [self loadplayers];
    self.scrollViews = [[NSMutableArray alloc] init];
    [self.tableView reloadData];
}

- (void)loadplayers {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://games.espn.go.com/fba/leaders?leagueId=%@&teamId=%@&scoringPeriodId=%d&startIndex=0&proTeamId=%d",self.session.leagueID,self.session.teamID,_scoringDay,_team]];
    NSData *html = [NSData dataWithContentsOfURL:url];
    self.parser = [TFHpple hppleWithHTMLData:html];
    NSString *XpathQueryString = @"//table[@class='playerTableTable tableBody']/tr";
    NSArray *nodes = [self.parser searchWithXPathQuery:XpathQueryString];
    self.players = [[NSMutableArray alloc] init];
    for (int i = 0; i < nodes.count; i++) {
        TFHppleElement *element = nodes[i];
        if ([element objectForKey:@"id"]) {
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            NSArray <TFHppleElement *> *children = element.children;
            [dict setObject:[children[0].children[0] content] forKey:@"firstName+lastName"];
            [dict setObject:[children[0].children[1] content] forKey:@"team+position"];
            if (children[0].children.count > 2 && ![((TFHppleElement *)children[0].children[2]).tagName isEqualToString:@"a"])
                [dict setObject:[children[0].children[2] content] forKey:@"injury"];
            [dict setObject:children[2].content forKey:@"type"];
            [dict setObject:children[5].content forKey:@"isHome+opponent"];
            [dict setObject:children[6].content forKey:@"isPlaying+gameState+score+status"];
            if (![dict[@"isPlaying+gameState+score+status"] isEqualToString:@""]) [dict setObject: [[[children[6] childrenWithTagName:@"a"] firstObject] objectForKey:@"href"] forKey:@"gameLink"];
            [dict setObject:children[8].content forKey:@"min"];
            [dict setObject:children[9].content forKey:@"fgm"];
            [dict setObject:children[10].content forKey:@"fga"];
            [dict setObject:children[11].content forKey:@"ftm"];
            [dict setObject:children[12].content forKey:@"fta"];
            [dict setObject:children[13].content forKey:@"rebounds"];
            [dict setObject:children[14].content forKey:@"assists"];
            [dict setObject:children[15].content forKey:@"steals"];
            [dict setObject:children[16].content forKey:@"blocks"];
            [dict setObject:children[17].content forKey:@"turnovers"];
            [dict setObject:children[18].content forKey:@"points"];
            [dict setObject:children[20].content forKey:@"fantasyPoints"];
            [self.players addObject:[[FBPlayer alloc] initWithDictionary:dict]];
        }
    }
}

#pragma mark - Table View

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.players.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    bool isLarge = self.view.frame.size.width > 400;
    UIView *cell = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 30)];
    cell.backgroundColor = [UIColor FBMediumOrangeColor];
    //NAME
    UILabel *name;
    if (isLarge) {
        name = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 180, 30)];
        name.text = @"   NAME                       TYPE";
    }
    else {
        name = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 30)];
        name.text = @"   NAME                TYPE";
    }
    name.font = [UIFont boldSystemFontOfSize:14];
    name.textColor = [UIColor whiteColor];
    [cell addSubview:name];
    //STATS SCROLLVIEW
    UIScrollView *scrollView = isLarge ? [[UIScrollView alloc] initWithFrame:CGRectMake(180, 0, self.tableView.frame.size.width-180, 30)]:
                                         [[UIScrollView alloc] initWithFrame:CGRectMake(150, 0, self.tableView.frame.size.width-150, 30)];
    [scrollView setContentSize:CGSizeMake(13*50+120, 30)];
    [scrollView setShowsHorizontalScrollIndicator:NO];
    [scrollView setShowsVerticalScrollIndicator:NO];
    [scrollView setBounces:NO];
    [cell addSubview:scrollView];
    scrollView.delegate = self;
    scrollView.tag = 1;
    [scrollView setContentOffset:CGPointMake(_globalScrollDistance, 0)];
    [self.scrollViews addObject:scrollView];
    //STATS LABELS
    NSString *arr[14] = {@"STATUS", @"FPTS", @"MIN", @"FGM", @"FGA", @"FTM", @"FTA", @"REB", @"AST", @"BLK", @"STL", @"TO", @"PTS"};
    UILabel *stats1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 120, 30)];
    stats1.text = [NSString stringWithFormat:@"%@",arr[0]];
    stats1.textAlignment = NSTextAlignmentCenter;
    stats1.font = [UIFont boldSystemFontOfSize:14];
    stats1.textColor = [UIColor whiteColor];
    [scrollView addSubview:stats1];
    for (int i = 1; i < 13; i++) {
        UILabel *stats = [[UILabel alloc] initWithFrame:CGRectMake(50*i+(120-50), 0, 50, 30)];
        stats.text = [NSString stringWithFormat:@"%@",arr[i]];
        stats.textAlignment = NSTextAlignmentCenter;
        stats.font = [UIFont boldSystemFontOfSize:14];
        stats.textColor = [UIColor whiteColor];
        [scrollView addSubview:stats];
    }
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PlayerCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Identifier"];
    FBPlayer *player = self.players[indexPath.row];
    cell = [[PlayerCell alloc] initWithPlayer:player view:self scrollDistance:_globalScrollDistance size:CGSizeMake(self.view.frame.size.width, 40.0)];
    cell.delegate = self;
    return cell;
}

#pragma mark - Scroll Views

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.tag == 1) {
        _globalScrollDistance = scrollView.contentOffset.x;
        for (UIScrollView *sV in self.scrollViews) [sV setContentOffset:CGPointMake(_globalScrollDistance, 0) animated:NO];
        for (NSIndexPath *path in [self.tableView indexPathsForVisibleRows]) [(PlayerCell *)[self.tableView cellForRowAtIndexPath:path] setScrollDistance:_globalScrollDistance];
    }
}

#pragma mark - FBPickerView

- (void)loadPickerViewData {
    _scoringDay = self.session.scoringPeriodID.intValue;
    _team = -1; //All (defualt)
    self.selectedPickerData = @[@"Today",@"All"];
    self.pickerData = [[NSMutableArray alloc] initWithCapacity:2];
    self.pickerData[0] = [[NSMutableArray alloc] init];
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"E, MMM d"];
    for (int i = 0; i < self.session.scoringPeriodID.intValue; i++) self.pickerData[0][i] = @"";
    for (int i = 1; i < self.session.scoringPeriodID.intValue; i++) { //days before
        date = [NSDate dateWithTimeIntervalSinceNow:-86400*i];
        self.pickerData[0][self.session.scoringPeriodID.intValue-1-i] = [formatter stringFromDate:date];
    }
    self.pickerData[0][self.session.scoringPeriodID.intValue-1] = @"Today";
    self.pickerData[1] = [[NSMutableArray alloc] initWithObjects:@"All", @"FA", @"Atl", @"Bkn", @"Bos", @"Cha", @"Chi", @"Cle", @"Dal", @"Den", @"Det", @"GS", @"Hou", @"Ind", @"LAC", @"LAL", @"Mem", @"Mia", @"Mil", @"Min", @"Nor", @"NY", @"OKC", @"Orl", @"Phi", @"Pho", @"Por", @"SA", @"Sac", @"Tor", @"Uta", @"Wsh", nil];
}

- (void)fadeIn:(UIButton *)sender {
    self.navigationItem.rightBarButtonItem.enabled = NO;
    FBPickerView *picker = [FBPickerView loadViewFromNib];
    picker.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    picker.delegate = self;
    [picker resetData];
    [picker setData:self.pickerData[0] ForColumn:0];
    [picker setData:self.pickerData[1] ForColumn:1];
    [picker selectString:self.selectedPickerData[0] inColumn:0];
    [picker selectString:self.selectedPickerData[1] inColumn:1];
    [picker setAlpha:0.0];
    [self.view addSubview:picker];
    [UIView animateWithDuration:0.25 animations:^{
        [picker setAlpha:1.0];
    } completion: nil];
}

#pragma mark - FBPickerView delegate methods

- (void)doneButtonPressedInPickerView:(FBPickerView *)pickerView {
    int data1 = (int)[pickerView selectedIndexForColumn:0];
    int data2 = (int)[pickerView selectedIndexForColumn:1];
    self.selectedPickerData = @[[pickerView selectedStringForColumn:0],
                                [pickerView selectedStringForColumn:1]];
    _scoringDay = data1+1;
    int indexs[32] = {-1, 0, 1, 17, 2, 30, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 29, 14, 15, 16, 3, 18, 25, 19, 20, 21, 22, 24, 23, 28, 26, 27};
    _team = indexs[data2];
    if (_scoringDay != self.session.scoringPeriodID.intValue) {
        [self.autorefreshSwitch setOn:NO];
        [self autorefreshStateChanged:self.autorefreshSwitch];
    }
    [self loadplayers];
    [self.tableView reloadData];
    [self fadeOutWithPickerView:pickerView];
}

- (void)cancelButtonPressedInPickerView:(FBPickerView *)pickerView {
    [self fadeOutWithPickerView:pickerView];
}

@end
