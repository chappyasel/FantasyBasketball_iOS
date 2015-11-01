//
//  PlayerViewController.m
//  FantasyBasketball
//
//  Created by Chappy Asel on 1/18/15.
//  Copyright (c) 2015 CD. All rights reserved.
//

#import "PlayerViewController.h"
#import "FBSession.h"
#import "FBPlayer.h"
#import "TFHpple.h"
#import "BEMSimpleLineGraphView.h"

@interface PlayerViewController () <BEMSimpleLineGraphDataSource, BEMSimpleLineGraphDelegate>

@property (nonatomic, strong) NSOperationQueue *imageOperationQueue;
@property (nonatomic, strong) NSCache *imageCache;

@end

@implementation PlayerViewController

bool handleError;
FBSession *session;
FBPlayer *player;
TFHpple *parser;

NSMutableArray *scrollViewsP;
float scrollDistanceP;
NSMutableArray *info;
NSMutableArray *games;
NSMutableArray *news;
NSMutableArray *rotoworld;
bool playerNotLoaded = YES;
bool needsLoadGamesButton = YES;

- (void)viewDidLoad {
    [super viewDidLoad];
    handleError = NO;
    [self loadScrollView];
    needsLoadGamesButton = YES;
    player = session.player;
    gameLogIsBasic = YES;
    self.imageOperationQueue = [[NSOperationQueue alloc]init];
    self.imageOperationQueue.maxConcurrentOperationCount = 4;
    self.imageCache = [[NSCache alloc] init];
    playerNotLoaded = YES;
    
    self.darkBackground.alpha = 0.0;
    [UIView animateWithDuration:0.3 animations:^(void) {
        self.darkBackground.alpha = 0.8;
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (playerNotLoaded) {
        [super viewDidAppear:animated];
        [self loadScrollView];
        [self loadOverview];
        [self loadPlayer];
        [self performSelector:@selector(contLoading) withObject:nil afterDelay:0];
        playerNotLoaded = NO;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    NSLog(@"PING");
}

- (void)contLoading {
    scrollViewsP = [[NSMutableArray alloc] init];
    if (parser.data != nil) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self performSelector:@selector(loadGameLogTableView) withObject:nil];
            [self performSelector:@selector(loadGraphView) withObject:nil];
            [self performSelector:@selector(loadInfoTableView) withObject:nil];
            //[self performSelector:@selector(loadStatsBasicTableView) withObject:nil];
            [self performSelector:@selector(loadRotoworldTableView) withObject:nil];
            //[self performSelector:@selector(loadStatsScrollView) withObject:nil];
            //[self performSelector:@selector(loadNewsLogTableView) withObject:nil];
            //[self performSelector:@selector(moreGames:) withObject:nil];
        });
    }
    else NSLog(@"Player not found.");
}

- (void)loadScrollView { //and its contents (tables...)
    //tab 1: Current game, Full stats, recent games overview, last rotowire, own%, news
    _gameTableView = [[UITableView alloc] initWithFrame:CGRectMake(375, 0, 375, 420)];
    _rotoworldTableView = [[UITableView alloc] initWithFrame:CGRectMake(375*2, 0, 375, 420)];
    _statsScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(375*3, 0, 375, 420)];
    _newsTableView = [[UITableView alloc] initWithFrame:CGRectMake(375*4, 0, 375, 420)];
    //_gameTableView.contentInset = UIEdgeInsetsMake(40, 0, 0, 0);
    //_newsTableView.contentInset = UIEdgeInsetsMake(40, 0, 0, 0);
    //_statsScrollView.contentInset = UIEdgeInsetsMake(40, 0, 0, 0);
    //_rotoworldTableView.contentInset = UIEdgeInsetsMake(40, 0, 0, 0);
    [_bottomScrollView addSubview:_newsTableView];
    [_bottomScrollView addSubview:_gameTableView];
    [_bottomScrollView addSubview:_statsScrollView];
    [_bottomScrollView addSubview:_rotoworldTableView];
    _bottomScrollView.contentSize = CGSizeMake(375*5, 420);
    _bottomScrollView.delegate = self;
    [self.view bringSubviewToFront:_titleView];
}

- (void)loadOverview {
    _infoTableView.delegate = self;
    _infoTableView.dataSource = self;
    _statsBasicTableView.delegate = self;
    _statsBasicTableView.dataSource = self;
    _gamesBasicTableView.delegate = self;
    _gamesBasicTableView.dataSource = self;
    _gamesBasicTableView.userInteractionEnabled = NO;
    _statsBasicTableView.userInteractionEnabled = NO;
}

