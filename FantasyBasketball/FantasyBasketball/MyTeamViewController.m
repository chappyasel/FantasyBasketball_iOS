//
//  MyTeamViewController.m
//  FantasyBasketball
//
//  Created by Chappy Asel on 1/14/15.
//  Copyright (c) 2015 CD. All rights reserved.
//

#import "MyTeamViewController.h"
#import "Session.h"
#import "Player.h"
#import "TFHpple.h"

@interface MyTeamViewController ()

@end

@implementation MyTeamViewController

Session *session;
UINavigationBar *bar;
UIBarButtonItem *refreshButton;
NSMutableArray *playersMT;
NSMutableArray *scrollViewsMT;
TFHpple *parser;
int numStarters = 0;
float scrollDistanceMT;
int scoringDay;
NSString *scoringPeriodMT = @"today";

- (void)viewDidLoad {
    [super viewDidLoad];
    scoringDay = session.scoringPeriodID;
    [self loadplayersMT];
}

- (void)viewWillAppear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(orientationChanged:)    name:UIDeviceOrientationDidChangeNotification  object:nil];
    [self loadTableView];
    [self loadNavBar];
    [self loadDatePicker];
}

- (void)loadNavBar {
    bar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 64)];
    if (self.view.frame.size.height < 500) bar.frame = CGRectMake(0, 0, self.view.frame.size.width, 44);
    NSString *XpathQueryString = @"//h3[@class='team-name']";
    NSArray *nodes = [parser searchWithXPathQuery:XpathQueryString];
    UINavigationItem *navItem = [[UINavigationItem alloc] initWithTitle:[[nodes firstObject] content]];
    navItem.title = [NSString stringWithFormat:@"My Team"];
    refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshButtonPressed:)];
    navItem.rightBarButtonItem = refreshButton;
    UIBarButtonItem *bi2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(fadeIn:)];
    navItem.leftBarButtonItem = bi2;
    bar.items = [NSArray arrayWithObject:navItem];
    [self.view addSubview:bar];
}

- (void)loadTableView {
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
    scrollViewsMT = [[NSMutableArray alloc] init];
    _tableView.contentInset = UIEdgeInsetsMake(64, 0, 47, 0);
    if (self.view.frame.size.height < 500) _tableView.contentInset = UIEdgeInsetsMake(44, 0, 47, 0);
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.showsHorizontalScrollIndicator = NO;
    _tableView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:_tableView];
    [_tableView reloadData];
}

