//
//  TodayViewController.m
//  Fantasy Basketball
//
//  Created by Chappy Asel on 1/18/15.
//  Copyright (c) 2015 CD. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>
#import "FBSession.h"
#import "FBPlayer.h"
#import "TFHpple.h"

@interface TodayViewController () <NCWidgetProviding>

@end

@implementation TodayViewController

NSDictionary *sessionDict;
NSNumber *scoringPeriodID;
NSMutableArray *players1;
NSMutableArray *players2;
TFHpple *parser;
UILabel *lastUpdated;
int numSlots = 0;

- (void)viewDidLoad {
    [super viewDidLoad];
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.chappyasel.fantasybasketball.sharedsession"];
    sessionDict = [sharedDefaults objectForKey:@"sharedSession"];
    if (!sessionDict) sessionDict = @{@"leagueID": @186088, @"teamID": @1, @"seasonID": @2018};
    //OLD SCORINGPERIODID METHOD
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://games.espn.com/fba/clubhouse?leagueId=%@&teamId=%@&seasonId=%@",sessionDict[@"leagueID"],sessionDict[@"teamID"],sessionDict[@"seasonID"]]];
    NSError *errorHTML;
    NSData *html = [NSData dataWithContentsOfURL:url options:NSDataReadingMapped error:&errorHTML];
    if (errorHTML) NSLog(@"%@",errorHTML);
    TFHpple *parser = [TFHpple hppleWithHTMLData:html];
    NSString *XpathQueryString = @"//script";
    NSArray *nodes = [parser searchWithXPathQuery:XpathQueryString];
    for (TFHppleElement *node in nodes) {
        if ([node.content containsString:@"scoringPeriodId"]) {
            NSString *content = node.content;
            NSRange r = [content rangeOfString:@"scoringPeriodId: "];
            int beg = (int)r.length + (int)r.location;
            int end = (int)[content rangeOfString:@",\n\t\tcurrentScoringPeriodId:"].location;
            scoringPeriodID = [NSNumber numberWithInt:[[content substringWithRange:NSMakeRange(beg, end-beg)] intValue]];
            break;
        }
    }
    if (scoringPeriodID == 0) NSLog(@"scoringPeriodID is 0, likely unintended");
    [self loadplayersMU];
    [self loadTableView];
    [self setPreferredContentSize:CGSizeMake(0, 115)];
    //Score display
    NSString *XpathQueryString1 = @"//table/tr[@style='text-align:right; background:#f2f2e8']/td";
    //NSString *XpathQueryString1 = @"//tr[@style='text-align:right; background:#f2f2e8']/td";
    NSArray *nodes1 = [parser searchWithXPathQuery:XpathQueryString1];
    if (nodes1.count) {
        _team1Display1.text = [nodes1[0] content];
        _team2Display1.text = [nodes1[1] content];
    }
    NSString *XpathQueryString2 = @"//div[@style='font-size:18px; margin-bottom:14px; font-family:Helvetica,sans-serif;']/b";
    NSArray *nodes2 = [parser searchWithXPathQuery:XpathQueryString2];
    if (nodes2.count) {
        _team1Display2.text = [nodes2[0] content];
        _team2Display2.text = [nodes2[1] content];
    }
    //reload button
    UIButton *refresh = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 320, 80+_tableView.frame.size.height)];
    [refresh addTarget:self action:@selector(refreshButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:refresh];
    NSLog(@"DONE");
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setPreferredContentSize:CGSizeMake(320, 115)];
}

- (IBAction)refreshButtonPressed:(UIButton *)sender {
    NSLog(@"REFRESH");
    [self loadplayersMU];
    [_tableView reloadData];
    //Last updated
    NSDate *currentTime = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"h:mm a, EEE, MMM d"];
    lastUpdated.text = [NSString stringWithFormat:@"Last Updated: %@",[dateFormatter stringFromDate: currentTime]];
    NSLog(@"REFRESHED");
}

- (void)loadTableView {
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 80, 320, 40*numSlots+60) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorColor = [UIColor whiteColor];
    _tableView.separatorInset = UIEdgeInsetsMake(15, 0, 0, 15);
    _tableView.userInteractionEnabled = NO;
    [self.view addSubview:_tableView];
    [_tableView reloadData];
}