- (void)loadPlayer {
    bool playerFound = NO;
    NSString *url = [NSString stringWithFormat:@"http://espn.go.com/nba/players/_/search/%@",[player.lastName stringByReplacingOccurrencesOfString:@" " withString:@"_"]];
    NSData *html = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
    parser = [TFHpple hppleWithHTMLData:html];
    if ([[[[parser searchWithXPathQuery:@"//h1[@class='h2']"] firstObject] content] containsString:@"NBA Player Search -"]) { //couldnt find player first try
        NSLog(@"Could not Find player, looking deeper...");
        for (TFHppleElement *p in [parser searchWithXPathQuery:@"//table[@class='tablehead']/tr"]) {
            if (![[p objectForKey:@"class"] isEqual:@"stathead"] && ![[p objectForKey:@"class"] isEqual:@"colhead"]) {
                NSArray *name = [p.firstChild.firstChild.content componentsSeparatedByString:@", "];
                if ([name[1] containsString:player.firstName]) { //player found
                    parser = [TFHpple hppleWithHTMLData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[p.firstChild.firstChild objectForKey:@"href"]]]];
                    NSLog(@"Found player");
                    playerFound = YES;
                    break;
                }
            }
        }
    }
    else playerFound = YES;
    if (!playerFound) {
        handleError = YES;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Player Not Found"
                                                        message:@"The requested player was not found on ESPNs server. This is likely a frontend error."
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    //name, team
    _playerNameDisplay.text = [[[parser searchWithXPathQuery:@"//div[@class='mod-content']/h1"] firstObject] content];
    _playerTeamDisplay.text = [[[parser searchWithXPathQuery:@"//ul[@class='general-info']/li[@class='last']/a"] firstObject] content];
    //stats
    NSArray *seasonStats = [[[parser searchWithXPathQuery:@"//table[@class='header-stats']/tr"] firstObject] children];
    if (seasonStats.count > 2) {
        _seasonDisplay1.text = [seasonStats[0] content];
        _seasonDisplay2.text = [seasonStats[1] content];
        _seasonDisplay3.text = [seasonStats[2] content];
    }
    NSArray *careerStats = [[[parser searchWithXPathQuery:@"//table[@class='header-stats']/tr[@class='career']"] firstObject] children];
    if (careerStats.count > 2) {
        _careerDisplay1.text = [careerStats[0] content];
        _careerDisplay2.text = [careerStats[1] content];
        _careerDisplay3.text = [careerStats[2] content];
    }
    NSArray *statNames = [[[parser searchWithXPathQuery:@"//table[@class='header-stats']/thead"] firstObject] children];
    if (statNames.count > 2) {
        for (UILabel *label in _statSlot1Header) label.text = [statNames[0] content];
        for (UILabel *label in _statSlot2Header) label.text = [statNames[1] content];
        for (UILabel *label in _statSlot3Header) label.text = [statNames[2] content];
    }
    //player image
    TFHppleElement *link = [[parser searchWithXPathQuery:@"//div[@class='main-headshot']/img"] firstObject];
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[link objectForKey:@"src"]]]];
    _playerImageView.image = image;
    //team image
    UIImageView *teamImage = [[UIImageView alloc] initWithFrame:CGRectMake(-10, 110, 100, 100*(1/1.25))];
    teamImage.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://a2.espncdn.com/prod/assets/clubhouses/2010/nba/teamlogos/%@.png",player.team]]]];
    teamImage.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:teamImage];
    [self.view sendSubviewToBack:teamImage];
}

- (void)loadGameLogTableView {
    if (handleError) return;
    _gameTableView.delegate = self;
    _gameTableView.dataSource = self;
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 375, 40)];
    UISegmentedControl *segControl = [[UISegmentedControl alloc] initWithFrame:CGRectMake(50, 5.5, 314, 29)];
    segControl.tintColor = [UIColor lightGrayColor];
    [segControl insertSegmentWithTitle:@"Simple" atIndex:0 animated:NO];
    [segControl insertSegmentWithTitle:@"Detail" atIndex:1 animated:NO];
    [segControl setSelectedSegmentIndex:0];
    [segControl addTarget:self action:@selector(changeGameLogStyle:) forControlEvents:UIControlEventValueChanged];
    [headerView addSubview:segControl];
    _gameTableView.tableHeaderView = headerView;
    //game log
    [self parseGamesWithParser:parser];
    [_gameTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
}

- (void)loadGraphView {
    _graphView = [[BEMSimpleLineGraphView alloc] initWithFrame:CGRectMake(0, 0, _graphContainerView.frame.size.width, _graphContainerView.frame.size.height)];
    _graphView.delegate = self;
    _graphView.dataSource = self;
    _graphView.enableBezierCurve = YES;
    _graphView.averageLine.enableAverageLine = YES;
    _graphView.averageLine.width = 1;
    _graphView.averageLine.alpha = 0.6;
    _graphView.averageLine.color = [UIColor grayColor];
    _graphView.colorLine = [UIColor lightGrayColor];
    _graphView.colorPoint = [UIColor lightGrayColor];
    _graphView.colorTop = [UIColor whiteColor];
    _graphView.colorBottom = [UIColor lightGrayColor];
    _graphView.colorBackgroundXaxis = [UIColor whiteColor];
    _graphView.alphaBottom = 0.15;
    _graphView.enableYAxisLabel = YES;
    _graphView.enablePopUpReport = YES;
    _graphView.widthLine = 2.0;
    _graphView.alwaysDisplayDots = YES;
    _graphView.autoScaleYAxis = YES;
    _graphView.animationGraphEntranceTime = 1.0;
    
    [_graphContainerView addSubview:_graphView];
}

bool gameLogIsBasic = YES;

- (void)changeGameLogStyle: (UISegmentedControl *)sender {
    if (sender.selectedSegmentIndex == 0) gameLogIsBasic = YES;
    else gameLogIsBasic = NO;
    [_gameTableView reloadData];
}

