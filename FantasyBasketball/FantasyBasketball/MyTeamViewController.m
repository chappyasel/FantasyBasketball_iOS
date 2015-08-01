//
//  MyTeamViewController.m
//  FantasyBasketball
//
//  Created by Chappy Asel on 1/14/15.
//  Copyright (c) 2015 CD. All rights reserved.
//

#import "MyTeamViewController.h"
#import "FBSession.h"
#import "FBPlayer.h"
#import "TFHpple.h"
#import "MZFormSheetController.h"

@interface MyTeamViewController ()
@end

@implementation MyTeamViewController

FBSession *session;
TFHpple *parser;
NSMutableArray *playersMT;
int numStarters = 0;
NSMutableArray *scrollViewsMT;
float scrollDistanceMT;

int scoringDay;                         //time of stats
NSString *scoringPeriodMT = @"today";   //span of stats

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadNavBar];
    scoringDay = session.scoringPeriodID;
    [self loadplayersMT];
    [self loadTableView];
    [self loadDatePickerData];
}

- (void)loadNavBar {
    NSString *XpathQueryString = @"//h3[@class='team-name']";
    NSArray *nodes = [parser searchWithXPathQuery:XpathQueryString];
    NSString *teamName = [[nodes firstObject] content];
    if (teamName) self.title = teamName;
    else self.title = @"My Team";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Menu"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(presentLeftMenuViewController:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                                                                           target:self
                                                                                           action:@selector(fadeIn:)];
}