- (void)orientationChanged:(NSNotification *)notification{
    [self adjustViewsForOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
}

- (void) adjustViewsForOrientation:(UIInterfaceOrientation) orientation {
    switch (orientation) {
        case UIInterfaceOrientationPortrait: case UIInterfaceOrientationPortraitUpsideDown: {
            [bar setFrame:CGRectMake(0, 0, 414, 64)];
            _tableView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
            _tableView.frame = CGRectMake(0, 0, 414, 687);
            _pickerView.frame = CGRectMake(0, 64, 414, 623);
            
        } break;
        case UIInterfaceOrientationLandscapeLeft: case UIInterfaceOrientationLandscapeRight: {
            [bar setFrame:CGRectMake(0, 0, 736, 44)];
            _tableView.contentInset = UIEdgeInsetsMake(44, 0, 0, 0);
            _tableView.frame = CGRectMake(0, 0, 736, 414-(736-687));
            _pickerView.frame = CGRectMake(0, 44, 736, 414-44-(736-687));
            //_picker.frame = CGRectMake(0, 414-44-(736-687)-180, 736, 180);
        } break;
        case UIInterfaceOrientationUnknown: break;
    }
    for (UIScrollView *sV in scrollViewsMT) {
        sV.frame = CGRectMake(130, 0, _tableView.frame.size.width-130, 40);
    }
}

- (IBAction)refreshButtonPressed:(UIButton *)sender {
    [self loadplayersMT];
    scrollViewsMT = [[NSMutableArray alloc] init];
    [_tableView reloadData];
}

- (void)loadplayersMT {
    numStarters = 0;
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://games.espn.go.com/fba/clubhouse?leagueId=%d&teamId=%d&seasonId=%d&version=%@&scoringPeriodMTId=%d",session.leagueID,session.teamID,session.seasonID,scoringPeriodMT,scoringDay]];
    NSData *html = [NSData dataWithContentsOfURL:url];
    parser = [TFHpple hppleWithHTMLData:html];
    NSString *XpathQueryString = @"//table[@class='playerTableTable tableBody']/tr";
    NSArray *nodes = [parser searchWithXPathQuery:XpathQueryString];
    playersMT = [[NSMutableArray alloc] initWithCapacity:13];
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
            [data insertObject:@"--" atIndex:4]; //type
            if (data.count == 18 || data.count == 19) { //not playing
                [data insertObject:@"--" atIndex:5];
                [data insertObject:@"--" atIndex:6];
                [data insertObject:@"--" atIndex:7];
            }
            [data insertObject:@"--" atIndex:8]; //gp
            [data insertObject:@"--" atIndex:9]; //gs
            [data insertObject:@"--" atIndex:10]; //min
            if (data.count != 25) [data insertObject:@"--" atIndex:21]; //tot
            [data addObject:[[element objectForKey:@"id"] substringFromIndex:4]];
            [playersMT addObject:[[Player alloc] initWithData:data]];
        }
    }
    for (Player *player in playersMT) if(player.isStarting) numStarters ++;
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) return numStarters;
    if (section == 1) return 13-numStarters;
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if ([scoringPeriodMT isEqual:@"today"]) return 40;
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *cell = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _tableView.frame.size.width, 40)];
    cell.backgroundColor = [UIColor lightGrayColor];
    //NAME
    UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 130, 40)];
    name.font = [UIFont boldSystemFontOfSize:17];
    if (section == 0) name.text = @"  STARTERS";
    if (section == 1) name.text = @"  BENCH";
    [cell addSubview:name];
    //Divider
    UILabel *div = [[UILabel alloc] initWithFrame:CGRectMake(129, 0, 1, 40)];
    div.backgroundColor = [UIColor lightGrayColor];
    [cell addSubview:div];
    //STATS SCROLLVIEW
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(130, 0, _tableView.frame.size.width-130, 40)];
    [scrollView setContentSize:CGSizeMake(13*50+150, 40)];
    [scrollView setShowsHorizontalScrollIndicator:NO];
    [scrollView setShowsVerticalScrollIndicator:NO];
    [scrollView setBounces:NO];
    [cell addSubview:scrollView];
    scrollView.delegate = self;
    scrollView.tag = 1;
    [scrollView setContentOffset:CGPointMake(scrollDistanceMT, 0)];
    [scrollViewsMT addObject:scrollView];
    //STATS LABELS
    NSString *arr[14] = {@"STATUS", @"FPTS", @"FGM", @"FGA", @"FTM", @"FTA", @"REB", @"AST", @"BLK", @"STL", @"TO", @"PTS", @"OWN", @"+/-"};
    UILabel *stats1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 40)];
    stats1.text = [NSString stringWithFormat:@"%@",arr[0]];
    stats1.textAlignment = NSTextAlignmentCenter;
    stats1.font = [UIFont boldSystemFontOfSize:17];
    [scrollView addSubview:stats1];
    for (int i = 1; i < 14; i++) {
        UILabel *stats = [[UILabel alloc] initWithFrame:CGRectMake(50*i+100/*size-50*/, 0, 50, 40)];
        stats.text = [NSString stringWithFormat:@"%@",arr[i]];
        stats.font = [UIFont boldSystemFontOfSize:17];
        stats.textAlignment = NSTextAlignmentCenter;
        [scrollView addSubview:stats];
    }
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *cell = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _tableView.frame.size.width, 40)];
    cell.backgroundColor = [UIColor lightGrayColor];
    //Divider
    UILabel *div = [[UILabel alloc] initWithFrame:CGRectMake(129, 0, 1, 40)];
    div.backgroundColor = [UIColor lightGrayColor];
    [cell addSubview:div];
    //STATS SCROLLVIEW
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(130, 0, _tableView.frame.size.width-130, 40)];
    [scrollView setContentSize:CGSizeMake(13*50+150, 40)];
    [scrollView setShowsHorizontalScrollIndicator:NO];
    [scrollView setShowsVerticalScrollIndicator:NO];
    [scrollView setBounces:NO];
    [cell addSubview:scrollView];
    scrollView.delegate = self;
    scrollView.tag = 1;
    [scrollView setContentOffset:CGPointMake(scrollDistanceMT, 0)];
    [scrollViewsMT addObject:scrollView];
    //STATS LABELS
    float arr[11] = {0,0,0,0,0,0,0,0,0,0,0};
    if (section == 0) {
        for (int i = 0; i < numStarters; i++) {
            Player *player = playersMT[i];
            if (player.isPlaying) {
                float arr2[11] = {player.fantasyPoints,player.fgm,player.fga,player.ftm,player.fta,player.rebounds,player.assists,player.blocks,player.steals,player.turnovers,player.points};
                for (int s = 0; s < 11; s++) arr[s] += arr2[s];
            }
        }
    }
    else {
        for (int i = numStarters; i < 13; i++) {
            Player *player = playersMT[i];
            if (player.isPlaying) {
                float arr2[11] = {player.fantasyPoints,player.fgm,player.fga,player.ftm,player.fta,player.rebounds,player.assists,player.blocks,player.steals,player.turnovers,player.points};
                for (int s = 0; s < 11; s++) arr[s] += arr2[s];
            }
        }
    }
    for (int i = 0; i < 11; i++) {
        UILabel *stats = [[UILabel alloc] initWithFrame:CGRectMake(50*i+150, 0, 50, 40)];
        stats.text = [NSString stringWithFormat:@"%.0f",arr[i]];
        stats.textAlignment = NSTextAlignmentCenter;
        stats.font = [UIFont boldSystemFontOfSize:17];
        [scrollView addSubview:stats];
    }
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PlayerCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Identifier"];
    Player *player = playersMT[indexPath.row+indexPath.section*numStarters];
    cell = [[PlayerCell alloc] initWithPlayer:player view:self scrollDistance:scrollDistanceMT];
    cell.delegate = self;
    return cell;
}

