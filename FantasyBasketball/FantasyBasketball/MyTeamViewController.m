//
//  MyTeamViewController.m
//  FantasyBasketball
//
//  Created by Chappy Asel on 1/14/15.
//  Copyright (c) 2015 CD. All rights reserved.
//

#import "MyTeamViewController.h"

@interface MyTeamViewController ()

@property NSString *globalLink;

@property TFHpple *parser;
@property NSMutableArray *players;
@property int numStarters;

@property NSMutableArray *scrollViews;
@property float globalScrollDistance;

@property NSMutableArray <NSMutableArray <NSString *> *> *pickerData;
@property NSArray <NSString *> *selectedPickerData;
@property int scoringDay; //time of stats
//@property NSString *scoringPeriod; //span of stats

@end

@implementation MyTeamViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupTableView];
    [self loadPickerViewData];
    [self beginAsyncLoading];
}

- (void)beginAsyncLoading {
    dispatch_queue_t myQueue = dispatch_queue_create("My Queue",NULL);
    dispatch_async(myQueue, ^{
        [self loadplayersWithCompletionBlock:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }];
        [self loadTitleWithCompletionBlock:^(NSString *title) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.title = title;
            });
        }];
    });
}

- (void)initWithTeamLink: (NSString *) link {
    self.globalLink = link;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(backButtonPressed:)];
}

- (IBAction)backButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)setupTableView {
    self.scrollViews = [[NSMutableArray alloc] init];
}

- (void)loadTitleWithCompletionBlock:(void (^)(NSString *title)) completed {
    if (!self.globalLink) completed(@"My Team");
    else {
        NSString *XpathQueryString = @"//h3[@class='team-name']";
        NSArray *nodes = [self.parser searchWithXPathQuery:XpathQueryString];
        NSString *teamName = [[nodes firstObject] content];
        if (teamName) completed(teamName);
        else completed(@"Team");
    }
}