- (void)loadplayersMU {
    int numStarters1 = 0, numStarters2 = 0;
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http:games.espn.com/fba/boxscorefull?leagueId=%@&teamId=%@&scoringPeriodId=%@&seasonId=%@&view=scoringperiod&version=full",
                                       sessionDict[@"leagueID"],sessionDict[@"teamID"],scoringPeriodID,sessionDict[@"seasonID"]]];
    NSData *html = [NSData dataWithContentsOfURL:url];
    parser = [TFHpple hppleWithHTMLData:html];
    NSString *XpathQueryString = @"//table[@class='playerTableTable tableBody']/tr";
    NSArray *nodes = [parser searchWithXPathQuery:XpathQueryString];
    players1 = [[NSMutableArray alloc] initWithCapacity:13];
    players2 = [[NSMutableArray alloc] initWithCapacity:13];
    int switchPoint = 0;
    bool switchValid = YES;
    for (int i = 0; i < nodes.count; i++) {
        TFHppleElement *element = nodes[i];
        if ([element objectForKey:@"id"]) {
            if (switchValid) switchPoint ++;
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            NSArray <TFHppleElement *> *children = element.children;
            [dict setObject:children[0].content forKey:@"isStarting"];
            [dict setObject:[children[1].children[0] content] forKey:@"firstName+lastName"];
            [dict setObject:[children[1].children[1] content] forKey:@"team+position"];
            if (children[1].children.count > 2 && ![((TFHppleElement *)children[1].children[2]).tagName isEqualToString:@"a"])
                [dict setObject:[children[1].children[2] content] forKey:@"injury"];
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
            [players1 addObject:[[FBPlayer alloc] initWithDictionary:dict]];
        }
        else if (switchPoint != 0) switchValid = NO;
    }
    NSMutableArray *markForDel1 = [[NSMutableArray alloc] init];
    for (int i = 0; i < players1.count; i++) {
        if([players1[i] isPlaying] && [players1[i] isStarting]) numStarters1 ++;
        else [markForDel1 addObject:[NSNumber numberWithInt:i]];
    }
    for (int i = (int)markForDel1.count-1; i >= 0; i--) [players1 removeObjectAtIndex:[markForDel1[i] integerValue]];
    NSMutableArray *markForDel2 = [[NSMutableArray alloc] init];
    for (int i = 0; i < players2.count; i++) {
        if([players2[i] isPlaying] && [players2[i] isStarting]) numStarters2 ++;
        else [markForDel2 addObject:[NSNumber numberWithInt:i]];
    }
    for (int i = (int)markForDel2.count-1; i >= 0; i--) [players2 removeObjectAtIndex:[markForDel2[i] integerValue]];
    if (numStarters1 > numStarters2) numSlots = numStarters1;
    else numSlots = numStarters2;
}

