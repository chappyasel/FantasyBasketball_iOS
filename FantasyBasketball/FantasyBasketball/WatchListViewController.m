//
//  WatchListViewController.m
//  FantasyBasketball
//
//  Created by Chappy Asel on 11/7/15.
//  Copyright © 2015 CD. All rights reserved.
//

#import "WatchListViewController.h"

@interface WatchListViewController ()

@property NSMutableArray *scrollViews;
@property float globalScrollDistance;

@property NSMutableArray *players;

@property NSArray <NSArray <NSString *> *> *pickerData;
@property NSArray <NSString *> *selectedPickerData;
@property NSString *scoringPeriod;

@end

@implementation WatchListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Watch List";
    self.scrollViews = [[NSMutableArray alloc] init];
    [self loadPickerViewData];
    [self beginAsyncLoading];
}

- (void)beginAsyncLoading {
    dispatch_queue_t myQueue = dispatch_queue_create("My Queue",NULL);
    dispatch_async(myQueue, ^{
        [self loadplayersWithCompletionBlock:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
                if (self.players.count > 0) [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
            });
        }];
    });
}

- (void)refreshNonAsync {
    [self loadplayersWithCompletionBlock:^{
        [self.tableView reloadData];
        if (self.players.count > 0) [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }];
}

- (void)loadplayersWithCompletionBlock:(void (^)(void)) completed {
    self.players = [[NSMutableArray alloc] init];
    for (NSString *name in self.watchList.playerArray) {
        NSDictionary *splitName = [FBPlayer separateFirstAndLastNameForString:name];
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://games.espn.com/fba/freeagency?leagueId=%@&seasonId=%@&context=freeagency&version=%@&avail=-1&search=%@&view=stats",self.session.leagueID,self.session.seasonID,_scoringPeriod,splitName[@"last"]]];
        NSData *html = [NSData dataWithContentsOfURL:url];
        TFHpple *parserR = [TFHpple hppleWithHTMLData:html];
        NSString *XpathQueryString = @"//table[@class='playerTableTable tableBody']/tr";
        NSArray *nodes = [parserR searchWithXPathQuery:XpathQueryString];
        for (int i = 0; i < nodes.count; i++) {
            TFHppleElement *element = nodes[i];
            if ([element objectForKey:@"id"]) {
                NSArray <TFHppleElement *> *children = element.children;
                if ([children[0].content containsString:splitName[@"first"]]) {
                    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
                    [dict setObject:[children[0].children[0] content] forKey:@"firstName+lastName"];
                    [dict setObject:[children[0].children[1] content] forKey:@"team+position"];
                    if (children[0].children.count > 2 && ![((TFHppleElement *)children[0].children[2]).tagName isEqualToString:@"a"])
                        [dict setObject:[children[0].children[2] content] forKey:@"injury"];
                    [dict setObject:children[2].content forKey:@"type"];
                    [dict setObject:children[5].content forKey:@"isHome+opponent"];
                    [dict setObject:children[6].content forKey:@"isPlaying+gameState+score+status"];
                    if (![dict[@"isPlaying+gameState+score+status"] isEqualToString:@""]) [dict setObject: [[[children[6] childrenWithTagName:@"a"] firstObject] objectForKey:@"href"] forKey:@"gameLink"];
                    [dict setObject:children[8].content forKey:@"fgm"];
                    [dict setObject:children[9].content forKey:@"fga"];
                    [dict setObject:children[10].content forKey:@"ftm"];
                    [dict setObject:children[11].content forKey:@"fta"];
                    [dict setObject:children[12].content forKey:@"rebounds"];
                    [dict setObject:children[13].content forKey:@"assists"];
                    [dict setObject:children[14].content forKey:@"steals"];
                    [dict setObject:children[15].content forKey:@"blocks"];
                    [dict setObject:children[16].content forKey:@"turnovers"];
                    [dict setObject:children[17].content forKey:@"points"];
                    [dict setObject:children[19].content forKey:@"totalFantasyPoints"];
                    [dict setObject:children[20].content forKey:@"fantasyPoints"];
                    [dict setObject:children[22].content forKey:@"percentOwned"];
                    [dict setObject:children[23].content forKey:@"plusMinus"];
                    [self.players addObject:[[FBPlayer alloc] initWithDictionary:dict]];
                    break;
                }
            }
        }
    }
    completed();
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
    [scrollView setContentSize:CGSizeMake(14*50+120, 30)];
    [scrollView setShowsHorizontalScrollIndicator:NO];
    [scrollView setShowsVerticalScrollIndicator:NO];
    [scrollView setBounces:NO];
    [cell addSubview:scrollView];
    scrollView.delegate = self;
    scrollView.tag = 1;
    [scrollView setContentOffset:CGPointMake(_globalScrollDistance, 0)];
    [self.scrollViews addObject:scrollView];
    //STATS LABELS
    NSString *arr[15] = {@"STATUS", @"FPTS", @"TOT", @"OWN", @"+/-", @"FGM", @"FGA", @"FTM", @"FTA", @"REB", @"AST", @"BLK", @"STL", @"TO", @"PTS"};
    UILabel *stats1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 120, 30)];
    stats1.text = [NSString stringWithFormat:@"%@",arr[0]];
    stats1.textAlignment = NSTextAlignmentCenter;
    stats1.font = [UIFont boldSystemFontOfSize:14];
    stats1.textColor = [UIColor whiteColor];
    [scrollView addSubview:stats1];
    for (int i = 1; i < 15; i++) {
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
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    FBPlayer *player = self.players[indexPath.row];
    BOOL isOnWL = [self.watchList.playerArray containsObject:player.fullName];
    cell = [[PlayerCell alloc] initWithPlayer:player view:self isOnWL:isOnWL size:CGSizeMake(self.view.frame.size.width, 40)];
    [cell setScrollDistance:_globalScrollDistance];
    cell.delegate = self;
    return cell;
}