- (void)loadplayersWithCompletionBlock:(void (^)(void)) completed {
    _numStarters = 0;
    NSString *link = self.globalLink;
    if (link == nil) link = [NSString stringWithFormat:@"http://games.espn.go.com/fba/clubhouse?leagueId=%@&teamId=%@&seasonId=%@",self.session.leagueID,self.session.teamID,self.session.seasonID];
    link = [NSString stringWithFormat:@"%@&version=%@&scoringPeriodId=%d",link,_scoringPeriod,_scoringDay];
    NSURL *url = [NSURL URLWithString:link];
    NSData *html = [NSData dataWithContentsOfURL:url];
    self.parser = [TFHpple hppleWithHTMLData:html];
    NSString *XpathQueryString = @"//table[@class='playerTableTable tableBody']/tr";
    NSArray *nodes = [self.parser searchWithXPathQuery:XpathQueryString];
    self.players = [[NSMutableArray alloc] initWithCapacity:13];
    for (int i = 2; i < nodes.count; i++) {
        TFHppleElement *element = nodes[i];
        if ([element objectForKey:@"id"]) {
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            NSArray <TFHppleElement *> *children = element.children;
            [dict setObject:children[0].content forKey:@"isStarting"];
            [dict setObject:[children[1].children[0] content] forKey:@"firstName+lastName"];
            [dict setObject:[children[1].children[1] content] forKey:@"team+position"];
            if (children[1].children.count > 2 && ![((TFHppleElement *)children[1].children[2]).tagName isEqualToString:@"a"])
                [dict setObject:[children[1].children[2] content] forKey:@"injury"];
            [dict setObject:children[3].content forKey:@"isHome+opponent"];
            [dict setObject:children[4].content forKey:@"isPlaying+gameState+score+status"];
            if (![dict[@"isPlaying+gameState+score+status"] isEqualToString:@""]) [dict setObject: [[[children[4] childrenWithTagName:@"a"] firstObject] objectForKey:@"href"] forKey:@"gameLink"];
            [dict setObject:children[6].content forKey:@"fgm"];
            [dict setObject:children[7].content forKey:@"fga"];
            [dict setObject:children[8].content forKey:@"ftm"];
            [dict setObject:children[9].content forKey:@"fta"];
            [dict setObject:children[10].content forKey:@"rebounds"];
            [dict setObject:children[11].content forKey:@"assists"];
            [dict setObject:children[12].content forKey:@"steals"];
            [dict setObject:children[13].content forKey:@"blocks"];
            [dict setObject:children[14].content forKey:@"turnovers"];
            [dict setObject:children[15].content forKey:@"points"];
            if ([self.scoringPeriod isEqualToString:@"today"]) {
                [dict setObject:children[16].content forKey:@"fantasyPoints"];
                [dict setObject:children[18].content forKey:@"percentOwned"];
                [dict setObject:children[19].content forKey:@"plusMinus"];
            }
            else {
                [dict setObject:children[17].content forKey:@"totalFantasyPoints"];
                [dict setObject:children[18].content forKey:@"fantasyPoints"];
                [dict setObject:children[20].content forKey:@"percentOwned"];
                [dict setObject:children[21].content forKey:@"plusMinus"];
            }
            [self.players addObject:[[FBPlayer alloc] initWithDictionary:dict]];
        }
    }
    for (FBPlayer *player in _players) if(player.isStarting) _numStarters ++;
    completed();
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) return _numStarters;
    if (section == 1) return self.players.count-_numStarters;
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if ([_scoringPeriod isEqual:@"today"]) return 30;
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 42.46;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    bool isLarge = self.view.frame.size.width > 400;
    UIView *cell = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 30)];
    cell.backgroundColor = [UIColor FBMediumOrangeColor];
    //NAME
    UILabel *name = isLarge ? [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 130, 30)]:[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 115, 30)];
    name.font = [UIFont boldSystemFontOfSize:14];
    name.textColor = [UIColor whiteColor];
    if (section == 0) name.text = @"  STARTERS";
    if (section == 1) name.text = @"  BENCH";
    [cell addSubview:name];
    //Divider
    //UILabel *div = [[UILabel alloc] initWithFrame:CGRectMake(129, 0, 1, 40)];
    //div.backgroundColor = [UIColor lightGrayColor];
    //[cell addSubview:div];
    //STATS SCROLLVIEW
    UIScrollView *scrollView = isLarge ? [[UIScrollView alloc] initWithFrame:CGRectMake(130, 0, self.tableView.frame.size.width-130, 30)]:
                                         [[UIScrollView alloc] initWithFrame:CGRectMake(115, 0, self.tableView.frame.size.width-115, 30)];
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
    NSString *arr[14] = {@"STATUS", @"FPTS", @"FGM", @"FGA", @"FTM", @"FTA", @"REB", @"AST", @"BLK", @"STL", @"TO", @"PTS", @"OWN", @"+/-"};
    UILabel *stats1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 120, 30)];
    stats1.text = [NSString stringWithFormat:@"%@",arr[0]];
    stats1.textAlignment = NSTextAlignmentCenter;
    stats1.font = [UIFont boldSystemFontOfSize:14];
    stats1.textColor = [UIColor whiteColor];
    [scrollView addSubview:stats1];
    for (int i = 1; i < 14; i++) {
        UILabel *stats = [[UILabel alloc] initWithFrame:CGRectMake(50*i+(120-50), 0, 50, 30)];
        stats.text = [NSString stringWithFormat:@"%@",arr[i]];
        stats.font = [UIFont boldSystemFontOfSize:14];
        stats.textAlignment = NSTextAlignmentCenter;
        stats.textColor = [UIColor whiteColor];
        [scrollView addSubview:stats];
    }
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    bool isLarge = self.view.frame.size.width > 400;
    UIView *cell = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 30)];
    cell.backgroundColor = [UIColor FBMediumOrangeColor];
    //Divider
    //UILabel *div = [[UILabel alloc] initWithFrame:CGRectMake(129, 0, 1, 40)];
    //div.backgroundColor = [UIColor lightGrayColor];
    //[cell addSubview:div];
    //STATS SCROLLVIEW
    UIScrollView *scrollView = isLarge ? [[UIScrollView alloc] initWithFrame:CGRectMake(130, 0, self.tableView.frame.size.width-130, 30)]:
                                         [[UIScrollView alloc] initWithFrame:CGRectMake(115, 0, self.tableView.frame.size.width-115, 30)];
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
    float arr[11] = {0,0,0,0,0,0,0,0,0,0,0};
    if (section == 0) {
        for (int i = 0; i < _numStarters; i++) {
            FBPlayer *player = self.players[i];
            if (player.isPlaying) {
                float arr2[11] = {player.fantasyPoints,player.fgm,player.fga,player.ftm,player.fta,player.rebounds,player.assists,player.blocks,player.steals,player.turnovers,player.points};
                for (int s = 0; s < 11; s++) arr[s] += arr2[s];
            }
        }
    }
    else {
        for (int i = _numStarters; i < 13; i++) {
            FBPlayer *player = self.players[i];
            if (player.isPlaying) {
                float arr2[11] = {player.fantasyPoints,player.fgm,player.fga,player.ftm,player.fta,player.rebounds,player.assists,player.blocks,player.steals,player.turnovers,player.points};
                for (int s = 0; s < 11; s++) arr[s] += arr2[s];
            }
        }
    }
    for (int i = 0; i < 11; i++) {
        UILabel *stats = [[UILabel alloc] initWithFrame:CGRectMake(50*i+120, 0, 50, 30)];
        stats.text = [NSString stringWithFormat:@"%.0f",arr[i]];
        stats.textAlignment = NSTextAlignmentCenter;
        stats.font = [UIFont boldSystemFontOfSize:17];
        stats.textColor = [UIColor whiteColor];
        [scrollView addSubview:stats];
    }
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PlayerCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Identifier"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    FBPlayer *player = self.players[indexPath.row+indexPath.section*_numStarters];
    BOOL isOnWL = [self.watchList.players containsObject:player.fullName];
    cell = [[PlayerCell alloc] initWithPlayer:player view:self isOnWL:isOnWL size:CGSizeMake(self.view.frame.size.width, 42.46)];
    [cell setScrollDistance:_globalScrollDistance];
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