- (void)loadInfoTableView {
    _infoTableView.pagingEnabled = YES;
    _infoTableView.showsVerticalScrollIndicator = NO;
    info = [[NSMutableArray alloc] init];
    NSArray *infoRaw = [parser searchWithXPathQuery:@"//div[@class='player-bio']/ul"];
    for (TFHppleElement *e in infoRaw) {
        if ([[e objectForKey:@"class"] isEqualToString:@"general-info"]) {
            NSString *final;
            for (TFHppleElement *c in e.children)
                if (![[c objectForKey:@"class"] isEqualToString:@"last"])
                    final = [NSString stringWithFormat:@"%@ %@",final,c.content];
            final = [final stringByReplacingOccurrencesOfString:@"(null) " withString:@""];
            [info addObject:final];
        }
        else if ([[e objectForKey:@"class"] isEqualToString:@"player-metadata floatleft"]) {
            for (TFHppleElement *c in e.children) {
                if ([c.content containsString:@"Experience"]) {
                    NSString *final = [c.content stringByReplacingOccurrencesOfString:@"Experience" withString:@", Experience: "];
                    if (info.count >= 4) [info replaceObjectAtIndex:3 withObject:[NSString stringWithFormat:@"%@ %@",info[3],final]];
                    else [info replaceObjectAtIndex:0 withObject:[NSString stringWithFormat:@"%@ %@",info[0],final]];
                }
                else {
                    NSString *final = [c.content stringByReplacingOccurrencesOfString:@"Born" withString:@"Born: "];
                    final = [final stringByReplacingOccurrencesOfString:@"Drafted" withString:@"Drafted: "];
                    final = [final stringByReplacingOccurrencesOfString:@"College" withString:@"College: "];
                    [info addObject:final];
                }
            }
        }
    }
    [_infoTableView reloadData];
}

- (void)loadStatsBasicTableView {
    [_statsBasicTableView reloadData];
}

- (void)loadStatsScrollView {
    
}

