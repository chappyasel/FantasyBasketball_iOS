//
//  PlayersViewController.m
//  FantasyBasketball
//
//  Created by Chappy Asel on 1/14/15.
//  Copyright (c) 2015 CD. All rights reserved.
//

#import "PlayersViewController.h"

@interface PlayersViewController ()

@end

@implementation PlayersViewController

NSArray *sortChoices;
NSString *sort;
int sortIndex;
int availability;
int team;
NSString *scoringPeriodPL;
NSString *searchText;
NSMutableArray *playersPL;
NSMutableArray *scrollViewsPL;
TFHpple *parser;
float scrollDistancePL;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Find Players";
    sortChoices = [[NSArray alloc] initWithObjects: //FPTS, TOT, OWN, +/-, ...
                   @"AAAAARgAAAAHAQAMc3RhdFNlYXNvbklkAwAAB%2BABAAhjYXRlZ29yeQMAAAACAQAJZGlyZWN0aW9uA%2F%2F%2F%2F%2F8BAAZjb2x1bW4D%2F%2F%2F%2F%2FgEAC3NwbGl0VHlwZUlkAwAAAAABABBzdGF0U291cmNlVHlwZUlkAwAAAAABAAtzdGF0UXVlcnlJZAMAAAAB", //FPTS
                   @"AAAAARgAAAAHAQAMc3RhdFNlYXNvbklkAwAAB%2BABAAhjYXRlZ29yeQMAAAACAQAJZGlyZWN0aW9uA%2F%2F%2F%2F%2F8BAAZjb2x1bW4D%2F%2F%2F%2F%2FQEAC3NwbGl0VHlwZUlkAwAAAAABABBzdGF0U291cmNlVHlwZUlkAwAAAAABAAtzdGF0UXVlcnlJZAMAAAAB&r=7692735", //TOT
                   @"AAAAARgAAAADAQAIY2F0ZWdvcnkDAAAAAwEABmNvbHVtbgMAAAAHAQAJZGlyZWN0aW9uA%2F%2F%2F%2F%2F8%3D&r=30813114", //OWN
                   @"AAAAARgAAAADAQAIY2F0ZWdvcnkDAAAAAwEABmNvbHVtbgMAAAAIAQAJZGlyZWN0aW9uA%2F%2F%2F%2F%2F8%3D&r=96697743", //+/-
                   @"AAAAARgAAAAIAQAMc3RhdFNlYXNvbklkAwAAB%2BABAAhjYXRlZ29yeQMAAAABAQAJZGlyZWN0aW9uA%2F%2F%2F%2F%2F8BAAZjb2x1bW4DAAAADQEAC3NwbGl0VHlwZUlkAwAAAAABABBzdGF0U291cmNlVHlwZUlkAwAAAAABAAtzb3J0QXZlcmFnZQkBAQALc3RhdFF1ZXJ5SWQDAAAAAQ%3D%3D&r=32599089", //FGM
                   @"AAAAARgAAAAIAQAMc3RhdFNlYXNvbklkAwAAB%2BABAAhjYXRlZ29yeQMAAAABAQAJZGlyZWN0aW9uA%2F%2F%2F%2F%2F8BAAZjb2x1bW4DAAAADgEAC3NwbGl0VHlwZUlkAwAAAAABABBzdGF0U291cmNlVHlwZUlkAwAAAAABAAtzb3J0QXZlcmFnZQkBAQALc3RhdFF1ZXJ5SWQDAAAAAQ%3D%3D&r=1234527", //FGA
                   @"AAAAARgAAAAIAQAMc3RhdFNlYXNvbklkAwAAB%2BABAAhjYXRlZ29yeQMAAAABAQAJZGlyZWN0aW9uA%2F%2F%2F%2F%2F8BAAZjb2x1bW4DAAAADwEAC3NwbGl0VHlwZUlkAwAAAAABABBzdGF0U291cmNlVHlwZUlkAwAAAAABAAtzb3J0QXZlcmFnZQkBAQALc3RhdFF1ZXJ5SWQDAAAAAQ%3D%3D&r=46481326", //FTM
                   @"AAAAARgAAAAIAQAMc3RhdFNlYXNvbklkAwAAB%2BABAAhjYXRlZ29yeQMAAAABAQAJZGlyZWN0aW9uA%2F%2F%2F%2F%2F8BAAZjb2x1bW4DAAAAEAEAC3NwbGl0VHlwZUlkAwAAAAABABBzdGF0U291cmNlVHlwZUlkAwAAAAABAAtzb3J0QXZlcmFnZQkBAQALc3RhdFF1ZXJ5SWQDAAAAAQ%3D%3D&r=75772049", //FTA
                   @"AAAAARgAAAAIAQAMc3RhdFNlYXNvbklkAwAAB%2BABAAhjYXRlZ29yeQMAAAABAQAJZGlyZWN0aW9uA%2F%2F%2F%2F%2F8BAAZjb2x1bW4DAAAABgEAC3NwbGl0VHlwZUlkAwAAAAABABBzdGF0U291cmNlVHlwZUlkAwAAAAABAAtzb3J0QXZlcmFnZQkBAQALc3RhdFF1ZXJ5SWQDAAAAAQ%3D%3D&r=29305171", //REB
                   @"AAAAARgAAAAIAQAMc3RhdFNlYXNvbklkAwAAB%2BABAAhjYXRlZ29yeQMAAAABAQAJZGlyZWN0aW9uA%2F%2F%2F%2F%2F8BAAZjb2x1bW4DAAAAAwEAC3NwbGl0VHlwZUlkAwAAAAABABBzdGF0U291cmNlVHlwZUlkAwAAAAABAAtzb3J0QXZlcmFnZQkBAQALc3RhdFF1ZXJ5SWQDAAAAAQ%3D%3D&r=16601350", //AST
                   @"AAAAARgAAAAIAQAMc3RhdFNlYXNvbklkAwAAB%2BABAAhjYXRlZ29yeQMAAAABAQAJZGlyZWN0aW9uA%2F%2F%2F%2F%2F8BAAZjb2x1bW4DAAAAAQEAC3NwbGl0VHlwZUlkAwAAAAABABBzdGF0U291cmNlVHlwZUlkAwAAAAABAAtzb3J0QXZlcmFnZQkBAQALc3RhdFF1ZXJ5SWQDAAAAAQ%3D%3D&r=93827578", //BLK
                   @"AAAAARgAAAAIAQAMc3RhdFNlYXNvbklkAwAAB%2BABAAhjYXRlZ29yeQMAAAABAQAJZGlyZWN0aW9uA%2F%2F%2F%2F%2F8BAAZjb2x1bW4DAAAAAgEAC3NwbGl0VHlwZUlkAwAAAAABABBzdGF0U291cmNlVHlwZUlkAwAAAAABAAtzb3J0QXZlcmFnZQkBAQALc3RhdFF1ZXJ5SWQDAAAAAQ%3D%3D&r=63854691", //STL
                   @"AAAAARgAAAAIAQAMc3RhdFNlYXNvbklkAwAAB%2BABAAhjYXRlZ29yeQMAAAABAQAJZGlyZWN0aW9uA%2F%2F%2F%2F%2F8BAAZjb2x1bW4DAAAACwEAC3NwbGl0VHlwZUlkAwAAAAABABBzdGF0U291cmNlVHlwZUlkAwAAAAABAAtzb3J0QXZlcmFnZQkBAQALc3RhdFF1ZXJ5SWQDAAAAAQ%3D%3D&r=67940983", //TO
                   @"AAAAARgAAAAIAQAMc3RhdFNlYXNvbklkAwAAB%2BABAAhjYXRlZ29yeQMAAAABAQAJZGlyZWN0aW9uA%2F%2F%2F%2F%2F8BAAZjb2x1bW4DAAAAAAEAC3NwbGl0VHlwZUlkAwAAAAABABBzdGF0U291cmNlVHlwZUlkAwAAAAABAAtzb3J0QXZlcmFnZQkBAQALc3RhdFF1ZXJ5SWQDAAAAAQ%3D%3D&r=36360871", /*PTS*/ nil];
    sort = sortChoices[3];
    sortIndex = 3; //+/- sort
    availability = 1; //Available
    scoringPeriodPL = @"last15";
    searchText = @"null";
    team = -1;
    scrollViewsPL = [[NSMutableArray alloc] init];
    [self loadplayersPL];
}