-(void)loadPickerViewData {
    _scoringPeriod = @"today";
    _scoringDay = self.session.scoringPeriodID.intValue;
    self.selectedPickerData = @[@"Today", @"Today"];
    self.pickerData = [[NSMutableArray alloc] initWithArray:
                       @[[[NSMutableArray alloc] initWithArray:
                          @[@"-", @"-", @"-", @"-", @"-", @"Yesterday", @"Today", @"Tomorrow", @"-", @"-", @"-", @"-", @"-"]],
                         [[NSMutableArray alloc] initWithArray:
                          @[@"Today", @"Last 7", @"Last 15", @"Last 30", @"Season", @"Last Season", @"Projections"]]]];
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"E, MMM d"];
    for (int i = 1; i < 6; i++) { //days before
        date = [NSDate dateWithTimeIntervalSinceNow:-86400*i];
        self.pickerData[0][5-i] = [formatter stringFromDate:date];
    }
    for (int i = 2; i < 7; i++) { //days after
        date = [NSDate dateWithTimeIntervalSinceNow:86400*i];
        self.pickerData[0][6+i] = [formatter stringFromDate:date];
    }
}

-(void) fadeIn:(UIButton *)sender {
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
    int data1 = [pickerView selectedIndexForColumn:0];
    int data2 = [pickerView selectedIndexForColumn:1];
    self.selectedPickerData = @[[pickerView selectedStringForColumn:0],
                                [pickerView selectedStringForColumn:1]];
    _scoringDay = self.session.scoringPeriodID.intValue-6+data1;
    if (data2 == 0) _scoringPeriod = @"today";
    else if (data2 == 1) _scoringPeriod = @"last7";
    else if (data2 == 2) _scoringPeriod = @"last15";
    else if (data2 == 3) _scoringPeriod = @"last30";
    else if (data2 == 4) _scoringPeriod = @"currSeason";
    else if (data2 == 5) _scoringPeriod = @"lastSeason";
    else _scoringPeriod = @"projections";
    [self beginAsyncLoading];
    [self fadeOutWithPickerView:pickerView];
}

- (void)cancelButtonPressedInPickerView:(FBPickerView *)pickerView {
    [self fadeOutWithPickerView:pickerView];
}

@end