- (void)loadRotoworldTableView {
    _rotoworldTableView.delegate = self;
    _rotoworldTableView.dataSource = self;
    rotoworld = [[NSMutableArray alloc] init];
    TFHpple *statParser = [[TFHpple alloc] initWithHTMLData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.rotoworld.com/content/playersearch.aspx?searchname=%@,%@&sport=nba",player.lastName,player.firstName]]]];
    NSString *rotoworldLink = [[[statParser searchWithXPathQuery:@"//div[@class='moreplayernews']/a"] firstObject] objectForKey:@"href"];
    TFHpple *rotoParser = [[TFHpple alloc] initWithHTMLData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.rotoworld.com%@",rotoworldLink]]]];
    NSArray *data = [rotoParser searchWithXPathQuery:@"//div[@class='RW_pn']/div[@class='pb']/div[@style='width:460px; float:left;']"];
    for (TFHppleElement *e in data) {
        NSMutableDictionary *rotoPeice = [[NSMutableDictionary alloc] init];
        for (TFHppleElement *c in e.children) {
            if ([[c objectForKey:@"class"] isEqualToString:@"report"]) {
                NSString *tmp = [c.content stringByReplacingOccurrencesOfString:@"\r" withString:@""];
                tmp = [tmp stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                tmp = [tmp stringByReplacingOccurrencesOfString:@"  " withString:@""];
                [rotoPeice setObject:tmp forKey:@"report"];
            }
            if ([[c objectForKey:@"class"] isEqualToString:@"impact"]) {
                NSString *tmp = [c.content stringByReplacingOccurrencesOfString:@"\r" withString:@""];
                tmp = [tmp stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                tmp = [tmp stringByReplacingOccurrencesOfString:@"  " withString:@""];
                [rotoPeice setObject:tmp forKey:@"impact"];
            }
            if ([[c objectForKey:@"class"] isEqualToString:@"info"]) {
                [rotoPeice setObject:[[[c childrenWithClassName:@"date"] firstObject] content] forKey:@"date"];
                [rotoPeice setObject:[[[c childrenWithClassName:@"source"] firstObject] content] forKey:@"source"];
                [rotoPeice setObject:[[[c childrenWithClassName:@"related"] firstObject] content] forKey:@"related"];
            }
        }
        [rotoworld addObject:rotoPeice];
    }
    TFHppleElement *e = [[rotoParser searchWithXPathQuery:@"//div[@class='pp']/div[@class='playernews']"] firstObject];
    NSMutableDictionary *rotoPeice = [[NSMutableDictionary alloc] init];
    for (TFHppleElement *c in e.children) {
        if ([[c objectForKey:@"class"] isEqualToString:@"report"]) {
            NSString *tmp = [c.content stringByReplacingOccurrencesOfString:@"\r" withString:@""];
            tmp = [tmp stringByReplacingOccurrencesOfString:@"\n" withString:@""];
            tmp = [tmp stringByReplacingOccurrencesOfString:@"  " withString:@""];
            [rotoPeice setObject:tmp forKey:@"report"];
        }
        if ([[c objectForKey:@"class"] isEqualToString:@"impact"]) {
            NSString *tmp = [c.firstChild.content stringByReplacingOccurrencesOfString:@"\r" withString:@""];
            tmp = [tmp stringByReplacingOccurrencesOfString:@"\n" withString:@""];
            tmp = [tmp stringByReplacingOccurrencesOfString:@"  " withString:@""];
            [rotoPeice setObject:tmp forKey:@"impact"];
            [rotoPeice setObject:[c.children[1] content] forKey:@"date"];
        }
    }
    [rotoworld insertObject:rotoPeice atIndex:0];
    [_rotoworldTableView reloadData];
}

- (void)parseGamesWithParser: (TFHpple *)parse {
    //game log
    NSArray *tables = [parse searchWithXPathQuery:@"//div/table[@class='tablehead']"];
    TFHppleElement *table = nil;
    for (TFHppleElement *tble in tables) {
        if([[tble content] containsString:@"OPPSCOREMIN"]) { table = tble; break; } }
    NSMutableArray *rawGames = [[NSMutableArray alloc] init];
    if (table) { //error checking
        for (TFHppleElement *gameT in table.children) {
            if (![[gameT objectForKey:@"class"] isEqual:@"colhead"] &&
                ![[gameT objectForKey:@"class"] isEqual:@"total"] &&
                ![[gameT objectForKey:@"class"] isEqual:@"stathead"]) {
                NSMutableArray *game = [[NSMutableArray alloc] init];
                for (TFHppleElement *stat in gameT.children) [game addObject:stat.content];
                [rawGames addObject:game];
            }
            else if ([[gameT objectForKey:@"class"] isEqual:@"colhead"])
                if ([[gameT.children.firstObject content] containsString:@"REGULAR SEASON STATS"]) break; //end of reg season
        }
    }
    games = [[NSMutableArray alloc] init];
    for (NSMutableArray *rawGame in rawGames) {
        if (rawGame.count > 16) {
            NSArray *fg = [rawGame[4] componentsSeparatedByString:@"-"];
            NSArray *tp = [rawGame[6] componentsSeparatedByString:@"-"];
            NSArray *ft = [rawGame[8] componentsSeparatedByString:@"-"];
            NSMutableArray *game = [[NSMutableArray alloc] initWithObjects:rawGame[0],
                                    [NSString stringWithFormat:@"%@: %@", rawGame[1], rawGame[2]],
                                    [NSNumber numberWithLong:[rawGame[3] integerValue]],
                                    [NSNumber numberWithLong:[fg[0] integerValue]],
                                    [NSNumber numberWithLong:[fg[1] integerValue]],
                                    [NSNumber numberWithLong:[tp[0] integerValue]],
                                    [NSNumber numberWithLong:[tp[1] integerValue]],
                                    [NSNumber numberWithLong:[ft[0] integerValue]],
                                    [NSNumber numberWithLong:[ft[1] integerValue]],
                                    [NSNumber numberWithLong:[rawGame[10] integerValue]],
                                    [NSNumber numberWithLong:[rawGame[11] integerValue]],
                                    [NSNumber numberWithLong:[rawGame[12] integerValue]],
                                    [NSNumber numberWithLong:[rawGame[13] integerValue]],
                                    [NSNumber numberWithLong:[rawGame[14] integerValue]],
                                    [NSNumber numberWithLong:[rawGame[15] integerValue]],
                                    [NSNumber numberWithLong:[rawGame[16] integerValue]], nil];
            [game insertObject:[NSNumber numberWithLong:[game[3] longValue]-[game[4] longValue]+[game[7] longValue]-[game[8] longValue]-
                                [game[14] longValue]+[game[15] longValue]+[game[12] longValue]+[game[11] longValue]+[game[10] longValue]+
                                [game[9] longValue]] atIndex:2]; //fpts
            [games addObject:game];
        }
    }
    [_gamesBasicTableView reloadData];
    [_gameTableView reloadData];
    [_graphView reloadGraph];
}

- (void)moreGames:(UIButton *)sender {
    needsLoadGamesButton = NO;
    NSArray *results = [parser searchWithXPathQuery:@"//div[@class='mod-content']/p[@class='footer']/a"];
    NSString *link = @"";
    for (TFHppleElement *e in results) if ([e.content containsString:@"Game Log"]) link = [e objectForKey:@"href"];
    NSString *url = [NSString stringWithFormat:@"http://espn.go.com%@",link];
    NSData *html = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
    TFHpple *parser2 = [TFHpple hppleWithHTMLData:html];
    [self parseGamesWithParser:parser2];
}

- (void)loadNewsLogTableView {
    _newsTableView.delegate = self;
    _newsTableView.dataSource = self;
    //news
    news = [[NSMutableArray alloc] init];
    NSArray *newsRaw = [parser searchWithXPathQuery:@"//div[@id='default-tab']/ol/li"];
    for (TFHppleElement *element in newsRaw) {
        NSMutableDictionary *newsPeice = [[NSMutableDictionary alloc] init];
        for (TFHppleElement *part in element.children) {
            if ([[part tagName] isEqual:@"p"]) { //contents
                [newsPeice setObject:part.content forKey:@"text"];
            }
            else if ([[part tagName] isEqual:@"h3"]) { //link, title
                if ([[[part childrenWithTagName:@"a"] firstObject] objectForKey:@"href"]) [newsPeice setObject:[[[part childrenWithTagName:@"a"] firstObject] objectForKey:@"href"] forKey:@"link"];
                [newsPeice setObject:[part content] forKey:@"title"];
            }
            else if ([[part tagName] isEqual:@"a"]) { //image
                TFHppleElement *i = [[part childrenWithTagName:@"img"] firstObject];
                if ([i objectForKey:@"src"]) [newsPeice setObject:[i objectForKey:@"src"] forKey:@"image"];
            }
            else if ([[part tagName] isEqual:@"cite"]) { //time
                [newsPeice setObject:[part content] forKey:@"time"];
            }
        }
        if (newsPeice.count > 0) [news addObject:newsPeice];
    }
    [_newsTableView reloadData];
}

#pragma mark - Table View Delegate Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (handleError) return 0;
    if (tableView == _infoTableView) return info.count;
    if (tableView == _statsBasicTableView) return 2;
    if (tableView == _gamesBasicTableView) return 3;
    if (tableView == _gameTableView && needsLoadGamesButton) return games.count+1;
    if (tableView == _gameTableView) return games.count;
    if (tableView == _rotoworldTableView) return rotoworld.count;
    return news.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (tableView == _gameTableView) return 40;
    if (tableView == _gamesBasicTableView ||
        tableView == _statsBasicTableView) return 40;
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == _infoTableView) return 30;
    if (tableView == _statsBasicTableView ||
        tableView == _gamesBasicTableView) return 40;
    if (tableView == _gameTableView && needsLoadGamesButton) return 40;
    if (tableView == _gameTableView) return 30;
    if (tableView == _rotoworldTableView) {
        NSString *text = [NSString stringWithFormat:@"%@ %@",[rotoworld[indexPath.row] objectForKey:@"report"],[rotoworld[indexPath.row] objectForKey:@"impact"]];
        UIFont *font = [UIFont systemFontOfSize:15];
        NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:text attributes:@ {NSFontAttributeName: font}];
        CGRect rect = [attributedText boundingRectWithSize:(CGSize){375-20.0, CGFLOAT_MAX} options:NSStringDrawingUsesLineFragmentOrigin context:nil];
        return (CGFloat)rect.size.height+30;
    }
    return 120;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (tableView == _gameTableView) {
        if (gameLogIsBasic) {
            UIView *cell = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _gameTableView.frame.size.width, 40)];
            cell.backgroundColor = [UIColor lightGrayColor];
            //   165   |      210
            //65 50 50 | 42 42 42 42 42
            NSString *arr[8] = {@"DATE", @"FPTS", @"MIN", @"REB", @"AST", @"BLK", @"STL", @"PTS"};
            for (int i = 0; i < 8; i++) {
                UILabel *stats;
                if (i == 0) stats = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 65, 40)];
                else if (i == 1 || i == 2) stats = [[UILabel alloc] initWithFrame:CGRectMake(i*50+15, 0, 50, 40)];
                else stats = [[UILabel alloc] initWithFrame:CGRectMake(42*i-126+165, 0, 42, 40)];
                stats.text = [NSString stringWithFormat:@"%@",arr[i]];
                stats.font = [UIFont boldSystemFontOfSize:17];
                stats.textAlignment = NSTextAlignmentCenter;
                [cell addSubview:stats];
            }
            return cell;
        }
        else {
            UIView *cell = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _gameTableView.frame.size.width, 40)];
            cell.backgroundColor = [UIColor lightGrayColor];
            //STATS SCROLLVIEW
            UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, _gameTableView.frame.size.width, 40)];
            [scrollView setContentSize:CGSizeMake(16*50+100, 40)];
            [scrollView setShowsHorizontalScrollIndicator:NO];
            [scrollView setShowsVerticalScrollIndicator:NO];
            [scrollView setBounces:NO];
            [cell addSubview:scrollView];
            scrollView.delegate = self;
            scrollView.tag = 2; //for 2nd seperate table
            [scrollView setContentOffset:CGPointMake(scrollDistanceP, 0)];
            [scrollViewsP addObject:scrollView];
            //STATS LABELS
            NSString *arr[17] = {@"DATE", @"GAME", @"FPTS", @"MIN", @"FGM", @"FGA", @"3PM", @"3PA", @"FTM", @"FTA", @"REB", @"AST", @"BLK", @"STL", @"PF", @"TO", @"PTS"};
            for (int i = 0; i < 17; i++) {
                UILabel *stats;
                if (i == 0) stats = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
                else if (i == 1) stats = [[UILabel alloc] initWithFrame:CGRectMake(100, 0, 150, 40)];
                else stats = [[UILabel alloc] initWithFrame:CGRectMake(50*i+150, 0, 50, 40)];
                stats.text = [NSString stringWithFormat:@"%@",arr[i]];
                stats.font = [UIFont boldSystemFontOfSize:17];
                stats.textAlignment = NSTextAlignmentCenter;
                [scrollView addSubview:stats];
            }
            return cell;
        }
    }
    if (tableView == _gamesBasicTableView) {
        UIView *cell = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _gameTableView.frame.size.width, 40)];
        cell.backgroundColor = [UIColor lightGrayColor];
        //   165   |      210
        //65 50 50 | 42 42 42 42 42
        NSString *arr[8] = {@"DATE", @"FPTS", @"MIN", @"REB", @"AST", @"BLK", @"STL", @"PTS"};
        for (int i = 0; i < 8; i++) {
            UILabel *stats;
            if (i == 0) stats = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 65, 40)];
            else if (i == 1 || i == 2) stats = [[UILabel alloc] initWithFrame:CGRectMake(i*50+15, 0, 50, 40)];
            else stats = [[UILabel alloc] initWithFrame:CGRectMake(42*i-126+165, 0, 42, 40)];
            stats.text = [NSString stringWithFormat:@"%@",arr[i]];
            stats.font = [UIFont boldSystemFontOfSize:17];
            stats.textAlignment = NSTextAlignmentCenter;
            [cell addSubview:stats];
        }
        return cell;
    }
    if (tableView == _statsBasicTableView) {
        UIView *cell = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _gameTableView.frame.size.width, 40)];
        cell.backgroundColor = [UIColor lightGrayColor];
        //STATS SCROLLVIEW
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, _gameTableView.frame.size.width, 40)];
        [scrollView setContentSize:CGSizeMake(16*50+100, 40)];
        [scrollView setShowsHorizontalScrollIndicator:NO];
        [scrollView setShowsVerticalScrollIndicator:NO];
        [scrollView setBounces:NO];
        [cell addSubview:scrollView];
        scrollView.delegate = self;
        scrollView.tag = 2; //for 2nd seperate table
        [scrollView setContentOffset:CGPointMake(scrollDistanceP, 0)];
        [scrollViewsP addObject:scrollView];
        //STATS LABELS
        NSString *arr[16] = {@"FPTS", @"GP", @"MIN", @"FGM", @"FGA", @"3PM", @"3PA", @"FTM", @"FTA", @"REB", @"AST", @"BLK", @"STL", @"PF", @"TO", @"PTS"};
        for (int i = 0; i < 16; i++) {
            UILabel *stats;
            stats = [[UILabel alloc] initWithFrame:CGRectMake(50*i+100, 0, 50, 40)];
            stats.text = [NSString stringWithFormat:@"%@",arr[i]];
            stats.font = [UIFont boldSystemFontOfSize:17];
            stats.textAlignment = NSTextAlignmentCenter;
            [scrollView addSubview:stats];
        }
        return cell;
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == _infoTableView) {
        static NSString *MyIdentifier = @"MyIdentifier";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
        cell = nil;
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyIdentifier];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 375-15, 30)];
        label.text = info[indexPath.row];
        label.font = [UIFont systemFontOfSize:15];
        [cell addSubview:label];
        return cell;
    }
    if (tableView == _statsBasicTableView) {
        static NSString *MyIdentifier = @"MyIdentifier";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
        cell = nil;
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyIdentifier];
        if (indexPath.row == 0) { //season
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 85, 40)];
            label.text = @"Season";
            [cell addSubview:label];
        }
        else { //career
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 85, 40)];
            label.text = @"Career";
            [cell addSubview:label];
        }
        return cell;
    }
    if (tableView == _gameTableView) {
        if (gameLogIsBasic) {
            //       0    1    2    3   4   5   6   7   8   9  10  11  12  13  14 15 16
            //game: date game fpts min fgm fga 3pm 3pa ftm fta reb ast blk stl pf to pts
            //   165   |      210
            //65 50 50 | 42 42 42 42 42
            static NSString *MyIdentifier = @"MyIdentifier";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
            cell = nil;
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyIdentifier];
            float height = 30.0;
            if (needsLoadGamesButton) height = 40.0;
            if (indexPath.row == games.count && needsLoadGamesButton) { //last row
                UIButton *more = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 375, 40)];
                [more setTitle:@"Load More Games" forState:UIControlStateNormal];
                [more addTarget:self action:@selector(moreGames:) forControlEvents:UIControlEventTouchUpInside];
                [more setTitleColor:[UIColor colorWithRed:0 green:0.478431 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
                [cell addSubview:more];
            }
            else {
                NSMutableArray *game = games[indexPath.row];
                if (game) {
                    for (int i = 0; i < 8; i++) {
                        UILabel *stats;
                        if (i == 0) stats = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 65, 40)];
                        else if (i == 1 || i == 2) stats = [[UILabel alloc] initWithFrame:CGRectMake(i*50+15, 0, 50, 40)];
                        else stats = [[UILabel alloc] initWithFrame:CGRectMake(42*i-126+165, 0, 42, 40)];
                        if (i==0)      stats.text = [NSString stringWithFormat:@"%@",[[game[0] componentsSeparatedByString:@" "] lastObject]];
                        else if (i==1) stats.text = [NSString stringWithFormat:@"%@",game[2]];
                        else if (i==2) stats.text = [NSString stringWithFormat:@"%@",game[3]];
                        else if (i==3) stats.text = [NSString stringWithFormat:@"%@",game[10]];
                        else if (i==4) stats.text = [NSString stringWithFormat:@"%@",game[11]];
                        else if (i==5) stats.text = [NSString stringWithFormat:@"%@",game[12]];
                        else if (i==6) stats.text = [NSString stringWithFormat:@"%@",game[13]];
                        else           stats.text = [NSString stringWithFormat:@"%@",game[16]];
                        stats.font = [UIFont systemFontOfSize:17];
                        stats.textAlignment = NSTextAlignmentCenter;
                        [cell addSubview:stats];
                    }
                }
            }
            return cell;
        }
        else {
            static NSString *MyIdentifier = @"MyIdentifier";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
            cell = nil;
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyIdentifier];
            float height = 30.0;
            if (needsLoadGamesButton) height = 40.0;
            if (indexPath.row == games.count && needsLoadGamesButton) { //last row
                UIButton *more = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 375, 40)];
                [more setTitle:@"Load More Games" forState:UIControlStateNormal];
                [more addTarget:self action:@selector(moreGames:) forControlEvents:UIControlEventTouchUpInside];
                [more setTitleColor:[UIColor colorWithRed:0 green:0.478431 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
                [cell addSubview:more];
            }
            else {
                NSMutableArray *game = games[indexPath.row];
                //STATS SCROLLVIEW
                UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, _gameTableView.frame.size.width, height)];
                [scrollView setContentSize:CGSizeMake(17*50+150, height)];
                [scrollView setShowsHorizontalScrollIndicator:NO];
                [scrollView setShowsVerticalScrollIndicator:NO];
                [scrollView setBounces:NO];
                [cell addSubview:scrollView];
                scrollView.delegate = self;
                scrollView.tag = 1;
                [scrollView setContentOffset:CGPointMake(scrollDistanceP, 0)];
                [scrollViewsP addObject:scrollView];
                for (int i = 0; i < 17; i++) {
                    UILabel *stats;
                    if (i == 0) stats = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, height)];
                    else if (i == 1) stats = [[UILabel alloc] initWithFrame:CGRectMake(100, 0, 150, height)];
                    else stats = [[UILabel alloc] initWithFrame:CGRectMake(50*i+150, 0, 50, height)];
                    stats.text = [NSString stringWithFormat:@"%@",game[i]];
                    stats.textAlignment = NSTextAlignmentCenter;
                    [scrollView addSubview:stats];
                }
            }
            return cell;
        }
    }
    else if (tableView == _gamesBasicTableView) {
        //       0    1    2    3   4   5   6   7   8   9  10  11  12  13  14 15 16
        //game: date game fpts min fgm fga 3pm 3pa ftm fta reb ast blk stl pf to pts
        //   165   |      210
        //65 50 50 | 42 42 42 42 42
        static NSString *MyIdentifier = @"MyIdentifier";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
        cell = nil;
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyIdentifier];
        NSMutableArray *game = games[indexPath.row];
        if (game!= nil) {
            for (int i = 0; i < 8; i++) {
                UILabel *stats;
                if (i == 0) stats = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 65, 40)];
                else if (i == 1 || i == 2) stats = [[UILabel alloc] initWithFrame:CGRectMake(i*50+15, 0, 50, 40)];
                else stats = [[UILabel alloc] initWithFrame:CGRectMake(42*i-126+165, 0, 42, 40)];
                if (i==0)      stats.text = [NSString stringWithFormat:@"%@",[[game[0] componentsSeparatedByString:@" "] lastObject]];
                else if (i==1) stats.text = [NSString stringWithFormat:@"%@",game[2]];
                else if (i==2) stats.text = [NSString stringWithFormat:@"%@",game[3]];
                else if (i==3) stats.text = [NSString stringWithFormat:@"%@",game[10]];
                else if (i==4) stats.text = [NSString stringWithFormat:@"%@",game[11]];
                else if (i==5) stats.text = [NSString stringWithFormat:@"%@",game[12]];
                else if (i==6) stats.text = [NSString stringWithFormat:@"%@",game[13]];
                else           stats.text = [NSString stringWithFormat:@"%@",game[16]];
                stats.font = [UIFont systemFontOfSize:17];
                stats.textAlignment = NSTextAlignmentCenter;
                [cell addSubview:stats];
            }
        }
        return cell;
    }
    else if (tableView == _rotoworldTableView) {
        static NSString *MyIdentifier = @"MyIdentifier";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
        cell = nil;
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyIdentifier];
        NSMutableDictionary *rotoPeice = rotoworld[indexPath.row];
        float height = [self tableView:_rotoworldTableView heightForRowAtIndexPath:indexPath];
        //start
        UILabel *text = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 375-20, height-25)];
        text.text = [NSString stringWithFormat:@"%@ %@",[rotoPeice objectForKey:@"report"],[rotoPeice objectForKey:@"impact"]];
        text.font = [UIFont systemFontOfSize:15];
        text.numberOfLines = (int)(text.frame.size.height/text.font.lineHeight);
        [cell addSubview:text];
        UILabel *extra = [[UILabel alloc] initWithFrame:CGRectMake(10, height-20, 205, 15)];
        extra.text = [NSString stringWithFormat:@"%@ %@",[rotoPeice objectForKey:@"source"],[rotoPeice objectForKey:@"related"]];
        extra.textColor = [UIColor lightGrayColor];
        extra.font = [UIFont systemFontOfSize:13];
        [cell addSubview:extra];
        UILabel *time = [[UILabel alloc] initWithFrame:CGRectMake(225, height-20, 140, 15)];
        time.text = [rotoPeice objectForKey:@"date"];
        time.textColor = [UIColor lightGrayColor];
        time.font = [UIFont systemFontOfSize:13];
        time.textAlignment = NSTextAlignmentRight;
        [cell addSubview:time];
        return cell;
    }
    else if (tableView == _newsTableView){
        //text, link, title, image, time
        static NSString *MyIdentifier = @"MyIdentifier";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
        cell = nil;
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyIdentifier];
        NSMutableDictionary *newsPeice = news[indexPath.row];
        int x = 0;
        if ([newsPeice objectForKey:@"image"]) {
            x = 100;
            UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(10, 30, 90, 80)];
            image.contentMode = UIViewContentModeScaleAspectFit;
            UIImage *imageFromCache = [self.imageCache objectForKey:[newsPeice objectForKey:@"image"]];
            if (imageFromCache) image.image = imageFromCache;
            else {
                [self.imageOperationQueue addOperationWithBlock:^{
                    NSURL *imageurl = [NSURL URLWithString:[newsPeice objectForKey:@"image"]];
                    UIImage *img = [UIImage imageWithData:[NSData dataWithContentsOfURL:imageurl]];
                    if (img != nil) {
                        [self.imageCache setObject:img forKey:[newsPeice objectForKey:@"image"]];
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                            UITableViewCell *updateCell = (UITableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
                            if (updateCell) {
                                image.image = img;
                                [updateCell addSubview:image];
                            }
                        }];
                    }
                }];
            }
            //image.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:]]];
            [cell addSubview:image];
        }
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 375-10, 20)];
        title.text = [newsPeice objectForKey:@"title"];
        if (![newsPeice objectForKey:@"title"]) title.text = @"Rotowire Player Update";
        title.font = [UIFont boldSystemFontOfSize:16];
        [cell addSubview:title];
        UILabel *text = [[UILabel alloc] initWithFrame:CGRectMake(10+x, 15, 375-20-x, 90)];
        text.text = [newsPeice objectForKey:@"text"];
        text.numberOfLines = 4;
        text.font = [UIFont systemFontOfSize:15];
        [cell addSubview:text];
        UILabel *time = [[UILabel alloc] initWithFrame:CGRectMake(110, 100, 375-120, 15)];
        time.text = [newsPeice objectForKey:@"time"];
        time.textColor = [UIColor lightGrayColor];
        time.font = [UIFont systemFontOfSize:12];
        time.textAlignment = NSTextAlignmentRight;
        [cell addSubview:time];
        return cell;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (tableView == _newsTableView) {
        NSMutableDictionary *newsPeice = news[indexPath.row];
        if ([newsPeice objectForKey:@"link"]) {
            session.link = [newsPeice objectForKey:@"link"];
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UIViewController *viewController = (UIViewController *)[storyboard instantiateViewControllerWithIdentifier:@"w"];
            [self presentViewController:viewController animated:YES completion:nil];
        }
        else {
            [self tab3Pressed:nil];
        }
    }
}

