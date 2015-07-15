//
//  DailyLeadersViewController.m
//  FantasyBasketball
//
//  Created by Chappy Asel on 1/17/15.
//  Copyright (c) 2015 CD. All rights reserved.
//

#import "DailyLeadersViewController.h"
#import "Session.h"
#import "Player.h"
#import "TFHpple.h"

@interface DailyLeadersViewController ()

@end

@implementation DailyLeadersViewController

Session *session;
UINavigationBar *bar;
UIBarButtonItem *refreshButton;
NSMutableArray *playersDL;
NSMutableArray *scrollViewsDL;
TFHpple *parser;
float scrollDistanceDL;
int scoringDay;
int team;

Session *session;

- (void)viewDidLoad {
    [super viewDidLoad];
    scoringDay = session.scoringPeriodID;
    team = -1; //All defualt
    [self loadplayersDL];
}

- (void)loadNavBar {
    bar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 64)];
    if (self.view.frame.size.height < 500) bar.frame = CGRectMake(0, 0, self.view.frame.size.width, 44);
    UINavigationItem *navItem = [[UINavigationItem alloc] initWithTitle:@"Daily Leaders"];
    refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshButtonPressed:)];
    navItem.rightBarButtonItem = refreshButton;
    UIBarButtonItem *bi2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(fadeIn:)];
    navItem.leftBarButtonItem = bi2;
    bar.items = [NSArray arrayWithObject:navItem];
    [self.view addSubview:bar];
}

- (void)loadTableView {
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
    scrollViewsDL = [[NSMutableArray alloc] init];
    _tableView.contentInset = UIEdgeInsetsMake(64, 0, 47, 0);
    _tableView.contentOffset = CGPointMake(0, 0); //CORECTLY DISPLAYS HEADER
    if (self.view.frame.size.height < 500) _tableView.contentInset = UIEdgeInsetsMake(44, 0, 47, 0);
    _tableView.delegate = self;
    _tableView.dataSource = self;
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

-(void)viewWillAppear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(orientationChanged:)    name:UIDeviceOrientationDidChangeNotification  object:nil];
    [self loadTableView];
    [self loadNavBar];
    [self loadDatePicker];
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
        } break;
        case UIInterfaceOrientationLandscapeLeft: case UIInterfaceOrientationLandscapeRight: {
            [bar setFrame:CGRectMake(0, 0, 736, 44)];
            _tableView.contentInset = UIEdgeInsetsMake(44, 0, 0, 0);
            _tableView.frame = CGRectMake(0, 0, 736, 414-(736-687));
        } break;
        case UIInterfaceOrientationUnknown: break;
    }
    for (UIScrollView *sV in scrollViewsDL) {
        sV.frame = CGRectMake(180, 0, _tableView.frame.size.width-180, 40);
    }
}

- (IBAction)refreshButtonPressed:(UIButton *)sender {
    [self loadplayersDL];
    scrollViewsDL = [[NSMutableArray alloc] init];
    [_tableView reloadData];
}

- (void)loadplayersDL {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://games.espn.go.com/fba/leaders?leagueId=%d&teamId=%d&scoringPeriodId=%d&startIndex=0&proTeamId=%d",session.leagueID,session.teamID,scoringDay,team]];
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
            [playersDL addObject:[[Player alloc] initWithData:data]];
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
    UIView *cell = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _tableView.frame.size.width, 40)];
    cell.backgroundColor = [UIColor lightGrayColor];
    //NAME
    UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 180, 40)];
    name.text = @"  NAME               TYPE";
    name.font = [UIFont boldSystemFontOfSize:17];
    [cell addSubview:name];
    //STATS SCROLLVIEW
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(180, 0, _tableView.frame.size.width-130, 40)];
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
    Player *player = playersDL[indexPath.row];
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

#pragma mark - Date Picker

NSMutableArray *pickerData;
NSArray *pickerData2;

-(void)loadDatePicker {
    _pickerView.hidden = YES;
    [self.view sendSubviewToBack:_pickerView];
    _picker.dataSource = self;
    _picker.delegate = self;
    pickerData = [[NSMutableArray alloc] initWithCapacity:session.scoringPeriodID];
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"E, MMM d"];
    for (int i = 0; i < session.scoringPeriodID; i++) pickerData[i] = @"";
    for (int i = 1; i < session.scoringPeriodID; i++) { //days before
        date = [NSDate dateWithTimeIntervalSinceNow:-86400*i];
        pickerData[session.scoringPeriodID-1-i] = [formatter stringFromDate:date];
    }
    pickerData[session.scoringPeriodID-1] = @"Today";
    pickerData2 = [[NSArray alloc] initWithObjects:@"All", @"FA", @"Atl", @"Bkn", @"Bos", @"Cha", @"Chi", @"Cle", @"Dal", @"Den", @"Det", @"GS", @"Hou", @"Ind", @"LAC", @"LAL", @"Mem", @"Mia", @"Mil", @"Min", @"Nor", @"NY", @"OKC", @"Orl", @"Phi", @"Pho", @"Por", @"SA", @"Sac", @"Tor", @"Uta", @"Wsh", nil];
    [self.picker selectRow:session.scoringPeriodID-1 inComponent:0 animated:NO];
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
        scoringDay = data1+1;
        int indexs[32] = {-1, 0, 1, 17, 2, 30, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 29, 14, 15, 16, 3, 18, 25, 19, 20, 21, 22, 24, 23, 28, 26, 27};
        team = indexs[data2];
        if (scoringDay == session.scoringPeriodID) refreshButton.enabled = YES;
        else refreshButton.enabled = NO;
        [self loadplayersDL];
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
    return pickerView.frame.size.width/2;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 40;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (component == 0) return pickerData[row];
    else return pickerData2[row];
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (component == 0) return session.scoringPeriodID;
    else return 32;
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 2; //day, team
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