- (void)loadSearchBar {
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 414, 44)];
    searchBar.delegate = self;
    searchBar.placeholder = @"Search by last name";
    searchBar.returnKeyType = UIReturnKeySearch;
    searchBar.showsCancelButton = YES;
    self.tableView.tableHeaderView = searchBar;
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
}

- (void)loadTableView {
    [self loadSearchBar];
}

-(void)viewWillAppear:(BOOL)animated{
    [self loadTableView];
    [self loadDatePickerData];
}

- (void)loadplayersPL {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://games.espn.go.com/fba/freeagency?leagueId=%d&seasonId=%d&context=freeagency&view=stats&version=%@&avail=%d&sortMap=%@&slotCategoryGroup=%@&search=%@&proTeamId=%d",self.session.leagueID,self.session.seasonID,scoringPeriodPL,availability,sort,@"null",searchText,team]];
    NSData *html = [NSData dataWithContentsOfURL:url];
    parser = [TFHpple hppleWithHTMLData:html];
    NSString *XpathQueryString = @"//table[@class='playerTableTable tableBody']/tr";
    NSArray *nodes = [parser searchWithXPathQuery:XpathQueryString];
    playersPL = [[NSMutableArray alloc] init];
    for (int i = 0; i < nodes.count; i++) {
        TFHppleElement *element = nodes[i];
        if ([element objectForKey:@"id"]) {
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            NSArray <TFHppleElement *> *children = element.children;
            [dict setObject:[children[0].children[0] content] forKey:@"firstName+lastName"];
            [dict setObject:[children[0].children[1] content] forKey:@"team+position"];
            if (children[1].children.count == 4) [dict setObject:[children[0].children[2] content] forKey:@"injury"];
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
            [playersPL addObject:[[FBPlayer alloc] initWithDictionary:dict]];
        }
    }
}