#pragma mark - BEMSimpleGraphView Delegate Methods

- (NSInteger)numberOfYAxisLabelsOnLineGraph:(BEMSimpleLineGraphView *)graph {
    return 2;
}

- (NSInteger)numberOfGapsBetweenLabelsOnLineGraph:(nonnull BEMSimpleLineGraphView *)graph {
    return 4;
}

int numGraphPoints;

- (NSInteger)numberOfPointsInLineGraph:(BEMSimpleLineGraphView *)graph {
    numGraphPoints = (games.count < 15) ? (int)games.count : 15;
    _graphNameDisplay.text = [NSString stringWithFormat:@"Fanstasy Points (Last %d games)",numGraphPoints];
    return numGraphPoints;
}

- (CGFloat)lineGraph:(BEMSimpleLineGraphView *)graph valueForPointAtIndex:(NSInteger)index {
    return (CGFloat)[games[numGraphPoints-index-1][2] intValue];
}

- (NSString *)lineGraph:(BEMSimpleLineGraphView *)graph labelOnXAxisForIndex:(NSInteger)index {
    return (NSString *)games[numGraphPoints-index-1][0];
}

- (CGFloat)baseValueForYAxisOnLineGraph:(nonnull BEMSimpleLineGraphView *)graph {
    return 0;
}