#pragma mark - Scroll Views

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.tag == 1) {
        scrollDistanceMT = scrollView.contentOffset.x;
        for (UIScrollView *sV in scrollViewsMT) [sV setContentOffset:CGPointMake(scrollDistanceMT, 0) animated:NO];
        for (NSIndexPath *path in [self.tableView indexPathsForVisibleRows]) [(PlayerCell *)[self.tableView cellForRowAtIndexPath:path] setScrollDistance:scrollDistanceMT];
    }
}

#pragma mark - Date Picker

NSArray *pickerData;

-(void)loadDatePicker {
    _pickerView.hidden = YES;
    [self.view sendSubviewToBack:_pickerView];
    _picker.dataSource = self;
    _picker.delegate = self;
    pickerData = [[NSMutableArray alloc] initWithObjects:
                  [[NSMutableArray alloc] initWithObjects: @"-", @"-", @"-", @"-", @"-", @"-", @"Today", @"-", @"-", @"-", @"-", @"-", @"-", nil],
                  [[NSMutableArray alloc]initWithObjects: @"Today", @"Last 7", @"Last 15", @"Last 30", @"Season", @"Last Season", @"Projections", nil], nil];
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"E, MMM d"];
    for (int i = 1; i < 7; i++) { //days before
        date = [NSDate dateWithTimeIntervalSinceNow:-86400*i];
        pickerData[0][6-i] = [formatter stringFromDate:date];
    }
    for (int i = 1; i < 7; i++) { //days after
        date = [NSDate dateWithTimeIntervalSinceNow:86400*i];
        pickerData[0][6+i] = [formatter stringFromDate:date];
    }
    [self.picker selectRow:6 inComponent:0 animated:NO];
}

-(void) fadeIn:(UIButton *)sender{
    [_pickerView setAlpha:0.0];
    _pickerView.hidden = NO;
    [self.view bringSubviewToFront:_pickerView];
    [UIView animateWithDuration:0.2 animations:^{
        [_pickerView setAlpha:1.0];
    } completion: nil];
}

-(void) fadeOut:(UIButton *)sender{
    if (sender) { //done button, do action
        int data1 = (int)[_picker selectedRowInComponent:0];
        int data2 = (int)[_picker selectedRowInComponent:1];
        scoringDay = session.scoringPeriodID-6+data1;
        if (data2 == 0) scoringPeriodMT = @"today";
        else if (data2 == 1) scoringPeriodMT = @"last7";
        else if (data2 == 2) scoringPeriodMT = @"last15";
        else if (data2 == 3) scoringPeriodMT = @"last30";
        else if (data2 == 4) scoringPeriodMT = @"currSeason";
        else if (data2 == 5) scoringPeriodMT = @"lastSeason";
        else  scoringPeriodMT = @"projections";
        if (data2 == 0 && data1 == 3) refreshButton.enabled = YES;
        else refreshButton.enabled = NO;
        [self loadplayersMT];
        [_tableView reloadData];
    }
    [_pickerView setAlpha:1.0];
    [UIView animateWithDuration:0.2 animations:^{
        [_pickerView setAlpha:0.0];
    } completion:^(BOOL finished) {
        [self.view sendSubviewToBack:_pickerView];
        _pickerView.hidden = YES;
    }];
}

- (IBAction)cancelButtonPressed:(UIButton *)sender {
    [self fadeOut:nil];
}

- (IBAction)doneButtonPressed:(UIButton *)sender {
    [self fadeOut:sender];
}

#pragma mark - Date picker methods

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    if (component == 0) return 207;
    if (component == 1) return 207;
    return 0;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 40;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return pickerData[component][row];
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (component == 0) return 13; //date (6 before, 6 after)
    if (component == 1) return 7; //time
    return 0;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 2;
}

#pragma mark - PlayerCell delegate

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