#pragma mark - Table View

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return numSlots;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 50.0f;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *cell = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 60)];
    UILabel *background = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 290, 40)];
    background.backgroundColor = [UIColor colorWithWhite:1 alpha:0.2];
    background.layer.cornerRadius = 10.0;
    background.clipsToBounds = YES;
    [cell addSubview:background];
    if (numSlots == 0) { //no players playing
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
        label.text = @"No players playing today";
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:18];
        label.textColor = [UIColor lightTextColor];
        [cell addSubview:label];
    }
    else {
        //STATS LABELS
        float tot1 = 0;
        float tot2 = 0;
        if (section == 0) {
            for (int i = 0; i < players1.count; i++) {
                FBPlayer *player = players1[i];
                if (player.isPlaying) tot1 += player.fantasyPoints;
            }
            for (int i = 0; i < players2.count; i++) {
                FBPlayer *player = players2[i];
                if (player.isPlaying) tot2 += player.fantasyPoints;
            }
        }
        UILabel *stats = [[UILabel alloc] initWithFrame:CGRectMake(160-40, 0, 40, 40)];
        stats.text = [NSString stringWithFormat:@"%.0f",tot1];
        stats.textAlignment = NSTextAlignmentCenter;
        stats.font = [UIFont boldSystemFontOfSize:18];
        stats.textColor = [UIColor whiteColor];
        [cell addSubview:stats];
        UILabel *stats2 = [[UILabel alloc] initWithFrame:CGRectMake(160, 0, 40, 40)];
        stats2.text = [NSString stringWithFormat:@"%.0f",tot2];
        stats2.textAlignment = NSTextAlignmentCenter;
        stats2.font = [UIFont boldSystemFontOfSize:18];
        stats2.textColor = [UIColor whiteColor];
        [cell addSubview:stats2];
    }
    lastUpdated = [[UILabel alloc] initWithFrame:CGRectMake(10, 45, 290, 20)];
    NSDate *currentTime = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"h:mm a, EEE, MMM d"];
    lastUpdated.text = [NSString stringWithFormat:@"Last Updated: %@",[dateFormatter stringFromDate: currentTime]];
    lastUpdated.font = [UIFont systemFontOfSize:11];
    lastUpdated.textAlignment = NSTextAlignmentCenter;
    lastUpdated.textColor = [UIColor lightTextColor];
    [cell addSubview:lastUpdated];
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *MyIdentifier = @"MyIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyIdentifier];
//    if (players1.count-1 >= indexPath.row) {
//        FBPlayer *player = players1[indexPath.row];
//        if (player.isPlaying) {
//            //NAME
//            UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 120, 25)];
//            name.text = [NSString stringWithFormat:@"%@. %@",[player.firstName substringToIndex:1],player.lastName];
//            name.textColor = [UIColor whiteColor];
//            [cell addSubview:name];
//            //Subname
//            UILabel *subName = [[UILabel alloc] initWithFrame:CGRectMake(0, 18, 120, 20)];
//            subName.font = [subName.font fontWithSize:10];
//            subName.lineBreakMode = NSLineBreakByTruncatingHead;
//            subName.textColor = [UIColor lightTextColor];
//            if (player.gameState != FBGameStateHasntStarted) subName.text = [NSString stringWithFormat:@"%@, %@ %@: %.0f + %.0f",player.opponent,player.score,player.status, player.points-(player.fta-player.ftm)-(player.fga-player.fgm), player.rebounds+player.assists+player.blocks+player.steals-player.turnovers];
//            else subName.text = [NSString stringWithFormat:@"%@, %@",player.opponent,player.status];
//            [cell addSubview:subName];
//            //Points
//            UILabel *stats = [[UILabel alloc] initWithFrame:CGRectMake(160-40, 0, 40, 40)];
//            if (!player.isPlaying) stats.text = @"-";
//            else stats.text = [NSString stringWithFormat:@"%.0f",player.fantasyPoints];
//            stats.textAlignment = NSTextAlignmentCenter;
//            stats.font = [UIFont boldSystemFontOfSize:18];
//            stats.textColor = [UIColor whiteColor];
//            [cell addSubview:stats];
//        }
//    }
//    if (players2.count-1 >= indexPath.row) {
//        FBPlayer *player = players2[indexPath.row];
//        if (player.isPlaying) {
//            //NAME
//            UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(320-120, 0, 120, 25)];
//            name.text = [NSString stringWithFormat:@"%@. %@",[player.firstName substringToIndex:1],player.lastName];
//            name.textColor = [UIColor whiteColor];
//            name.textAlignment = NSTextAlignmentRight;
//            [cell addSubview:name];
//            //Subname
//            UILabel *subName = [[UILabel alloc] initWithFrame:CGRectMake(320-120, 18, 120, 20)];
//            subName.font = [subName.font fontWithSize:10];
//            subName.lineBreakMode = NSLineBreakByTruncatingTail;
//            subName.textColor = [UIColor lightTextColor];
//            subName.textAlignment = NSTextAlignmentRight;
//            if (player.gameState != FBGameStateHasntStarted) subName.text = [NSString stringWithFormat:@"%.0f + %.0f :%@ %@, %@", player.points-(player.fta-player.ftm)-(player.fga-player.fgm), player.rebounds+player.assists+player.blocks+player.steals-player.turnovers,player.status,player.score, player.opponent];
//            else subName.text = [NSString stringWithFormat:@"%@, %@",player.status,player.opponent];
//            [cell addSubview:subName];
//            //Points
//            UILabel *stats = [[UILabel alloc] initWithFrame:CGRectMake(160, 0, 40, 40)];
//            if (!player.isPlaying) stats.text = @"-";
//            else stats.text = [NSString stringWithFormat:@"%.0f",player.fantasyPoints];
//            stats.textAlignment = NSTextAlignmentCenter;
//            stats.font = [UIFont boldSystemFontOfSize:18];
//            stats.textColor = [UIColor whiteColor];
//            [cell addSubview:stats];
//        }
//    }
    return cell;
}

#pragma mark - other

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    [self refreshButtonPressed:nil];
    completionHandler(NCUpdateResultNewData);
}

@end