- (CGFloat)incrementValueForYAxisOnLineGraph:(nonnull BEMSimpleLineGraphView *)graph {
    return 40;
}

- (CGFloat)maxValueForLineGraph:(BEMSimpleLineGraphView *)graph {
    return 40;
}

- (CGFloat)minValueForLineGraph:(nonnull BEMSimpleLineGraphView *)graph {
    return 0;
}

#pragma mark - Scroll Views

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.tag == 1) {
        for (UIScrollView *sV in scrollViewsP) [sV setContentOffset:CGPointMake(scrollView.contentOffset.x, 0) animated:NO];
        scrollDistanceP = scrollView.contentOffset.x;
    }
    else if (scrollView == _bottomScrollView){
        float dist = scrollView.contentOffset.x/375;
        if (dist <= 1.0) { //between 1,2
            _scrollIndicator.frame = CGRectMake(_tabButton1.frame.origin.x+(_tabButton2.frame.origin.x-_tabButton1.frame.origin.x)*dist, 37, _tabButton1.frame.size.width+(_tabButton2.frame.size.width-_tabButton1.frame.size.width)*dist, 3);
        }
        else if (dist <= 2.0) { //between 2,3
            _scrollIndicator.frame = CGRectMake(_tabButton2.frame.origin.x+(_tabButton3.frame.origin.x-_tabButton2.frame.origin.x)*(dist-1), 37, _tabButton2.frame.size.width+(_tabButton3.frame.size.width-_tabButton2.frame.size.width)*(dist-1), 3);
        }
        else if (dist <= 3.0){ //between 3,4
            _scrollIndicator.frame = CGRectMake(_tabButton3.frame.origin.x+(_tabButton4.frame.origin.x-_tabButton3.frame.origin.x)*(dist-2), 37, _tabButton3.frame.size.width+(_tabButton4.frame.size.width-_tabButton3.frame.size.width)*(dist-2), 3);
        }
        else { //between 4,5
            _scrollIndicator.frame = CGRectMake(_tabButton4.frame.origin.x+(_tabButton5.frame.origin.x-_tabButton4.frame.origin.x)*(dist-3), 37, _tabButton4.frame.size.width+(_tabButton5.frame.size.width-_tabButton4.frame.size.width)*(dist-3), 3);
        }
    }
}

- (IBAction)tab1Pressed:(UIButton *)sender {
    [_bottomScrollView scrollRectToVisible:CGRectMake(0, 0, 375, 1) animated:YES];
}

- (IBAction)tab2Pressed:(UIButton *)sender {
    [_bottomScrollView scrollRectToVisible:CGRectMake(375, 0, 375, 1) animated:YES];
}

- (IBAction)tab3Pressed:(UIButton *)sender {
    [_bottomScrollView scrollRectToVisible:CGRectMake(375*2, 0, 375, 1) animated:YES];
}

- (IBAction)tab4Pressed:(UIButton *)sender {
    [_bottomScrollView scrollRectToVisible:CGRectMake(375*3, 0, 375, 1) animated:YES];
}

- (IBAction)tab5Pressed:(UIButton *)sender {
    [_bottomScrollView scrollRectToVisible:CGRectMake(375*4, 0, 375, 1) animated:YES];
}

#pragma mark - Swipe Gesture

- (IBAction)UserDidSwipe:(UISwipeGestureRecognizer *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Navigation

- (IBAction)backButtonPressed:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
}

@end