#pragma mark - Table View

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return playersPL.count;
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
    [scrollView setContentSize:CGSizeMake(14*50+150, 40)];
    [scrollView setShowsHorizontalScrollIndicator:NO];
    [scrollView setShowsVerticalScrollIndicator:NO];
    [scrollView setBounces:NO];
    [cell addSubview:scrollView];
    scrollView.delegate = self;
    scrollView.tag = 1;
    [scrollView setContentOffset:CGPointMake(scrollDistancePL, 0)];
    [scrollViewsPL addObject:scrollView];
    //STATS LABELS
    NSString *arr[15] = {@"STATUS", @"FPTS", @"TOT", @"OWN", @"+/-", @"FGM", @"FGA", @"FTM", @"FTA", @"REB", @"AST", @"BLK", @"STL", @"TO", @"PTS"};
    UILabel *stats1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 40)];
    stats1.text = [NSString stringWithFormat:@"%@",arr[0]];
    stats1.textAlignment = NSTextAlignmentCenter;
    stats1.font = [UIFont boldSystemFontOfSize:17];
    [scrollView addSubview:stats1];
    for (int i = 1; i < 15; i++) {
        UILabel *stats = [[UILabel alloc] initWithFrame:CGRectMake(50*i+100, 0, 50, 40)];
        //stats.text = [NSString stringWithFormat:@"%@",arr[i]];
        NSDictionary *underlineAttribute = @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)};
        stats.attributedText = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",arr[i]]
                                                               attributes:underlineAttribute];
        stats.textAlignment = NSTextAlignmentCenter;
        stats.font = [UIFont boldSystemFontOfSize:17];
        [scrollView addSubview:stats];
    }
    //STATS BUTTONS
    for (int i = 0; i < 14; i++) {
        UIButton *refresh = [[UIButton alloc] initWithFrame:CGRectMake(50*i+150, 0, 50, 40)];
        refresh.titleLabel.text = @"";
        refresh.tag = i; //used for determining sortChoices[] index
        [refresh addTarget:self action:@selector(updateSort:) forControlEvents:UIControlEventTouchUpInside];
        [scrollView addSubview:refresh];
    }
    return cell;
}

- (void)updateSort: (UIButton *)sender {
    sort = sortChoices[sender.tag];
    sortIndex = (int)sender.tag;
    [self loadplayersPL];
    scrollViewsPL = [[NSMutableArray alloc] init];
    [self.tableView reloadData];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PlayerCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Identifier"];
    FBPlayer *player = playersPL[indexPath.row];
    cell = [[PlayerCell alloc] initWithPlayer:player view:self scrollDistance:scrollDistancePL];
    cell.delegate = self;
    return cell;
}