- (void)loadTableView {
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)
                                              style:UITableViewStylePlain];
    scrollViewsMT = [[NSMutableArray alloc] init];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.showsHorizontalScrollIndicator = NO;
    _tableView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:_tableView];
    [_tableView reloadData];
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
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            NSArray <TFHppleElement *> *children = element.children;
            [dict setObject:children[0].content forKey:@"isStarting"];
            [dict setObject:[children[1].children[0] content] forKey:@"firstName+lastName"];
            [dict setObject:[children[1].children[1] content] forKey:@"team+position"];
            if (children[1].children.count == 4) [dict setObject:[children[1].children[2] content] forKey:@"injury"];
            int offset = 0;
            if (children.count == 21) {
                [dict setObject:children[3].content forKey:@"isHome+opponent"];
                [dict setObject:children[4].content forKey:@"isPlaying+gameState+score+status"];
                [dict setObject:[[[children[4] childrenWithTagName:@"a"] firstObject] objectForKey:@"href"] forKey:@"gameLink"];
                offset = 3;
            }
            [dict setObject:children[3+offset].content forKey:@"fgm"];
            [dict setObject:children[4+offset].content forKey:@"fga"];
            [dict setObject:children[5+offset].content forKey:@"ftm"];
            [dict setObject:children[6+offset].content forKey:@"fta"];
            [dict setObject:children[7+offset].content forKey:@"rebounds"];
            [dict setObject:children[8+offset].content forKey:@"assists"];
            [dict setObject:children[9+offset].content forKey:@"steals"];
            [dict setObject:children[10+offset].content forKey:@"blocks"];
            [dict setObject:children[11+offset].content forKey:@"turnovers"];
            [dict setObject:children[12+offset].content forKey:@"points"];
            [dict setObject:children[14+offset].content forKey:@"totalFantasyPoints"];
            [dict setObject:children[15+offset].content forKey:@"fantasyPoints"];
            [dict setObject:children[17+offset].content forKey:@"percentOwned"];
            [dict setObject:children[18+offset].content forKey:@"plusMinus"];
            [playersMT addObject:[[FBPlayer alloc] initWithDictionary:dict]];
        }
    }
    for (FBPlayer *player in playersMT) if(player.isStarting) numStarters ++;
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
            FBPlayer *player = playersMT[i];
            if (player.isPlaying) {
                float arr2[11] = {player.fantasyPoints,player.fgm,player.fga,player.ftm,player.fta,player.rebounds,player.assists,player.blocks,player.steals,player.turnovers,player.points};
                for (int s = 0; s < 11; s++) arr[s] += arr2[s];
            }
        }
    }
    else {
        for (int i = numStarters; i < 13; i++) {
            FBPlayer *player = playersMT[i];
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
    FBPlayer *player = playersMT[indexPath.row+indexPath.section*numStarters];
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

-(void)loadDatePickerData {
    pickerData = [[NSMutableArray alloc] initWithObjects:
                  [[NSMutableArray alloc] initWithObjects: @"-", @"-", @"-", @"-", @"-", @"Yesterday", @"Today", @"Tomorrow", @"-", @"-", @"-", @"-", @"-", nil],
                  [[NSMutableArray alloc]initWithObjects: @"Today", @"Last 7", @"Last 15", @"Last 30", @"Season", @"Last Season", @"Projections", nil], nil];
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"E, MMM d"];
    for (int i = 1; i < 6; i++) { //days before
        date = [NSDate dateWithTimeIntervalSinceNow:-86400*i];
        pickerData[0][5-i] = [formatter stringFromDate:date];
    }
    for (int i = 2; i < 7; i++) { //days after
        date = [NSDate dateWithTimeIntervalSinceNow:86400*i];
        pickerData[0][6+i] = [formatter stringFromDate:date];
    }
}

-(void) fadeIn:(UIButton *)sender {
    self.navigationItem.rightBarButtonItem.enabled = NO;
    FBPickerView *picker = [FBPickerView loadViewFromNib];
    picker.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    picker.delegate = self;
    [picker setData:pickerData[0] ForColumn:0];
    [picker setData:pickerData[1] ForColumn:1];
    [picker selectIndex:-(session.scoringPeriodID-scoringDay)+6 inColumn:0];
    [picker selectIndex:(int)[[NSArray arrayWithObjects:@"today", @"last7", @"last15", @"last30", @"currSeason", @"lastSeason", @"projections",nil] indexOfObject:scoringPeriodMT] inColumn:1];
    [picker setAlpha:0.0];
    [self.view addSubview:picker];
    [UIView animateWithDuration:0.1 animations:^{
        [picker setAlpha:1.0];
    } completion: nil];
}

-(void)fadeOutWithPickerView: (FBPickerView *) pickerView {
    [pickerView setAlpha:1.0];
    [UIView animateWithDuration:0.1 animations:^{
        [pickerView setAlpha:0.0];
    } completion:^(BOOL finished) {
        [pickerView removeFromSuperview];
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }];
}

#pragma mark - FBPickerView delegate methods

- (void)doneButtonPressedInPickerView:(FBPickerView *)pickerView {
    int data1 = [pickerView selectedIndexForColumn:0];
    int data2 = [pickerView selectedIndexForColumn:1];
    scoringDay = session.scoringPeriodID-6+data1;
    if (data2 == 0) scoringPeriodMT = @"today";
    else if (data2 == 1) scoringPeriodMT = @"last7";
    else if (data2 == 2) scoringPeriodMT = @"last15";
    else if (data2 == 3) scoringPeriodMT = @"last30";
    else if (data2 == 4) scoringPeriodMT = @"currSeason";
    else if (data2 == 5) scoringPeriodMT = @"lastSeason";
    else  scoringPeriodMT = @"projections";
    //if (data2 == 0 && data1 == 3) refreshButton.enabled = YES;
    //else refreshButton.enabled = NO;
    [self loadplayersMT];
    [_tableView reloadData];
    [self fadeOutWithPickerView:pickerView];
}

- (void)cancelButtonPressedInPickerView:(FBPickerView *)pickerView {
    [self fadeOutWithPickerView:pickerView];
}

#pragma mark - PlayerCell delegate

- (void)linkWithPlayer:(FBPlayer *)player {
    session.player = player;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *viewController = (UIViewController *)[storyboard instantiateViewControllerWithIdentifier:@"p"];
    MZFormSheetController *formSheet = [[MZFormSheetController alloc] initWithViewController:viewController];
    formSheet.shouldDismissOnBackgroundViewTap = YES;
    formSheet.transitionStyle = MZFormSheetTransitionStyleSlideFromBottom;
    formSheet.shouldCenterVertically = YES;
    formSheet.cornerRadius = 5.0;
    formSheet.portraitTopInset = 6.0;
    formSheet.landscapeTopInset = 6.0;
    formSheet.presentedFormSheetSize = CGSizeMake(375, 680);
    [self mz_presentFormSheetController:formSheet animated:YES completionHandler:^(MZFormSheetController *formSheetController) {
        
    }];
}

- (void)linkWithGameLink:(FBPlayer *)player {
    session.link = [player gameLink];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *viewController = (UIViewController *)[storyboard instantiateViewControllerWithIdentifier:@"w"];
    //[self addChildViewController:viewController];
    //[self presentViewController:viewController animated:YES completion:nil];
    viewController.modalPresentationStyle=UIModalPresentationFormSheet;
    viewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:viewController animated:YES completion:^{
        viewController.view.superview.frame = CGRectMake(0, 0, 310, 500);
        viewController.view.superview.center = self.view.center;
    }];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
// Get the new view controller using [segue destinationViewController].
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

}

@end