#pragma mark - FBPickerView

- (void)loadPickerViewData {
    _scoringPeriod = @"last15";
    self.selectedPickerData = @[@"Last 15"];
    self.pickerData = @[ @[@"Last 7", @"Last 15", @"Last 30", @"Season", @"Last Season", @"Projections"] ];
}

- (void)fadeIn:(UIButton *)sender {
    self.navigationItem.rightBarButtonItem.enabled = NO;
    [self.view endEditing:YES];
    FBPickerView *picker = [FBPickerView loadViewFromNib];
    picker.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    picker.delegate = self;
    [picker resetData];
    [picker setData:self.pickerData[0] ForColumn:0];
    [picker selectString:self.selectedPickerData[0] inColumn:0];
    [picker setAlpha:0.0];
    [self.view addSubview:picker];
    [UIView animateWithDuration:0.25 animations:^{
        [picker setAlpha:1.0];
    } completion: nil];
}

#pragma mark - FBPickerView delegate methods

- (void)doneButtonPressedInPickerView:(FBPickerView *)pickerView {
    int data1 = (int)[pickerView selectedIndexForColumn:0];
    self.selectedPickerData = @[[pickerView selectedStringForColumn:0]];
    if (data1 == 0) _scoringPeriod = @"last7";
    else if (data1 == 1) _scoringPeriod = @"last15";
    else if (data1 == 2) _scoringPeriod = @"last30";
    else if (data1 == 3) _scoringPeriod = @"currSeason";
    else if (data1 == 4) _scoringPeriod = @"lastSeason";
    else _scoringPeriod = @"projections";
    [self refreshNonAsync];
    [self fadeOutWithPickerView:pickerView];
}

- (void)cancelButtonPressedInPickerView:(FBPickerView *)pickerView {
    [self fadeOutWithPickerView:pickerView];
}


#pragma mark - PlayerCell delegate

- (void)togglePlayer:(FBPlayer *)player WLStatusToState:(BOOL)isOnWL {
    [super togglePlayer:player WLStatusToState:isOnWL];
    [self refreshNonAsync];
}

#pragma mark - Scroll Views

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.tag == 1) {
        _globalScrollDistance = scrollView.contentOffset.x;
        for (UIScrollView *sV in self.scrollViews) [sV setContentOffset:CGPointMake(_globalScrollDistance, 0) animated:NO];
        for (NSIndexPath *path in [self.tableView indexPathsForVisibleRows])
            if ([self.tableView cellForRowAtIndexPath:path]) [(PlayerCell *)[self.tableView cellForRowAtIndexPath:path] setScrollDistance:_globalScrollDistance];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