#pragma mark - Scroll Views

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.tag == 1) {
        scrollDistancePL = scrollView.contentOffset.x;
        for (UIScrollView *sV in scrollViewsPL) [sV setContentOffset:CGPointMake(scrollDistancePL, 0) animated:NO];
        for (NSIndexPath *path in [self.tableView indexPathsForVisibleRows])
            if ([self.tableView cellForRowAtIndexPath:path]) [(PlayerCell *)[self.tableView cellForRowAtIndexPath:path] setScrollDistance:scrollDistancePL];
    }
}

#pragma mark - Seach Bar

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    searchBar.text = @"";
    searchText = @"";
    //[self.picker selectRow:1 inComponent:0 animated:NO];
    availability = 1;
    sortIndex = 3;
    sort = sortChoices[3];
    [self loadplayersPL];
    [self.tableView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    if ([searchBar.text isEqualToString:@""]) searchText = @"null";
    else searchText = searchBar.text;
    //[self.picker selectRow:0 inComponent:0 animated:NO];
    availability = -1;
    sortIndex = 0;
    sort = sortChoices[0];
    [self loadplayersPL];
    [self.tableView reloadData];
}

#pragma mark - FBPickerView

NSMutableArray <NSArray <NSString *> *> *pickerData;

- (void)loadDatePickerData {
    pickerData = [[NSMutableArray alloc] initWithObjects:
                  [[NSArray alloc] initWithObjects:@"All", @"Available", @"On Waivers", @"Free Agents", @"On Rosters", nil],
                  [[NSArray alloc] initWithObjects:@"Last 7", @"Last 15", @"Last 30", @"Season", @"Last Season", @"Projections", nil],
                  [[NSArray alloc] initWithObjects:@"All", @"FA", @"Atl", @"Bkn", @"Bos", @"Cha", @"Chi", @"Cle", @"Dal", @"Den", @"Det", @"GS", @"Hou", @"Ind", @"LAC", @"LAL", @"Mem", @"Mia", @"Mil", @"Min", @"Nor", @"NY", @"OKC", @"Orl", @"Phi", @"Pho", @"Por", @"SA", @"Sac", @"Tor", @"Uta", @"Wsh", nil], nil];
}

- (void)fadeIn:(UIButton *)sender {
    self.navigationItem.rightBarButtonItem.enabled = NO;
    FBPickerView *picker = [FBPickerView loadViewFromNib];
    picker.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    picker.delegate = self;
    [picker resetData];
    [picker setData:pickerData[0] ForColumn:0];
    [picker setData:pickerData[1] ForColumn:1];
    [picker setData:pickerData[2] ForColumn:2];
    [picker selectIndex:1 inColumn:0];
    [picker selectIndex:1 inColumn:1];
    [picker selectIndex:0 inColumn:2];
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
    int data3 = (int)[pickerView selectedIndexForColumn:2];
    if (data1 == 0) availability = -1; //All
    if (data1 == 1) availability = 1; //Available
    if (data1 == 2) availability = 3; //On Waivers
    if (data1 == 3) availability = 2; //Free Agents
    if (data1 == 4) availability = 4; //On Rosters
    else if (data2 == 0) scoringPeriodPL = @"last7";
    else if (data2 == 1) scoringPeriodPL = @"last15";
    else if (data2 == 2) scoringPeriodPL = @"last30";
    else if (data2 == 3) scoringPeriodPL = @"currSeason";
    else if (data2 == 4) scoringPeriodPL = @"lastSeason";
    else  scoringPeriodPL = @"projections";
    int indexs[32] = {-1, 0, 1, 17, 2, 30, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 29, 14, 15, 16, 3, 18, 25, 19, 20, 21, 22, 24, 23, 28, 26, 27};
    team = indexs[data3];
    [self loadplayersPL];
    [self.tableView reloadData];
    [self fadeOutWithPickerView:pickerView];
}

- (void)cancelButtonPressedInPickerView:(FBPickerView *)pickerView {
    [self fadeOutWithPickerView:pickerView];
}

@end
